#%%
import pandas as pd
import numpy as np
from get_data import Connection
import matplotlib.pyplot as plt 
import seaborn as sns 
from sklearn.preprocessing import StandardScaler
from sqlalchemy import text
from datetime import datetime, timedelta
from sklearn.linear_model import LinearRegression
import pandas_market_calendars as mcal 
from scipy.stats import norm, uniform 
import yfinance
# %%
class ModelFramework:

    def __init__(self):
        self.calendar = mcal.get_calendar('NYSE')
        self.calendar = self.calendar.valid_days(start_date='1920-01-01',
                                 end_date='2050-01-01')
        self.calendar = pd.DataFrame({'dt':self.calendar})
        self.calendar['dt'] = self.calendar['dt'].dt.date
        self.calendar['dt'] = pd.to_datetime(self.calendar['dt'])


class StockSimulation(ModelFramework):

    def __init__(self, stock_data):
        super().__init__()
        self.stock_data = stock_data.copy()
        self.price_stats = self._get_price_stats(self.stock_data) 
        self.all_stock_tickers = list(stock_data['ticker'].unique())
        self.all_p0 = self.stock_data[self.stock_data['dt'] == self.stock_data['dt'].max()][['ticker', 'adj_close']]
        self.best_calls = pd.DataFrame()
        self.best_puts = pd.DataFrame() 
        self.simulation_size = 10000

    def _get_price_stats(self, stock_data):    
        dprice= []
        for i in stock_data.ticker.unique().tolist():
            tmp = stock_data.loc[stock_data.ticker==i]['adj_close']
            d = pd.DataFrame(tmp - tmp.shift(1))
            d=d.rename({'adj_close':'dprice'}, axis=1)
            dprice.append(d)
        dprice = pd.concat(dprice,axis=0)
        stock_data = stock_data.join(dprice)
        means = pd.DataFrame(stock_data.groupby('ticker')['dprice'].mean())
        means.reset_index(inplace=True)
        means.columns = ['ticker', 'xbar']
        stds = pd.DataFrame(stock_data.groupby('ticker')['dprice'].std())
        stds.reset_index(inplace=True)
        stds.columns = ['ticker', 'vol']
        return pd.concat([means, stds['vol']], axis=1)
    
    def simulate_price_states(self, ticker, p0, mu, sigma, sims, periods):
        simulation_container = np.zeros((periods + 1, sims))
        start_price = p0 
        col_names = [] 
        for j in range(sims):
            start_price = p0 
            col_names.append('col' + str(j))
            pricef =[] 
            pricef.append(start_price)
            for i in range(periods):
                start_price += (mu+sigma*np.random.standard_normal())
                pricef.append(start_price)
            simulation_container[:, j] = pricef
        frame = pd.DataFrame.from_records(simulation_container)
        frame.columns = col_names
        return frame
    
    def simulate_all_stock_price_states(self, periods, sims=100):
        simulation_frames = [] 
        print('simulate_all_stock_price_states status:')
        ticker_list = self.all_p0.ticker.to_list()
        for t in self.all_stock_tickers:
            print('Simulating ticker {}'.format(t))
            
            if t in ticker_list:
                p0 = self.all_p0[self.all_p0.ticker == t]['adj_close'].item()
                mu = self.price_stats[self.price_stats.ticker==t]['xbar'].item()
                sigma = self.price_stats[self.price_stats.ticker==t]['vol'].item() 
                frame = self.simulate_price_states(t, p0, mu, sigma, sims, periods)
                frame['ticker'] = t
                simulation_frames.append(frame)
        if len(simulation_frames)>0:
            simulations = pd.concat(simulation_frames, axis=0) 
            do = self.get_dates_out(self.stock_data['dt'].max(), 11, True)
            simulations = simulations.join(do)
            return simulations
        
    def get_ticker_xbar(self, ticker):
        return self.price_stats[self.price_stats.ticker==ticker]['xbar'].item()

    def get_ticker_vol(self, ticker):
        return self.price_stats[self.price_stats.ticker==ticker]['vol'].item()
    
    def create_chain(self, lower, upper, period):
        chain = []
        print('Status: ')
        for i, t in enumerate(self.all_stock_tickers):
            print('ticker {}'.format(t))
            stock_history = self.stock_data[self.stock_data.ticker==t]
            p0 = stock_history['adj_close'].iloc[-1]
            ub = int(p0) + upper
            x = int(p0) - lower
            m = self.price_stats[self.price_stats.ticker==t]['xbar'].item()
            v = self.price_stats[self.price_stats.ticker==t]['vol'].item()
            while x < ub:
                p = self.put_option_price(p0, x, period,m, v)
                c = self.call_option_price(p0, x, period, m, v)
                if x < p0:
                    itm = 1
                else:
                    itm = 0
                chain.append((t, x, p, c, period, itm))
                x += .5
        return pd.DataFrame(chain, columns=['ticker', 'strike', 'put', 'call', 'dte', 'itm'])

    def get_dates_out(self, date, periods_out, inclusive=False):
        if inclusive==True:
            indx = self.calendar[self.calendar['dt']<=date].idxmax()[0]
        else:
            indx = self.calendar[self.calendar['dt']<=date].idxmax()[0] + 1 
        dates = self.calendar.iloc[indx:(indx+periods_out)]
        dates.reset_index(inplace=True, drop=True)
        return dates
    
    def shifted_exponential(self, x, shift):
            return np.exp(-x + shift)
    
    def put_option_price(self, p0, strike, periods, pct_growth, avg_vol):
        m_at_expiry = pct_growth*periods + p0 
        b = (strike - m_at_expiry)/avg_vol
        z = -m_at_expiry/avg_vol
        y = np.random.uniform(0, strike, size= (self.simulation_size,))
        y = (y - m_at_expiry)/avg_vol
        updf = 1/(strike)
        tpdf = 1
        pdfy = norm.pdf(y)*(1/tpdf)
        pdfy[pdfy<1e-8] = 0  
        importance_weight = (b-y)*(pdfy/updf)
        return importance_weight.sum()/len(importance_weight)

    def call_option_price(self, p0, strike, periods, pct_growth, avg_vol):        
        m_at_expiry = pct_growth*periods + p0 
        a = (strike - m_at_expiry)/avg_vol
        y = np.random.exponential(size=(self.simulation_size,)) + a
        exp_pdf = self.shifted_exponential(y, a)
        pdfy = norm.pdf((y-m_at_expiry)/avg_vol)
        pdfy[pdfy>.99999] = 1
        importance_weight = (y-a)*(pdfy/exp_pdf)
        return importance_weight.sum()/len(importance_weight)
        
    
    def RankOptions(self, chains, expiry_date):
        calls = []
        puts = []  
        cols = ['ticker', 'expiry', 'strike', 'lastPrice', 'inTheMoney']
        print('RankOptions status:')
        for t in self.all_stock_tickers:
            d = yfinance.Ticker(t)
            try:
                print('ticker {}'.format(t))
                opts = d.option_chain(expiry_date)
                call_opts = opts.calls.copy()
                put_opts = opts.puts.copy() 
                call_opts['ticker'] = t
                call_opts['expiry'] = expiry_date
                put_opts['ticker'] = t
                put_opts['expiry'] = expiry_date
                calls.append(call_opts[cols])
                puts.append(put_opts[cols])
            except ValueError as ve:
                pass 
        if len(calls) > 0:
            calls = pd.concat(calls, axis=0)
            calls.inTheMoney = calls.inTheMoney.astype(bool)
            calls = calls.merge(chains[['ticker', 'strike', 'call']], on=['ticker', 'strike'])
            calls['value'] = calls['call'] - calls['lastPrice'] 
            calls['vr'] = calls['call']/calls['lastPrice']
            calls.sort_values(by='value', inplace=True, ascending=False)
            self.best_calls = calls 
        if len(puts) > 0:
            puts = pd.concat(puts, axis=0)
            puts.inTheMoney = puts.inTheMoney.astype(bool)
            puts = puts.merge(chains[['ticker', 'strike', 'put']], on=['ticker', 'strike'])
            puts['value'] = puts['put'] - puts['lastPrice'] 
            puts['vr'] = puts['put']/puts['lastPrice']
            puts.sort_values(by=[ 'value'], inplace=True, ascending=False)
            self.best_puts=puts 
    
    
# %%
if __name__ == '__main__':
    # %%
    sql7 = '''
        select p.*
        from 
            (
                select max(dt) dt, 
                    max(Sector) Sector
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
        on Z.dt=p.dt;
        '''

    db_host = 'localhost'
    db_user = 'dillon'
    db_pass = 'Zelzah12'
    db_name = 'Securities'
    c = Connection(db_host, db_user, db_pass, db_name)
    daily_stock_data = pd.read_sql(text(sql7), c.conn)
    test_dataset = daily_stock_data[daily_stock_data.ticker.isin(
        ['A', 'AAPL', 'AAL', 'WBD', 'XRAY'])]

    # %%
    test_dataset

# %%
