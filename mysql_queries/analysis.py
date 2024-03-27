#%%
import pandas as pd
import numpy as np
from get_data import Connection
import matplotlib.pyplot as plt 
import seaborn as sns 
from sklearn.preprocessing import StandardScaler
from sqlalchemy import text
import pandas_market_calendars as pmc 
from datetime import datetime, timedelta
from sklearn.linear_model import LinearRegression
import pandas_market_calendars as mcal 
from scipy.stats import norm 
class InterpolateData:

    def __init__(self):
        pass 

    def interpolate_range(self, dates, data):
        dtf = self.make_date_tuples(dates,data)
        return self.interpolate_over_days(dtf)
    
    def make_date_tuples(self, dates, data):
        datescopy = dates.to_numpy()
        datacopy = data.to_numpy() 
        if len(dates)  != len(data):
            raise Exception('Error in input')
        date0 = datescopy[0]
        data0 = datacopy[0] 
        date_domain = [] 
        data_range = [] 
        for i in range(1,len(datescopy)):
            end_date = datescopy[i]
            end_data = datacopy[i]
            be_date = (date0, end_date)
            be_data = (data0, end_data)
            date_domain.append(be_date)
            data_range.append(be_data)
            data0 = end_data 
            date0=end_date
        return pd.DataFrame({'dts':date_domain, 'data':data_range})

    def interpolate_over_days(self, data_tuple_frame):
        interpolation = [] 
        index = [] 
        for row in range(data_tuple_frame.shape[0]):
            beg_date = data_tuple_frame.iloc[row]['dts'][0]
            end_date = data_tuple_frame.iloc[row]['dts'][1]
            y1 = data_tuple_frame.iloc[row]['data'][0]
            y2 = data_tuple_frame.iloc[row]['data'][1]
            xdelta = end_date-beg_date
            ydelta = y2-y1
            xdelta = xdelta.astype('timedelta64[D]').astype(int).astype(float)
            M = ydelta/xdelta
            b = y1
            interpolation.append(b)
            index.append(beg_date)
            c = 1 
            while c < xdelta:
                interpolation.append(M*c + b)
                beg_date += np.timedelta64(1, 'D')
                index.append(beg_date)
                c += 1    
        return pd.DataFrame({'interp_dates':index, 'interp_data':interpolation})  
#%%
db_host = 'localhost'
db_user = 'dillon'
db_pass = 'Zelzah12'
db_name = 'Securities'
c = Connection(db_host, db_user, db_pass, db_name)
#%%
sql1 = '''
        SELECT p.*, s.Sector
        FROM Securities.stock_prices p
        join snp500 as s 
        on p.ticker=s.Symbol
        where p.ticker='AAPL';
        '''
sql2 = '''
        SELECT *
        FROM Securities.tentwo_sprd tt;
        '''
sql3 = '''
        SELECT *
        FROM Securities.truck_ton;
        '''
sql4 = '''SELECT *
          From Securities.fed_funds;
          '''
sql5 = '''
        SELECT *
        FROM Securities.nber_recessions;
        '''
sql6 = "SELECT * FROM Securities.spy;"
    
stock_data = pd.read_sql(text(sql1), c.conn)
ttspread = pd.read_sql(text(sql2), c.conn)
tons = pd.read_sql(text(sql3), c.conn)
ff = pd.read_sql(text(sql4), c.conn)
recessions = pd.read_sql(text(sql5), c.conn)
spy = pd.read_sql(text(sql6), c.conn)
#%%
ttspread['dt'] = pd.to_datetime(ttspread['dt'])
ttspread[~ttspread['sprd'].isna()]
tons['dt'] = pd.to_datetime(tons['dt'])
ff['dt'] = pd.to_datetime(ff['dt'])
min_date = stock_data['dt'].min()
ttspread_in = ttspread[ttspread['dt'] >= min_date] 
tons = tons[tons['dt'] >= min_date]
ff = ff[ff['dt'] >= min_date]

