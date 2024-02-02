# %%
import time
import pathlib
import sys
import getopt
from pdHelper import execQuery
import os
from keras.models import load_model
from pdHelper import selectData
import socket
import threading
from timeit import repeat
import keras
from keras import backend as K
import tensorflow as tf
import pandas as pd
import numpy as np
import warnings
import pickle
from mizerHelper import knn_imputation
from sklearn.metrics import log_loss
warnings.filterwarnings('ignore')
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'
warnings.filterwarnings('ignore')
tf.get_logger().setLevel('INFO')

def prob(x, s,m,w):
    return (1./(1+np.exp(-w))) * (1./(1+np.exp(8*np.exp(s)*(x - m) )))

# %%
def SQLAction(args, proc, action_type, addtl=None):
    """
    Loads input and push output to SQL.

    Parameters:
        args - includes outputid, server and database info.
        proc - action proc name.
        action_type - type of action to be performed in SQL.

    Returns:
        Dataframe with data or nothing depending on the action_type.
    """

    if action_type == 'EvalSuccess':
        query = 'exec ' + proc + ' @ActionType = ' + action_type + ', @OutputId = ' + \
            str(args[3]) + ', @EvalResultJson = ' + "'" + addtl + "'"
        execQuery(query, server=args[1], database=args[2])
        return

    elif action_type == 'EvalFail':
        query = 'exec ' + proc + ' @ActionType = ' + action_type + ', @OutputId = ' + \
            str(args[3]) + ', @ErrMsgTxt = ' + "'" + addtl + "'"
        execQuery(query, server=args[1], database=args[2])
        return

    elif len(args) == 4:
        query = 'exec ' + proc + ' @ActionType = ' + \
            action_type + ', @OutputId = ' + str(args[3])
        data_table = selectData(query, server=args[1], database=args[2])

    elif addtl is not None:
        if len(args) == len(addtl) + 4:
            query = 'exec ' + proc + ' @ActionType = ' + \
                action_type + ', @OutputId = ' + str(args[3])
            i = 4
            for field in addtl:
                query = query + ', @' + field + ' = ' + str(args[i])
                i = i + 1
            data_table = selectData(query, server=args[1], database=args[2])

    return data_table

def push_output(args, proc, results):
    """
    Pushes the model output to SQL in the Json format.

    Parameters:
        args: The arguments that we receive from the eval file
        proc: The Action Proc to receive the input data
        results: The final result dataframe

    Returns:
        Look, S and M in the Json format.

    """
    SQLAction(args, proc, 'EvalSuccess', results.to_json(orient='records'))

    return

def load_model_features(data, scaler):
    """
    Handles the categorical features in following ways:
        1. Remove the features not in training.
        2. Add the feature values not seen before as NewData.
        3. Add the features from the training set that are missing in the eval set.
        4. Perform KNN imputation on the missing continuous features.

    Parameters:
        data: The dataframe containing the look level features
        model_path: The path where the model is stored
        scaler: The objec which has been used to normalize training data
    Returns:
        Dataframe that has all the right features.
    """

    eval_data_col = data.columns.to_list()
    try:
        eval_data_col.remove('LookId')
    except ValueError:
        pass
    training_data_col = set([val.split('_')[0]
                            for val in list(scaler.feature_names_in_)])
    drop_cols = list(set(eval_data_col) - set(training_data_col))
    if (bool(drop_cols)):
        data.drop(columns=drop_cols, inplace=True, errors=False)
    categorical_features_model = data.select_dtypes(
        include=['object']).columns.to_list()
    categorical_data = pd.get_dummies(data, columns=categorical_features_model)

    blank_columns = []
    for feat in categorical_data.columns:
        if (feat[-1] == "_"):
            blank_columns.append(feat)

    categorical_data.drop(columns=blank_columns, inplace=True)

    train_cat_features = [feat for feat in list(
        scaler.feature_names_in_) if feat[-1] != '_']

    for feature in train_cat_features:
        if (feature not in categorical_data.columns):
            categorical_data[feature] = 0

    data.drop(columns=categorical_features_model, inplace=True, errors=False)
    data = data.merge(categorical_data)
    data = knn_imputation(data)
    return data

def ProcessArguments():
    """
   Processes the Arguments according to the file path.

   Returns:
       args - Processed Arguments

    """

    abspath = os.path.abspath(__file__)
    dname = os.path.dirname(abspath)
    os.chdir(dname)

    opts, args = getopt.getopt(sys.argv, "", "")
    return args

def get_new_feature_names(feature_col_names, scaler_names, feature_name):
    x = []
    for c in feature_col_names:
        if c.startswith(feature_name):
            x.append(c)
    new_names = set(x) - set(scaler_names)
    return new_names

def get_missing_indices(features, missing_names):
    missing_indices = []
    for i in missing_names:
        missing_indices.append(features[features[i] == 1].index)
    return [j for i in missing_indices for j in i]

def make_missing_predictions_average(features, missing_indices, model, 
                                     scaler, seller_weights, ohe_root_name):
    col_nums = []
    for i, name in enumerate(features.columns):
        if name.startswith(ohe_root_name):
            col_nums.append(i)

    n_cols = len(col_nums)
    names = features.columns
    missing_results = {'S': [], 'M': [], 'W': []}
    for i in missing_indices:
        print(i)
        y = []
        row = features.iloc[i, :].to_numpy()
        row = np.reshape(row, (-1, features.shape[1]))
        for j in col_nums:
            row[0, j] = 1
            x = {}
            for m, k in zip(names, row.tolist()[0]):
                x[m] = k
            y.append(x)
            row[0, j] = 0
        y = pd.DataFrame(y)
        y = scaler.transform(y)
        y = np.asarray(y).astype(np.float32)

        S = K.function([model.layers[0].input], [
            model.get_layer('S').output])([y])[0]

        try:
            M = K.function([model.layers[0].input], [
                model.get_layer('dM').output])([y])[0]
        except:
            M = K.function([model.layers[0].input], [
                model.get_layer('M').output])([y])[0]

        W = K.function([model.layers[0].input], [
            model.get_layer('W').output])([y])[0]
        tmp = pd.DataFrame(
            {'S': np.ravel(S), 'M': np.ravel(M), 'W': np.ravel(W)})
        missing_results['S'].append(tmp.median()['S'])
        missing_results['M'].append(tmp.median()['M'])
        missing_results['W'].append(tmp.median()['W'])
    missing_results = pd.DataFrame(missing_results, index=missing_indices)
    newdf = scaler.transform(features)
    newdf = np.asarray(newdf).astype(np.float32)
    S = K.function([model.layers[0].input], [
        model.get_layer('S').output])([newdf])[0]
    try:
        M = K.function([model.layers[0].input], [
            model.get_layer('dM').output])([newdf])[0]
    except:
        M = K.function([model.layers[0].input], [
            model.get_layer('M').output])([newdf])[0]

    W = K.function([model.layers[0].input], [
        model.get_layer('W').output])([newdf])[0]
    results = pd.DataFrame(
        {'S': np.ravel(S), 'M': np.ravel(M), 'W': np.ravel(W)})
    results.iloc[missing_indices] = missing_results
    return results

