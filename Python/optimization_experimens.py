#%%
import pandas as pd 
import numpy as np
from scipy.stats import uniform 
from scipy.stats import norm
import matplotlib.pyplot as plt 
from itertools import chain 
from scipy import optimize
from scipy.stats import logistic
#%%
def pdf(bid, breakeven):
    p0 = breakeven - 2
    p1 = breakeven + 2
    y0 = 0
    y1 = 1
    m = (y1-y0)/(p1-p0)
    b = -m*(breakeven-2)
    px = bid*m + b
    return px 

def dpdf(bid, breakeven):
    p0 = breakeven - 2
    p1 = breakeven + 2
    y0 = 0
    y1 = 1
    m = (y1-y0)/(p1-p0)
    return m 

def rev_func(bid, breakeven):
    mu = 2
    T= .75
    return  -(pdf(bid, breakeven) * ( breakeven - bid ) - mu *(pdf(bid, breakeven) - T))

def drev_func(bid_mu, breakeven, T):
    bid = bid_mu[0]
    mu = 10
    return -(dpdf(bid, breakeven) * (breakeven - bid) - pdf(bid, breakeven) - mu *(pdf(bid, breakeven) - T))

def max_bid(breakeven):
    p0 = breakeven - 2
    p1 = breakeven + 2
    y0 = 0
    y1 = 1
    m = (y1-y0)/(p1-p0)
    b = -m*(breakeven-2)
    return (m*breakeven - b)/(2*m)

# pbids = 
# %%

# %%
N = 1000
BidTape = pd.DataFrame({'Breakeven':norm.rvs(loc=100, scale=2, size=(N, ))})
#%%


# %%
LoanTypes = ['Fha', 'Va', 'HighBal', 'Conf']

freq = [.1, .02, .6, .28]

# %%

def gen_loan_types(LoanTypes, freq, N):
    n_type = [N*i for i in freq]
    print(n_type)
    loan_list = []
    rindx = np.arange(N)
    np.random.shuffle(rindx)
    for i in range(len(LoanTypes)):
        t = int(n_type[i])*[LoanTypes[i]]
        loan_list.append(t)        
    loan_list = chain.from_iterable(loan_list)
    lt = pd.DataFrame({'LoanType':list(loan_list), 'Index':rindx})
    print(lt.shape)
    return lt


# %%
BidTape[['LoanType', 'LoanId']] = gen_loan_types(LoanTypes, freq, N)

#%%
BidTape = BidTape.sort_values(by='LoanId')

#%%
def gen_reserve_prices(BidTape):
    rp = []
    for i in BidTape['Breakeven']:
        rp.append(norm.rvs(loc=i-1, scale=1, size=(1,))[0])
    return rp


BidTape['ReservePrice'] = gen_reserve_prices(BidTape)
# %%
BidTape
# %%
BidTape['BestBid'] = BidTape['Breakeven'].apply(max_bid)
BidTape['Profit'] = BidTape['Breakeven']- BidTape['BestBid']
BidTape['ProbBestBid'] = pdf(BidTape['BestBid'],BidTape['Breakeven'])
# %%
# %%
dummies = pd.get_dummies(BidTape['LoanType'])
BidTape = pd.concat([BidTape, dummies], axis=1)
# %%
print((BidTape['ProbBestBid']*(BidTape['Breakeven']- BidTape['BestBid'])).sum())
print((BidTape['ProbBestBid']*BidTape['Conf']).sum())
print((BidTape['ProbBestBid']*BidTape['Fha']).sum())
print((BidTape['ProbBestBid']*BidTape['HighBal']).sum())
print((BidTape['ProbBestBid']*BidTape['Va']).sum())
# %%




def optimize_bids(BidTape, drev_func, pdf, Targets):
    headers = ['Breakeven', 'LoanType']
    for i in headers:
        if i not in BidTape.columns:
            print('Error in BidTape')
            return 
    dummies = pd.get_dummies(BidTape['LoanType'])
    X = pd.concat([BidTape[headers], dummies], axis=1)
    bb = [] 
    pb = [] 
    be = X['Breakeven'].squeeze()
    T = Targets
    print(T)
    print(be)
    x = optimize.minimize(rev_func, x0=(100,), method='BFGS', args=(be,))
    print(x)

    
#%%    
Targets = pd.DataFrame({'LoanTarget':['Fha'],'Constraint':[20], 'Type':['leq'], 'Penalty':[10]})


#%%
bt = pd.DataFrame(BidTape.iloc[0].to_dict(), index=[0])
optimize_bids(bt, rev_func, pdf, 1)

# %%
x = np.linspace(91, 102,1000)
y = rev_func(x, BidTape['Breakeven'][0])
plt.plot(x,y)

# %%

def 