#%%
from MyMizerEval import *
import os 
from natsort import natsorted
import glob 
import tensorflow as tf
import pickle 
import matplotlib.pyplot as plt 
from sklearn.calibration import calibration_curve
import tensorflow as tf
import tensorflow.keras as keras 
from sklearn.model_selection import ShuffleSplit 
from sklearn.metrics import log_loss
from sklearn.metrics import confusion_matrix
from sklearn.metrics import ConfusionMatrixDisplay
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import f1_score

#%%
d = [] 
rd = natsorted(glob.glob('tenparts_datapartitions/training/partition*'))
for i in rd:
    d.append(pd.read_csv(i))
d = pd.concat(d)
d.to_csv('tenk_insample.csv',index=False)


d = [] 
rd = natsorted(glob.glob('tenparts_rawdata/raw*'))
for i in rd:
    d.append(pd.read_csv(i))
d = pd.concat(d)
d.to_csv('tenk_rawdata.csv', index=False)

# file = '\\\\corp.lan\\Shares\\TradingDesk\\Analytics\\Cronus\\Market\\MarginOptimization\\Model\\tenparts\\ModelCheckpoints\\'
# models = natsorted(glob.glob(file+'Model*'))
# scalers = natsorted(glob.glob(file+'Scaler*'))
# data = pd.read_csv('tenk.csv')
# data['WinBit'] = 1*(~data['WinBoundaryMarginPrice'].isna())
# fig, axs = plt.subplots(5,2, figsize=(8,6))
# fig.tight_layout()
# c = 0
# d= 0
# for i,j in zip(models,scalers):
#     m = tf.keras.models.load_model(i)
#     with open(j, 'rb') as f:
#         s = pickle.load(f)
#     mname = i[i.find('Model_'):]
#     sname = j[j.find('Scaler_'):]
#     results = run_model_from_file('tenk.csv', file, mname, sname)
#     probs = predict_probs(results, data)
#     true, pred= calibration_curve(data['WinBit'], probs['probs'], n_bins=10)
#     if ((c % 5) == 0) and (c != 0):
#         d+=1
#         c=0
#     axs[c, d].plot(pred, true)
#     axs[c,d].plot(true, true )
#     c+=1


model = keras.models.load_model('Model_prod.h5')
with open('Scaler_prod.pkl', 'rb') as f:
    scaler = pickle.load(f)

DATA = pd.read_csv('chunk_2023-06-28_14_55_33.csv')


results = run_model_from_file(DATA, model, scaler)
probs = predict_probs(results, DATA)
true, pred = calibration_curve(probs['WinBit'], probs['probs'], n_bins=10, strategy='uniform')
plt.plot(pred,true)
plt.plot([0,1], [0,1])



with open('testmodel/Scaler.pkl', 'rb') as f:
    scaler = pickle.load(f)
for i in range(10):
    model = keras.models.load_model('testmodel/ModelCheckpoints/Model_{0}.h5'.format(i+1))
    results = run_model_from_file(DATA, model, scaler)
    probs = predict_probs(results, DATA)
    true, pred = calibration_curve(probs['WinBit'], probs['probs'], n_bins=10, strategy='uniform')
    plt.plot(pred,true)
plt.plot([0,1], [0,1])


model = keras.models.load_model('testmodel/Model.h5')
with open('testmodel/Scaler.pkl', 'rb') as f:
    scaler = pickle.load(f)
results = run_model_from_file(DATA, model, scaler)


insamp = pd.read_csv('tenk_insample.csv')
raw = pd.read_csv('tenk_rawdata.csv')
ins = pd.DataFrame(insamp['LookId'])
insample = ins.merge(raw)
insample.to_csv('insample.csv')  
    

results = run_model_from_file(pd.read_csv('insample.csv'), model, scaler)
probs = predict_probs(results, pd.read_csv('insample.csv'))
true, pred = calibration_curve(probs['WinBit'], probs['probs'], n_bins=10, strategy='uniform')
plt.plot(pred,true)
plt.plot([0,1], [0,1])

results = run_model_from_file(pd.read_csv('tenk_rawdata.csv'), model, scaler)
probs = predict_probs(results, pd.read_csv('tenk_rawdata.csv'))
true, pred = calibration_curve(probs['WinBit'], probs['probs'], n_bins=10, strategy='quantile')
plt.plot(pred,true)
plt.plot([0,1], [0,1])


