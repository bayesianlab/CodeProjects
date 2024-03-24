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
    
stock_data = pd.read_sql(text(sql1), c.conn)
ttspread = pd.read_sql(text(sql2), c.conn)
tons = pd.read_sql(text(sql3), c.conn)
ff = pd.read_sql(text(sql4), c.conn)
recessions = pd.read_sql(text(sql5), c.conn)
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
merged_data['sprd'] = merged_data['sprd'].shift(1)
merged_data['stock_lag1'] = merged_data['adj_close'].shift(1)
merged_data = merged_data.iloc[1:]
merged_data = merged_data[~merged_data['sprd'].isna()]
y = merged_data['adj_close']
x = merged_data[['sprd', 'stock_lag1']]
x['const'] = 1
lr = LinearRegression(fit_intercept=False)
lr.fit(x, y)

# %%
plt.plot(merged_data['dt'], lr.predict(x))
plt.plot(merged_data['dt'], y)
# %%

class ModelFramework:

    def __init__(self):
        self.calendar = mcal.get_calendar('NYSE')
        self.calendar = self.calendar.valid_days(start_date='1920-01-01',
                                 end_date='2050-01-01')
        self.calendar = pd.DataFrame({'dt_nyse':self.calendar})
        self.calendar['dt_nyse'] = self.calendar['dt_nyse'].dt.date
        self.calendar['dt_nyse'] = pd.to_datetime(self.calendar['dt_nyse'])

class SpreadModel(ModelFramework):

    def __init__(self, spread_data) -> None:
        super().__init__()
        self.ttspread= spread_data
        self.ttspread['dt'] = pd.to_datetime(self.ttspread['dt'])
        self.ttspread['dt'] = pd.to_datetime(self.ttspread['dt'].dt.date)
        self.y_column_name = 'sprd'
        self.ttspread = self.ttspread[~self.ttspread[self.y_column_name].isna()]
        self.model = None 
        
    def model_spread(self, ar_order=1):
        model_data = self.ttspread.copy()
        feature_cols = [] 
        model_data['const'] =1
        data = pd.concat([model_data['const'], 
                          self.ttspread['sprd'], 
                          self.ttspread['sprd'].shift(1)], axis=1)
        data.columns = ['const', 'sprd', 'sprd_lag1']
        data = data.iloc[1:]
        X = data[['const', 'sprd_lag1']]
        self.model = LinearRegression(fit_intercept=False)
        self.model.fit(X, np.reshape(data['sprd'].to_numpy(), (-1,1)))
    
    def forecast(self, periods, sigma=1, start_date=None):
        if start_date is None:
            start_date = self.ttspread['dt'].iloc[-1]
        x = self.ttspread[self.ttspread['dt']<=start_date]        
        X = np.reshape(np.array([1, x['sprd'].iloc[-1]]), (1,-1))
        yf = []
        p = 0
        dt_index = self.calendar[self.calendar['dt_nyse']==start_date].index.item()
        dt_index_list = [] 
        while p < periods:
            Xb = np.matmul(X, self.model.coef_.T)
            yt = np.squeeze(Xb + np.sqrt(sigma)*np.random.standard_normal(1))
            yf.append(yt)
            dt_index += 1
            p+=1
            dt_index_list.append(dt_index)
        self.spread_forecast = pd.DataFrame({'dt':np.squeeze(self.calendar.iloc[dt_index_list].to_numpy()),
                                             'sprd':yf})
        
        self.spread_forecast = pd.concat([x[['dt', 'sprd']], self.spread_forecast], axis=0)

            
sm = SpreadModel(ttspread)
nyse = mcal.get_calendar('NYSE')
sm.model_spread()
sm.forecast(10, .1*ttspread['sprd'].std())

class SimulateStockPrice:

    def __init__(self, X, y) -> None:
        self.data = X.merge(y, on='dt', how='left')
        self.data = self.data[self.data['dt'] >= y['dt'].min()]
        ycnames = set(y.columns.to_list())
        self.price = list(ycnames - set('dt'))[0] 
        self.data[]
        

    def simulate(self, y_lags):
        pass 



# %%
ssp = SimulateStockPrice(sm.spread_forecast, daily_stock_data[['dt', 'adj_close']])
# %%
