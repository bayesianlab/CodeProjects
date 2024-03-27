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
sql7=    '''
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
        where p.ticker='QCOM';
        '''
#%%
spy = pd.read_sql(text(sql6), c.conn)

daily_stock_data = pd.read_sql(text(sql7), c.conn)
stock_data = daily_stock_data[['dt', 'ticker', 'adj_close']]
# %%
class ModelFramework:

    def __init__(self):
        self.calendar = mcal.get_calendar('NYSE')
        self.calendar = self.calendar.valid_days(start_date='1920-01-01',
                                 end_date='2050-01-01')
        self.calendar = pd.DataFrame({'dt_nyse':self.calendar})
        self.calendar['dt_nyse'] = self.calendar['dt_nyse'].dt.date
        self.calendar['dt_nyse'] = pd.to_datetime(self.calendar['dt_nyse'])

class StockSimulation(ModelFramework):

    def __init__(self, stock_data):
        self.stock_data = stock_data.copy()
        dprice = self.stock_data['adj_close'] - self.stock_data['adj_close'].shift(1)
        self.stock_data['dprice'] = dprice 
        self.price_stats = {}
        self.price_stats['mu'] = [self.stock_data['dprice'].mean()]
        self.price_stats['vol'] = [self.stock_data['dprice'].std()] 
        self.price_stats = pd.DataFrame.from_dict(self.price_stats)
    
    def simulate_price_states(self, sims, periods):
        start_price = self.stock_data['adj_close'].iloc[-1]
        simulation_container = np.zeros((periods + 1, sims))
        for j in range(sims):
            pricef =[] 
            p0 = start_price
            pricef.append(p0)
            for i in range(periods):
                p0 += self.price_stats['mu'] + self.price_stats['vol']*np.random.standard_normal()                
                pricef.append(p0[0])
            simulation_container[:, j] = pricef
        frame = pd.DataFrame.from_records(simulation_container)
        return frame
    
    def get_dates_out(self, date, periods_out):
        indx = self.calendar[self.calendar['dt_nyse']==date].index.to_list()[0] + 1
        dates = self.calendar.iloc[indx:(indx+periods_out)]
        dates.reset_index(inplace=True, drop=True)
        return dates

    def call_option_price(self, p0, strike, periods, mu, sigma, prices_at_exp, rate):
        tmu = p0 
        tsig = periods*sigma
        probs = norm.cdf(prices_at_exp, loc=tmu, scale=tsig)
        print(probs)
        profit = prices_at_exp - strike
        profit[profit<0] = 0    
        discount_factor = rate/365.0
        discount_factor = pow(1+discount_factor, -periods)
        ev = (discount_factor*np.matmul(probs, profit))/100.0
        return ev
    
    def put_option_price(self, p0, strike, periods, mu, sigma, prices_at_exp, rate):
        tmu = p0 
        tsig = periods*sigma
        probs = norm.cdf(prices_at_exp, loc=tmu, scale=tsig)
        print(probs)
        profit = strike - prices_at_exp
        profit[profit<0] = 0    
        discount_factor = rate/365.0
        discount_factor = pow(1+discount_factor, -periods)
        ev = (discount_factor*np.matmul(probs, profit))/100.0
        return ev



ss = StockSimulation(stock_data.tail(10))
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
