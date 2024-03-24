#%%
from datetime import datetime
import pandas as pd 
import numpy as np
import matplotlib.pyplot as plt 
import seaborn as sns 
from statsmodels.graphics.tsaplots import plot_acf, plot_pacf
from sklearn.preprocessing import StandardScaler

#%% 
alldata = pd.read_csv('data.csv')
plt.plot(alldata['LookCnt'])
plt.figure()
zt = np.reshape(alldata['LookCnt'], (-1,1))
ss = StandardScaler()
ss.fit(zt)
zt = ss.transform(zt)
plt.plot(zt)
xzt = np.reshape(alldata['PrimaryRate30Y'],(-1,1))
ssx = StandardScaler()
ssx.fit(xzt)
xzt = ssx.transform(xzt)
plt.plot(xzt, color='r')

bzt = np.reshape(alldata['ps_spread'], (-1,1))
ssb = StandardScaler()
ssb.fit(bzt)
bzt = ssb.transform(bzt)
plt.plot(bzt, color='black')

# np.reshape(alldata[''])
# %%
