#%%
import datetime
import pymysql
from sqlalchemy import create_engine, text


import pandas as pd
import numpy as np

class Connection:

    def __init__(self,db_host, db_user, db_pass, db_name) -> None:
        self.host = db_host
        self.user = db_user
        self.passwd = db_pass
        self.db_name = db_name
        self.connstring = ''.join(['mysql+pymysql://', self.user, ':',
                                   self.passwd, '@', self.host, '/', self.db_name])
        self.engine = create_engine(self.connstring, echo=False)
        with self.engine.connect() as conn:
            try:
                conn.execute(text('select 1;'))
                print('Connection successful.')
            except Exception as e:
                print('Connection unsuccessful')
db_host = 'localhost'
db_user = 'dillon'
db_pass = 'Zelzah12'
db_name = 'Securities'
#%%

ri = pd.read_csv('/home/dillon/gdrivelocal/Datasets/Probitdata/GlobalData/globaldata.csv')


#%%
c = Connection(db_host, db_user, db_pass, db_name)
with c.engine.begin() as conn:
    ri.to_sql('gdp', con=conn, if_exists='replace', index=False, schema='Securities')

# %%
