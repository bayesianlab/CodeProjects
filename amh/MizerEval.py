#%%
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
warnings.filterwarnings('ignore')
from pdHelper import selectData
from keras.models import load_model
import os
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3' 
warnings.filterwarnings('ignore')
from pdHelper import execQuery
tf.get_logger().setLevel('INFO')
import getopt
import sys
import pathlib 

#%%
args = ['', 'Awsdevsql013', 'Market', 82370213]
proc = 'MizerEvalAction'

#%%
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
        execQuery(query, server = args[1], database = args[2])
        return

    elif action_type == 'EvalFail':
        query = 'exec ' + proc + ' @ActionType = ' + action_type + ', @OutputId = ' + \
            str(args[3]) + ', @ErrMsgTxt = ' + "'" + addtl + "'"
        execQuery(query, server = args[1], database = args[2])
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
    SQLAction(args, proc, 'EvalSuccess', results.to_json(orient = 'records'))

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
    training_data_col = set([val.split('_')[0] for val in list(scaler.feature_names_in_)])
    drop_cols = list(set(eval_data_col) - set(training_data_col))
    if(bool(drop_cols)):
        data.drop(columns = drop_cols, inplace = True, errors=False)
    categorical_features_model = data.select_dtypes(include=['object']).columns.to_list()
    categorical_data = pd.get_dummies(data, columns=categorical_features_model)

    blank_columns = []
    for feat in categorical_data.columns:
        if(feat[-1] == "_"):
            blank_columns.append(feat)

    categorical_data.drop(columns = blank_columns, inplace = True)

    train_cat_features = [feat for feat in list(scaler.feature_names_in_) if feat[-1] != '_']

    for feature in train_cat_features:
        if(feature not in categorical_data.columns):
            categorical_data[feature] = 0
    
    data.drop(columns=categorical_features_model, inplace=True, errors=False)
    data = data.merge(categorical_data)
    data = knn_imputation(data)
    return data


def make_ohe_name_list(column_names,feature_name):
    x = []
    for c in column_names:
        if c.startswith(feature_name):
            x.append(c)
    return x    

def get_missing_indices(features, missing_names):
    missing_indices = [] 
    for i in missing_names:
        missing_indices.append(features[features[i]==1].index)
    return [j for i in missing_indices for j in i]    

def make_missing_predictions(features, missing_indices, ohe_root_name):
    col_nums = []
    for i, name in enumerate(features.columns):
        if name.startswith(ohe_root_name):
            col_nums.append(i)

    n_cols = len(col_nums)
    for i in missing_indices:
        i=4
        row = features.iloc[i,:].to_numpy()
        row = np.reshape(row, (-1, features.shape[1]))
        for j in col_nums:
            row[0, j] = 1
            print(row)
        
        