model = keras.models.load_model('production/Model.h5')
with open('production/Scaler.pkl', 'rb') as f:
    scaler = pickle.load(f)

results = run_model_from_file(pd.read_csv('tenk_rawdata.csv'), model, scaler)
probs = predict_probs(results, pd.read_csv('tenk_rawdata.csv'))
true, pred = calibration_curve(probs['WinBit'], probs['probs'], n_bins=10, strategy='quantile')
plt.plot(pred,true)
plt.plot([0,1], [0,1])
# %%
model = keras.models.load_model('testmodel2/Model.h5')
with open('testmodel2/Scaler.pkl', 'rb') as f:
    scaler = pickle.load(f)


dat = pd.read_csv('chunk_2023-06-29_09_05_57.csv')
results = run_model_from_file(dat, model, scaler)
probs = predict_probs(results, dat)
true, pred = calibration_curve(probs['WinBit'], probs['probs'], n_bins=10, strategy='quantile')
plt.plot(pred,true)
plt.plot([0,1], [0,1])


model = keras.models.load_model('testmodel2/Model_prod.h5')
with open('testmodel2/Scaler_prod.pkl', 'rb') as f:
    scaler = pickle.load(f)
dat = pd.read_csv('chunk_2023-06-29_08_54_48.csv')
results = run_model_from_file(dat, model, scaler)
probs = predict_probs(results, dat)
true, pred = calibration_curve(probs['WinBit'], probs['probs'], n_bins=10, strategy='quantile')
plt.plot(pred,true)
plt.plot([0,1], [0,1])

#%%
model_path = '\\\\corp.lan\\Shares\\TradingDesk\\Analytics\\Cronus\\Market\\MarginOptimization\\Model\\model42day\\'
model = keras.models.load_model(model_path+r'\Model.h5')
with open(model_path+'Scaler.pkl', 'rb') as f:
    scaler = pickle.load(f)
dat = pd.read_csv('data42.csv')

results = run_model_from_file(dat, model, scaler)
probs = predict_probs(results, dat)
true, pred = calibration_curve(probs['WinBit'], probs['probs'], n_bins=10, strategy='quantile')
plt.plot(pred,true)
plt.plot([0,1], [0,1])

results[['S', 'M', 'W']].describe()

# %%
model_path = 'z\\'
model = keras.models.load_model(model_path+'Model.h5')
with open(model_path+'Scaler.pkl', 'rb') as f:
    scaler = pickle.load(f)
dat = pd.read_csv(model_path+'data.csv')

results = run_model_from_file(dat, model, scaler)
probs = predict_probs(results, dat)
true, pred = calibration_curve(probs['WinBit'], probs['probs'], n_bins=10, strategy='quantile')
plt.plot(pred,true)
plt.plot([0,1], [0,1])

results[['S', 'M', 'W']].describe()

#%%
model_path = '\\\\corp.lan\\Shares\\TradingDesk\\Analytics\\Cronus\\Market\\MarginOptimization\\Model\\model42\\'
model = keras.models.load_model(model_path+'Model.h5')
with open(model_path+'Scaler.pkl', 'rb') as f:
    scaler = pickle.load(f)
dat = pd.read_csv(model_path+'data.csv')
print(dat.shape)
results = run_model_from_file(dat, model, scaler)
results[['S', 'M', 'W']].describe()
results[['S', 'M', 'W']].hist(bins=50)
probs = predict_probs(results, dat)
true, pred = calibration_curve(probs['WinBit'], probs['probs'], n_bins=10, strategy='uniform')
plt.figure()
plt.plot(pred,true)
plt.plot([0,1], [0,1])


# results.to_csv('tenepochs.csv')
# probs.to_csv('tenepochs_probs.csv')

#%% swaps 

model_path = '\\\\corp.lan\\Shares\\TradingDesk\\Analytics\\Cronus\\Market\\MarginOptimization\\Model\\74592032\\'
model = keras.models.load_model(model_path+'Model.h5')
with open(model_path+'Scaler.pkl', 'rb') as f:
    scaler = pickle.load(f)

dat = pd.read_csv('dataswap.csv')


results = run_model_from_file(dat, model, scaler)
results[['S', 'M', 'W']].describe()
results[['S', 'M', 'W']].hist(bins=50)
probs = predict_probs(results, dat)
true, pred = calibration_curve(probs['WinBit'], probs['probs'], n_bins=20, strategy='quantile')
plt.plot(pred,true)
plt.plot([0,1], [0,1])