def make_missing_predictions_weighted_average(features, missing_indices, model, 
                                     scaler, seller_weights, ohe_root_name):
    name_to_number = {} 
    for i, name in enumerate(features.columns):
        if name.startswith(ohe_root_name):
            name_to_number[name] = i 
    seller_dictionary = dict(zip(seller_weights['SellerName'], seller_weights['SellerPct']))
    names = features.columns
    missing_results = {'S': [], 'M': [], 'W': []}
    for i in missing_indices:
        print(i)
        y = []
        row = features.iloc[i, :].to_numpy()
        row = np.reshape(row, (-1, features.shape[1]))
        for name,number in name_to_number.items():
            row[0, number] = seller_dictionary[name]
            x = {}
            for m, k in zip(names, row.tolist()[0]):
                x[m] = k
            y.append(x)
            row[0, number] = 0
        y = pd.DataFrame(y)
        y = scaler.transform(y)
        y = np.asarray(y).astype(np.float32)

        S = K.function([model.layers[0].input], [
            model.get_layer('S').output])([y])[0]

        try:
            M = K.function([model.layers[0].input], [
                model.get_layer('dM').output])([y])[0]
        except:
            M = K.function([model.layers[0].input], [
                model.get_layer('M').output])([y])[0]

        W = K.function([model.layers[0].input], [
            model.get_layer('W').output])([y])[0]
        tmp = pd.DataFrame(
            {'S': np.ravel(S), 'M': np.ravel(M), 'W': np.ravel(W)})
        missing_results['S'].append(tmp.median()['S'])
        missing_results['M'].append(tmp.median()['M'])
        missing_results['W'].append(tmp.median()['W'])
    missing_results = pd.DataFrame(missing_results, index=missing_indices)
    newdf = scaler.transform(features)
    newdf = np.asarray(newdf).astype(np.float32)
    S = K.function([model.layers[0].input], [
        model.get_layer('S').output])([newdf])[0]
    try:
        M = K.function([model.layers[0].input], [
            model.get_layer('dM').output])([newdf])[0]
    except:
        M = K.function([model.layers[0].input], [
            model.get_layer('M').output])([newdf])[0]

    W = K.function([model.layers[0].input], [
        model.get_layer('W').output])([newdf])[0]
    results = pd.DataFrame(
        {'S': np.ravel(S), 'M': np.ravel(M), 'W': np.ravel(W)})
    results.iloc[missing_indices] = missing_results
    return results

def merge_results(results, missing_data, data, output_path):
    try:
        temp_results = pd.merge(
            results, data[['LookId', 'SellerName', 'MarginPrice', 'WinBit']], on='LookId')
        temp_results = temp_results.merge(missing_data, on="LookId")
        temp_results['Missing'] = temp_results['Missing'].astype('bool')
        temp_results['WinProb'] = prob(temp_results['MarginPrice'], temp_results['S'], temp_results['M'], temp_results['W'])
        temp_results = temp_results[['LookId', 'SellerName', 'Missing', 'MarginPrice', 'S',
                                        'M', 'W', 'WinProb', 'WinBit']]
    except KeyError:
        print("Data does not have margin price or winbit")
        temp_results = pd.merge(
            results, data[['LookId', 'SellerName']], on='LookId')
        temp_results = temp_results.merge(missing_data, on="LookId")
        temp_results['Missing'] = temp_results['Missing'].astype('bool')        
        temp_results = temp_results[['LookId', 'SellerName', 'Missing', 'S',
                                        'M', 'W']]
    os.makedirs(output_path[:output_path.rindex(os.path.sep)], exist_ok=True)
    temp_results.to_csv(output_path, index=False)
    return temp_results

def get_missing_col_indices(features, ohe_root_name):
    col_nums = []
    for i, name in enumerate(features.columns):
        if name.startswith(ohe_root_name):
            col_nums.append(i)
    return col_nums

def get_seller_subset_indices(features, seller_subset):
    col_nums = []
    fnames = list(features.columns)
    for name in seller_subset:
        col_nums.append(fnames.index(name))
    return col_nums

def format_seller_weights_table(seller_weight_file_name):
    seller_weights = pd.read_csv(seller_weight_file_name)
    seller_weights = seller_weights.T
    seller_weights.columns = seller_weights.iloc[0]
    seller_weights.drop('SellerName', axis=0, inplace=True)
    return seller_weights

