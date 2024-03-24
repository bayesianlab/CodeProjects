#%% 
from datetime import datetime
import pandas as pd 
import numpy as np
import matplotlib.pyplot as plt 
import seaborn as sns 
from statsmodels.graphics.tsaplots import plot_acf, plot_pacf
import statsmodels.api as sm 
from  sklearn.linear_model import LinearRegression
from sklearn.model_selection import TimeSeriesSplit
import warnings 
import keras 
import tensorflow as tf 

warnings.simplefilter(action='ignore', category=FutureWarning)
warnings.simplefilter(action='ignore', category=UserWarning)
def ols(X,y):
    XX = np.matmul(Xtrain.T,Xtrain)
    Xy = np.matmul(Xtrain.T, ytrain)
    XXinv = np.linalg.inv(XX)
    bhat = np.matmul(XXinv, Xy)
    return bhat 

def split_data(data, date):
    data.reset_index(drop=True, inplace=True)
    test_indices = data[data['BidBusDt']>date].index 
    training_indices = data[data['BidBusDt']<=date].index 
    xcols = []
    for i, c in enumerate(data.columns):
        if c!='LookCnt' and c!='BidBusDt':
            xcols.append(i)
    X = data.iloc[:, xcols]
    if 'BidMonth' in X.columns:
        X.loc[:,'BidMonth'] = X['BidMonth'].astype(object)
    if 'DayNum' in X.columns:
        X.loc[:,'DayNum'] = X['DayNum'].astype(object)
    if 'WeekNum' in X.columns:
        X.loc[:,'WeekNum'] = X['WeekNum'].astype(object)
    X = pd.get_dummies(X, drop_first=True)
    X['const'] = 1
    y = data['LookCnt']
    Xtest = X.iloc[test_indices,:]
    ytest = y[test_indices]
    Xtrain = X.iloc[training_indices, :]
    ytrain = y[training_indices] 
    return Xtrain, ytrain, Xtest, ytest
#%% 
# Data import 
alldata = pd.read_csv('data.csv')
alldata['BidBusDt'] = pd.to_datetime(alldata['BidBusDt'])
interest_rates = pd.read_csv('interest_rates.csv')
interest_rates['BidBusDt'] = pd.to_datetime(interest_rates['BidBusDt'])
alldata = alldata.merge(interest_rates, on='BidBusDt')
data = alldata 

cutoff_date = pd.to_datetime('2024-01-01')
insample_time = alldata[alldata['BidBusDt']<=cutoff_date]['BidBusDt']
outsample_time = alldata[alldata['BidBusDt']>cutoff_date]['BidBusDt']
#%%
#Correlations
C = alldata.loc[:,['DayNum', 'LookCnt', 'SecMtgRate_Fixed30', 'PrimaryMtgRate_Fixed30', 
               'PsSpread', 'SecMtgRate_Fixed15', 'PrimaryMtgRate_Fixed15', 'SecMtgRate_Arm07',
                 'PrimaryMtgRate_Arm07']]
sns.heatmap(C.corr())

#%% 
# Baseline 
data= alldata 
data = data[['BidBusDt', 'BidMonth', 'DayNum', 'WeekNum', 'LookCnt']]
Xtrain,ytrain, Xtest,ytest = split_data(data, cutoff_date)
baseline = pd.read_csv('forecasted_values.csv')
baseline.loc[:,'BidBusDt'] = pd.to_datetime(baseline['BidBusDt'])
bl = baseline[baseline['BidBusDt']>cutoff_date]
bl.rename(columns={'BidBusDt':'Periods Out'}, inplace=True)
bl['MAE'] = np.abs((bl['LookCnt'].to_numpy() - ytest.to_numpy())).sum()/bl.shape[0]
bl['Model'] = 'Current Look Predictor'

#%%
# Model 1
data= alldata 
data = data[['BidBusDt', 'BidMonth', 'DayNum', 'WeekNum', 'LookCnt']]
Xtrain,ytrain, Xtest,ytest = split_data(data, cutoff_date)
print(Xtrain)
lr = LinearRegression(fit_intercept=False)
lr.fit(Xtrain,ytrain)
actuals = {'LookCnt':ytest}
actuals = pd.DataFrame(actuals)
actuals['Model'] = 'Actuals'
actuals['MAE'] = 0 

actuals['Periods Out'] = outsample_time 
yhat = lr.predict(Xtest)
MAE = (ytest- yhat).abs().sum()/(len(ytest))
results_M1 = {} 
results_M1['MAE'] = MAE 
results_M1['LookCnt'] = yhat
results_M1['Periods Out'] = outsample_time 
results_M1['Model'] = 'M-DWM'
results_M1 = pd.DataFrame(results_M1)
all_results = pd.concat([actuals, bl, results_M1], axis=0)
sns.lineplot(data=all_results, x='Periods Out', y='LookCnt', hue='Model')
plt.xticks(rotation=45)