# %%
model_path = 'z\\'
model = keras.models.load_model(model_path+'Model.h5')
with open(model_path+'Scaler.pkl', 'rb') as f:
    scaler = pickle.load(f)
dat = pd.read_csv(model_path+'data.csv')
results = run_model_from_file(dat, model, scaler)
results[['S', 'M', 'W']].describe()
results[['S', 'M', 'W']].hist(bins=50)
probs = predict_probs(results, dat)
true, pred = calibration_curve(probs['WinBit'], probs['probs'], n_bins=10, strategy='quantile')
plt.plot(pred,true)
plt.plot([0,1], [0,1])
# %%
model_path = ''
model = keras.models.load_model(model_path+'Model.h5')
with open(model_path+'Scaler.pkl', 'rb') as f:
    scaler = pickle.load(f)
dat = pd.read_csv('z\\'+'data.csv')
results = run_model_from_file(dat, model, scaler)
results[['S', 'M', 'W']].describe()
results[['S', 'M', 'W']].hist(bins=50)
probs = predict_probs(results, dat)
true, pred = calibration_curve(probs['WinBit'], probs['probs'], n_bins=10, strategy='quantile')
plt.plot(pred,true)
plt.plot([0,1], [0,1])

#%%
model_path = '\\\\corp.lan\\Shares\\TradingDesk\\Analytics\\Cronus\\Market\\MarginOptimization\\Model\\model42\\ModelCheckpoints\\'
model = keras.models.load_model(model_path+'Model_1.h5')

scaler_path = 'mod42\\'
with open(scaler_path+'Scaler_prod.pkl', 'rb') as f:
    scaler = pickle.load(f)

dat = pd.read_csv(scaler_path+'data.csv')


results = run_model_from_file(dat, model, scaler)
results[['S', 'M', 'W']].describe()
results[['S', 'M', 'W']].hist(bins=50)
probs = predict_probs(results, dat)
true, pred = calibration_curve(probs['WinBit'], probs['probs'], n_bins=20, strategy='quantile')
plt.plot(pred,true)
plt.plot([0,1], [0,1])
#%%
import seaborn as sns 
import pandas as pd 

dat = pd.read_csv('data42.csv')
dat.describe()


sname = pd.DataFrame(dat['SellerName'].value_counts())[0:25]
sns.barplot(data=sname, x=sname['SellerName'], y=sname.index)

pd.set_option('display.max_columns', None)
dat.select_dtypes(exclude='object').describe().round(2).T
dat.select_dtypes(include='object').columns

sname = pd.DataFrame(dat['PropTypeName'].value_counts())[0:25]
sns.barplot(data=sname, x=sname['PropTypeName'], y=sname.index)

sname = pd.DataFrame(dat['PropUsageTypeName'].value_counts())
sns.barplot(data=sname, x=sname['PropUsageTypeName'], y=sname.index)


sname = pd.DataFrame(dat['MtgTypeName'].value_counts())
sns.barplot(data=sname, x=sname['MtgTypeName'], y=sname.index)

sname = pd.DataFrame(dat['LoanPurposeTypeName'].value_counts())
sns.barplot(data=sname, x=sname['LoanPurposeTypeName'], y=sname.index)

sname = pd.DataFrame(dat['DocumentationTypeName'].value_counts())
sns.barplot(data=sname, x=sname['DocumentationTypeName'], y=sname.index)

sname = pd.DataFrame(dat['AusTypeName'].value_counts())
sns.barplot(data=sname, x=sname['AusTypeName'], y=sname.index)

sname = pd.DataFrame(dat['PropStateCd'].value_counts())[0:25]
sns.barplot(data=sname, x=sname['PropStateCd'], y=sname.index)

sname = pd.DataFrame(dat['PropStateCd'].value_counts())[25:50]
sns.barplot(data=sname, x=sname['PropStateCd'], y=sname.index)

sname = pd.DataFrame(dat['RefiTypeName'].value_counts())
sns.barplot(data=sname, x=sname['RefiTypeName'], y=sname.index)

sname = pd.DataFrame(dat['RefiProgTypeName'].value_counts())
sns.barplot(data=sname, x=sname['RefiProgTypeName'], y=sname.index)


sname = pd.DataFrame(dat['UnderwritingProgName'].value_counts())
sns.barplot(data=sname, x=sname['UnderwritingProgName'], y=sname.index)

