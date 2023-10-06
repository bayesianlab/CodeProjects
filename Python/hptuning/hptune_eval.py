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

def analyze(model_path, insample_file, outofsample_file, plot_names):
    model = keras.models.load_model(model_path+'Model.h5')
    with open(model_path+'Scaler.pkl', 'rb') as f:
        scaler = pickle.load(f)
    data_insample = pd.read_csv(insample_file)
    data_outofsample = pd.read_csv(outofsample_file)
    # Cross Validation Graphs
    try:
        cv = cross_validate(model, scaler, data_outofsample, 10000, 15, plot=1, name=plot_names)
    except:
        cv = other_cross_validate(model, scaler, data_outofsample, 10000, 15, plot=1, name=plot_names)
    # Log Loss Graphs
    fig, ax = plt.subplots(1,1)
    ax.scatter(x=np.arange(cv.shape[0]), y = cv['f1']) 
    ax.plot(np.arange(cv.shape[0]), cv['f1'], label='Model K-fold F1')
    ax.axhline(y=cv['f1'].mean(), color='red', label='Model Mean F1')
    ax.set_title('Log loss per fold\n{0}'.format(plot_names))
    ax.set_xlabel('Fold number')
    ax.set_ylabel('Log loss')
    try:
        results_insample = run_model_from_file(data_insample, model, scaler)
        results_outofsample = run_model_from_file(data_outofsample, model, scaler)
        results_insample[['S', 'M', 'W']].describe()
        results_insample[['S', 'M', 'W']].hist(bins=50)
        results_outofsample[['S', 'M', 'W']].describe()
        results_outofsample[['S', 'M', 'W']].hist(bins=50)
    except:
        results_insample = run_other_models(data_insample, model, scaler)
        results_outofsample = run_other_models(data_outofsample, model, scaler)
    random_classifier = np.random.uniform(0,1, results_outofsample.shape[0])
    always_zero_classifier = np.zeros(results_outofsample.shape[0])
    acc = keras.metrics.BinaryAccuracy()
    cmd = ConfusionMatrixDisplay(confusion_matrix(results_outofsample['WinBit'], 1*(random_classifier>.5)))
    cmd.plot() 
    plt.grid(None) 
    random_f1 = f1_score(results_outofsample['WinBit'], 1*(random_classifier>.5))
    ax.axhline(y=random_f1, color='black', label='Random F1')
    plt.title('{name}\nRandom Classifier (F1 {:.2f})'.format(random_f1, name=plot_names))
    cmd = ConfusionMatrixDisplay(confusion_matrix(results_outofsample['WinBit'], always_zero_classifier))
    cmd.plot() 
    plt.grid(None) 
    zero_acc = acc(results_outofsample['WinBit'], always_zero_classifier)
    plt.title('{name}\nAlways Zero (Acc {:.2f})'.format(zero_acc, name=plot_names))
    ax.legend(loc='upper right')

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
    bars=  ax.bar([.25,.5, .75], height=[np.round(cv['recall'].mean(),2), np.round(cv['precision'].mean(),2),
                                         np.round(cv['f1'].mean(),2)], 
           width=.25, label=['Recall', 'Precision', 'F1'], tick_label=['Recall', 'Precision', 'F1'],
           color=['red', 'green', 'black'], alpha=.55)
    ax.bar_label(bars)
    ax.set_title('Mean Recall / Mean Precsion / Mean F1\nOut of sample K-fold')
    ax.grid(None)
    return cv

#%%

# analyze_logit('logit\\', 'insample_small.csv', 'outofsample.csv', 'Logit')

#%%
ranking = {'ModelName':['P-75933337','Production','Wide-Sigmoid','Wide-Deep-Sigmoid',
                        'Wide-Deep-Concat-Dropout', 'Wide-Relu', 'Wide-Deep-Dropout-Sigmoid',
                        'Narrow-Relu','Narrow-Deep-Relu', 'Wide-Deep-Relu']}
ranking = pd.DataFrame(index=ranking['ModelName'])
ranking['F1'] = 0

#%%

cv = analyze("75933337\\", 'insample_small.csv', 'outofsample.csv', 'Production-75933337')
ranking.loc['P-75933337', 'F1']=cv.mean()['f1']
ranking

#%%
cv = analyze("production\\", 'insample_small.csv', 'outofsample.csv', 'Production')
ranking.loc['Production', 'F1']=cv.mean()['f1']
ranking

# %%
cv = analyze('wide\\', 'insample_small.csv', 'outofsample.csv', 'Wide Sigmoid')
ranking.loc['Wide-Sigmoid', 'F1']=cv.mean()['f1']
ranking

# %%
cv = analyze('wide_deep_sigmoid\\', 'insample_small.csv', 'outofsample.csv', 'Wide Deep Sigmoid')
ranking.loc['Wide-Deep-Sigmoid', 'F1']=cv.mean()['f1']
ranking

# %%
cv = analyze('concat\\', 'insample_small.csv', 'outofsample.csv', 'Wide Deep Concat Dropout')
ranking.loc['Wide-Deep-Concat-Dropout', 'F1']=cv.mean()['f1']
ranking

#%%
cv = analyze('wide_relu\\', 'insample_small.csv', 'outofsample.csv', 'Wide Relu (L2 Regulizer)')
ranking.loc['Wide-Relu', 'F1']=cv.mean()['f1']
ranking

# %%
cv = analyze('wide_deep_sigmoid_dropout\\', 'insample_small.csv', 'outofsample.csv', 'Wide Deep Dropout Sigmoid')
ranking.loc['Wide-Deep-Dropout-Sigmoid', 'F1']=cv.mean()['f1']
ranking

# %%
cv = analyze('narrow\\', 'insample_small.csv', 'outofsample.csv', 'Narrow Relu')
ranking.loc['Narrow-Relu', 'F1']=cv.mean()['f1']
ranking
#%%
cv = analyze('narrow_deep\\', 'insample_small.csv', 'outofsample.csv', 'Narrow Deep Relu')
ranking.loc['Narrow-Deep-Relu', 'F1']=cv.mean()['f1']
ranking

# %%
cv = analyze('wide_relu\\', 'insample_small.csv', 'outofsample.csv', 'Wide Deep Relu (L2 Regulizer)')
ranking.loc['Wide-Deep-Relu', 'F1']=cv.mean()['f1']
ranking

# %%


