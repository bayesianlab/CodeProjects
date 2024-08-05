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
# country_keys.to_csv('country_keys.csv', index=False)
# %%
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


# %%
datacopy = data
datacopy = pd.concat(datacopy, axis=0)

#%%
c = Connection(db_host, db_user, db_pass, db_name)
#%%
# datacopy.to_sql(name='GlobalRecessions', con=c.engine, index=False, if_exists='replace')

#%%

#%%
with c.engine.connect() as b:
    probit_data_y = pd.read_sql(text('select * from Securities.ProbitData;'), con=b)
    probit_data_x = pd.read_sql(text('select * from Securities.ProbitData order by Yr,Mon,Country;'), con=b)
    probit_data_y.to_csv('/home/dillon/gdrivelocal/Datasets/Probitdata/GlobalData/probit_data.csv', index=False)
# %%

data_y = probit_data_y 

#%%
dts = data_y[['Dt']]
data_y = data_y[['Country', 'Ri']]

# %%
countries = pd.unique(data_y.Country.values)

cdata = {} 
ydata = {} 
for i in countries:
    x = data_y[data_y.Country==i ].copy()
    i = i.replace(' ', '')
    ynames = 'Ri_' + i 
    y = x['Ri']
    y.columns = ynames 
    y.reset_index(inplace=True, drop=True)
    ydata[ynames] = y 

y = pd.concat(ydata, axis=1)
# %%
y.to_csv('RecessionIndicatorY.csv', index=False)
# %%
data_x = probit_data_x[['GDP', 'StockIndex']].copy()

ss = StandardScaler()
ss.fit(data_x)
scaled = ss.transform(data_x)
data_x['GDP'] = scaled[:,0]
data_x['StockIndex'] = scaled[:,1]
data_x['c'] = 1
data_x = data_x[['c', 'GDP', 'StockIndex']]
data_x.to_csv('RecessionIndicatorX.csv', index=False)
# %%
