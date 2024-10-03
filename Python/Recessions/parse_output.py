#%%
import pandas as pd
import numpy as np
import os 
import matplotlib.pyplot as plt 
import seaborn as sns 

# %%
x  = np.random.normal(0,1, size=(100,10))
(x-x.mean(axis=0)).mean(0)

#%%
factor_path = '/home/dillon/gdrivelocal/LatexDocuments/probit/Data/simulations/'
insample_path = '/home/dillon/gdrivelocal/LatexDocuments/probit/Data/insample_output/'
true_path = '/home/dillon/gdrivelocal/LatexDocuments/probit/Data/simulations/'
save_path = '/home/dillon/gdrivelocal/LatexDocuments/probit/'
#%%
factors = pd.read_csv(factor_path+'factor_8/factors.csv', header=None)
f80 = factors.iloc[np.arange(0,factors.shape[0], 2)]
f81 = factors.iloc[np.arange(1,factors.shape[0], 2)]
f80.reset_index(inplace=True, drop=True)
f81.reset_index(inplace=True, drop=True)
f80bar = f80.mean(axis=0)
f81bar = f81.mean(axis=0)
true8 = pd.read_csv(true_path+'true_8', header=None)
factors8 = true8.T
factors8.columns = ['Factor_0', 'Factor_1']


# %%
f80summary = pd.DataFrame(f80.mean())
f80summary.columns=['Factor_0'] 
f80summary['Q_upper'] = f80.quantile(q=.80)
f80summary['Q_lower'] = f80.quantile(q=.20)
# %%
fig, ax = plt.subplots()
x = np.arange(0,100)
ax.plot(x, f80summary['Factor_0'],label='Estimated')
ax.fill_between(x, f80summary['Q_upper'], f80summary['Q_lower'], color='b', alpha=.15, label='80%-20% quantile')
ax.plot(x, factors8['Factor_0'], color='black', label='Actual')
handles, labels = ax.get_legend_handles_labels()
order = [2,0,1]
ax.legend([handles[idx] for idx in order],[labels[idx] for idx in order])
ax.set_xlabel('T')
ax.set_ylabel('Factor Value')
ax.set_title('True vs. Estimated Factor for $K=8$')
#%%
# CAREFUL
# fig.savefig(save_path + 'factor0_8.png')
# %%
f81summary = pd.DataFrame(f81.mean())
f81summary.columns=['Factor_1'] 
f81summary['Q_upper'] = f81.quantile(q=.80)
f81summary['Q_lower'] = f81.quantile(q=.20)
#%%
fig, ax = plt.subplots()
x = np.arange(0,100)
ax.plot(x, f81summary['Factor_1'],label='Estimated')
ax.fill_between(x, f81summary['Q_upper'], f81summary['Q_lower'], color='b', alpha=.15, label='80%-20% quantile')
ax.plot(x, factors8['Factor_0'], color='black', label='Actual')
handles, labels = ax.get_legend_handles_labels()
order = [2,0,1]
ax.legend([handles[idx] for idx in order],[labels[idx] for idx in order])
ax.set_xlabel('T')
ax.set_ylabel('Factor Value')
ax.set_title('True vs. Estimated Factor for $K=8$')
#%%
# CAREFUL
# fig.savefig(save_path + 'factor1_8.png')
# %%

