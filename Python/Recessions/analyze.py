#%%
import pandas  as pd 
import numpy as np
from sqlalchemy import create_engine, text
import matplotlib.pyplot as plt 

class Connection:

    def __init__(self,db_host, db_user, db_pass, db_name) -> None:
        self.host = db_host
        self.user = db_user
        self.passwd = db_pass
        self.db_name = db_name
        self.connstring = ''.join(['mysql+pymysql://', self.user, ':',
                                   self.passwd, '@', self.host, '/', self.db_name])
        self.engine = create_engine(self.connstring, echo=False)
db_host = 'localhost'
db_user = 'dillon'
db_pass = 'Zelzah12'
db_name = 'Securities'
#%%
insample_path = '/home/dillon/gdrivelocal/LatexDocuments/probit/Data/insample_output/'
save_path = '/home/dillon/gdrivelocal/LatexDocuments/probit/'
factors = pd.read_csv(insample_path+'factors.csv', header=None)

y= pd.read_csv('/home/dillon/CodeProjects/Python/Recessions/RecessionIndicatorY.csv')
fsort = pd.DataFrame(np.sort(factors.values, axis=0))

factorbar = fsort.quantile(.50, axis=0)
fupper = fsort.quantile(.66, axis=0)
flower = fsort.quantile(.33, axis=0)
c = Connection(db_host, db_user, db_pass, db_name)
with c.engine.connect() as b:
    probit_data = pd.read_sql(text('select * from Securities.Insample;'), con=b)
    dts = probit_data[['Dt']]
    qry = """
            select *
            from GrowthRateData
            where Country='China'
            """
    global_recessions = pd.read_sql(text(qry), con=b)

global_recessions
# %%
usdts = probit_data[probit_data['Country']=='USA']['Dt'].copy()
usdts.reset_index(inplace=True, drop=True)
usdts = pd.to_datetime(usdts)
usRecess = pd.DataFrame({'Global Factor':factorbar, 'US Recessions':y['Ri_USA'],
                         'Dt':usdts})
usRecess
# %%
b = 0 
e = 1 
recessions = [] 
for i in usRecess.itertuples():
    if i[2] == 1 and b == 0:
        start = i[3]
        b = 1
        e = 0
    if i[2] ==0 and e==0:
        end = j[3]
        e = 1
        b = 0
        recessions.append((start , end ))
    j = i  


plt.plot(usRecess['Dt'],factorbar)
plt.ylabel('Factor Value')
plt.fill_between(usRecess['Dt'], y1=fupper, y2=flower, color='red', alpha=.25)
ax2 = plt.twinx()
for i in recessions:
    b = i[0]
    e = i[1]
    plt.axvspan(b, e, alpha=.45, color='grey')
ax2.set_ylabel('Recession Probability')


plt.savefig(save_path+'global_factor.png')


# %%
orthants = pd.read_csv(insample_path+'orthant_probs.csv', header=None)
                       

# %%
oupper = orthants.quantile(.95, axis=0)
olower = orthants.quantile(.05, axis=0)
obar = orthants.quantile(.50, axis=0)
odf = pd.DataFrame({'66th Quantile':oupper, '33rd Quantile': olower, 'Median':obar, 'Dt':usRecess['Dt']})
odf
odf = pd.melt(odf, id_vars='Dt',value_name='Orthant Prob.', var_name='Quantile')
# %%
plt.plot(usRecess['Dt'], obar, label='Log-probability')
plt.fill_between(usRecess['Dt'], oupper, olower, color='red', alpha=.25)
plt.legend() 
plt.savefig(save_path+'logprob.png')
# %%
obarreal = np.exp(obar)
oupperreal = np.exp(oupper)
olowerreal = np.exp(olower)
plt.plot(usRecess['Dt'], obarreal, label='Probability 0-1 scale')
plt.fill_between(usRecess['Dt'], olowerreal, oupperreal, color='red', alpha=.25)
plt.legend(loc='upper left')
plt.savefig(save_path+'prob01.png')

# %%
loaders = pd.read_csv('loadings.csv', header=None)
loaders = loaders.to_numpy()
loaders = loaders.reshape(32,9000)
#%%
loadersbar = loaders.mean(axis=1)
loadersbar = loadersbar.reshape(32,1)
# %%



cov= np.matmul(loadersbar, loadersbar.T)
# %%
pd.DataFrame(cov)
# %%
outsample_path = save_path+'Data/prediction_output/'
predictions = pd.read_csv(outsample_path+'ypred.csv', header=None)
countries = pd.read_csv('/home/dillon/CodeProjects/Python/Recessions/countries.csv')
countries=countries.iloc[:,1:]

# %%
predictions = pd.concat([countries, predictions], axis=1)
#%%
predictions = predictions.rename({0:'2022-Q3', 1:'2022-Q4', 2:'2023-Q1', 3:'2023-Q2', 4:'2023-Q3', 5:'2023-Q4'}, axis=1)
predictions.to_csv(save_path+'predictions.csv', index=False)
# %%
plt.plot(global_recessions['Dt'] , global_recessions['GDPGrowth'], label='GDP Growth')
plt.plot(global_recessions['Dt'], global_recessions['ExpRet'], label='Expected Qrt. Returns-Chinese Index')
plt.legend()
plt.xlabel('Date')
plt.ylabel('Growth Rate/Expected Return')
plt.savefig(save_path+'ChinaGrate.png')
# %%
os_orthants = pd.read_csv(outsample_path+'prediction_ort/prediction_orthant_probs.csv', header=None)
                       
# %%

oupper = os_orthants.quantile(.95, axis=0)
olower = os_orthants.quantile(.05, axis=0)
obar = os_orthants.quantile(.50, axis=0)

odf = pd.DataFrame({'66th Quantile':oupper, '33rd Quantile': olower, 'Median':obar, 'Dt':usRecess['Dt']})
odf
odf = pd.melt(odf, id_vars='Dt',value_name='Orthant Prob.', var_name='Quantile')
# %%
xlabels = predictions.columns[1:]
plt.plot(xlabels, obar, label='Log-probability')
plt.fill_between(xlabels, oupper, olower, color='red', alpha=.25)
plt.legend() 
plt.savefig(save_path+'logprob_outsample.png')
# %%
obarreal = np.exp(obar)
oupperreal = np.exp(oupper)
olowerreal = np.exp(olower)
plt.plot(xlabels, obarreal, label='Probability 0-1 scale')
plt.fill_between(xlabels,  olowerreal, oupperreal, color='red', alpha=.25)
plt.legend(loc='upper left')
plt.savefig(save_path+'prob_outsample.png')

# %%