def run_model(args, proc):
    
    """
    This is the file where majority of the work is done, everytime a client connects and sends a message(The Output Id)
    the Output Id is used is added to the arguments and the results(S,M,W) are stored in the SQL database
    
    Parameters:
    message - The Output Id that the Eval file sends.
    client - The Eval File that is connected to the server.
    args - The arguments received by the MizerEvalServer file

    """
    print("Processing MizerEval for OutputId:"+ f"{args[3]}", flush = True)
    # try:
    #     # data = SQLAction(args, proc, 'GetLooks')
    #     data = pd.read_csv('avgseller1.csv')
    # except:
    #     print('error with data')
    data = pd.read_csv('AvgSeller/avgseller1.csv')

    data_copy = data.copy()
    model_path = SQLAction(args, proc, 'GetEvalParams')['ModelPath'][0]+'\\'
    P = pathlib.Path(model_path)
    model = load_model(P/'Model.h5', compile=False)

    scaler_path = P/'Scaler.pkl'
    with open(scaler_path, 'rb') as f:
        scaler = pickle.load(f)

    try:
        features = load_model_features(data, scaler)
    except:
        print('error with model features')


    new_names = make_ohe_name_list(features.columns, 'SellerName')
    scaler_names = make_ohe_name_list(scaler.feature_names_in_, 'SellerName')
    missing_names = set(new_names) - set(scaler_names)
    missing_indices = get_missing_indices(features, missing_names)
    
    features = features[scaler.feature_names_in_]

    make_missing_predictions(features, missing_indices, 'SellerName')




    # try:
    #     seller_name_indx = [] 
    #     seller_names = [] 

        
    #     results = pd.DataFrame({'S':[],
    #                         'M':[],
    #                         'W':[]})
        
        
        
        # for i in range(features.shape[0]):
        #     if features.iloc[i, seller_name_indx].sum() == 0:
        #         print(features.iloc[i, seller_name_indx])
        #         seller_iden = pd.DataFrame(np.identity(len(seller_name_indx)), columns=features.columns[seller_name_indx])
        #         repeated_row = np.repeat(features.iloc[i, not_seller_cols], len(seller_name_indx))
        #         other_repeated_rows = pd.DataFrame(np.reshape(repeated_row, (len(seller_name_indx),len(not_seller_cols)), order='F'), 
        #                                             columns=features.columns[not_seller_cols])
        #         newdf = pd.concat([seller_iden, other_repeated_rows], axis=1)
        #         newdf=newdf[scaler.feature_names_in_]
        #         newdf = scaler.transform(newdf)
        #         newdf = np.asarray(newdf).astype(np.float32)
                # try:
                #     S = K.function([model.layers[0].input], [
                #             model.get_layer('S').output])([newdf])[0]

                #     try:
                #         M = K.function([model.layers[0].input], [
                #                 model.get_layer('dM').output])([newdf])[0]
                #     except:
                #         M = K.function([model.layers[0].input], [
                #                 model.get_layer('M').output])([newdf])[0]

                #     W = K.function([model.layers[0].input], [
                #             model.get_layer('W').output])([newdf])[0]
                # except:
                #     print('error with s m w prediction')
                # temp['S'] = np.ravel(S)
                # temp['M'] = np.ravel(M)
                # temp['W'] = np.ravel(W)
                
                # bmp = data_copy.iloc[i]['BenchMarginPrice']
                # temp['M'] = temp['M'] + bmp
                # temp = pd.DataFrame(temp).median()
                
                
                
            # else:
            #     try:
            #         S = K.function([model.layers[0].input], [
            #                 model.get_layer('S').output])([newdf])[0]

            #         try:
            #             M = K.function([model.layers[0].input], [
            #                     model.get_layer('dM').output])([newdf])[0]
            #         except:
            #             M = K.function([model.layers[0].input], [
            #                     model.get_layer('M').output])([newdf])[0]

            #         W = K.function([model.layers[0].input], [
            #                 model.get_layer('W').output])([newdf])[0]
            #     except:
            #         print('error with s m w prediction')
                    
                    
    #     features = scaler.transform(features)
    #     features = np.asarray(features).astype(np.float32)
    # except:
    #     print('couldnt standardize')
    
    # try:
    #     S = K.function([model.layers[0].input], [
    #             model.get_layer('S').output])([features])[0]

    #     try:
    #         M = K.function([model.layers[0].input], [
    #                 model.get_layer('dM').output])([features])[0]
    #     except:
    #         M = K.function([model.layers[0].input], [
    #                 model.get_layer('M').output])([features])[0]

    #     W = K.function([model.layers[0].input], [
    #             model.get_layer('W').output])([features])[0]
    # except:
    #     print('error with s m w prediction')
    
    # results = pd.DataFrame({'LookId':data['LookId'],
    #                         'S':np.ravel(S),
    #                         'M':np.ravel(M),
    #                         'W':np.ravel(W)})
    # results['M'] = results['M'] + data_copy['BenchMarginPrice']

    # try:
    #     push_output(args, proc, results)
    # except:
    #     print('couldnt save results')
    return  


def ProcessArguments():
    """
   Processes the Arguments according to the file path.
   
   Returns:
       args - Processed Arguments
     
    """
    
    abspath = os.path.abspath(__file__)
    dname = os.path.dirname(abspath)
    os.chdir(dname)
    
    opts, args = getopt.getopt(sys.argv,"","")    
    return args

    return data

#%%
if __name__ == '__main__':
    # args = ProcessArguments()
    run_model(args, proc)


# %%