factors = pd.read_csv(factor_path + 'factor_16/factors.csv', header=None)
f_16_0 = factors.iloc[np.arange(0,factors.shape[0], 2)]
f_16_1 = factors.iloc[np.arange(1,factors.shape[0], 2)]
f_16_0.reset_index(inplace=True, drop=True)
f_16_1.reset_index(inplace=True, drop=True)
f_16_0_bar = f_16_0.mean(axis=0)
f_16_1_bar = f_16_1.mean(axis=0)
true16 = pd.read_csv(true_path+'true_16', header=None)
factors16 = true16.T
factors16.columns = ['Factor_0', 'Factor_1']
# %%
f_16_0_summary = pd.DataFrame(f_16_0.mean())
f_16_0_summary.columns=['Factor_0'] 
f_16_0_summary['Q_upper'] = f_16_0.quantile(q=.80)
f_16_0_summary['Q_lower'] = f_16_0.quantile(q=.20)
# %%
fig, ax = plt.subplots()
x = np.arange(0,100)
ax.plot(x, f_16_0_summary['Factor_0'],label='Estimated')
ax.fill_between(x, f_16_0_summary['Q_upper'], f_16_0_summary['Q_lower'], color='b', alpha=.15, label='80%-20% quantile')
ax.plot(x, factors16['Factor_0'], color='black', label='Actual')
handles, labels = ax.get_legend_handles_labels()
order = [2,0,1]
ax.legend([handles[idx] for idx in order],[labels[idx] for idx in order])
ax.set_xlabel('T')
ax.set_ylabel('Factor Value')
ax.set_title('True vs. Estimated Factor for $K=16$')
#%%
# CAREFUL
# fig.savefig(save_path + 'factor0_16.png')
# %%
f_16_1_summary = pd.DataFrame(f_16_1.mean())
f_16_1_summary.columns=['Factor_1'] 
f_16_1_summary['Q_upper'] = f_16_1.quantile(q=.80)
f_16_1_summary['Q_lower'] = f_16_1.quantile(q=.20)
#%%
fig, ax = plt.subplots()
x = np.arange(0,100)
ax.plot(x, f_16_1_summary['Factor_1'],label='Estimated')
ax.fill_between(x, f_16_1_summary['Q_upper'], f_16_1_summary['Q_lower'], color='b', alpha=.15, label='80%-20% quantile')
ax.plot(x, factors16['Factor_1'], color='black', label='Actual')
handles, labels = ax.get_legend_handles_labels()
order = [2,0,1]
ax.legend([handles[idx] for idx in order],[labels[idx] for idx in order])
ax.set_xlabel('T')
ax.set_ylabel('Factor Value')
ax.set_title('True vs. Estimated Factor for $K=16$')
#%%
# CAREFUL
# fig.savefig(save_path + 'factor1_16.png')
# %%
def plot_results(est_path, true_path):
    dim = true_path[(true_path.find('_')+1):]
    factors = pd.read_csv(est_path, header=None)
    factor0 = factors.iloc[np.arange(0,factors.shape[0], 2)]
    factor1 = factors.iloc[np.arange(1,factors.shape[0], 2)]
    factor0.reset_index(inplace=True, drop=True)
    factor1.reset_index(inplace=True, drop=True)
    true_factor = pd.read_csv(true_path, header=None).T
    true_factor.columns = ['Factor_0', 'Factor_1']
    factor0_summary = pd.DataFrame(factor0.mean())
    factor0_summary.columns=['Factor_0'] 
    factor0_summary['Q_upper'] = factor0.quantile(q=.80)
    factor0_summary['Q_lower'] = factor0.quantile(q=.20)
    fig, ax = plt.subplots(figsize=(8,6))
    x = np.arange(0,100)
    ax.plot(x, factor0_summary['Factor_0'],label='Estimated')
    ax.fill_between(x, factor0_summary['Q_upper'], factor0_summary['Q_lower'], color='b',
                     alpha=.15, label='80%-20% quantile')
    ax.plot(x, true_factor['Factor_0'], color='black', label='Actual')
    handles, labels = ax.get_legend_handles_labels()
    order = [2,0,1]
    ax.legend([handles[idx] for idx in order],[labels[idx] for idx in order])
    plt.savefig('/home/dillon/gdrivelocal/LatexDocuments/probit/f0_'+str(dim))

    factor1_summary = pd.DataFrame(factor1.mean())
    factor1_summary.columns=['Factor_1'] 
    factor1_summary['Q_upper'] = factor1.quantile(q=.80)
    factor1_summary['Q_lower'] = factor1.quantile(q=.20)
    ax.set_xlabel('T')
    ax.set_ylabel('Factor Value')
    ax.set_title('True vs. Estimated Factor for $K={}$'.format(dim))
    fig, ax = plt.subplots(figsize=(8,6))
    ax.plot(x, factor1_summary['Factor_1'],label='Estimated')
    ax.fill_between(x, factor1_summary['Q_upper'], factor1_summary['Q_lower'], 
                    color='b', alpha=.15, label='80%-20% quantile')
    ax.plot(x, true_factor['Factor_1'], color='black', label='Actual')
    handles, labels = ax.get_legend_handles_labels()
    order = [2,0,1]
    ax.legend([handles[idx] for idx in order],[labels[idx] for idx in order])
    ax.set_xlabel('T')
    ax.set_ylabel('Factor Value')
    ax.set_title('True vs. Estimated Factor for $K={}$'.format(dim))
    plt.savefig('/home/dillon/gdrivelocal/LatexDocuments/probit/f1_'+str(dim))