def weighted_avg_weights(features, missing_indices, model, scaler, ohe_root_name, seller_weight_file_name):
    seller_weights = format_seller_weights_table(seller_weight_file_name)
    col_nums = get_missing_col_indices(features, ohe_root_name)
    missing_results = {'S': [], 'M': [], 'W': []}
    features_copy = features.copy(deep=True)
    seller_weights = seller_weights[features_copy.iloc[:, col_nums].columns]
    features_copy.iloc[missing_indices, col_nums] = seller_weights
    missing_df = features_copy
    missing_df = scaler.transform(missing_df)
    missing_df = missing_df[missing_indices, :]
    missing_df = np.asarray(missing_df).astype(np.float32)
    newdf = scaler.transform(features)
    newdf = np.asarray(newdf).astype(np.float32)
    S = K.function([model.layers[0].input], [
        model.get_layer('S').output])([missing_df])[0]
    try:
        M = K.function([model.layers[0].input], [
            model.get_layer('dM').output])([missing_df])[0]
    except:
        M = K.function([model.layers[0].input], [
            model.get_layer('M').output])([missing_df])[0]

    W = K.function([model.layers[0].input], [
        model.get_layer('W').output])([missing_df])[0]
    missing_results = pd.DataFrame(
        {'S': np.ravel(S), 'M': np.ravel(M), 'W': np.ravel(W)})
    S = K.function([model.layers[0].input], [
        model.get_layer('S').output])([newdf])[0]
    try:
        M = K.function([model.layers[0].input], [
            model.get_layer('dM').output])([newdf])[0]
    except:
        M = K.function([model.layers[0].input], [
            model.get_layer('M').output])([newdf])[0]
    W = K.function([model.layers[0].input], [
        model.get_layer('W').output])([newdf])[0]
    results = pd.DataFrame(
        {'S': np.ravel(S), 'M': np.ravel(M), 'W': np.ravel(W)})
    results.iloc[missing_indices] = missing_results
    return results

def make_missing_predictions_weights(features, missing_indices, model, scaler, ohe_root_name):
    col_nums = get_missing_col_indices(features, ohe_root_name)
    missing_results = {'S': [], 'M': [], 'W': []}
    features_copy = features.copy(deep=True)
    features_copy.iloc[missing_indices, col_nums] = 1
    missing_df = features_copy
    missing_df.iloc[missing_indices,
                    col_nums] = missing_df.iloc[missing_indices, col_nums]/len(col_nums)
    missing_df = scaler.transform(missing_df)
    missing_df = missing_df[missing_indices, :]
    missing_df = np.asarray(missing_df).astype(np.float32)
    newdf = scaler.transform(features)
    newdf = np.asarray(newdf).astype(np.float32)
    S = K.function([model.layers[0].input], [
        model.get_layer('S').output])([missing_df])[0]
    try:
        M = K.function([model.layers[0].input], [
            model.get_layer('dM').output])([missing_df])[0]
    except:
        M = K.function([model.layers[0].input], [
            model.get_layer('M').output])([missing_df])[0]

    W = K.function([model.layers[0].input], [
        model.get_layer('W').output])([missing_df])[0]
    missing_results = pd.DataFrame(
        {'S': np.ravel(S), 'M': np.ravel(M), 'W': np.ravel(W)})
    S = K.function([model.layers[0].input], [
        model.get_layer('S').output])([newdf])[0]
    try:
        M = K.function([model.layers[0].input], [
            model.get_layer('dM').output])([newdf])[0]
    except:
        M = K.function([model.layers[0].input], [
            model.get_layer('M').output])([newdf])[0]
    W = K.function([model.layers[0].input], [
        model.get_layer('W').output])([newdf])[0]
    results = pd.DataFrame(
        {'S': np.ravel(S), 'M': np.ravel(M), 'W': np.ravel(W)})
    results.iloc[missing_indices] = missing_results
    return results

def make_all1_predictions(features, missing_indices, model, scaler, ohe_root_name):
    col_nums = get_missing_col_indices(features, ohe_root_name)
    n_cols = len(col_nums)
    names = features.columns
    missing_results = {'S': [], 'M': [], 'W': []}
    features_copy = features.copy(deep=True)
    features_copy.iloc[missing_indices, col_nums] = 1
    missing_df = features_copy
    missing_df.iloc[missing_indices,
                    col_nums] = missing_df.iloc[missing_indices, col_nums]
    missing_df = scaler.transform(missing_df)
    missing_df = missing_df[missing_indices, :]
    missing_df = np.asarray(missing_df).astype(np.float32)
    newdf = scaler.transform(features)
    newdf = np.asarray(newdf).astype(np.float32)
    S = K.function([model.layers[0].input], [
        model.get_layer('S').output])([missing_df])[0]
    try:
        M = K.function([model.layers[0].input], [
            model.get_layer('dM').output])([missing_df])[0]
    except:
        M = K.function([model.layers[0].input], [
            model.get_layer('M').output])([missing_df])[0]

    W = K.function([model.layers[0].input], [
        model.get_layer('W').output])([missing_df])[0]
    missing_results = pd.DataFrame(
        {'S': np.ravel(S), 'M': np.ravel(M), 'W': np.ravel(W)})
    S = K.function([model.layers[0].input], [
        model.get_layer('S').output])([newdf])[0]
    try:
        M = K.function([model.layers[0].input], [
            model.get_layer('dM').output])([newdf])[0]
    except:
        M = K.function([model.layers[0].input], [
            model.get_layer('M').output])([newdf])[0]
    W = K.function([model.layers[0].input], [
        model.get_layer('W').output])([newdf])[0]
    results = pd.DataFrame(
        {'S': np.ravel(S), 'M': np.ravel(M), 'W': np.ravel(W)})
    results.iloc[missing_indices] = missing_results
    return results

def make_subset_predictions(features, missing_indices, model, scaler, seller_subset):
    col_nums = get_seller_subset_indices(features, seller_subset)
    missing_results = {'S': [], 'M': [], 'W': []}
    features_copy = features.copy(deep=True)
    features_copy.iloc[missing_indices, col_nums] = 1
    missing_df = features_copy
    missing_df.iloc[missing_indices,
                    col_nums] = missing_df.iloc[missing_indices, col_nums]
    missing_df = scaler.transform(missing_df)
    missing_df = missing_df[missing_indices, :]
    missing_df = np.asarray(missing_df).astype(np.float32)
    newdf = scaler.transform(features)
    newdf = np.asarray(newdf).astype(np.float32)
    S = K.function([model.layers[0].input], [
        model.get_layer('S').output])([missing_df])[0]
    try:
        M = K.function([model.layers[0].input], [
            model.get_layer('dM').output])([missing_df])[0]
    except:
        M = K.function([model.layers[0].input], [
            model.get_layer('M').output])([missing_df])[0]

    W = K.function([model.layers[0].input], [
        model.get_layer('W').output])([missing_df])[0]
    missing_results = pd.DataFrame(
        {'S': np.ravel(S), 'M': np.ravel(M), 'W': np.ravel(W)})
    S = K.function([model.layers[0].input], [
        model.get_layer('S').output])([newdf])[0]
    try:
        M = K.function([model.layers[0].input], [
            model.get_layer('dM').output])([newdf])[0]
    except:
        M = K.function([model.layers[0].input], [
            model.get_layer('M').output])([newdf])[0]
    W = K.function([model.layers[0].input], [
        model.get_layer('W').output])([newdf])[0]
    results = pd.DataFrame(
        {'S': np.ravel(S), 'M': np.ravel(M), 'W': np.ravel(W)})
    results.iloc[missing_indices] = missing_results
    return results

