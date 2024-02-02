"""
    Eval Server 
    
    This job takes the different Eval files and Processes them to save startup time while loading libraries

    Parameters
    ----------
    Please see the main function.


"""
import socket
import threading
import keras
from keras import backend as K
import tensorflow as tf
import pandas as pd
import numpy as np
import warnings
import pickle
from mizerHelper import knn_imputation
from cronusHelper import ProcessArguments 
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

proc = 'MizerEvalAction'
# args = ['','awsdevsql013','Market']
# =============================================================================
# Functions
# =============================================================================

HEADER = 1024
PORT = 5052
SERVER = socket.gethostbyname(socket.gethostname())
ADDR = (SERVER, PORT)
FORMAT = 'utf-8'
DISCONNECT_MESSAGE = "!DISCONNECT"
server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
clients = []

def connect_server():
    """
    Tries to connect to the address and the port
    If it can then returns true else returns false
     
    """
    
    try:
       server.bind(ADDR)
       return True
    except:
       return False


def handle(client,args):
    """
   Handles the Eval Files(Clients) as they come in and calls the execute function
   which generates results and the results are saved in SQL.

    Parameters:
       client - The client is the Eval file .
       args - The arguments received by the MizerEvalServer file
     
    """
    
    connected = True
    while connected:
        try:
            msg_length = client.recv(HEADER).decode(FORMAT)
            if msg_length:
               msg_length = int(msg_length)
               message = client.recv(msg_length).decode(FORMAT)
               if message == DISCONNECT_MESSAGE:
                   connected = False
            if message == DISCONNECT_MESSAGE:
                connected = False
            run_model(message, client,args)
            
        except:
           break

def receive(args):
    """
    Receives the client and the address from the server each time an Eval file is called and the Server is connected
    After that a thread is allocated to each new connection to the server
    
    Parameters:
    args - The arguments received by the MizerEvalServer file


    """
    
    while True:
        try:
           client, address = server.accept()
        
           thread = threading.Thread(target = handle, args = [client,args,])
           thread.start()
        except:
            print("Server has timeout out")
            return

def load_model_features_8_29(data, model_path, scaler):
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
        # send_message_to_client('Removing the features not in training: '+ str(drop_cols).strip('[]'),client)
    # send_message_to_client('Number of columns included: ' + f"{data.shape[1]:,}", client)
    categorical_features_model = data.select_dtypes(include=['object']).columns.to_list()
    categorical_data = pd.get_dummies(data, columns=categorical_features_model)
    blank_columns = []
    for feat in categorical_data.columns:
        if(feat[-1] == "_"):
            blank_columns.append(feat)

    # send_message_to_client('Removing magic value OHE features: ' + str(blank_columns).strip('[]'),client)
    categorical_data.drop(columns = blank_columns, inplace = True)

    # send_message_to_client('Adding features in training but not in eval...', client)
    train_cat_features = [feat for feat in list(scaler.feature_names_in_) if feat[-1]!='_']

    for feature in train_cat_features:
        if(feature not in categorical_data.columns):
            categorical_data[feature] = 0
            
    data.drop(columns=categorical_features_model, inplace=True, errors=False)
    data = data.merge(categorical_data)
    data = knn_imputation(data)
        
    return data

