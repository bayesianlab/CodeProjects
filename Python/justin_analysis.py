#%%
import pandas as pd 
import numpy as np
from datetime import datetime
from statsmodels.api import OLS 
#%%
data = pd.read_csv('justin_regression.csv')
data['DOB'] = pd.to_datetime(data['DOB'])
# %%
x = (datetime.now() - data['DOB'])/365.25
y = [] 
for i in range(x.shape[0]):
    y.append(x.iloc[i].days)

data['Age'] = y
data['AgexWBH'] = data['Age']*data['Whole Blood Histamine']
data['AgexCeruloplasmin'] = data['Age']*data['Ceruloplasmin']
data['AgexSerumCu'] = data['Age']*data['Serum Cu']
data['BloodX'] = data['Whole Blood Histamine']*data['Ceruloplasmin']*data['Serum Cu']*data['Urine KP']
#%%
X = data[['Urine KP', 'Whole Blood Histamine', 'Ceruloplasmin', 'Serum Cu', 'Serum Zn', 'Age']]
X['const'] = 1

y  = data['PHQ-9']
# %%
lr = OLS(y, X, hasconst=False).fit() 
lr.summary()

# %%
