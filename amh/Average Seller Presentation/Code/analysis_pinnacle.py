#%%
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns
def prob(x, s,m,w):
    return (1./(1+np.exp(-w))) * (1./(1+np.exp(8*np.exp(s)*(x - m) )))

A = -1
B = 1
#%%
path = r'\\corp.lan\shares\TradingDesk\Analytics\Aspen\Margin Optimization\Presentation\Average Seller Presentation\Results + Analysis\Jan18' + "\\"
avgdata = pd.read_csv(path+'pinnacle_average_output.csv')
avgdata['Method'] = 'Avg. Output'
weights = pd.read_csv(path+'pinnacle_weights_output.csv')
weights['Method'] = 'Avg. Weights'
all0= pd.read_csv(path+'pinnacle_all0_output.csv')
all0['Method'] = 'All 0'
change_name= pd.read_csv(path+'pinnacle_changename_output.csv')
change_name['Method'] = 'Change Seller Name'
waw= pd.read_csv(path+'pinnacle_waw_output.csv')
waw['Method'] = 'WAW'
all1= pd.read_csv(path+'pinnacle_all1_output.csv')
all1['Method'] = 'All 1'
subset5= pd.read_csv(path+'pinnacle_subset5_output.csv')
subset5['Method'] = 'Subset 5'
subset10= pd.read_csv(path+'pinnacle_subset10_output.csv')
subset10['Method'] = 'Subset 10'
subset15= pd.read_csv(path+'pinnacle_subset15_output.csv')
subset15['Method'] = 'Subset 15'

data = pd.concat([avgdata,all0, change_name,
                 waw, all1, weights,subset5,subset10,subset15 ], axis=0)
data["Missing"]=data["Missing"].astype("object")
data.sort_values(by="Method", inplace=True)

bpdata = data[(data['Method']=='Change Seller Name') & (data['Missing']==False)].copy()
bpdata['Method'] = 'All Known'

bpdata = pd.concat([bpdata, 
           data[(data['Method']=='Avg. Output') & (data['Missing']==True)], 
           data[(data['Method']=='Avg. Weights') & (data['Missing']==True)],
           data[(data['Method']=='All 0') & (data['Missing']==True)],
           data[(data['Method']=='Change Seller Name') & (data['Missing']==True)],
           data[(data['Method']=='WAW') & (data['Missing']==True)],
           data[(data['Method']=='All 1') & (data['Missing']==True)],
           data[(data['Method']=='Subset 5') & (data['Missing']==True)],
           data[(data['Method']=='Subset 10') & (data['Missing']==True)],
           data[(data['Method']=='Subset 15') & (data['Missing']==True)]
           ])

# %%
# BOXPLOTS 
f=plt.figure()

sns.set_style("whitegrid") 
idx=[ 'All Known', 'Avg. Output', 'WAW', 'Avg. Weights', 'Change Seller Name', 'All 0', 
     'All 1', 'Subset 5', 'Subset 10', 'Subset 15']
pt = sns.boxplot(data=bpdata, x="Method", y="S",hue='Method', order=idx)
plt.xticks(rotation=55)
plt.title("Comparison of methods - S", fontsize=20)
plt.xlabel("Method", fontsize=20)
plt.ylabel("S", fontsize=20)

f=plt.figure()

sns.set_style("whitegrid") 
idx=[ 'All Known', 'Avg. Output', 'WAW', 'Avg. Weights', 'Change Seller Name', 'All 0', 
     'All 1', 'Subset 5', 'Subset 10', 'Subset 15']
pt = sns.boxplot(data=bpdata, x="Method", y="M", hue='Method', order=idx)
plt.xticks(rotation=55)
plt.title("Comparison of methods - M", fontsize=20)
plt.xlabel("Method", fontsize=20)
plt.ylabel("M", fontsize=20)

f=plt.figure()

sns.set_style("whitegrid") 
idx=[ 'All Known', 'Avg. Output', 'WAW', 'Avg. Weights', 'Change Seller Name', 'All 0', 
     'All 1', 'Subset 5', 'Subset 10', 'Subset 15']
pt = sns.boxplot(data=bpdata, x="Method", y="W", hue='Method', order=idx)
plt.xticks(rotation=55)
plt.title("Comparison of methods - W", fontsize=20)
plt.xlabel("Method", fontsize=20)
plt.ylabel("W", fontsize=20)
# %%

smedians = bpdata.groupby('Method')['S'].median().reset_index()
mmedians = bpdata.groupby('Method')['M'].median().reset_index()
wmedians = bpdata.groupby('Method')['W'].median().reset_index()

sbaseline = smedians[smedians['Method']=='All Known']['S'].to_numpy()[0]
mbaseline = mmedians[mmedians['Method']=='All Known']['M'].to_numpy()[0]
wbaseline = wmedians[wmedians['Method']=='All Known']['W'].to_numpy()[0]
x=np.arange(A,B,.01)
y=prob(x,sbaseline,mbaseline,wbaseline)
d1 = pd.DataFrame({"Margin":x, "Probability":y, "Method":'All Known'})

