#%%
from sqlaction import SQLAction
import pickle 
import pandas as pd 
from mizerHelper import knn_imputation
import numpy as np
import tensorflow as tf
from tensorflow import keras
from sklearn.calibration import calibration_curve
import matplotlib.pyplot as plt 
import sys
from sklearn.metrics import f1_score


def short_load_model_features(data, scaler):
    print('Number of columns included: ' + f"{data.shape[1]:,}", flush=True)
    x = data.copy() 
    x = pd.get_dummies(x)
    print('Adding features in training but not in eval...', flush =  True)
    train_cat_features = [feat for feat in list(scaler.feature_names_in_) if feat[-1]!='_']

    for feature in train_cat_features:
        if(feature not in x.columns):
            x[feature] = 0
    x = x[scaler.feature_names_in_]
    x = knn_imputation(x)
    return x

def short_load_logit_features(data, names):
    print('Number of columns included: ' + f"{data.shape[1]:,}", flush=True)
    x = data.copy() 
    x = pd.get_dummies(x)
    print('Adding features in training but not in eval...', flush =  True)
    train_cat_features = [feat for feat in list(names) if feat[-1]!='_']

    for feature in train_cat_features:
        if(feature not in x.columns):
            x[feature] = 0
    x = x[names]
    x = knn_imputation(x)
    return x

def load_model_features(data, model_path, scaler):
    """
    Handles the categorical features in following ways:
        1. Remove the features not in training.
        2. Add the feature values not seen before as NewData.
        3. Add the features from the training set that are missing in the eval set.
        4. Perform KNN imputation on the missing continuous features.

    Parameters:
        Look Level Features
    Returns:
        Dataframe that has all the right features.
    """

    eval_data_col = data.columns.to_list()

    try:
        eval_data_col.remove('LookId')
    except ValueError:
        pass

    training_data_col = set([val.split('_')[0] for val in list(scaler.feature_names_in_)])
    drop_cols = list(set(eval_data_col) - set(training_data_col))

    if(bool(drop_cols)):
        data.drop(columns = drop_cols, inplace = True, errors=False)
        print('Removing the features not in training: ', str(drop_cols).strip('[]'), flush=True)

    print('Number of columns included: ' + f"{data.shape[1]:,}", flush=True)
    categorical_features_model = data.select_dtypes(include=['object']).columns.to_list()
    categorical_data = pd.get_dummies(data, columns=categorical_features_model)

    blank_columns = []
    for feat in categorical_data.columns:
        if(feat[-1] == "_"):
            blank_columns.append(feat)

    print('Removing magic value OHE features: ' + str(blank_columns).strip('[]'), flush =  True)
    categorical_data.drop(columns = blank_columns, inplace = True)

    print('Adding features in trainign but not in eval...', flush =  True)
    train_cat_features = [feat for feat in list(scaler.feature_names_in_) if feat[-1]!='_']

    # print('Adding features in trainign but not in eval: ' + str(train_cat_features).strip('[]'), flush =  True)
    for feature in train_cat_features:
        if(feature not in categorical_data.columns):
            categorical_data[feature] = 0
            
    data.drop(columns=categorical_features_model, inplace=True, errors=False)
    data = data.merge(categorical_data)

    data = knn_imputation(data)
        
    return data

def run_model(args ,proc ):
    """
    Loads the input data and runs the model.

    Parameters:
        args - includes outputid, server and database info.
        proc - action proc name.

    Returns:
        Model results.

    """

    print('Loading data...', flush=True)
    data = SQLAction(args, proc, 'GetLooks')
    # data = pd.read_csv('tenk_rawdata.csv')
    print('Number of looks loaded: ' + f"{data.shape[0]:,}", flush=True)
    data_copy = data.copy()
    print('Loading Model...', flush=True)
    
    model_path = SQLAction(args, proc, 'GetEvalParams')['ModelPath'][0]+'\\'
    # model_path = 'production\\'

    model = tf.keras.models.load_model(model_path+'Model.h5', compile=False)

    print('Loading Scaler...', flush=True)
    scaler_path = model_path+'Scaler.pkl'
    with open(scaler_path, 'rb') as f:
        scaler = pickle.load(f)

    print('Loading model features...', flush=True)

    features = load_model_features(data, model_path, scaler)
  
    print('Normalizing data...', flush=True)
    
    features = features[scaler.feature_names_in_]
    print('Number of features included: ' + f"{features.shape[1]:,}", flush=True)
    features = scaler.transform(features)
    features = np.asarray(features).astype(np.float32)
    print('Predicting S/M/W...', flush=True)
    
    S = tf.keras.backend.function([model.layers[0].input], [
            model.get_layer('S').output])([features])[0]
    try:
        M = tf.keras.backend.function([model.layers[0].input], [
                model.get_layer('M').output])([features])[0]
    except ValueError:
        M = tf.keras.backend.function([model.layers[0].input], [
        model.get_layer('M').output])([features])[0]
    W = tf.keras.backend.function([model.layers[0].input], [
            model.get_layer('W').output])([features])[0]


    results = pd.DataFrame({'LookId':data['LookId'],
                            'S':np.ravel(S),
                            'dM':np.ravel(M),
                            'W':np.ravel(W)})
    results['M'] = results['dM'] + data_copy['BenchMarginPrice']

    return results