#%%
ss = StandardScaler()
ttspread_in = ttspread_in[~ttspread_in.isna()]
zrate = ss.fit_transform(np.reshape(ttspread_in['sprd'].to_numpy(), (-1,1)))
zstock = ss.fit_transform(np.reshape(stock_data['adj_close'].to_numpy(), (-1,1)))
ztons = ss.fit_transform(np.reshape(tons['tons'].to_numpy(), (-1,1)))
zff = ss.fit_transform(np.reshape(ff['rate'].to_numpy(), (-1,1)))
ttspread_in['zsprd'] = zrate
stock_data['zprc'] = zstock
tons['ztons'] = ztons 
ttspread_in['neg'] = -zrate
ff['zff'] = zff 
# %%
plt.plot(stock_data['dt'], stock_data['zprc'], label='A')
plt.plot(ttspread_in['dt'], ttspread_in['zsprd'], label='Zsprd')
plt.plot(tons['dt'], tons['ztons'], label='tons')
plt.plot(ff['dt'], ff['zff'], label='Fed Funds')
plt.legend()
plt.xticks(rotation=45)
# %%
sql4=    '''
        select p.*, daynum, monthnum, yearnum
        from 
            (
                select max(dt) dt, 
                    max(Sector) Sector,
                    daynum,
                    monthnum,
                    yearnum
                from 
                    (select *,
                        row_number() over(partition by X.daynum, X.monthnum, X.yearnum) as dt_rank
                    from 
                        (SELECT p.*, 
                            s.Sector, 
                            s.Security, 
                            day(p.dt) daynum, 
                            month(p.dt) monthnum,
                            year(p.dt) yearnum
                        FROM Securities.stock_prices p
                        join snp500 as s 
                        on p.ticker=s.Symbol
                        where p.ticker='A') as X) as Y 
                group by Y.daynum, Y.monthnum, Y.yearnum
            ) as Z 
        join Securities.stock_prices p 
        on Z.dt=p.dt
        where p.ticker='A';
        '''
daily_stock_data = pd.read_sql(text(sql4), c.conn)
daily_stock_data['extradt'] = daily_stock_data['dt'].dt.strftime('%Y-%m-%d')
daily_stock_data['extradt'] = pd.to_datetime(daily_stock_data['extradt'])

#%%
tons['monthnum'] = tons['dt'].dt.month
tons['yearnum'] = tons['dt'].dt.year
daily_stock_data.merge(tons[['monthnum', 'yearnum', 'tons', 'ztons']], on=['monthnum', 'yearnum'])
daily_stock_data['dt'] = pd.to_datetime(daily_stock_data['dt'].dt.date)
# %%

interp = InterpolateData()
tuple_data = interp.make_date_tuples(tons['dt'], tons['tons'])
data = interp.interpolate_over_days(tuple_data)


# %%
ttspread['daynum'] = ttspread['dt'].dt.day
ttspread['monthnum'] = ttspread['dt'].dt.month
ttspread['yearnum'] = ttspread['dt'].dt.year
merged_data = daily_stock_data.merge(ttspread[['daynum', 'monthnum', 'yearnum', 'sprd']], on=['daynum', 'monthnum', 'yearnum'])
merged_data = merged_data[['dt', 'adj_close', 'sprd']]
merged_data = merged_data[~merged_data['sprd'].isna()]

# %%
class ModelFramework:

    def __init__(self):
        self.calendar = mcal.get_calendar('NYSE')
        self.calendar = self.calendar.valid_days(start_date='1920-01-01',
                                 end_date='2050-01-01')
        self.calendar = pd.DataFrame({'dt_nyse':self.calendar})
        self.calendar['dt_nyse'] = self.calendar['dt_nyse'].dt.date
        self.calendar['dt_nyse'] = pd.to_datetime(self.calendar['dt_nyse'])
#%%