sname = pd.DataFrame(dat['BorrowerIncomeTypeName'].value_counts())
sns.barplot(data=sname, x=sname['BorrowerIncomeTypeName'], y=sname.index)

sname = pd.DataFrame(dat['CensusTractMinorityTypeName'].value_counts())
sns.barplot(data=sname, x=sname['CensusTractMinorityTypeName'], y=sname.index)


sname = pd.DataFrame(dat['ExecInvestorName'].value_counts())
sns.barplot(data=sname, x=sname['ExecInvestorName'], y=sname.index)


sname = pd.DataFrame(dat['ExecMethodName'].value_counts())
sns.barplot(data=sname, x=sname['ExecMethodName'], y=sname.index)


sname = pd.DataFrame(dat['ProdCd'].value_counts())
sns.barplot(data=sname, x=sname['ProdCd'], y=sname.index)

sname = pd.DataFrame(dat['SpecName'].value_counts())
sns.barplot(data=sname, x=sname['SpecName'], y=sname.index)

# %%

model_path = 'harsh\\'
model = keras.models.load_model(model_path+'Model.h5')

with open(model_path+'Scaler.pkl', 'rb') as f:
    scaler = pickle.load(f)

dat = pd.read_csv(model_path+'test_data.csv')
results = run_model_from_file(dat, model, scaler)
results[['S', 'M', 'W']].describe()
results[['S', 'M', 'W']].hist(bins=50)
probs = predict_probs(results, dat)
true, pred = calibration_curve(probs['WinBit'], probs['probs'], n_bins=20, strategy='quantile')
plt.plot(pred,true)
plt.plot([0,1], [0,1])

#%%
model_path = 'harsh_other\\'
model = keras.models.load_model(model_path+'Model.h5')

with open(model_path+'Scaler.pkl', 'rb') as f:
    scaler = pickle.load(f)
dat = pd.read_csv('harsh\\'+'test_data.csv')
results = run_model_from_file(dat, model, scaler)
results[['S', 'M', 'W']].describe()
results[['S', 'M', 'W']].hist(bins=50)
probs = predict_probs(results, dat)
true, pred = calibration_curve(probs['WinBit'], probs['probs'], n_bins=20, strategy='uniform')
plt.plot(pred,true)
plt.plot([0,1], [0,1])

#%%
model_path = 'harsh_y\\'
model = keras.models.load_model(model_path+'Model.h5')

with open(model_path+'Scaler.pkl', 'rb') as f:
    scaler = pickle.load(f)
dat = pd.read_csv(model_path+'test_data.csv')
results = run_model_from_file(dat, model, scaler)
results[['S', 'M', 'W']].describe()
results[['S', 'M', 'W']].hist(bins=50)
probs = predict_probs(results, dat)
true, pred = calibration_curve(probs['WinBit'], probs['probs'], n_bins=10, strategy='uniform')
plt.plot(pred,true)
plt.plot([0,1], [0,1])

#%% 
model_path = 'mmod\\'
model = keras.models.load_model(model_path+'Model.h5')

with open(model_path+'Scaler.pkl', 'rb') as f:
    scaler = pickle.load(f)
    
data = pd.read_csv('data42.csv', nrows=10000) 
results = run_model_from_file(data, model, scaler)
cv = cross_validate(model, scaler, data, 1000, 10, 1)
fig, ax = plt.subplots(1,1)
ax.scatter(x=np.arange(cv.shape[0]), y = cv['LL']) 
ax.plot(np.arange(cv.shape[0]), cv['LL'], label='Log Loss')
ax.axhline(y=cv.mean()[0], color='red', label='Mean Log Loss')
ax.legend(loc='upper right')
ax.set_title('Log loss per fold')
ax.set_xlabel('Fold number')
ax.set_ylabel('Log loss')

#%%
model_path = 'prod\\'
model = keras.models.load_model(model_path+'Model.h5')

with open(model_path+'Scaler.pkl', 'rb') as f:
    scaler = pickle.load(f)
    
data = pd.read_csv('insample_data.csv', nrows=1000) 
results = run_model_from_file(data, model, scaler)
cv = cross_validate(model, scaler, data, 300, 5, 1)
fig, ax = plt.subplots(1,1)
ax.scatter(x=np.arange(cv.shape[0]), y = cv['LL']) 
ax.plot(np.arange(cv.shape[0]), cv['LL'], label='Log Loss')
ax.axhline(y=cv.mean()[0], color='red', label='Mean Log Loss')
ax.legend(loc='upper right')
ax.set_title('Log loss per fold')
ax.set_xlabel('Fold number')
ax.set_ylabel('Log loss')