#%%
# AR Model
residuals = ytrain - lr.predict(Xtrain)
residuals_mat = pd.concat([insample_time, residuals, residuals.shift(1), residuals.shift(2)], axis=1)
residuals_mat
residuals_mat = residuals_mat.iloc[2:,:]
residuals_mat.columns = ['BidBusDt', ytrain, 'LookCnt_Lag1', 'LookCnt_Lag2']
y = residuals_mat.loc[:, 'LookCnt']
X = residuals_mat.loc[:, ['LookCnt_Lag1', 'LookCnt_Lag2']]
ma_reg = LinearRegression()
ma_reg.fit(X,y)
ytest = ytest.to_numpy() 
yt1 = [] 
et = residuals_mat.iloc[-1, [2,3]].to_numpy()
print(et)
for i in range(len(ytest)):
    Xbeta = lr.predict(np.atleast_2d(Xtest.to_numpy()[i,:])) + np.matmul(ma_reg.coef_,et)
    yt1.append(Xbeta)
    etnew = ytest[i] - Xbeta 
    et[0:(len(et)-1)] = et[1:]
    et[-1] = etnew

yhat= np.asarray(yt1).flatten()
MAE = np.abs((ytest - yhat)).sum()/(len(ytest))
results_M1_MA = {} 
results_M1_MA['MAE'] = MAE 
results_M1_MA['LookCnt'] = yhat
results_M1_MA['Periods Out'] = outsample_time 
results_M1_MA['Model'] = 'M-DWM-MA'
results_M1_MA = pd.DataFrame(results_M1_MA)
all_results = pd.concat([actuals, bl, results_M1, results_M1_MA], axis=0)
sns.lineplot(data=all_results, x='Periods Out', y='LookCnt', hue='Model')
plt.xticks(rotation=45)

# %%
data= alldata
data = data[['BidBusDt', 'BidMonth', 'DayNum', 'LookCnt']]
Xtrain,ytrain, Xtest,ytest = split_data(data, cutoff_date)
lr = LinearRegression()
lr.fit(Xtrain, ytrain)
yhat = lr.predict(Xtest)
MAE = (ytest- yhat).abs().sum()/(len(ytest))
results_no_weeknum = {} 
results_no_weeknum['MAE'] = MAE 
results_no_weeknum['LookCnt'] =yhat 
results_no_weeknum['Periods Out'] = outsample_time 
results_no_weeknum['Model'] = 'M-DM'
results_no_weeknum = pd.DataFrame(results_no_weeknum)
all_results = pd.concat([actuals, bl, results_no_weeknum, results_M1], axis=0)
sns.lineplot(data=all_results, x='Periods Out', y='LookCnt', hue='Model')
plt.xticks(rotation=45)
#%% 

data= alldata
data = pd.concat([data['BidBusDt'],
                  data['BidMonth'],
                  data['DayNum'],
                  data['WeekNum'], 
                  data['LookCnt'],
                  data['LookCnt'].shift(1)], 
                 axis=1)
data.columns =  ['BidBusDt',
                 'BidMonth',
                 'DayNum',
                 'WeekNum',
                 'LookCnt',
                 'LookCnt_Lag1']
data = data.iloc[10:,:]
Xtrain,ytrain, Xtest,ytest = split_data(data, cutoff_date)
lr = LinearRegression()
lr.fit(Xtrain, ytrain)
yhat = lr.predict(Xtest)
MAE = (ytest- yhat).abs().sum()/(len(ytest))
results_AR1 = {} 
results_AR1['MAE'] = MAE 
results_AR1['LookCnt'] =yhat 
results_AR1['Periods Out'] = outsample_time 
results_AR1['Model'] = 'M1-DWM-AR(1)'
results_AR1 = pd.DataFrame(results_AR1)
all_results = pd.concat([actuals, bl, results_AR1, results_M1], axis=0)
sns.lineplot(data=all_results, x='Periods Out', y='LookCnt', hue='Model')
plt.xticks(rotation=45)
# %%

data= alldata
data = pd.concat([data['BidBusDt'],
                  data['BidMonth'],
                  data['DayNum'], 
                  data['LookCnt'],
                  data['SecMtgRate_Fixed30'].shift(1)], 
                 axis=1)