def run_model_average_predictions(args, proc, data, model_path, log_file=None):
    """
    This is the file where majority of the work is done, everytime a client connects and sends a message(The Output Id)
    the Output Id is used is added to the arguments and the results(S,M,W) are stored in the SQL database

    Parameters:
    message - The Output Id that the Eval file sends.
    client - The Eval File that is connected to the server.
    args - The arguments received by the MizerEvalServer file

    """
    # print("Processing MizerEval for OutputId:"+ f"{args[3]}", flush = True)
    try:
        pass
        # data = SQLAction(args, proc, 'GetLooks')
        # data = pd.read_csv('time_test.csv')
        # data=pd.read_csv('bad_sellers.csv')
        # data = pd.to_csv('time_test.csv')
        # data = pd.read_csv('time_test.csv')
        # data = pd.read_csv('avgseller1.csv')
    except:
        print('error with data')
    # data = pd.read_csv('avgseller1.csv')

    data_copy = data.copy()
    # model_path = SQLAction(args, proc, 'GetEvalParams')['ModelPath'][0]+'\\'
    P = pathlib.Path(model_path)
    model = load_model(P/'Model.h5', compile=False)
    scaler_path = P/'Scaler.pkl'
    with open(scaler_path, 'rb') as f:
        scaler = pickle.load(f)
    try:
        features = load_model_features(data, scaler)
    except:
        print('error with model features')

    missing_names = get_new_feature_names(
        features.columns, scaler.feature_names_in_, 'SellerName')
    print(missing_names)
    missing_indices = get_missing_indices(features, missing_names)
    miss_col = np.zeros(features.shape[0])
    miss_col[missing_indices] = 1
    missing_data = pd.DataFrame({'LookId':data_copy['LookId'], 'Missing':miss_col})
    features = features[scaler.feature_names_in_]
    results = make_missing_predictions_average(
        features, missing_indices, model, scaler, 'SellerName')
    results['LookId'] = data['LookId']
    results['M'] = results['M'] + data_copy['BenchMarginPrice']
    if log_file is not None:
        return merge_results(results, missing_data, data_copy, log_file)
    else:
        return results
    
def run_model_weighted_average_predictions(data, model_path, seller_weights, log_file=None):
    """
    This is the file where majority of the work is done, everytime a client connects and sends a message(The Output Id)
    the Output Id is used is added to the arguments and the results(S,M,W) are stored in the SQL database

    Parameters:
    message - The Output Id that the Eval file sends.
    client - The Eval File that is connected to the server.
    args - The arguments received by the MizerEvalServer file

    """
    # print("Processing MizerEval for OutputId:"+ f"{args[3]}", flush = True)
    try:
        pass
        # data = SQLAction(args, proc, 'GetLooks')
        # data = pd.read_csv('time_test.csv')
        # data=pd.read_csv('bad_sellers.csv')
        # data = pd.to_csv('time_test.csv')
        # data = pd.read_csv('time_test.csv')
        # data = pd.read_csv('avgseller1.csv')
    except:
        print('error with data')
    # data = pd.read_csv('avgseller1.csv')

    data_copy = data.copy()
    # model_path = SQLAction(args, proc, 'GetEvalParams')['ModelPath'][0]+'\\'
    model_path = pathlib.Path(model_path)
    model = load_model(model_path/'Model.h5', compile=False)
    scaler_path = model_path/'Scaler.pkl'
    with open(scaler_path, 'rb') as f:
        scaler = pickle.load(f)
    try:
        features = load_model_features(data, scaler)
    except:
        print('error with model features')

    missing_names = get_new_feature_names(
        features.columns, scaler.feature_names_in_, 'SellerName')
    print(missing_names)
    missing_indices = get_missing_indices(features, missing_names)
    miss_col = np.zeros(features.shape[0])
    miss_col[missing_indices] = 1
    missing_data = pd.DataFrame({'LookId':data_copy['LookId'], 'Missing':miss_col})
    features = features[scaler.feature_names_in_]
    results = make_missing_predictions_weighted_average(
        features, missing_indices, model, scaler, seller_weights, 'SellerName')
    results['LookId'] = data['LookId']
    results['M'] = results['M'] + data_copy['BenchMarginPrice']
    if log_file is not None:
        return merge_results(results, missing_data, data_copy, log_file)
    else:
        return results

def run_model_average_weights(args, proc, data, model_path, log_file=None):
    """
    This is the file where majority of the work is done, everytime a client connects and sends a message(The Output Id)
    the Output Id is used is added to the arguments and the results(S,M,W) are stored in the SQL database

    Parameters:
    message - The Output Id that the Eval file sends.
    client - The Eval File that is connected to the server.
    args - The arguments received by the MizerEvalServer file

    """
    data_copy = data.copy()
    # model_path = SQLAction(args, proc, 'GetEvalParams')['ModelPath'][0]+'\\'
    # model_path = '84668229'
    P = pathlib.Path(model_path)
    model = load_model(P/'Model.h5', compile=False)
    scaler_path = P/'Scaler.pkl'
    with open(scaler_path, 'rb') as f:
        scaler = pickle.load(f)
    try:
        features = load_model_features(data, scaler)
    except:
        print('error with model features')
    missing_names = get_new_feature_names(
        features.columns, scaler.feature_names_in_, 'SellerName')
    print(missing_names)
    missing_indices = get_missing_indices(features, missing_names)
    miss_col = np.zeros(features.shape[0])
    miss_col[missing_indices] = 1
    missing_data = pd.DataFrame({'LookId':data_copy['LookId'], 'Missing':miss_col})
    features = features[scaler.feature_names_in_]
    results = make_missing_predictions_weights(
        features, missing_indices, model, scaler, 'SellerName')
    results['LookId'] = data['LookId']
    results['M'] = results['M'] + data_copy['BenchMarginPrice']
    if log_file is not None:
        return merge_results(results, missing_data, data_copy, P/log_file)
    else:
        return results