# %%

def analyze_logit(model_path, insample_file, outofsample_file, plot_names):
    with open(model_path+'Model.pkl', 'rb') as f:
        model = pickle.load(f)
    with open(model_path+'feature_names_in.pkl', 'rb') as f:
        names = pickle.load(f)
    data_insample = pd.read_csv(insample_file)
    data_outofsample = pd.read_csv(outofsample_file)
    # Cross Validation Graphs
    cv = logit_cross_validate(model, names, data_outofsample, 10000, 15, plot=1, name=plot_names)
    # Log Loss Graphs
    fig, ax = plt.subplots(1,1)
    ax.scatter(x=np.arange(cv.shape[0]), y = cv['f1']) 
    ax.plot(np.arange(cv.shape[0]), cv['f1'], label='F1 score')
    ax.axhline(y=cv['f1'].mean(), color='red', label='Mean F1')
    ax.legend(loc='upper right')
    ax.set_title('Log loss per fold\n{0}'.format(plot_names))
    ax.set_xlabel('Fold number')
    ax.set_ylabel('Log loss')
    
    results_insample = run_logit(data_insample, model, names)
    results_outofsample = run_logit(data_outofsample, model, names)
    print(results_insample)
    random_classifier = np.random.uniform(0,1, results_outofsample.shape[0])
    always_zero_classifier = np.zeros(results_outofsample.shape[0])
    bce = keras.metrics.BinaryCrossentropy() 
    acc = keras.metrics.BinaryAccuracy()
    cmd = ConfusionMatrixDisplay(confusion_matrix(results_outofsample['WinBit'], 1*(random_classifier>.5)))
    cmd.plot() 
    plt.grid(None) 
    randomll = bce(results_outofsample['WinBit'], random_classifier).numpy()
    plt.title('{name}\nRandom Classifier (LL {:.2f})'.format(randomll, name=plot_names))
    cmd = ConfusionMatrixDisplay(confusion_matrix(results_outofsample['WinBit'], always_zero_classifier))
    cmd.plot() 
    plt.grid(None) 
    zero_acc = acc(results_outofsample['WinBit'], always_zero_classifier)
    plt.title('{name}\nAlways Zero (Acc {:.2f})'.format(zero_acc, name=plot_names))
    
    cmd = ConfusionMatrixDisplay(confusion_matrix(results_insample['WinBit'], 1*(results_insample['probs']>.5)))
    cmd.plot() 
    plt.grid(None) 
    plt.title('{0}\nIn sample'.format(plot_names))
    cmd = ConfusionMatrixDisplay(confusion_matrix(results_outofsample['WinBit'], 1*(results_outofsample['probs']>.5)))
    cmd.plot() 
    plt.grid(None)
    plt.title('{0}\nOut of sample'.format(plot_names))
    # Calibration Curves
    true, pred = calibration_curve(results_insample['WinBit'], results_insample['probs'], n_bins=10, strategy='uniform')
    insample_f1 = f1_score(results_insample['WinBit'], 1*(results_insample['probs']>.5))
    fig,ax = plt.subplots(1,1)
    ax.plot(pred,true, label='In sample (F1 {:.2f})'.format(insample_f1))
    true, pred = calibration_curve(results_outofsample['WinBit'], results_outofsample['probs'], n_bins=10, strategy='uniform')
    outf1 = f1_score(results_outofsample['WinBit'], 1*(results_outofsample['probs']>.5))
    ax.plot(pred,true, label='Out of sample (F1 {:.2f})'.format(outf1))
    ax.plot([0,1], [0,1], label='Perfectly calibrated model')
    ax.legend(loc='upper left')
    ax.set_title('{0} calibration curve'.format(plot_names))
    ax.set_xlabel('Predicted')
    ax.set_ylabel('Actual')
    fig, ax = plt.subplots(1,1)
    ax.bar([.25,.5], height=[cv['recall'].mean(), cv['precision'].mean()], 
           width=.25, label=['Recall', 'Precision'], tick_label=['Recall', 'Precision'],
           color=['red', 'green'], alpha=.65)
    ax.set_title('Mean Recall / Mean Precsion')
    ax.grid(None)
    return cv
#%%
