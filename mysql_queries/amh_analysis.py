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
frame = ss.simulate_price_states(1000, 12)

# %%
p0 = 167.07
x = 182.50
call = ss.call_option_price(p0, x, 12, ss.price_stats['mu'], 
                     ss.price_stats['vol'], frame.iloc[-1], 0.05)

put = ss.put_option_price(p0, x, 12, ss.price_stats['mu'],
                          ss.price_stats['vol'], frame.iloc[-1], 0.05)
print(call)
print(put)
# %%