# %%
plot_results(factor_path + 'factor_8/factors.csv' ,true_path + 'true_8')
# %%
plot_results(factor_path + 'factor_16/factors.csv' ,true_path + 'true_16')
#%%
plot_results(factor_path + 'factor_32/factors.csv' ,true_path + 'true_32')
#%%
plot_results(factor_path + 'factor_64/factors.csv' ,true_path + 'true_64')
# %%
plot_results(factor_path + 'factor_128/factors.csv' ,true_path + 'true_128')

# %%
def hist_plots(path, ParamName, Kname,  SimNum, K, outfile, Q=None):
    param = pd.read_csv(path, header=None)
    param = param.rename({0:ParamName}, axis=1)
    if Q is None:
        index = np.kron(np.ones(SimNum),np.arange(0, K)).astype(int)
    else:
        index = np.kron(np.ones(SimNum),np.arange(0, Q)).astype(int)
    param[Kname] = index 
    plt.figure() 
    ax = sns.histplot(param, x=ParamName, hue=Kname)
    ax.set_title(r'Distribution of $\{}$ for ${}={}$'.format(ParamName, Kname, K))
    ax.set_xlabel(r'$\{}$'.format(ParamName))
    plt.legend([],[], frameon=False)
    plt.savefig(save_path + outfile +'_' +str(K) + '.png')
#%%
hist_plots(factor_path + 'factor_8/beta.csv', 'beta', 'K', 2700, 8, 'beta_dist')
hist_plots(factor_path + 'factor_16/beta.csv', 'beta', 'K', 2700, 16, 'beta_dist')
hist_plots(factor_path + 'factor_32/beta.csv', 'beta', 'K', 2700, 32, 'beta_dist')
hist_plots(factor_path + 'factor_64/beta.csv', 'beta', 'K', 2700, 64, 'beta_dist')
hist_plots(factor_path + 'factor_128/beta.csv', 'beta', 'K', 2700, 128, 'beta_dist')

# %%
hist_plots(factor_path + 'factor_8/gammas.csv', 'gamma', 'K', 2700, 8, 'gamma_dist', Q=2)
hist_plots(factor_path + 'factor_16/gammas.csv', 'gamma', 'K', 2700, 16, 'gamma_dist', Q=2)
hist_plots(factor_path + 'factor_32/gammas.csv', 'gamma', 'K', 2700, 32, 'gamma_dist', Q=2)
hist_plots(factor_path + 'factor_64/gammas.csv', 'gamma', 'K', 2700, 64, 'gamma_dist', Q=2)
hist_plots(factor_path + 'factor_128/gammas.csv', 'gamma', 'K', 2700, 128, 'gamma_dist', Q=2)
# %%

loadings = pd.read_csv(factor_path + 'factor_8/loadings.csv', header=None)
loadings.rename({0:'alpha_1', 1:'alpha_2'}, axis=1, inplace=True)
loadings['K'] = np.kron(np.ones(2700), np.arange(0,8)).astype(int)
#%%
plt.figure() 
ax = sns.histplot(loadings, x='alpha_1', hue='K')
ax.set_title(r'Distribution of $\alpha_1$ for $K=8$')
ax.set_xlabel(r'$\alpha_1$')
plt.legend([],[], frameon=False)
plt.savefig(save_path + 'alpha_1_8' + '.png')

plt.figure() 
ax = sns.histplot(loadings[loadings.K>0], x='alpha_2', hue='K')
ax.set_title(r'Distribution of $\alpha_2$ for $K=8$')
ax.set_xlabel(r'$\alpha_2$')
plt.legend([],[], frameon=False)
plt.savefig(save_path + 'alpha_2_8' + '.png')
# %%
loadings = pd.read_csv(factor_path + 'factor_16/loadings.csv', header=None)
loadings.rename({0:'alpha_1', 1:'alpha_2'}, axis=1, inplace=True)
loadings['K'] = np.kron(np.ones(2700), np.arange(0,16)).astype(int)
#%%
plt.figure() 
ax = sns.histplot(loadings, x='alpha_1', hue='K')
ax.set_title(r'Distribution of $\alpha_1$ for $K=16$')
ax.set_xlabel(r'$\alpha_1$')
plt.legend([],[], frameon=False)
plt.savefig(save_path + 'alpha_1_16' + '.png')