def run_model_weighted_avg_weights(args, proc, data, model_path, seller_weight_file_name, log_file=None):
    """
    This is the file where majority of the work is done, everytime a client connects and sends a message(The Output Id)
    the Output Id is used is added to the arguments and the results(S,M,W) are stored in the SQL database

    Parameters:
    message - The Output Id that the Eval file sends.
    client - The Eval File that is connected to the server.
    args - The arguments received by the MizerEvalServer file

    """
    data_copy = data.copy()
    # model_path = SQLAction(args, proc, 'GetEvalParams')['ModelPath'][0]+'\\'
    # model_path = '84668229'
    P = pathlib.Path(model_path)
    model = load_model(P/'Model.h5', compile=False)
    scaler_path = P/'Scaler.pkl'
    with open(scaler_path, 'rb') as f:
        scaler = pickle.load(f)
    try:
        features = load_model_features(data, scaler)
    except:
        print('error with model features')
    missing_names = get_new_feature_names(
        features.columns, scaler.feature_names_in_, 'SellerName')
    print(missing_names)
    missing_indices = get_missing_indices(features, missing_names)
    miss_col = np.zeros(features.shape[0])
    miss_col[missing_indices] = 1
    missing_data = pd.DataFrame({'LookId':data_copy['LookId'], 'Missing':miss_col})
    features = features[scaler.feature_names_in_]
    results = weighted_avg_weights(
        features, missing_indices, model, scaler, 'SellerName', seller_weight_file_name)
    results['LookId'] = data['LookId']
    results['M'] = results['M'] + data_copy['BenchMarginPrice']
    if log_file is not None:
        return merge_results(results, missing_data, data_copy, P/log_file)
    else:
        return results

def run_model_original(args, proc, data, model_path, log_file=None):
    """
    This is the file where majority of the work is done, everytime a client connects and sends a message(The Output Id)
    the Output Id is used is added to the arguments and the results(S,M,W) are stored in the SQL database

    Parameters:
    message - The Output Id that the Eval file sends.
    client - The Eval File that is connected to the server.
    args - The arguments received by the MizerEvalServer file

    """
    # args =  args[:3]
    # OutputId = message
    # args.append(int(OutputId))
    data_copy = data.copy()
    P = pathlib.Path(model_path)
    model = load_model(P/'Model.h5', compile=False)
    scaler_path = P/'Scaler.pkl'
    with open(scaler_path, 'rb') as f:
        scaler = pickle.load(f)
    features = load_model_features(data, scaler)
    clist = []
    for f in features.columns:
        if f.startswith('Seller'):
            clist.append(f)
    missing_names = get_new_feature_names(
        features.columns, scaler.feature_names_in_, 'SellerName')
    print(missing_names)
    missing_indices = get_missing_indices(features, missing_names)
    miss_col = np.zeros(features.shape[0])
    miss_col[missing_indices] = 1
    missing_data = pd.DataFrame({'LookId':data_copy['LookId'], 'Missing':miss_col})
    features = features[scaler.feature_names_in_]
    clist = []
    for f in features.columns:
        if f.startswith('Seller'):
            clist.append(f)
    if features.iloc[missing_indices][clist].sum().sum() != 0:
        print(
            "Error with how missing indices are made, missing sellers have seller bits = 1")
        sys.exit()
    else:
        print("This proves that all missing sellers have all 0's for seller ohe columns " +
              str(features.iloc[missing_indices][clist].sum().sum()))
    clist = []
    for f in features.columns:
        if f.startswith('Seller'):
            clist.append(f)

    features = scaler.transform(features)
    features = np.asarray(features).astype(np.float32)
    S = K.function([model.layers[0].input], [
        model.get_layer('S').output])([features])[0]
    try:
        M = K.function([model.layers[0].input], [
            model.get_layer('dM').output])([features])[0]
    except Exception as e:
        M = K.function([model.layers[0].input], [
            model.get_layer('M').output])([features])[0]

    W = K.function([model.layers[0].input], [
        model.get_layer('W').output])([features])[0]

    results = pd.DataFrame({'LookId': data['LookId'],
                            'S': np.ravel(S),
                            'M': np.ravel(M),
                            'W': np.ravel(W)})
    results['M'] = results['M'] + data_copy['BenchMarginPrice']

    if log_file is not None:
        return merge_results(results, missing_data, data_copy, log_file)
    else:
        return results

def run_model_all1(args, proc, data, model_path, log_file=None):
    """
    This is the file where majority of the work is done, everytime a client connects and sends a message(The Output Id)
    the Output Id is used is added to the arguments and the results(S,M,W) are stored in the SQL database

    Parameters:
    message - The Output Id that the Eval file sends.
    client - The Eval File that is connected to the server.
    args - The arguments received by the MizerEvalServer file

    """
    data_copy = data.copy()
    # model_path = SQLAction(args, proc, 'GetEvalParams')['ModelPath'][0]+'\\'
    # model_path = '84668229'
    P = pathlib.Path(model_path)
    model = load_model(P/'Model.h5', compile=False)
    scaler_path = P/'Scaler.pkl'
    with open(scaler_path, 'rb') as f:
        scaler = pickle.load(f)
    try:
        features = load_model_features(data, scaler)
    except:
        print('error with model features')
    missing_names = get_new_feature_names(
        features.columns, scaler.feature_names_in_, 'SellerName')
    print(missing_names)
    missing_indices = get_missing_indices(features, missing_names)
    miss_col = np.zeros(features.shape[0])
    miss_col[missing_indices] = 1
    missing_data = pd.DataFrame({'LookId':data_copy['LookId'], 'Missing':miss_col})
    features = features[scaler.feature_names_in_]
    results = make_all1_predictions(
        features, missing_indices, model, scaler, 'SellerName')
    results['LookId'] = data['LookId']
    results['M'] = results['M'] + data_copy['BenchMarginPrice']
    if log_file is not None:
        return merge_results(results, missing_data, data_copy, log_file)
    else:
        return results