data.columns = ['BidBusDt', 'BidMonth', 'DayNum', 'LookCnt', 'SecMtgRate_Fixed30_Lag1']
data = data.iloc[1:,:]
Xtrain,ytrain, Xtest,ytest = split_data(data, cutoff_date)
lr = LinearRegression(fit_intercept=False)
lr.fit(Xtrain,ytrain)
yhat = lr.predict(Xtest)
MAE = (ytest- yhat).abs().sum()/(len(ytest))
results_SecMtg = {} 
results_SecMtg['MAE'] = MAE 
results_SecMtg['LookCnt'] =yhat 
results_SecMtg['Periods Out'] = outsample_time 
results_SecMtg['Model'] = 'M1 + SecMtgRts'
results_SecMtg = pd.DataFrame(results_SecMtg)
all_results = pd.concat([actuals, bl, results_SecMtg, results_M1, results_AR1], axis=0)
sns.lineplot(data=all_results, x='Periods Out', y='LookCnt', hue='Model')
plt.xticks(rotation=45)
# %%
data=alldata 
data = pd.concat([data['BidBusDt'],
                  data['BidMonth'],
                  data['DayNum'],
                  data['WeekNum'], 
                  data['LookCnt'],
                  data['PsSpread']], 
                 axis=1)
data.columns = ['BidBusDt', 'BidMonth', 'DayNum', 'WeekNum', 'LookCnt', 
                'PrimarySecondarySpread']
data = data.iloc[1:,:]
Xtrain,ytrain, Xtest,ytest = split_data(data, cutoff_date)
lr = LinearRegression(fit_intercept=False)
lr.fit(Xtrain,ytrain)
yhat = lr.predict(Xtest)
MAE = (ytest- yhat).abs().sum()/(len(ytest))
results_PS_Spread = {} 
results_PS_Spread['MAE'] = MAE 
results_PS_Spread['LookCnt'] =yhat 
results_PS_Spread['Periods Out'] = outsample_time 
results_PS_Spread['Model'] = 'M1-DWM-PS'
results_PS_Spread = pd.DataFrame(results_PS_Spread)
all_results = pd.concat([actuals, bl, results_PS_Spread, results_M1, results_AR1], axis=0)
sns.lineplot(data=all_results, x='Periods Out', y='LookCnt', hue='Model')
plt.xticks(rotation=45)

#%%
data=alldata 
data = pd.concat([data['BidBusDt'],
                  data['BidMonth'],
                  data['DayNum'],
                  data['WeekNum'], 
                  data['LookCnt'],
                  data['PsSpread'],
                  data['PsSpread'].shift(1)], 
                 axis=1)
data.columns = ['BidBusDt', 'BidMonth', 'DayNum', 'WeekNum', 'LookCnt', 
                'PrimarySecondarySpread','PrimarySecondarySpread_Lag1']
data = data.iloc[1:,:]
Xtrain,ytrain, Xtest,ytest = split_data(data, cutoff_date)
lr = LinearRegression(fit_intercept=False)
lr.fit(Xtrain,ytrain)
yhat = lr.predict(Xtest)
MAE = (ytest- yhat).abs().sum()/(len(ytest))
results_PS_Spread_Lag1 = {} 
results_PS_Spread_Lag1['MAE'] = MAE 
results_PS_Spread_Lag1['LookCnt'] =yhat 
results_PS_Spread_Lag1['Periods Out'] = outsample_time 
results_PS_Spread_Lag1['Model'] = 'M1-DWM-PS-PS_Lag1'
results_PS_Spread_Lag1 = pd.DataFrame(results_PS_Spread_Lag1)
all_results = pd.concat([actuals, bl, results_M1_MA, results_PS_Spread, results_PS_Spread_Lag1, results_M1, results_AR1], axis=0)
sns.lineplot(data=all_results, x='Periods Out', y='LookCnt', hue='Model')
plt.xticks(rotation=45)

# %%
# Prophet 
data= alldata
Npast= alldata[alldata['BidBusDt'] < cutoff_date].shape[0]
Nfuture = alldata[alldata['BidBusDt'] >= cutoff_date].shape[0]
Y = data[data['BidBusDt']<cutoff_date][['BidBusDt', 'LookCnt']]
Y.columns = ['ds', 'y']
m = Prophet()
m.fit(Y)
future = m.make_future_dataframe(periods=Nfuture+12)
yhat = m.predict(future)
oos = alldata[alldata['BidBusDt'] >= cutoff_date]
prophet_data = oos.merge(yhat, left_on='BidBusDt', right_on='ds')
yhat = prophet_data['yhat']
MAE = np.abs((ytest.to_numpy() - yhat.to_numpy())).sum()/(len(ytest))
results_prophet = {} 
results_prophet['MAE'] = MAE 
results_prophet['LookCnt'] =yhat.to_numpy() 
results_prophet['Periods Out'] = outsample_time 
results_prophet['Model'] = 'Prophet'
results_prophet = pd.DataFrame(results_prophet)
all_results = pd.concat([actuals, bl, results_prophet, results_M1, results_AR1], axis=0)
sns.lineplot(data=all_results, x='Periods Out', y='LookCnt', hue='Model')
plt.xticks(rotation=45)
# %%
all_results.groupby(by='Model').max(MAE).sort_values(by='MAE')
# %%