plt.figure() 
ax = sns.histplot(loadings[loadings.K>0], x='alpha_2', hue='K')
ax.set_title(r'Distribution of $\alpha_2$ for $K=16$')
ax.set_xlabel(r'$\alpha_2$')
plt.legend([],[], frameon=False)
plt.savefig(save_path + 'alpha_2_16' + '.png')
# %%
loadings = pd.read_csv(factor_path + 'factor_32/loadings.csv', header=None)
loadings.rename({0:'alpha_1', 1:'alpha_2'}, axis=1, inplace=True)
loadings['K'] = np.kron(np.ones(2700), np.arange(0,32)).astype(int)
#%%
plt.figure() 
ax = sns.histplot(loadings, x='alpha_1', hue='K')
ax.set_title(r'Distribution of $\alpha_1$ for $K=32$')
ax.set_xlabel(r'$\alpha_1$')
plt.legend([],[], frameon=False)
plt.savefig(save_path + 'alpha_1_32' + '.png')

plt.figure() 
ax = sns.histplot(loadings[loadings.K>0], x='alpha_2', hue='K')
ax.set_title(r'Distribution of $\alpha_2$ for $K=32$')
ax.set_xlabel(r'$\alpha_2$')
plt.legend([],[], frameon=False)
plt.savefig(save_path + 'alpha_2_32' + '.png')
# %%
loadings = pd.read_csv(factor_path + 'factor_64/loadings.csv', header=None)
loadings.rename({0:'alpha_1', 1:'alpha_2'}, axis=1, inplace=True)
loadings['K'] = np.kron(np.ones(2700), np.arange(0,64)).astype(int)
#%%
plt.figure() 
ax = sns.histplot(loadings, x='alpha_1', hue='K')
ax.set_title(r'Distribution of $\alpha_1$ for $K=64$')
ax.set_xlabel(r'$\alpha_1$')
plt.legend([],[], frameon=False)
plt.savefig(save_path + 'alpha_1_64' + '.png')

plt.figure() 
ax = sns.histplot(loadings[loadings.K>0], x='alpha_2', hue='K')
ax.set_title(r'Distribution of $\alpha_2$ for $K=64$')
ax.set_xlabel(r'$\alpha_2$')
plt.legend([],[], frameon=False)
plt.savefig(save_path + 'alpha_2_64' + '.png')
# %%
loadings = pd.read_csv(factor_path + 'factor_128/loadings.csv', header=None)
loadings.rename({0:'alpha_1', 1:'alpha_2'}, axis=1, inplace=True)
loadings['K'] = np.kron(np.ones(2700), np.arange(0,128)).astype(int)
#%%
plt.figure() 
ax = sns.histplot(loadings, x='alpha_1', hue='K')
ax.set_title(r'Distribution of $\alpha_1$ for $K=128$')
ax.set_xlabel(r'$\alpha_1$')
plt.legend([],[], frameon=False)
plt.savefig(save_path + 'alpha_1_128' + '.png')

plt.figure() 
ax = sns.histplot(loadings[loadings.K>0], x='alpha_2', hue='K')
ax.set_title(r'Distribution of $\alpha_2$ for $K=128$')
ax.set_xlabel(r'$\alpha_2$')
plt.legend([],[], frameon=False)
plt.savefig(save_path + 'alpha_2_128' + '.png')
# %%

param = pd.read_csv(insample_path + 'beta.csv', header=None)

# %%
nparam = param.to_numpy()
inner_index = np.kron(np.ones(32), np.arange(0,3)).astype(int)
outer_index = np.kron(np.ones(9000), inner_index).astype(int)
Kindex = np.kron(np.ones(9000), np.kron(np.arange(32), np.ones(3))).astype(int)

beta = pd.DataFrame({'beta':nparam.squeeze(), 'p':outer_index, 'K':Kindex})
plt.figure() 
ax = sns.histplot(beta[beta['p']==0], x='beta', hue='p')
ax.set_title(r'Distribution of $\{}$ for $p=$'.format('beta', 0))
ax.set_xlabel(r'$\{}$'.format('beta'))
plt.legend([],[], frameon=False)
# plt.savefig(save_path + outfile +'_' +str(K) + '.png')
# %%