def run_model_all1_subset(args, proc, data, model_path, seller_subset, log_file=None):
    """
    This is the file where majority of the work is done, everytime a client connects and sends a message(The Output Id)
    the Output Id is used is added to the arguments and the results(S,M,W) are stored in the SQL database

    Parameters:
    message - The Output Id that the Eval file sends.
    client - The Eval File that is connected to the server.
    args - The arguments received by the MizerEvalServer file

    """
    data_copy = data.copy()
    # model_path = SQLAction(args, proc, 'GetEvalParams')['ModelPath'][0]+'\\'
    # model_path = '84668229'
    P = pathlib.Path(model_path)
    model = load_model(P/'Model.h5', compile=False)
    scaler_path = P/'Scaler.pkl'
    with open(scaler_path, 'rb') as f:
        scaler = pickle.load(f)
    try:
        features = load_model_features(data, scaler)
    except:
        print('error with model features')
    missing_names = get_new_feature_names(
        features.columns, scaler.feature_names_in_, 'SellerName')
    print(missing_names)
    missing_indices = get_missing_indices(features, missing_names)
    miss_col = np.zeros(features.shape[0])
    miss_col[missing_indices] = 1
    missing_data = pd.DataFrame({'LookId':data_copy['LookId'], 'Missing':miss_col})
    features = features[scaler.feature_names_in_]
    results = make_subset_predictions(
        features, missing_indices, model, scaler, seller_subset)
    results['LookId'] = data['LookId']
    results['M'] = results['M'] + data_copy['BenchMarginPrice']
    if log_file is not None:
        return merge_results(results, missing_data, data_copy, log_file)
    else:
        return results


def run_model_experiments(data, model_path, log_file=None):
    data_copy = data.copy()
    # model_path = SQLAction(args, proc, 'GetEvalParams')['ModelPath'][0]+'\\'
    # model_path = '84668229'
    model = load_model('\\'.join([model_path, 'Model.h5']), compile=False)
    scaler_path = '\\'.join([model_path, 'Scaler.pkl'])
    with open(scaler_path, 'rb') as f:
        scaler = pickle.load(f)

    features = load_model_features(data, scaler)
    col_nums = get_missing_col_indices(features, 'SellerName')
    features[:, col_nums] = 0 


