#%%
from fredapi import Fred
import requests as req
import pandas as pd
import numpy as np 
from sqlalchemy import create_engine, text
import csv
import pickle
import os.path
from os import path
import sys
import seaborn as sns 
import matplotlib.pyplot as plt 
import subprocess
import datetime
from sklearn.preprocessing import StandardScaler
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
country_codes = pd.read_csv('/home/dillon/gdrivelocal/Datasets/Probitdata/GlobalData/country_codes.csv')
ids = search['id']
#%%
codes = [] 
pk = 0 
for i in ids:
    if i[-1] == 'C':
        codes.append((pk , i[0:3], i))
        pk+=1
search_codes = pd.DataFrame(codes, columns=['Key', 'CountryCode', 'SeriesId'])

# %%
country_keys = search_codes.merge(country_codes, on='CountryCode')
country_keys.to_csv('country_keys.csv', index=False)
ids = country_keys['SeriesId']
# %%
data = [] 
for i in ids:
    name = country_keys[country_keys['SeriesId']==i][['CountryCode', 'SeriesId', 'Country']]
    print(name)
    series = fred.get_series(i)
    series = pd.DataFrame(series, columns=['RecessionIndicator'])
    series['CountryCode'] = name['CountryCode'].squeeze()
    series['SeriesId'] = name['SeriesId'].squeeze()
    series['Country'] = name['Country'].squeeze()
    series.reset_index(inplace=True)
    series.rename({'index':'Dt'}, inplace=True, axis=1)
    data.append(series)
c = Connection(db_host, db_user, db_pass, db_name)
datacopy = pd.concat(data, axis=0)
#%%
with c.engine.begin() as conn:
    datacopy.to_sql('GlobalRecessions', con=conn, if_exists='replace', index=False)
# %%
datacopy = data
datacopy = pd.concat(datacopy, axis=0)

#%%
c = Connection(db_host, db_user, db_pass, db_name)

with c.engine.connect() as b:
    probit_data = pd.read_sql(text('select * from Securities.Insample;'), con=b)
    
# %%

dts = probit_data[['Dt']]
probit_data_y = probit_data[['Country', 'RecessionIndicator']]

# %%
countries = pd.unique(probit_data_y.Country.values)
countries_frame = pd.DataFrame(countries, columns=['Countries'])
countries_frame.to_csv('countries.csv')
print(len(countries))
cdata = {} 
ydata = {} 
for i in countries:
    x = probit_data_y[probit_data_y.Country==i ].copy()
    i = i.replace(' ', '')
    ynames = 'Ri_' + i 
    y = x['RecessionIndicator']
    y.columns = ynames 
    y.reset_index(inplace=True, drop=True)
    ydata[ynames] = y 

y = pd.concat(ydata, axis=1)
# %%
y.to_csv('RecessionIndicatorY.csv', index=False)
# %%
data_x = probit_data[['GDPGrowth', 'ExpRet']].copy()

# ss = StandardScaler()
# ss.fit(data_x)
# scaled = ss.transform(data_x)

#%%
data_x['c'] = 1
data_x = data_x[['c', 'GDPGrowth', 'ExpRet']]
data_x.to_csv('RecessionIndicatorX.csv', index=False)
# %%
c = Connection(db_host, db_user, db_pass, db_name)

with c.engine.connect() as b:
    probit_data_outsample = pd.read_sql(text('select * from Securities.OutSample;'), con=b)

probit_data_outsample['Dt']=pd.to_datetime(probit_data_outsample['Dt'])
probit_data_outsample= probit_data_outsample[probit_data_outsample['Dt']>pd.to_datetime('2022-06-01')]
#%%
country_frame = pd.DataFrame(countries, columns=['Country'])
probit_data_outsample=probit_data_outsample.merge(country_frame)
print(len(probit_data_outsample.Country.unique()))
#%%
data_x = probit_data_outsample[['GDPGrowth', 'ExpRet']].copy()
data_x['c'] = 1
data_x = data_x[['c', 'GDPGrowth', 'ExpRet']]
data_x.to_csv('RecessionIndicatorX_Outsample.csv', index=False)
# %%

# %%
