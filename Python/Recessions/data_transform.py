#%%
import pandas as pd
import numpy as np
#%%
data = pd.read_csv('query1.csv')
dts = data[['Yr', 'Mon']]
data = data[['Country', 'GDP', 'IndustrialProd', 'Investment', 'Employment']]

# %%
countries = pd.unique(data.Country.values)

cdata = {} 
ydata = {} 
for i in countries:
    x = data[data.Country==i ].copy()
    i = i.replace(' ', '')
    nnames = ['_'.join([j,i]) for j in ['IndustrialProd', 'Investment', 'Employment']]
    ynames = 'GDP_' + i 
    y = x['GDP']
    x = x[['IndustrialProd', 'Investment', 'Employment']]
    x.columns = nnames 
    y.columns = ynames 
    x.reset_index(inplace=True, drop=True)
    y.reset_index(inplace=True, drop=True)
    cdata[i] = x
    ydata[ynames] = y 

X = pd.concat(cdata.values(), axis=1)
y = pd.concat(ydata, axis=1)
# %%
y.to_csv('worldgdp.csv', index=False)
# %%
