#%%
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt 
import seaborn as sns 
from sklearn.preprocessing import StandardScaler
from sqlalchemy import text
from datetime import datetime, timedelta
from sklearn.linear_model import LinearRegression
import pandas_market_calendars as mcal 
from scipy.stats import norm 
from analysis2 import StockSimulation
import warnings 
pd.options.mode.chained_assignment = None

#%%
daily_stock_data = pd.read_csv('AAPL.csv')
stock_data = daily_stock_data[['Date', 'Adj Close']]
stock_data.rename({'Adj Close':'adj_close', 'Date':'dt'}, axis=1, inplace=True)
ss = StockSimulation(stock_data.tail(250))
ss.price_stats
p0 = 173.31
frame = ss.simulate_price_states(p0, 10, 11)
#%%
d = ss.get_dates_out('2024-03-26', 12)

# %%

x = 175
call = ss.call_option_price(p0, x, 11, ss.price_stats['mu'], 
                     ss.price_stats['vol'], frame.iloc[-1], 0.05)

put = ss.put_option_price(p0, x, 11, ss.price_stats['mu'],
                          ss.price_stats['vol'], frame.iloc[-1], 0.05)
print("call {:.2}".format(call))
print("put {:.2}".format(put))
# %%

sims = pd.concat([d, frame],axis=1)
longform = pd.melt(sims, id_vars='dt_nyse')
longform['dt_nyse'] = pd.to_datetime(longform['dt_nyse'])

#%%
plt.figure() 
sd = stock_data.tail(250)
sns.lineplot(longform, x='dt_nyse', y='value', hue='variable')
# sns.lineplot(sd, x='dt', y='adj_close')

plt.xticks(rotation=45)
plt.show() 
# %%