# %%
if __name__ == '__main__':

    '''
        All known seller output 
    '''
    model_path = r'\\corp.lan\shares\TradingDesk\Analytics\Aspen\Margin Optimization\Presentation\Average Seller Presentation\Data\79747158'
    data=pd.read_csv('\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Data\\data_with_marginprice_winbit_2801.csv')
    with open('\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Code\\dtypes.pkl', 'rb') as f:
        dt = pickle.load(f)
    data=data.astype(dt)
    data_copy = data.copy()
    args=[]
    proc=[]
    all_known= "\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Results + Analysis\\Jan18\\allknown_output.csv"
    d=run_model_original(args, proc,data_copy, model_path, log_file=all_known)

    '''
        All 0 output 
    '''
    model_path = r'\\corp.lan\shares\TradingDesk\Analytics\Aspen\Margin Optimization\Presentation\Average Seller Presentation\Data\79747158'
    data = pd.read_csv(
        '\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Data\\data_with_marginprice_winbit_2801_zztop.csv')
    with open('\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Code\\dtypes.pkl', 'rb') as f:
        dt = pickle.load(f)
    data = data.astype(dt)
    data_copy = data.copy()
    args = []
    proc = []
    all0_output = "\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Results + Analysis\\Jan18\\all0_output.csv"
    run_model_original(args, proc,data_copy, model_path, log_file=all0_output)

    '''
        All 1 output
    '''
    model_path = r'\\corp.lan\shares\TradingDesk\Analytics\Aspen\Margin Optimization\Presentation\Average Seller Presentation\Data\79747158'
    data = pd.read_csv(
        '\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Data\\data_with_marginprice_winbit_2801_zztop.csv')
    with open('\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Code\\dtypes.pkl', 'rb') as f:
        dt = pickle.load(f)
    data = data.astype(dt)
    data_copy = data.copy()
    args = []
    proc = []
    all1_output = "\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Results + Analysis\\Jan18\\all1_output.csv"
    run_model_all1(args, proc, data_copy, model_path, 
                                    log_file=all1_output)
    
    '''
        Average of output 
    '''
    model_path = r'\\corp.lan\shares\TradingDesk\Analytics\Aspen\Margin Optimization\Presentation\Average Seller Presentation\Data\79747158'
    data = pd.read_csv(
        '\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Data\\data_with_marginprice_winbit_2801_zztop.csv')
    with open('\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Code\\dtypes.pkl', 'rb') as f:
        dt = pickle.load(f)
    data = data.astype(dt)
    data_copy = data.copy()
    args = []
    proc = []
    avg_output = "\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Results + Analysis\\Jan18\\average_output.csv"
    run_model_average_predictions(args, proc, data_copy, model_path, log_file=avg_output)

    '''
        Average weights 
    '''
    model_path = r'\\corp.lan\shares\TradingDesk\Analytics\Aspen\Margin Optimization\Presentation\Average Seller Presentation\Data\79747158'
    data = pd.read_csv(
        '\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Data\\data_with_marginprice_winbit_2801_zztop.csv')
    with open('\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Code\\dtypes.pkl', 'rb') as f:
        dt = pickle.load(f)
    data = data.astype(dt)
    data_copy = data.copy()
    args = []
    proc = []
    avg_weights = "\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Results + Analysis\\Jan18\\weights_output.csv"
    run_model_average_weights(args, proc, data_copy, model_path, log_file=avg_weights)
    
    '''
        Paramount name change
    '''
    data = pd.read_csv(
        '\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Data\\data_with_marginprice_winbit_2801_paramount.csv')
    with open('\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Code\\dtypes.pkl', 'rb') as f:
        dt = pickle.load(f)
    data = data.astype(dt)
    data_copy = data.copy()
    args = []
    proc = []
    paramount_name_change ="\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Results + Analysis\\Jan18\\paramount_output.csv"
    run_model_original(args, proc, data_copy, model_path, log_file=paramount_name_change)

    '''
        Weighted average weights output 
    '''
    data = pd.read_csv(
        '\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Data\\data_with_marginprice_winbit_2801_zztop.csv')
    with open('\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Code\\dtypes.pkl', 'rb') as f:
        dt = pickle.load(f)
    data = data.astype(dt)
    data_copy = data.copy()
    args = []
    proc = []
    pinnacle_output = "\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Results + Analysis\\Jan18\\weighted_avg_weights_output.csv"
    seller_weight_file_name = r'\\corp.lan\shares\TradingDesk\Analytics\Aspen\Margin Optimization\Presentation\Average Seller Presentation\Data\seller_weights.csv'
    run_model_weighted_avg_weights(
        args, proc, data_copy, model_path, seller_weight_file_name, log_file=pinnacle_output)
    
    '''
         seller subset 5
    '''
    data = pd.read_csv(
        '\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Data\\data_with_marginprice_winbit_2801_zztop.csv')
    with open('\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Code\\dtypes.pkl', 'rb') as f:
        dt = pickle.load(f)
    data = data.astype(dt)
    data_copy = data.copy()
    args = []
    proc = []
    pinnacle_output = "\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Results + Analysis\\Jan18\\subset5_output.csv"
    seller_weight_file_name = r'\\corp.lan\shares\TradingDesk\Analytics\Aspen\Margin Optimization\Presentation\Average Seller Presentation\Data\seller_weights.csv'
    seller_subset = ['SellerName_guaranteedrate',
                     'SellerName_crosscountrymortgage',
                     'SellerName_mortgageresearch',
                     'SellerName_kindlending',
                     'SellerName_prosperity']

    run_model_all1_subset(
        args, proc, data_copy, model_path, seller_subset, log_file=pinnacle_output)
    
    '''
         seller subset 10
    '''
    data = pd.read_csv(
        '\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Data\\data_with_marginprice_winbit_2801_zztop.csv')
    with open('\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Code\\dtypes.pkl', 'rb') as f:
        dt = pickle.load(f)
    data = data.astype(dt)
    data_copy = data.copy()
    args = []
    proc = []
    pinnacle_output = "\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Results + Analysis\\Jan18\\subset10_output.csv"
    seller_weight_file_name = r'\\corp.lan\shares\TradingDesk\Analytics\Aspen\Margin Optimization\Presentation\Average Seller Presentation\Data\seller_weights.csv'
    seller_subset = ['SellerName_guaranteedrate',
                     'SellerName_crosscountrymortgage',
                     'SellerName_mortgageresearch',
                     'SellerName_kindlending',
                     'SellerName_prosperity',
                     'SellerName_arklatex',
                     'SellerName_paramount',
                     'SellerName_uamc',
                     'SellerName_churchillmortgage',
                     'SellerName_fairwayindependentmortgage']

    run_model_all1_subset(
        args, proc, data_copy, model_path, seller_subset, log_file=pinnacle_output)
    
    '''
         seller subset 15
    '''
    data = pd.read_csv(
        '\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Data\\data_with_marginprice_winbit_2801_zztop.csv')
    with open('\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Code\\dtypes.pkl', 'rb') as f:
        dt = pickle.load(f)
    data = data.astype(dt)
    data_copy = data.copy()
    args = []
    proc = []
    pinnacle_output = "\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Results + Analysis\\Jan18\\subset15_output.csv"
    seller_weight_file_name = r'\\corp.lan\shares\TradingDesk\Analytics\Aspen\Margin Optimization\Presentation\Average Seller Presentation\Data\seller_weights.csv'
    seller_subset = ['SellerName_guaranteedrate',
                     'SellerName_crosscountrymortgage',
                     'SellerName_mortgageresearch',
                     'SellerName_kindlending',
                     'SellerName_prosperity',
                     'SellerName_arklatex',
                     'SellerName_paramount',
                     'SellerName_uamc',
                     'SellerName_churchillmortgage',
                     'SellerName_fairwayindependentmortgage',
                     'SellerName_cardinalfinancial',
                     'SellerName_nvr',
                     'SellerName_afn',
                     'SellerName_fbc',
                     'SellerName_americanpacific']

    run_model_all1_subset(
        args, proc, data_copy, model_path, seller_subset, log_file=pinnacle_output)

    '''
        Pinnacle output all0
    '''
    model_path = r'\\corp.lan\shares\TradingDesk\Analytics\Aspen\Margin Optimization\Presentation\Average Seller Presentation\Data\79747158'
    data = pd.read_csv(
        '\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Data\\pinnacle_marginprice_winbit.csv')
    with open('\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Code\\dtypes.pkl', 'rb') as f:
        dt = pickle.load(f)
    data = data.astype(dt)
    data_copy = data.copy()
    args = []
    proc = []
    pinnacle_output = "\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Results + Analysis\\Jan18\\pinnacle_all0_output.csv"
    run_model_original(
        args, proc, data_copy, model_path, log_file=pinnacle_output)
    
    '''
        Pinnacle output all1
    '''
    model_path = r'\\corp.lan\shares\TradingDesk\Analytics\Aspen\Margin Optimization\Presentation\Average Seller Presentation\Data\79747158'
    data = pd.read_csv(
        '\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Data\\pinnacle_marginprice_winbit.csv')
    with open('\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Code\\dtypes.pkl', 'rb') as f:
        dt = pickle.load(f)
    data = data.astype(dt)
    data_copy = data.copy()
    args = []
    proc = []
    pinnacle_output = "\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Results + Analysis\\Jan18\\pinnacle_all1_output.csv"
    run_model_all1(
        args, proc, data_copy, model_path, log_file=pinnacle_output)
    
    '''
        Pinnacle Paramount name change
    '''
    data = pd.read_csv(
        '\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Data\\pinnacle_marginprice_winbit_paramount.csv')
    with open('\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Code\\dtypes.pkl', 'rb') as f:
        dt = pickle.load(f)
    data = data.astype(dt)
    data_copy = data.copy()
    args = []
    proc = []
    paramount_name_change ="\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Results + Analysis\\Jan18\\pinnacle_changename_output.csv"
    run_model_original(args, proc, data_copy, model_path, log_file=paramount_name_change)
    
    
    '''
        Pinnacle Average of output 
    '''
    data = pd.read_csv(
        '\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Data\\pinnacle_marginprice_winbit.csv')
    with open('\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Code\\dtypes.pkl', 'rb') as f:
        dt = pickle.load(f)
    data = data.astype(dt)
    data_copy = data.copy()
    args = []
    proc = []
    avg_output = "\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Results + Analysis\\Jan18\\pinnacle_average_output.csv"
    run_model_average_predictions(args, proc, data_copy, model_path, log_file=avg_output)
    

    '''
        Pinnacle Average weights 
    '''
    model_path = r'\\corp.lan\shares\TradingDesk\Analytics\Aspen\Margin Optimization\Presentation\Average Seller Presentation\Data\79747158'
    data = pd.read_csv(
        '\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Data\\pinnacle_marginprice_winbit.csv')
    # data = pd.read_csv(
    #     '\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Data\\zztop_data.csv')
    with open('\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Code\\dtypes.pkl', 'rb') as f:
        dt = pickle.load(f)
    data = data.astype(dt)
    data_copy = data.copy()
    args = []
    proc = []
    avg_weights = "\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Results + Analysis\\Jan18\\pinnacle_weights_output.csv"
    run_model_average_weights(args, proc, data_copy, model_path, log_file=avg_weights)
    
    '''
        Pinnacle Average waw 
    '''
    model_path = r'\\corp.lan\shares\TradingDesk\Analytics\Aspen\Margin Optimization\Presentation\Average Seller Presentation\Data\79747158'
    data = pd.read_csv(
        '\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Data\\pinnacle_marginprice_winbit.csv')
    with open('\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Code\\dtypes.pkl', 'rb') as f:
        dt = pickle.load(f)
    data = data.astype(dt)
    data_copy = data.copy()
    args = []
    proc = []
    avg_weights = "\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Results + Analysis\\Jan18\\pinnacle_waw_output.csv"
    seller_weight_file_name = r'\\corp.lan\shares\TradingDesk\Analytics\Aspen\Margin Optimization\Presentation\Average Seller Presentation\Data\seller_weights.csv'
    run_model_weighted_avg_weights(args, proc, data_copy, model_path, seller_weight_file_name, log_file=avg_weights)
    
    '''
        Pinnacle seller subset 5
    '''
    data = pd.read_csv(
        '\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Data\\pinnacle_marginprice_winbit.csv')
    with open('\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Code\\dtypes.pkl', 'rb') as f:
        dt = pickle.load(f)
    data = data.astype(dt)
    data_copy = data.copy()
    args = []
    proc = []
    pinnacle_output = "\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Results + Analysis\\Jan18\\pinnacle_subset5_output.csv"
    seller_weight_file_name = r'\\corp.lan\shares\TradingDesk\Analytics\Aspen\Margin Optimization\Presentation\Average Seller Presentation\Data\seller_weights.csv'
    seller_subset = ['SellerName_guaranteedrate',
                     'SellerName_crosscountrymortgage',
                     'SellerName_mortgageresearch',
                     'SellerName_kindlending',
                     'SellerName_prosperity']

    run_model_all1_subset(
        args, proc, data_copy, model_path, seller_subset, log_file=pinnacle_output)
    
    '''
        Pinnacle seller subset 10
    '''
    data = pd.read_csv(
        '\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Data\\pinnacle_marginprice_winbit.csv')
    with open('\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Code\\dtypes.pkl', 'rb') as f:
        dt = pickle.load(f)
    data = data.astype(dt)
    data_copy = data.copy()
    args = []
    proc = []
    pinnacle_output = "\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Results + Analysis\\Jan18\\pinnacle_subset10_output.csv"
    seller_weight_file_name = r'\\corp.lan\shares\TradingDesk\Analytics\Aspen\Margin Optimization\Presentation\Average Seller Presentation\Data\seller_weights.csv'
    seller_subset = ['SellerName_guaranteedrate',
                     'SellerName_crosscountrymortgage',
                     'SellerName_mortgageresearch',
                     'SellerName_kindlending',
                     'SellerName_prosperity',
                     'SellerName_arklatex',
                     'SellerName_paramount',
                     'SellerName_uamc',
                     'SellerName_churchillmortgage',
                     'SellerName_fairwayindependentmortgage']

    run_model_all1_subset(
        args, proc, data_copy, model_path, seller_subset, log_file=pinnacle_output)
    
    '''
        Pinnacle seller subset 15
    '''
    data = pd.read_csv(
        '\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Data\\pinnacle_marginprice_winbit.csv')
    with open('\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Code\\dtypes.pkl', 'rb') as f:
        dt = pickle.load(f)
    data = data.astype(dt)
    data_copy = data.copy()
    args = []
    proc = []
    pinnacle_output = "\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Results + Analysis\\Jan18\\pinnacle_subset15_output.csv"
    seller_weight_file_name = r'\\corp.lan\shares\TradingDesk\Analytics\Aspen\Margin Optimization\Presentation\Average Seller Presentation\Data\seller_weights.csv'
    seller_subset = ['SellerName_guaranteedrate',
                     'SellerName_crosscountrymortgage',
                     'SellerName_mortgageresearch',
                     'SellerName_kindlending',
                     'SellerName_prosperity',
                     'SellerName_arklatex',
                     'SellerName_paramount',
                     'SellerName_uamc',
                     'SellerName_churchillmortgage',
                     'SellerName_fairwayindependentmortgage',
                     'SellerName_cardinalfinancial',
                     'SellerName_nvr',
                     'SellerName_afn',
                     'SellerName_fbc',
                     'SellerName_americanpacific']

    run_model_all1_subset(
        args, proc, data_copy, model_path, seller_subset, log_file=pinnacle_output)
# %%