sall1 = smedians[smedians['Method']=='All 1']['S'].to_numpy()[0]
mall1 = mmedians[mmedians['Method']=='All 1']['M'].to_numpy()[0]
wall1 = wmedians[wmedians['Method']=='All 1']['W'].to_numpy()[0]
x=np.arange(A,B,.01)
y=prob(x,sall1,mall1,wall1)
d2 = pd.DataFrame({"Margin":x, "Probability":y, 'Method':'All 1'})

savg = smedians[smedians['Method']=='Avg. Output']['S'].to_numpy()[0]
mavg = mmedians[mmedians['Method']=='Avg. Output']['M'].to_numpy()[0]
wavg = wmedians[wmedians['Method']=='Avg. Output']['W'].to_numpy()[0]
x=np.arange(A,B,.01)
y=prob(x,savg,mavg,wavg)
d3 = pd.DataFrame({"Margin":x, "Probability":y, 'Method':'Avg. Output'})

sweight = smedians[smedians['Method']=='Avg. Weights']['S'].to_numpy()[0]
mweight = mmedians[mmedians['Method']=='Avg. Weights']['M'].to_numpy()[0]
wweight = wmedians[wmedians['Method']=='Avg. Weights']['W'].to_numpy()[0]
x=np.arange(A,B,.01)
y=prob(x,sweight,mweight,wweight)
d4 = pd.DataFrame({"Margin":x, "Probability":y, 'Method':'Avg. Weights'})

schange_name = smedians[smedians['Method']=='Change Seller Name']['S'].to_numpy()[0]
mchange_name = mmedians[mmedians['Method']=='Change Seller Name']['M'].to_numpy()[0]
wchange_name = wmedians[wmedians['Method']=='Change Seller Name']['W'].to_numpy()[0]
x=np.arange(A,B,.01)
y=prob(x,schange_name,mchange_name,wchange_name)
d5 = pd.DataFrame({"Margin":x, "Probability":y, 'Method':'Change Seller Name'})

swaw = smedians[smedians['Method']=='WAW']['S'].to_numpy()[0]
mwaw = mmedians[mmedians['Method']=='WAW']['M'].to_numpy()[0]
wwaw = wmedians[wmedians['Method']=='WAW']['W'].to_numpy()[0]
x=np.arange(A,B,.01)
y=prob(x,swaw,mwaw,wwaw)
d6 = pd.DataFrame({"Margin":x, "Probability":y, 'Method':'WAW'})

ssubset5 = smedians[smedians['Method']=='Subset 5']['S'].to_numpy()[0]
msubset5 = mmedians[mmedians['Method']=='Subset 5']['M'].to_numpy()[0]
wsubset5 = wmedians[wmedians['Method']=='Subset 5']['W'].to_numpy()[0]
x=np.arange(A,B,.01)
y=prob(x,ssubset5,msubset5,wsubset5)
d7 = pd.DataFrame({"Margin":x, "Probability":y, 'Method':'Subset 5'})

ssubset10 = smedians[smedians['Method']=='Subset 10']['S'].to_numpy()[0]
msubset10 = mmedians[mmedians['Method']=='Subset 10']['M'].to_numpy()[0]
wsubset10 = wmedians[wmedians['Method']=='Subset 10']['W'].to_numpy()[0]
x=np.arange(A,B,.01)
y=prob(x,ssubset10,msubset10,wsubset10)
d8 = pd.DataFrame({"Margin":x, "Probability":y, 'Method':'Subset 10'})

ssubset15 = smedians[smedians['Method']=='Subset 15']['S'].to_numpy()[0]
msubset15 = mmedians[mmedians['Method']=='Subset 15']['M'].to_numpy()[0]
wsubset15 = wmedians[wmedians['Method']=='Subset 15']['W'].to_numpy()[0]
x=np.arange(A,B,.01)
y=prob(x,ssubset15,msubset15,wsubset15)
d9 = pd.DataFrame({"Margin":x, "Probability":y, 'Method':'Subset 15'})

lpdata = pd.concat([d1,d2,d3,d4,d5,d6,d7,d8,d9])
# p = sns.color_palette('RdPu', 10)
# p.reverse()
# sns.set_palette(p)
idx=['All Known', 'Avg. Output', 'WAW', 'Change Seller Name', 'All 0', 
     'All 1', 'Avg. Weights', 'Subset 5', 'Subset 10', 'Subset 15']
sns.lineplot(data=lpdata, x="Margin",y="Probability", hue='Method', hue_order=idx)
plt.title("Comparison of elasticities", fontsize=20)
plt.xlabel("Margin", fontsize=20)
plt.ylabel("Probability", fontsize=20)
# %%
idx=['All Known', 'Avg. Output', 'WAW', 'Change Seller Name']
sns.lineplot(data=lpdata, x="Margin",y="Probability", hue='Method', hue_order=idx)
plt.title("Comparison of elasticities", fontsize=20)
plt.xlabel("Margin", fontsize=20)
plt.ylabel("Probability", fontsize=20)
# %%