def create_lags(data_series,name, lags, fit_intercept=True):
    if lags < 1:
        raise Exception('lags must be greater than 1')
    else:
        L = [] 
        names = []
        for i in range(1,lags+1):
            names.append(''.join([name,'_lag_',str(i)]))
            L.append(data_series.shift(i))
        if len(L) < 2:
            lag_frames= pd.DataFrame.from_dict(dict(zip(names,L)))
        else:
            lag_frames = pd.concat(L, axis=1)
            lag_frames.columns = names 
        data = pd.concat([data_series, lag_frames],axis=1)
        data = data.iloc[lags:]
        data['const'] = 1
        return data 
sprd_lags = create_lags(merged_data['sprd'], 'sprd', 1)
stock_lags = create_lags(merged_data['adj_close'], 'stock', 1)
#%%    
class SpreadModel(ModelFramework):

    def __init__(self, spread_data) -> None:
        super().__init__()
        self.ttspread= spread_data
        self.ttspread['dt'] = pd.to_datetime(self.ttspread['dt'])
        self.ttspread['dt'] = pd.to_datetime(self.ttspread['dt'].dt.date)
        self.ttspread = self.ttspread[~self.ttspread['sprd'].isna()]
        self.model = None 
        self.insample_dates = self.ttspread['dt']
        
    def model_spread(self, lags=1):
        model_data = self.ttspread.copy()
        feature_cols = [] 
        lagmat = create_lags(self.ttspread['sprd'], 'sprd', lags)   
        X = lagmat.iloc[:,1:] 
        y = lagmat.iloc[:,0]     
        self.model = LinearRegression(fit_intercept=False)
        self.model.fit(X, y)
        self.insample_dates = self.ttspread['dt']
        self.insample_dates = self.insample_dates.iloc[lags:]
        
    
    def forecast(self, periods, sigma=1, start_date=None):
        if start_date is None:
            start_date = self.insample_dates.iloc[-1]
        yf = []
        start_index = int(self.calendar[self.calendar['dt_nyse']==start_date].index.to_list()[0])
        osindx = [] 
        sprd_lags = self.ttspread.tail(len(self.model.coef_) - 1)['sprd']
        x = sprd_lags.to_numpy()
        x = np.concatenate((x,[1]))
        p = 0
        while p < periods:
            Xb = np.matmul(x.T, self.model.coef_.T)
            yf.append(Xb)
            x[0:(len(x)-2)] = x[1:(len(x)-1)]
            x[len(x)-2] = Xb            
            p+=1
            start_index+=1
            osindx.append(start_index)
        osdates = self.calendar[self.calendar.index.isin(osindx)]
        osdates.reset_index(inplace=True, drop=True)
        osdata = pd.concat([osdates, pd.Series(yf)], axis=1) 
        osdata.columns = ['dt', 'sprd']
        return osdata 
        
sm = SpreadModel(ttspread)
nyse = mcal.get_calendar('NYSE')
sm.model_spread(lags=1)
sprdf = sm.forecast(100, .0001)
print(sprdf)

#%%

def train_stock_model(X, y):
    model = LinearRegression(fit_intercept=False)
    model.fit(X,y)
    return model 