def run_model(message, client, args):
    
    """
    This is the file where majority of the work is done, everytime a client connects and sends a message(The Output Id)
    the Output Id is used is added to the arguments and the results(S,M,W) are stored in the SQL database
    
    Parameters:
    message - The Output Id that the Eval file sends.
    client - The Eval File that is connected to the server.
    args - The arguments received by the MizerEvalServer file

    """
    

    args =  args[:3]
    OutputId = message
    args.append(int(OutputId))
    
    try:
        
        # data = SQLAction(args, proc, 'GetLooks')
        # data.to_csv('pinnacle.csv', index=False)
        # with open('dtypes.pkl', 'wb') as f:
        #     pickle.dump(data.dtypes.to_dict(), f) 
        data=pd.read_csv('pinnacle.csv')
        with open('dtypes.pkl', 'rb') as f:
            dt = pickle.load(f)
        data=data.astype(dt)
        # send_message_to_client('Number of looks loaded: ' + f"{data.shape[0]:,}",client)
    except Exception as e:
        print("error")
        # send_message_to_client("Python Error " + str(e), client)
        # error_handler(args,'Failed to load the input data', client)
    data_copy = data.copy()
    # send_message_to_client('Loading Model...',client)
    
    try:
        # model_path = SQLAction(args, proc, 'GetEvalParams')['ModelPath'][0]+'\\'
        model_path='79747158\\'
        print(model_path)
        model = load_model(model_path+'Model.h5', compile=False)
        
    except Exception as e:
        print("error")
        # send_message_to_client("Python Error " + str(e), client)
        # error_handler(args, 'Model not loaded.', client)
    # send_message_to_client('Loading Scaler...',client)
    try:
        scaler_path = model_path+'Scaler.pkl'
        with open(scaler_path, 'rb') as f:
            scaler = pickle.load(f)
    except Exception as e:
        print("error")
        # send_message_to_client("Python Error " + str(e), client)
        # error_handler(args, 'Failed to load scaler', client)

    # send_message_to_client('Loading model features...',client)
    try:
        features = load_model_features_8_29(data, model_path, scaler)
    except Exception as e:
        print("error")
        # send_message_to_client("Python Error " + str(e), client)
        # error_handler(args,'Failed to load model features...',client)
             
    # send_message_to_client('Normalizing data...',client)
    try:
        features = features[scaler.feature_names_in_]
        # send_message_to_client('Number of features included: ' + f"{features.shape[1]:,}",client)
        features = scaler.transform(features)
        features = np.asarray(features).astype(np.float32)
    except Exception as e:
        # send_message_to_client("Python Error " + str(e), client)
        # error_handler(args,'Failed to normalize the input data...',client)
        W = K.function([model.layers[0].input], [
        model.get_layer('W').output])([features])[0]
    
    try:
        S = K.function([model.layers[0].input], [
                model.get_layer('S').output])([features])[0]

        try:
            M = K.function([model.layers[0].input], [
                    model.get_layer('dM').output])([features])[0]
        except Exception as e:
            # send_message_to_client("Python Error " + str(e), client)
            M = K.function([model.layers[0].input], [
                    model.get_layer('M').output])([features])[0]

        W = K.function([model.layers[0].input], [
                model.get_layer('W').output])([features])[0]
    except Exception as e:
        print("error")
        # send_message_to_client("Python Error " + str(e), client)
        # error_handler(args,'Failed to predict S/M/W...',client)
    
    # send_message_to_client("Predicting S/M/W...", client)

    results = pd.DataFrame({'LookId':data['LookId'],
                            'S':np.ravel(S),
                            'M':np.ravel(M),
                            'W':np.ravel(W)})
    results['M'] = results['M'] + data_copy['BenchMarginPrice']

    # send_message_to_client('Saving results...',client)
    try:
        push_output(args, proc, results)
    except Exception as e:
        print("error")
        # send_message_to_client("Python Error " + str(e), client)
        # error_handler(args,'Failed to save the results...',client)
    send_message_to_client("Job Done",client)
    client.close()
    clients.remove(client)
    results.to_csv(model_path+'results-8-29.csv')
    return        

def send_message_to_client(msg,client):
    
    """
    Encodes the message and sends it to the client.

    Parameters:
        msg - Message to be pushed to the client
        client - action proc name.
       
    """
    
    message = msg.encode(FORMAT)
    msg_length = len(message)
    send_length = str(msg_length).encode(FORMAT)
    send_length += b' '*(HEADER - len(send_length))
    client.send(message)

    return

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

def load_model_features(data, model_path, scaler,client):
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
        send_message_to_client('Removing the features not in training: '+ str(drop_cols).strip('[]'),client)
    send_message_to_client('Number of columns included: ' + f"{data.shape[1]:,}", client)
    categorical_features_model = data.select_dtypes(include=['object']).columns.to_list()
    categorical_data = pd.get_dummies(data, columns=categorical_features_model)
    blank_columns = []
    for feat in categorical_data.columns:
        if(feat[-1] == "_"):
            blank_columns.append(feat)

    send_message_to_client('Removing magic value OHE features: ' + str(blank_columns).strip('[]'),client)
    categorical_data.drop(columns = blank_columns, inplace = True)

    send_message_to_client('Adding features in training but not in eval...', client)
    train_cat_features = [feat for feat in list(scaler.feature_names_in_) if feat[-1]!='_']

    for feature in train_cat_features:
        if(feature not in categorical_data.columns):
            categorical_data[feature] = 0
            
    data.drop(columns=categorical_features_model, inplace=True, errors=False)
    data = data.merge(categorical_data)
    data = knn_imputation(data)
        
    return data

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

def error_handler(args,errMsgTxt, client, python_error=None):
    """
    Prints the error message and saves the error message in the SQL object
    and sends it back to the eval file.

    Parameters:
        args: Arguments required to evaluate 
        errMsgTxt:error message
        client:The eval file to which the error message is sent in case of failure

    """

    print(errMsgTxt, flush=True)
    msg = errMsgTxt
    message = msg.encode(FORMAT)
    msg_length = len(message)
    send_length = str(msg_length).encode(FORMAT)
    send_length += b' '*(HEADER - len(send_length))
    client.send(message)
    client.close()
    
    print("Message Sent to Client", flush = True)
    SQLAction(args, proc, 'EvalFail', errMsgTxt)

def run_eval_server(args):
    """
    Checks if the args are good 
    Checks if the Server can be connected to,if it can then 
    connects and then runs the python file else it ends the script execution
    Runs the model after getting the receive command
    Parameters:
        args: Arguments required to evaluate

    """
    if(len(args)<3):
        print("Insufficient Arguemnts Supplied...", flush = True)
        return 
    
    if connect_server() == True:
       print('MizerEvalServer is Listening for {} Server and {} Database ...'.format(args[1],args[2]), flush=True)
       server.listen() 
       receive(args)
    else:
        return

if __name__ == '__main__':
    
    args = ProcessArguments()
    # args = ['','awsdevsql013','Market']
    
    run_eval_server(args)

    
