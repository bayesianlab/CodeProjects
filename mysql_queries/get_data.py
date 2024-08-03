# %%
import datetime
import pymysql
from sqlalchemy import create_engine, text
import urllib3
import requests
import yfinance
from math import ceil
from bs4 import BeautifulSoup as bs
import pandas as pd
import numpy as np
import pyfredapi as pf 

# Obtain a database connection to the MySQL instance
db_host = 'localhost'
db_user = 'dillon'
db_pass = 'Zelzah12'
db_name = 'Securities'

# %%
class Connection:

    def __init__(self,db_host, db_user, db_pass, db_name) -> None:
        self.host = db_host
        self.user = db_user
        self.passwd = db_pass
        self.db_name = db_name
        self.connstring = ''.join(['mysql+pymysql://', self.user, ':',
                                   self.passwd, '@', self.host, '/', self.db_name])
        self.engine = create_engine(self.connstring, echo=False)
        

class SNP500:

    def __init__(self, db_host, db_user, db_pass, db_name) -> None:
        self.host = db_host
        self.user = db_user
        self.passwd = db_pass
        self.db_name = db_name
        self.connstring = ''.join(['mysql+pymysql://', self.user, ':',
                                   self.passwd, '@', self.host, '/', self.db_name])
        self.engine = create_engine(self.connstring, echo=False)
        self.conn = self.engine.connect()

    def obtain_parse_wiki_snp500(self):
        """Download and parse the Wikipedia list of S&P500 
        constituents using requests and libxml.

        Returns a list of tuples for to add to MySQL."""

        # Stores the current time, for the created_at record
        now = datetime.datetime.utcnow()

        # Use libxml to download the list of S&P500 companies and obtain the symbol table
        link = 'http://en.wikipedia.org/wiki/List_of_S%26P_500_companies'
        resp = requests.get(link).text

        soup = bs(resp, 'html.parser')
        table = soup.find('table')
        tb = table.find('tbody')
        tr = tb.find_all('tr')
        rows = {}
        i = 0
        for r in tr:
            col = []
            data = r.find_all('td')
            for ele in data:
                if not isinstance(ele, str):
                    e = ele.text.strip()
                    col.append(e)
                else:
                    col.append(ele)
                if len(col) == 8:
                    rows[i] = col
            i += 1
        self.symbols_list = pd.DataFrame.from_dict(rows, orient='index')
        self.symbols_list.columns = ['Symbol', 'Security', 'Sector', 'Sub-Industry',
                                'Headquarters', 'DateAdded', 'CIK', 'Founded']
        self.symbols_list[['Symbol', 'Security', 'Sector', 'Sub-Industry']].to_sql('snp500', self.conn,
                                                                              if_exists='replace')

# %%

class YahooHistoricalError(Exception):
    def __init__(self, message) -> None:
        super().__init__(message)