class StockModel(ModelFramework):

    def __init__(self) -> None:
        super().__init__()
    
    def predict_stock(self, model, Xf, stock_prices, lags):
        tmp = stock_prices.tail(lags)
        tmp.reset_index(inplace=True, drop=True)
        i = 0
        tmpx = np.reshape(Xf.to_numpy(), (-1,1))
        tmpy = np.reshape(tmp.to_numpy(), (1,-1))
        yf = [] 
        while i < Xf.shape[0]:
            tx = np.atleast_2d(tmpx[i,:])
            ty = tmpy
            x = np.concatenate((tx, ty, [[1]]), axis=1)
            yhat = model.predict(x).tolist()[0]
            ty[0:(len(ty)-2)] = ty[1:(len(ty)-1)]
            ty[len(ty)-2] = yhat
            yf.append(yhat)
            i+=1
        return pd.Series(yf)

    def get_dates_out(self, date, periods_out):
        indx = self.calendar[self.calendar['dt_nyse']==date].index.to_list()[0] + 1
        dates = self.calendar.iloc[indx:(indx+periods_out)]
        dates.reset_index(inplace=True, drop=True)
        return dates 
    
    def simulate(self, model, Xf, stock_prices, lags, simulations, sigma):
        tmp = stock_prices.tail(lags)
        tmp.reset_index(inplace=True, drop=True)
        tmpx = np.reshape(Xf.to_numpy(), (-1,1))
        sims = []  
        for j in range(simulations):
            yf = []
            tmpy = np.reshape(tmp.to_numpy(), (1,-1))
            i = 0
            while i < Xf.shape[0]:
                tx = np.atleast_2d(tmpx[i,:])
                ty = tmpy
                x = np.concatenate((tx, ty, [[1]]), axis=1)
                yhat = model.predict(x) + sigma*np.random.normal(0,1,(1,1))
                yhat = np.squeeze(yhat)
                ty[0:(len(ty)-2)] = ty[1:(len(ty)-1)]
                ty[len(ty)-2] = yhat
                yf.append(yhat)
                i+=1
            sims.append(yf)
        return pd.DataFrame(sims).T

         
sm = StockModel()

Xstock = pd.concat([sprd_lags['sprd_lag_1'],stock_lags.iloc[:,1:]], axis=1)
ystock = stock_lags.iloc[:,0]



model = train_stock_model(Xstock.to_numpy(), ystock)
yf = sm.predict_stock(model, sprdf['sprd'], ystock, 1)
out_dates = sm.get_dates_out(stock_data.iloc[-1]['dt'], len(yf))
out_frame = pd.concat([out_dates, yf], axis=1)
out_frame.columns = ['dt', 'adj_close']
sigma = spy['adj_close'].tail(100).std()
frame = sm.simulate(model, sprdf['sprd'], ystock, 1, 4, sigma)
frame = pd.concat([out_dates, frame], axis=1)
# %%
plot_data = daily_stock_data[daily_stock_data['dt'] > '2024-01-01']
sns.lineplot(data=plot_data, x='dt', y='adj_close')
plt.xticks(rotation=45)
longform = pd.melt(frame, id_vars='dt_nyse')
longform['value'] = longform['value'].astype(np.float32)
sns.lineplot(longform, x='dt_nyse', y='value', hue='variable')
#%%
#%%

price = daily_stock_data[['dt', 'adj_close']]

price.loc[:, 'dprice'] = (price['adj_close'] - price['adj_close'].shift(1))
price.mean()
sigmas = price.std()
N = 21
n_sims = 10000
sims = np.zeros((N + 1, n_sims))
for j in range(n_sims):
    pricef =[] 
    p = price['adj_close'].iloc[-1]
    pricef.append(p)
    for i in range(N):
        p += 0.06 + sigmas['dprice']*np.random.standard_normal()
        pricef.append(p)
    sims[:, j] = pricef
frame = pd.DataFrame.from_records(sims)
out_dates = sm.get_dates_out(stock_data.iloc[-1]['dt'], N+1)
frame['dt'] = out_dates

longform = pd.melt(frame, id_vars='dt')
frame = frame.set_index('dt')
frame.iloc[-1]
# %%
# plot_data = daily_stock_data[daily_stock_data['dt'] > '2024-01-01']
# sns.lineplot(data=plot_data, x='dt', y='adj_close')
# sns.lineplot(longform, x='dt', y='value', hue='variable')
# %%

def call_option_price(p0, strike, periods, mu, sigma, price_states, irate):
    tmu = p0 + periods*mu
    tsig = periods*sigma
    probs = norm.cdf(price_states, loc=tmu, scale=tsig)
    profit = price_states - strike
    profit[profit<0] = 0    
    discount_factor = irate/365.0
    discount_factor = pow(1+discount_factor, -periods)
    ev = (discount_factor*np.matmul(probs, profit))/100.0
    return ev
    

call_option_price(145.56, 160, 21, .06, sigmas['dprice'], frame.iloc[-1], .05)


# %%
