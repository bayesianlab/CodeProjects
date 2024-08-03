#%%
from fredapi import Fred
import requests as req
import pandas as pd
from sqlalchemy import create_engine, text
import csv
import pickle
import os.path
from os import path
import sys
import subprocess
# Obtain a database connection to the MySQL instance
db_host = 'localhost'
db_user = 'dillon'
db_pass = 'Zelzah12'
db_name = 'Securities'

class Connection:

    def __init__(self,db_host, db_user, db_pass, db_name) -> None:
        self.host = db_host
        self.user = db_user
        self.passwd = db_pass
        self.db_name = db_name
        self.connstring = ''.join(['mysql+pymysql://', self.user, ':',
                                   self.passwd, '@', self.host, '/', self.db_name])
        self.engine = create_engine(self.connstring, echo=False)
fred = Fred(api_key='1593ee3cad0646216ab4b80aa9f63cd2')
#%%
search = fred.search('OECD based Recession Indicators')

# %%
search = search[search['frequency']=='Monthly']
# %%
ids = search['id']
# %%
data = [] 
for i in ids:
    print(i)
    data.append(fred.get_series(i))

# %%
datacopy = data


# %%
c = 0
for i in ids:
    i = ids[1]
    c = 1
    datacopy[c] = pd.DataFrame(datacopy[c], columns=['RecessionIndicator'])
    b = search[(search['id']==i) & (search['frequency']=='Monthly')]['title'][0].find('for') + 4
    e = search[(search['id']==i) & (search['frequency']=='Monthly')]['title'][0].find('from')
    n = search[(search['id']==i) & (search['frequency']=='Monthly')]['title'][0][b:e]
    print(n)
    datacopy[c]['Name'] = n
    c+=1
    
# %%
D = pd.concat(datacopy, axis=0)

# %%
D.rename({'index':'Dt'}, axis=1, inplace=True)
#%%
c = Connection(db_host, db_user, db_pass, db_name)
#%%

D.to_sql(name='GlobalRecessions', con=c.engine, index=False, if_exists='append')

# %%

search[(search['id']==ids) & (search['frequency']=='Monthly')]['title'][0][b:e]
#%%
country_codes = pd.read_csv('/home/dillon/gdrivelocal/Datasets/Probitdata/GlobalData/country_codes.csv')

#%%
codes = [] 
pk = 0 
for i in ids:
    if i[-1] == 'C':
        codes.append((pk , i[0:3], i))
        pk+=1
search_codes = pd.DataFrame(codes, columns=['Key', 'CountryCode', 'SeriesId'])
search_codes_unique = pd.DataFrame(search_codes['CountryCode'].unique(), columns=['CountryCode'])

# %%
search_codes.merge(country_codes, on='CountryCode')
# %%