class YahooHistorical(SNP500):

    def __init__(self, db_host, db_user, db_pass, db_name) -> None:
        super().__init__(db_host, db_user, db_pass, db_name)
        self.last_added_date = pd.DataFrame()

    def CreateDatabaseTable(self, _days_ago):
        T  = pd.read_sql(text('SELECT * FROM stock_prices limit 10'), self.conn)
        if T.empty: 
            frame = self.get_historical_data(days_ago=_days_ago)
            self.insert_historical_data_to_sql(frame)
        else:
            print('Database exists')

    def UpdateDatabaseTable(self, days_ago):
        self.get_last_date()
        frame = self.get_historical_data(days_ago)
        self.insert_historical_data_to_sql(frame)

    def get_spy(self, days_ago):
        if days_ago is not None:
            days_ago = datetime.timedelta(days=days_ago)
            self.start_time = datetime.datetime.now() - days_ago 
        else:
            days_ago=700
        sql = 'select distinct dt from Securities.spy order by dt desc limit 1;'
        existing = pd.read_sql(text(sql), self.conn)
        if existing.empty:
            print('table does not exist')
            self.start_time = datetime.datetime.today() - datetime.timedelta(days=700)
        else:
            self.start_time = existing['dt']
        frame = yfinance.download('SPY', interval='1h', start=self.start_time.item())
        frame['ticker'] = 'SPY'
        frame.reset_index(inplace=True)
        frame.rename({'Ticker': 'ticker', 'Datetime': 'dt', 'Adj Close': 'adj_close',
                    'Close': 'closing', 'Open': 'opening', 'High': 'high', 'Low': 'low',
                    'Volume':'volume'},
                    axis=1, inplace=True)
        if not frame.empty:
            frame.to_sql('spy', self.engine, if_exists='append', index=False,
                                    schema='Securities')

    def get_historical_data(self, days_ago=None):
        if days_ago is not None:
            days_ago = datetime.timedelta(days=days_ago)
            self.start_time = datetime.datetime.now() - days_ago 
        else:
            self.get_last_date()
        symbols = pd.read_sql(text('SELECT * FROM snp500;'),
                              self.conn, index_col='index')
        symbols = list(symbols['Symbol'])
        return yfinance.download(symbols, interval='1h',
                                             start=self.start_time)
        
    def get_last_date(self):
        sql = text('''
              SELECT DISTINCT dt 
              FROM Securities.stock_prices 
              ORDER BY dt 
              DESC LIMIT 1;
              ''')
        self.last_added_date = pd.read_sql(sql,self.conn)
        if self.last_added_date.empty:
            raise YahooHistoricalError('stock_prices database does not exist. Create first.')
        self.start_time = self.last_added_date.iloc[0] 
        t = self.start_time['dt'] 
        self.start_time = t + datetime.timedelta(days=1)

    
    def insert_historical_data_to_sql(self, frame):
        if frame.empty:
            raise YahooHistoricalError('Empty dataframe. Check dates. {}'.format(self.start_time))

        frame = frame.stack().swaplevel()
        frame = pd.DataFrame(frame.to_records())
        newrecords = frame.shape[0]
        if 'level_1' in frame.columns:
            frame.rename({'Ticker': 'ticker', 'level_1': 'dt', 'Adj Close': 'adj_close',
                        'Close': 'closing', 'Open': 'opening', 'High': 'high', 'Low': 'low',
                        'Volume':'volume'},
                        axis=1, inplace=True)
        else:
            frame.rename({'Ticker': 'ticker', 'Datetime': 'dt', 'Adj Close': 'adj_close',
                        'Close': 'closing', 'Open': 'opening', 'High': 'high', 'Low': 'low',
                        'Volume':'volume'},
                        axis=1, inplace=True)
        frame['grp_id'] = 'snp500'
        frame['freq'] = 'h'
        frame['dt'] = pd.to_datetime(frame['dt'], utc=True)
        print('New records added into database {}'.format(frame.shape[0]))
        frame.to_sql('stock_prices', self.engine, if_exists='append', index=False,
                                    schema='Securities')
        print('Done.')

#%%
class FredData:

    def __init__(self, engine):
        self.fred_api_key = '03b844c47ed3f30d4b9bba660c25df79'
        self.engine = engine 
    
    def upload_fred(self, fred_name, table_name, fred_col_names, new_col_names):
        sql = text('''
              SELECT DISTINCT dt 
              FROM Securities.{} 
              ORDER BY dt 
              DESC LIMIT 1;
              '''.format(table_name))
        data = pf.get_series(fred_name, api_key=self.fred_api_key)
        data = data[fred_col_names]
        data.columns = new_col_names
        try:
            data.to_sql(table_name, self.engine, if_exists='fail', index=False, schema='Securities')
        except ValueError as e:
            with self.engine.connect() as conn:
                print('dropping table')
                conn.execute(text("drop table tentwo_sprd;").execution_options(autocommit=True))
            data.to_sql(table_name, self.engine, index=False, schema='Securities')
            print('recommited table')



#%% 
if __name__ == "__main__":
    c = Connection(db_host, db_user, db_pass, db_name)
    # snp = SNP500(db_host, db_user, db_pass, db_name)
    # snp.obtain_parse_wiki_snp500()
    yh = YahooHistorical(db_host, db_user, db_pass, db_name)
    # yh.CreateDatabaseTable(7)
    yh.UpdateDatabaseTable(5)
    yh.get_spy(3)
    
    # fd = FredData(c.engine)
    # fd.upload_fred('T10Y2Y', 'tentwo_sprd', ['date', 'value'], ['dt', 'sprd'])
    # fd.upload_fred('TRUCKD11', 'truck_ton', ['date', 'value'], ['dt', 'tons'])
    # fd.upload_fred('DFF', 'fed_funds', ['date', 'value'], ['dt', 'rate'])
    # fd.upload_fred('USREC', 'nber_recessions', ['date', 'value'], ['dt', 'recession_indicator'])

# %%