def run_model_from_file(data, model, scaler ):
    """
    Loads the input data and runs the model.

    Parameters:
        args - includes outputid, server and database info.
        proc - action proc name.

    Returns:
        Model results.

    """
    print('Loading model features...', flush=True)
    features = short_load_model_features(data, scaler)

    print('Normalizing data...', flush=True)
    features = features[scaler.feature_names_in_]
    
    print('Number of features included: ' + f"{features.shape[1]:,}", flush=True)
    features = scaler.transform(features)
    features = np.asarray(features).astype(np.float32)

    print('Predicting S/M/W...', flush=True)
    
    S = tf.keras.backend.function([model.layers[0].input], [
            model.get_layer('S').output])([features])[0]
    try:
        M = tf.keras.backend.function([model.layers[0].input], [
                model.get_layer('dM').output])([features])[0]
    except ValueError:
        M = tf.keras.backend.function([model.layers[0].input], [
        model.get_layer('M').output])([features])[0]
        
    W = tf.keras.backend.function([model.layers[0].input], [
            model.get_layer('W').output])([features])[0]
    
    results = pd.DataFrame({'LookId':data['LookId'],
                            'S':np.ravel(S),
                            'M':np.ravel(M),
                            'W':np.ravel(W)})
    results['M'] = results['M'] + data['BenchMarginPrice']
    
    results['probs'] = model.predict([features, data['MarginPrice'], data['BenchMarginPrice'], np.ones(data.shape[0])])
    results['WinBit'] = 0
    results.loc[~data['WinBoundaryMarginPrice'].isna(), 'WinBit'] = 1
    return results

def run_other_models(data, model, scaler):
    
    print('Loading model features...', flush=True)
    features = short_load_model_features(data, scaler)

    print('Normalizing data...', flush=True)
    features = features[scaler.feature_names_in_]
    
    print('Number of features included: ' + f"{features.shape[1]:,}", flush=True)
    features = scaler.transform(features)
    features = np.asarray(features).astype(np.float32)
    results=pd.DataFrame({'LoodId':data['LookId']})
    results['probs'] = model.predict(features)
    results['WinBit'] = 0
    results.loc[~data['WinBoundaryMarginPrice'].isna(),'WinBit']=1
    return results
    
    
def predict_probs(results, data):
    x = pd.DataFrame() 
    x['MarginPrice'] = data['WinBoundaryMarginPrice'].fillna(0) + data['LossBoundaryMarginPrice'].fillna(0)
    x['eS'] = np.exp(results['S'])
    x['W'] = results['W']
    try:
        x['M'] = results['dM']
    except KeyError:
        x['M'] = results['M']
    x['S'] = results['S']
    x['fac'] = 8*x['eS']*(x['MarginPrice'] - results['M'] )
    x.loc[x['fac'] > 120, 'probs'] = 0
    x.loc[x['fac'] < -120, 'probs'] = 1
    den1 = 1+ np.exp(-x.loc[(x['fac']<120)&(x['fac']>-120), 'W'])
    den2 = 1+np.exp(x.loc[(x['fac']<120)&(x['fac']>-120), 'fac'])
    x.loc[(x['fac']<120)&(x['fac']>-120), 'probs'] = 1./ (den1*den2)
    x['WinBit'] = 0
    x.loc[~data['WinBoundaryMarginPrice'].isna(), 'WinBit'] = 1
    return x 
    
def my_log_loss(trues, preds):
    newpreds = []
    eps = sys.float_info.epsilon 
    for i in preds:
        newpreds.append(max(eps, min(1-eps,i)))
    newpreds = np.array(newpreds)
    return -((trues*np.log(newpreds)) + ((1- trues)*np.log(1-newpreds))).sum()/len(trues)

def cross_validate(model, scaler, data, sample_size, splits=5, plot=0, name=None):
    cv = {'Loss':[], 'LL':[], 'precision':[], 'recall':[], 'f1':[]}
    features = short_load_model_features(data, scaler)
    features = features[scaler.feature_names_in_]
    features = scaler.transform(features)
    features = np.asarray(features).astype(np.float32)
    indices = np.arange(data.shape[0])
    bce = keras.metrics.BinaryCrossentropy()
    precision = keras.metrics.Precision()
    recall = keras.metrics.Recall()
    for i in range(splits):
        tindex = np.random.choice(indices, size=sample_size)
        tdata = data.iloc[tindex]

        results = run_model_from_file(tdata, model, scaler)
        trues = results['WinBit']
        preds = results['probs']
        bce.update_state(trues, preds)
        precision.update_state(trues,preds)
        recall.update_state(trues,preds)
        cv['Loss'].append(bce.result().numpy())
        cv['precision'].append(precision.result().numpy())
        cv['recall'].append(recall.result().numpy())
        cv['LL'].append(my_log_loss(trues, preds))
        cv['f1'].append(f1_score(trues, 1*(preds>.5)))
        if plot == 1:
            ctrue, cpred = calibration_curve(trues, preds, n_bins=10, strategy='uniform')
            plt.plot(cpred, ctrue)
            if name is not None:
                plt.title('Cross validation calibration curve\n {0}'.format(name))
            else:
                plt.title('Cross validation calibration curve\nUsing out of sample data')
            plt.xlabel('Predicted Probability')
            plt.ylabel('Actual Probability')
    if plot == 1:
        plt.plot([0,1], [0,1])
    return pd.DataFrame(cv)  

