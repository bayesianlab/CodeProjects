# %%
from get_data import Connection
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
from StockSimulation import StockSimulation
import warnings
import yfinance
import matplotlib.pyplot as plt 
import seaborn as sns 
import pickle 
pd.options.mode.chained_assignment = None
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


#%%
recent = daily_stock_data[daily_stock_data['dt'] > '2024-01-01']
small = recent[recent.ticker=='AAL']
stock_sim2 = StockSimulation(recent)

chain = stock_sim2.create_chain(5,5, 6)
stock_sim2.RankOptions(chain, '2024-04-26')
stock_sim2.best_puts.round(3).sort_values(by='strike')

# %%
best_puts = stock_sim2.best_puts.sort_values(by='vr', ascending=False).round(3)

# %%

g = sns.scatterplot(best_puts[(best_puts['lastPrice']<1)&(best_puts['vr']>1)], 
                x='lastPrice', y='vr', hue='ticker')
g.legend(loc='center left', bbox_to_anchor=(1., 0), ncol=1)