def other_cross_validate(model, scaler, data, sample_size, splits=5, plot=0, name=None):
    cv = {'Loss':[], 'LL':[], 'precision':[], 'recall':[], 'f1':[]}
    data['MarginPrice'] = data['WinBoundaryMarginPrice'].fillna(0) + data['LossBoundaryMarginPrice'].fillna(0)
    features = short_load_model_features(data, scaler)
    features = features[scaler.feature_names_in_]
    features = scaler.transform(features)
    features = np.asarray(features).astype(np.float32)
    indices = np.arange(data.shape[0])
    bce = keras.metrics.BinaryCrossentropy()
    precision = keras.metrics.Precision()
    recall = keras.metrics.Recall()
    for i in range(splits):
        tindex = np.random.choice(indices, size=sample_size)
        tdata = data.iloc[tindex]
        results = run_other_models(tdata, model, scaler)
        trues = results['WinBit']
        preds = results['probs']
        bce.update_state(trues, preds)
        precision.update_state(trues,preds)
        recall.update_state(trues,preds)
        cv['Loss'].append(bce.result().numpy())
        cv['LL'].append(my_log_loss(trues, preds))
        cv['precision'].append(precision.result().numpy())
        cv['recall'].append(recall.result().numpy())
        cv['f1'].append(f1_score(trues, 1*(preds>.5)))
        if plot == 1:
            ctrue, cpred = calibration_curve(trues, preds, n_bins=10, strategy='uniform')
            plt.plot(cpred, ctrue)
            if name is not None:
                plt.title('Cross validation calibration curve\n {0}'.format(name))
            else:
                plt.title('Cross validation calibration curve')
            plt.xlabel('Predicted Probability')
            plt.ylabel('Actual Probability')
    if plot == 1:
        plt.plot([0,1], [0,1])
    return pd.DataFrame(cv)  

def run_logit(data, model, names):
    features = short_load_logit_features(data, names)
    results = pd.DataFrame({'probs':[], 'WinBit':[]})
    results['probs'] = model.predict_proba(features)[:,1]
    results['WinBit'] = np.zeros(features.shape[0]).astype(int)
    results.loc[(~data['WinBoundaryMarginPrice'].isna()).values,'WinBit']=1 
    return results
  
def logit_cross_validate(model, names, data, sample_size, splits=5, plot=0, name=None):
    cv = {'Loss':[], 'LL':[], 'precision':[], 'recall':[]}
    data['MarginPrice'] = data['WinBoundaryMarginPrice'].fillna(0) + data['LossBoundaryMarginPrice'].fillna(0)
    indices = np.arange(data.shape[0])
    bce = keras.metrics.BinaryCrossentropy()
    precision = keras.metrics.Precision()
    recall = keras.metrics.Recall()
    for i in range(splits):
        results = pd.DataFrame({'WinBit':[], 'probs':[]})
        tindex = np.random.choice(indices, size=sample_size)
        tdata = data.iloc[tindex]
        features = short_load_logit_features(tdata, names)
        results['probs'] = model.predict_proba(features)[:,1]
        results['WinBit'] = np.zeros(features.shape[0]).astype(int)
        results.loc[(~tdata['WinBoundaryMarginPrice'].isna()).values,'WinBit']=1 
        true = results['WinBit']
        pred = results['probs']
        bce.update_state(true, pred)
        precision.update_state(true,1*(pred>.5))
        recall.update_state(true,1*(pred>.5))
        cv['Loss'].append(bce.result().numpy())
        cv['LL'].append(my_log_loss(true, pred))
        cv['precision'].append(precision.result().numpy())
        cv['recall'].append(recall.result().numpy())
        if plot == 1:
            ctrue, cpred = calibration_curve(true, pred, n_bins=10, strategy='uniform')
            plt.plot(cpred, ctrue)
            if name is not None:
                plt.title('Cross validation calibration curve\n {0}'.format(name))
            else:
                plt.title('Cross validation calibration curve')
            plt.xlabel('Predicted Probability')
            plt.ylabel('Actual Probability')
    if plot == 1:
        plt.plot([0,1], [0,1])
    return pd.DataFrame(cv)  
  
    
    
#%%
if __name__=='__main__':

    pass 
    
    
    
    
    

# %%
