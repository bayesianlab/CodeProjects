#%%
import warnings
import pickle
from tensorflow.keras.models import save_model
import keras
import os
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'
import tensorflow as tf
import cronusHelper
from keras.layers import Dense, Dropout, Input
from keras import backend as K
from sklearn.preprocessing import StandardScaler
import pandas as pd
import tensorflow.compat
import numpy as np
import seaborn as sns
from sklearn.model_selection import train_test_split
from pdHelper import selectData
import json
from pdHelper import execQuery
from keras.callbacks import LambdaCallback
import time
tf.keras.utils.set_random_seed(4)
warnings.filterwarnings('ignore')
import pyodbc
from pathlib import Path
#%%


class TimeHistory(keras.callbacks.Callback):
   
    """
       A class to store the time in each epoch
        
       Methods
       -------
       on_train_begin(additional=""):
           Decides the behaviour when the Training Begins.
       on_epoch_begin(additional=""):
           Decides the behaviour when the Epoch Begins.  
       on_epoch_end(additional=""):
           Decides the behaviour when the Epoch Ends.           

    """

    def on_train_begin(self, logs={}):
        """
        Starts the process when the training starts and stores the time for all epochs.

        Parameters:
            logs: Stores the start and end time for the epochs

        """
        self.times = []

    def on_epoch_begin(self, epoch, logs={}):
        """
        Starts the start time for the epoch

        Parameters:
            logs: Stores the start time for the epochs
            epoch:Epoch Number

        """       

        self.epoch_time_start = time.time()

    def on_epoch_end(self, epoch, logs={}):
        """
        Starts the process when the epoch end and stores the time for all epochs.

        Parameters:
            logs: Stores the end time for the epoch
            epoch:Epoch Number

        """  
        print("","EpochTime:", str(round((time.time() - self.epoch_time_start),2))+"s")
        self.times.append(time.time() - self.epoch_time_start)
    
def load_process_data(file,  win_simulation_cnt=25, loss_simulation_cnt=25, simulation_step_price_chg=.01):
    """
    Loads the input data and creates simulations

    Parameters:
        Arguments
        Action proc
        Categorical feature list
        Win simulation count
        Loss simulation count
        Simulation step size

    Returns:
        Dataset to be used for Training

    """

    print('Loading data...', flush=True)
    # data = SQLAction(args, proc, 'GetLooks')
    # conn = conn = pyodbc.connect('DRIVER={SQL Server};SERVER='+args[1]+';DATABASE='+args[2], autocommit=True)
    # action_type = 'GetLooks'
    # query = 'exec ' + proc + ' @ActionType = ' + action_type + ', @OutputId = ' + str(args[3])
    # data = pd.read_sql(query, conn)
    # data = data.head(10000)
    data = pd.read_csv(file, nrows=1000)
    print('Number of looks loaded: ' + f"{data.shape[0]:,}", flush=True)

    # if (bool(drop_cols)):
    #     print('Removing not needed features:' + str(drop_cols).strip('[]'), flush=True)
    #     data.drop(columns=drop_cols, inplace = True, errors=False)

    categorical_features = data.select_dtypes(include=['object']).columns.to_list()

    print('Number of columns included: ' + f"{data.shape[1]:,}", flush=True)

    print('Performing OHE...', flush=True)
    dummy_cols_data = pd.get_dummies(data, columns=categorical_features)
    data.drop(columns=categorical_features, inplace=True)

    try:
        data = data.merge(dummy_cols_data)
    except:
        pass 

    del dummy_cols_data
 
    blank_columns = []
    for feat in data.columns:
        if(feat[-1] == "_"):
            blank_columns.append(feat)

    print('Removing magic value OHE features: ' + str(blank_columns).strip('[]'), flush =  True)
    data.drop(columns = blank_columns, inplace = True)
    
    training,validation = train_test_split(data, test_size=0.10, random_state=42)
    

    # list1 = training['LookId'].unique()
    # list2 = validation['LookId'].unique()
    
    # list(set(list1).intersection(list2))

    print('Creating simulations...', flush=True)
    training['SimulatedWinBit'] = 0
    validation['SimulatedWinBit'] = 0
    simulations_scenario = pd.DataFrame()
    simulations_training = []
    simulations_validation = []


    win_above_margin_price_training = training[(training['WinBoundaryMarginPrice'].notnull())&(training['WinAboveObjectiveWt']>0)]
    loss_above_margin_price_training = training[(training['LossBoundaryMarginPrice'].notnull())&(training['LossAboveObjectiveWt']>0)]
    win_below_margin_price_training = training[(training['WinBoundaryMarginPrice'].notnull())&(training['WinBelowObjectiveWt']>0)]
    loss_below_margin_price_training = training[(training['LossBoundaryMarginPrice'].notnull())&(training['LossBelowObjectiveWt']>0)]
    
    win_above_margin_price_validation = validation[(validation['WinBoundaryMarginPrice'].notnull())&(validation['WinAboveObjectiveWt']>0)]
    loss_above_margin_price_validation = validation[(validation['LossBoundaryMarginPrice'].notnull())&(validation['LossAboveObjectiveWt']>0)]
    win_below_margin_price_validation = validation[(validation['WinBoundaryMarginPrice'].notnull())&(validation['WinBelowObjectiveWt']>0)]
    loss_below_margin_price_validation = validation[(validation['LossBoundaryMarginPrice'].notnull())&(validation['LossBelowObjectiveWt']>0)]

    for m in range(1, win_simulation_cnt+1, 1):

        simulations_scenario = win_below_margin_price_training.copy()
        simulations_scenario['SimulatedMarginPrice'] = simulations_scenario['WinBoundaryMarginPrice'] - m*simulation_step_price_chg
        simulations_scenario['SimulatedWinBit'] = 1
        simulations_scenario['ObjectiveWt'] = simulations_scenario['WinBelowObjectiveWt']
        simulations_scenario.drop(columns=['WinBoundaryMarginPrice','LossBoundaryMarginPrice','LookId'], inplace=True, errors = False)
        simulations_training.append(simulations_scenario)
        
    for m in range(1, win_simulation_cnt+1, 1):

        simulations_scenario = win_above_margin_price_training.copy()
        simulations_scenario['SimulatedMarginPrice'] = simulations_scenario['WinBoundaryMarginPrice'] + m*simulation_step_price_chg
        simulations_scenario['SimulatedWinBit'] = 1
        simulations_scenario['ObjectiveWt'] = simulations_scenario['WinAboveObjectiveWt']
        simulations_scenario.drop(columns=['WinBoundaryMarginPrice','LossBoundaryMarginPrice','LookId'], inplace=True, errors = False)
        simulations_training.append(simulations_scenario)
     
    for m in range(1, loss_simulation_cnt+1, 1):

        simulations_scenario = loss_below_margin_price_training.copy()
        simulations_scenario['SimulatedMarginPrice'] = simulations_scenario['LossBoundaryMarginPrice'] - m*simulation_step_price_chg
        simulations_scenario['SimulatedWinBit'] = 0
        simulations_scenario['ObjectiveWt'] = simulations_scenario['LossBelowObjectiveWt']
        simulations_scenario.drop(columns=['WinBoundaryMarginPrice','LossBoundaryMarginPrice','LookId'], inplace=True, errors = False)
        simulations_training.append(simulations_scenario)
        
    for m in range(1, loss_simulation_cnt+1, 1):

        simulations_scenario = loss_above_margin_price_training.copy()
        simulations_scenario['SimulatedMarginPrice'] = simulations_scenario['LossBoundaryMarginPrice'] + m*simulation_step_price_chg
        simulations_scenario['SimulatedWinBit'] = 0
        simulations_scenario['ObjectiveWt'] = simulations_scenario['LossAboveObjectiveWt']
        simulations_scenario.drop(columns=['WinBoundaryMarginPrice','LossBoundaryMarginPrice','LookId'], inplace=True, errors = False)
        simulations_training.append(simulations_scenario)    

    del win_above_margin_price_training
    del loss_above_margin_price_training
    del win_below_margin_price_training
    del loss_below_margin_price_training
    del simulations_scenario

    simulations_training = pd.concat(simulations_training)
    
    for m in range(1, win_simulation_cnt+1, 1):

        simulations_scenario = win_below_margin_price_validation.copy()
        simulations_scenario['SimulatedMarginPrice'] = simulations_scenario['WinBoundaryMarginPrice'] - m*simulation_step_price_chg
        simulations_scenario['SimulatedWinBit'] = 1
        simulations_scenario['ObjectiveWt'] = simulations_scenario['WinBelowObjectiveWt']
        simulations_scenario.drop(columns=['WinBoundaryMarginPrice','LossBoundaryMarginPrice','LookId'], inplace=True, errors = False)
        simulations_validation.append(simulations_scenario)
        
    for m in range(1, win_simulation_cnt+1, 1):

        simulations_scenario = win_above_margin_price_validation.copy()
        simulations_scenario['SimulatedMarginPrice'] = simulations_scenario['WinBoundaryMarginPrice'] + m*simulation_step_price_chg
        simulations_scenario['SimulatedWinBit'] = 1
        simulations_scenario['ObjectiveWt'] = simulations_scenario['WinAboveObjectiveWt']
        simulations_scenario.drop(columns=['WinBoundaryMarginPrice','LossBoundaryMarginPrice','LookId'], inplace=True, errors = False)
        simulations_validation.append(simulations_scenario)
     
    for m in range(1, loss_simulation_cnt+1, 1):

        simulations_scenario = loss_below_margin_price_validation.copy()
        simulations_scenario['SimulatedMarginPrice'] = simulations_scenario['LossBoundaryMarginPrice'] - m*simulation_step_price_chg
        simulations_scenario['SimulatedWinBit'] = 0
        simulations_scenario['ObjectiveWt'] = simulations_scenario['LossBelowObjectiveWt']
        simulations_scenario.drop(columns=['WinBoundaryMarginPrice','LossBoundaryMarginPrice','LookId'], inplace=True, errors = False)
        simulations_validation.append(simulations_scenario)
        
    for m in range(1, loss_simulation_cnt+1, 1):

        simulations_scenario = loss_above_margin_price_validation.copy()
        simulations_scenario['SimulatedMarginPrice'] = simulations_scenario['LossBoundaryMarginPrice'] + m*simulation_step_price_chg
        simulations_scenario['SimulatedWinBit'] = 0
        simulations_scenario['ObjectiveWt'] = simulations_scenario['LossAboveObjectiveWt']
        simulations_scenario.drop(columns=['WinBoundaryMarginPrice','LossBoundaryMarginPrice','LookId'], inplace=True, errors = False)
        simulations_validation.append(simulations_scenario)    

    del win_above_margin_price_validation
    del loss_above_margin_price_validation
    del win_below_margin_price_validation
    del loss_below_margin_price_validation
    del simulations_scenario

    simulations_validation = pd.concat(simulations_validation)

    print('Number of Training simulations created: ' + f"{simulations_training.shape[0]:,}", flush=True)
    print('Number of Validation simulations created: ' + f"{simulations_validation.shape[0]:,}", flush=True)
    
    actuals_training = training.copy()
    actuals_validation =validation.copy()
  

    actuals_training.drop(columns=['WinBoundaryMarginPrice', 'LossBoundaryMarginPrice','SimulatedWinBit'], inplace=True, errors = False)
    actuals_validation.drop(columns=['WinBoundaryMarginPrice', 'LossBoundaryMarginPrice','SimulatedWinBit'], inplace=True, errors = False)
    

    return simulations_training, simulations_validation, actuals_training, actuals_validation

def load_process_data2(file,  win_simulation_cnt=25, loss_simulation_cnt=25, simulation_step_price_chg=.01 ):
    """
    Loads the input data and creates simulations

    Parameters:
        Arguments
        Action proc
        Categorical feature list
        Win simulation count
        Loss simulation count
        Simulation step size

    Returns:
        Dataset to be used for Training

    """

    print('Loading data...', flush=True)
    # data = SQLAction(args, proc, 'GetLooks')
    # conn = conn = pyodbc.connect('DRIVER={SQL Server};SERVER='+args[1]+';DATABASE='+args[2], autocommit=True)
    # action_type = 'GetLooks'
    # query = 'exec ' + proc + ' @ActionType = ' + action_type + ', @OutputId = ' + str(args[3])
    # data = pd.read_sql(query, conn)
    # data = data.head(10000)
    data = pd.read_csv(file, nrows=1000)



    categorical_features = data.select_dtypes(include=['object']).columns.to_list()

    print('Number of columns included: ' + f"{data.shape[1]:,}", flush=True)

    print('Performing OHE...', flush=True)
    dummy_cols_data = pd.get_dummies(data, columns=categorical_features)
    data.drop(columns=categorical_features, inplace=True)


    data = data.merge(dummy_cols_data)


    del dummy_cols_data
 
    blank_columns = []
    for feat in data.columns:
        if(feat[-1] == "_"):
            blank_columns.append(feat)

    print('Removing magic value OHE features: ' + str(blank_columns).strip('[]'), flush =  True)
    data.drop(columns = blank_columns, inplace = True)
    
    training,validation = train_test_split(data, test_size=0.10, random_state=42)
    

    # list1 = training['LookId'].unique()
    # list2 = validation['LookId'].unique()
    
    # list(set(list1).intersection(list2))

    print('Creating simulations...', flush=True)
    training['SimulatedWinBit'] = 0
    validation['SimulatedWinBit'] = 0
    simulations_scenario = pd.DataFrame()
    simulations_training = []
    simulations_validation = []


    win_above_margin_price_training = training[(training['WinBoundaryMarginPrice'].notnull())&(training['WinAboveObjectiveWt']>0)]
    loss_above_margin_price_training = training[(training['LossBoundaryMarginPrice'].notnull())&(training['LossAboveObjectiveWt']>0)]
    win_below_margin_price_training = training[(training['WinBoundaryMarginPrice'].notnull())&(training['WinBelowObjectiveWt']>0)]
    loss_below_margin_price_training = training[(training['LossBoundaryMarginPrice'].notnull())&(training['LossBelowObjectiveWt']>0)]
    
    win_above_margin_price_validation = validation[(validation['WinBoundaryMarginPrice'].notnull())&(validation['WinAboveObjectiveWt']>0)]
    loss_above_margin_price_validation = validation[(validation['LossBoundaryMarginPrice'].notnull())&(validation['LossAboveObjectiveWt']>0)]
    win_below_margin_price_validation = validation[(validation['WinBoundaryMarginPrice'].notnull())&(validation['WinBelowObjectiveWt']>0)]
    loss_below_margin_price_validation = validation[(validation['LossBoundaryMarginPrice'].notnull())&(validation['LossBelowObjectiveWt']>0)]

    for m in range(1, win_simulation_cnt+1, 1):

        simulations_scenario = win_below_margin_price_training.copy()
        simulations_scenario['SimulatedMarginPrice'] = simulations_scenario['WinBoundaryMarginPrice'] - m*simulation_step_price_chg
        simulations_scenario['SimulatedWinBit'] = 1
        simulations_scenario['ObjectiveWt'] = simulations_scenario['WinBelowObjectiveWt']
        simulations_scenario.drop(columns=['WinBoundaryMarginPrice','LossBoundaryMarginPrice','LookId'], inplace=True, errors = False)
        simulations_training.append(simulations_scenario)
        
    for m in range(1, win_simulation_cnt+1, 1):

        simulations_scenario = win_above_margin_price_training.copy()
        simulations_scenario['SimulatedMarginPrice'] = simulations_scenario['WinBoundaryMarginPrice'] + m*simulation_step_price_chg
        simulations_scenario['SimulatedWinBit'] = 1
        simulations_scenario['ObjectiveWt'] = simulations_scenario['WinAboveObjectiveWt']
        simulations_scenario.drop(columns=['WinBoundaryMarginPrice','LossBoundaryMarginPrice','LookId'], inplace=True, errors = False)
        simulations_training.append(simulations_scenario)
     
    for m in range(1, loss_simulation_cnt+1, 1):

        simulations_scenario = loss_below_margin_price_training.copy()
        simulations_scenario['SimulatedMarginPrice'] = simulations_scenario['LossBoundaryMarginPrice'] - m*simulation_step_price_chg
        simulations_scenario['SimulatedWinBit'] = 0
        simulations_scenario['ObjectiveWt'] = simulations_scenario['LossBelowObjectiveWt']
        simulations_scenario.drop(columns=['WinBoundaryMarginPrice','LossBoundaryMarginPrice','LookId'], inplace=True, errors = False)
        simulations_training.append(simulations_scenario)
        
    for m in range(1, loss_simulation_cnt+1, 1):

        simulations_scenario = loss_above_margin_price_training.copy()
        simulations_scenario['SimulatedMarginPrice'] = simulations_scenario['LossBoundaryMarginPrice'] + m*simulation_step_price_chg
        simulations_scenario['SimulatedWinBit'] = 0
        simulations_scenario['ObjectiveWt'] = simulations_scenario['LossAboveObjectiveWt']
        simulations_scenario.drop(columns=['WinBoundaryMarginPrice','LossBoundaryMarginPrice','LookId'], inplace=True, errors = False)
        simulations_training.append(simulations_scenario)    

    del win_above_margin_price_training
    del loss_above_margin_price_training
    del win_below_margin_price_training
    del loss_below_margin_price_training
    del simulations_scenario

    simulations_training = pd.concat(simulations_training)
    
    for m in range(1, win_simulation_cnt+1, 1):

        simulations_scenario = win_below_margin_price_validation.copy()
        simulations_scenario['SimulatedMarginPrice'] = simulations_scenario['WinBoundaryMarginPrice'] - m*simulation_step_price_chg
        simulations_scenario['SimulatedWinBit'] = 1
        simulations_scenario['ObjectiveWt'] = simulations_scenario['WinBelowObjectiveWt']
        simulations_scenario.drop(columns=['WinBoundaryMarginPrice','LossBoundaryMarginPrice','LookId'], inplace=True, errors = False)
        simulations_validation.append(simulations_scenario)
        
    for m in range(1, win_simulation_cnt+1, 1):

        simulations_scenario = win_above_margin_price_validation.copy()
        simulations_scenario['SimulatedMarginPrice'] = simulations_scenario['WinBoundaryMarginPrice'] + m*simulation_step_price_chg
        simulations_scenario['SimulatedWinBit'] = 1
        simulations_scenario['ObjectiveWt'] = simulations_scenario['WinAboveObjectiveWt']
        simulations_scenario.drop(columns=['WinBoundaryMarginPrice','LossBoundaryMarginPrice','LookId'], inplace=True, errors = False)
        simulations_validation.append(simulations_scenario)
     
    for m in range(1, loss_simulation_cnt+1, 1):

        simulations_scenario = loss_below_margin_price_validation.copy()
        simulations_scenario['SimulatedMarginPrice'] = simulations_scenario['LossBoundaryMarginPrice'] - m*simulation_step_price_chg
        simulations_scenario['SimulatedWinBit'] = 0
        simulations_scenario['ObjectiveWt'] = simulations_scenario['LossBelowObjectiveWt']
        simulations_scenario.drop(columns=['WinBoundaryMarginPrice','LossBoundaryMarginPrice','LookId'], inplace=True, errors = False)
        simulations_validation.append(simulations_scenario)
        
    for m in range(1, loss_simulation_cnt+1, 1):

        simulations_scenario = loss_above_margin_price_validation.copy()
        simulations_scenario['SimulatedMarginPrice'] = simulations_scenario['LossBoundaryMarginPrice'] + m*simulation_step_price_chg
        simulations_scenario['SimulatedWinBit'] = 0
        simulations_scenario['ObjectiveWt'] = simulations_scenario['LossAboveObjectiveWt']
        simulations_scenario.drop(columns=['WinBoundaryMarginPrice','LossBoundaryMarginPrice','LookId'], inplace=True, errors = False)
        simulations_validation.append(simulations_scenario)    

    del win_above_margin_price_validation
    del loss_above_margin_price_validation
    del win_below_margin_price_validation
    del loss_below_margin_price_validation
    del simulations_scenario

    simulations_validation = pd.concat(simulations_validation)

    print('Number of Training simulations created: ' + f"{simulations_training.shape[0]:,}", flush=True)
    print('Number of Validation simulations created: ' + f"{simulations_validation.shape[0]:,}", flush=True)
    
    actuals_training = training.copy()
    actuals_validation =validation.copy()
  

    actuals_training.drop(columns=['WinBoundaryMarginPrice', 'LossBoundaryMarginPrice', 'SimulatedWinBit'], inplace=True, errors = False)
    actuals_validation.drop(columns=['WinBoundaryMarginPrice', 'LossBoundaryMarginPrice', 'SimulatedWinBit'], inplace=True, errors = False)
    

    return simulations_training, simulations_validation, actuals_training, actuals_validation


def train_model(model_path, simulations_training, simulations_validation, actuals_training,actuals_validation, batch_size=64, 
                epoch_cnt=30, learning_rate=5e-6):

    drop_col = ['SimulatedWinBit','ObjectiveWt', \
                'SimulatedMarginPrice','WinAboveObjectiveWt','WinBelowObjectiveWt',
                'LossAboveObjectiveWt','LossBelowObjectiveWt', 'BenchMarginPrice', 'MarginPrice']

    Y_simulations_training = simulations_training['SimulatedWinBit']
    X_simulations_training = simulations_training.drop(columns=drop_col, errors = False)
    X1_simulations_training = simulations_training['SimulatedMarginPrice']
    X2_simulations_training = simulations_training['ObjectiveWt']
    Bench_training = simulations_training['BenchMarginPrice']

    Y_simulations_validation = simulations_validation['SimulatedWinBit']
    X_simulations_validation = simulations_validation.drop(columns=drop_col, errors = False)
    X1_simulations_validation = simulations_validation['SimulatedMarginPrice']
    X2_simulations_validation = simulations_validation['ObjectiveWt']
    Bench_validation = simulations_validation['BenchMarginPrice']

    drop_col =['LookId','WinAboveObjectiveWt','WinBelowObjectiveWt','LossAboveObjectiveWt', 
               'LossBelowObjectiveWt', 'BenchMarginPrice']

    X_actuals_training = actuals_training.drop(columns=drop_col)
    X_actuals_validation = actuals_validation.drop(columns=drop_col)
  

    print('Number of features included: ' + f"{X_actuals_training.shape[1]:,}", flush=True)
    
    class_weight = {0: 1,
                    1: 1}
    
    print('Normalizing data...', flush=True)
    try:
        scaler = StandardScaler(copy=False)
        scaler.fit(X_actuals_training)
    
        X_simulations_training = scaler.transform(X_simulations_training, copy=False)
        X_simulations_validation = scaler.transform(X_simulations_validation, copy=False)
    
        X_actuals_training = scaler.transform(X_actuals_training, copy=False)
        X_actuals_validation = scaler.transform(X_actuals_validation, copy=False)

    except:
        pass

    print('Setting up NN architecture...', flush=True)
    calc_metrics = [
        keras.metrics.Precision(name='Precision'),
        keras.metrics.Recall(name='Recall'),
        keras.metrics.AUC(name='Auc'),
        # keras.metrics.AUC(name='prc', curve='PR'),
        keras.metrics.BinaryCrossentropy(name='LogLoss')
    ]

    inputA = Input(shape=(X_simulations_training.shape[1],))
    inputB = Input(shape=(1,))
    inputC = Input(shape=(1,))
    inputD = Input(shape=(1,))
    call_back = TimeHistory()

    epoch_print_callback = LambdaCallback(
        on_epoch_end = lambda epoch, logs: print("EpochNumber:",str(epoch+1) + "/"+ str(epoch_cnt),
                                                "TrainingLoss:",np.round(logs.get("loss"),4),
                                                "ValidationLoss:",np.round(logs.get("val_loss"),4),
                                                "TrainingPrecision:",np.round(logs.get("Precision"),4),
                                                "ValidationPrecision:",np.round(logs.get("val_Precision"),4),
                                                "TrainingRecall:",np.round(logs.get("Recall"),4),
                                                "ValidationRecall:",np.round(logs.get("val_Recall"),4),flush = True, sep = ' ',end = ""),flush = True)

    my_callbacks = [epoch_print_callback,tf.keras.callbacks.EarlyStopping(patience=2, restore_best_weights = True), call_back]

    try:
        Y_simulations_training = np.asarray(Y_simulations_training).astype(np.float32)
        X_simulations_training = np.asarray(X_simulations_training).astype(np.float32)
        X1_simulations_training = np.asarray(X1_simulations_training).astype(np.float32)
        X2_simulations_training = np.asarray(X2_simulations_training).astype(np.float32)
        Bench_training = np.asarray(Bench_training).astype(np.float32)
    
        Y_simulations_validation = np.asarray(Y_simulations_validation).astype(np.float32)
        X_simulations_validation = np.asarray(X_simulations_validation).astype(np.float32)
        X1_simulations_validation = np.asarray(X1_simulations_validation).astype(np.float32)
        X2_simulations_validation = np.asarray(X2_simulations_validation).astype(np.float32)
        Bench_validation = np.asarray(Bench_validation).astype(np.float32)

    except:
        pass

    S = Dense(50, activation='sigmoid')(inputA)
    S = Dropout(0.2)(S)
    S = Dense(50, activation='sigmoid')(S)
    S = Dense(1, name='S')(S)

    dM = Dense(50, activation='sigmoid')(inputA)
    dM = Dropout(0.2)(dM)
    dM = Dense(50, activation='sigmoid')(dM)
    dM = Dense(1, name='dM')(dM)

    W = Dense(50, activation='sigmoid')(inputA)
    W = Dropout(.2)(W)
    W = Dense(50, activation='sigmoid')(W)
    W = Dense(1, name='W')(W)

    Wmodified = Dense(1,trainable = False, activation='sigmoid', name = 'w_modified', kernel_initializer=keras.initializers.Ones(),
                bias_initializer=keras.initializers.Zeros())(W)
    dMmodified = keras.layers.Add()([inputB, -inputC,-dM])
    ExpdMModified = keras.layers.Multiply()([8*tf.exp(S), dMmodified])
    dMfinal  = Dense(1,trainable = False, activation='sigmoid', kernel_initializer=keras.initializers.Ones(),
                bias_initializer=keras.initializers.Zeros())(-ExpdMModified)
    Zmodified = keras.layers.Multiply()([Wmodified, dMfinal])
    ZmodifiedWtAdj = keras.layers.Multiply()([Zmodified, inputD])

    out = Dense(1, trainable=False, kernel_initializer=keras.initializers.Ones(),
                bias_initializer=keras.initializers.Zeros())(ZmodifiedWtAdj)
    model = keras.models.Model(inputs=[inputA, inputB, inputC, inputD], outputs=out)
    model.compile(loss='binary_crossentropy', optimizer=keras.optimizers.Adam(
        learning_rate=learning_rate), metrics=calc_metrics)
    model.layers[-1].trainable = True
    model.summary()

    print('Training the model...', flush=True)
    try:
        training_log = model.fit([X_simulations_training, X1_simulations_training, Bench_training, X2_simulations_training], Y_simulations_training, validation_data=(
            [X_simulations_validation, X1_simulations_validation, Bench_validation,X2_simulations_validation], Y_simulations_validation),
            batch_size=batch_size, epochs=epoch_cnt, callbacks=my_callbacks, class_weight=class_weight,verbose = 0)
        
        # epoch_number = [epoch for epoch in range(1,len(training_log.history['loss'])+1)]
        training_loss = training_log.history['loss']
        validation_loss = training_log.history['val_loss']
        training_log_json = json.dumps({'TrainingLoss':[round(elem,4) for elem in training_loss],
                                 'ValidationLoss': [round(elem,4) for elem in validation_loss],
                                 'TimePerEpoch(s)':[round(elem,2) for elem in call_back.times]})
    except:
        pass
        
    training_performance = model.evaluate([X_simulations_training, X1_simulations_training, Bench_training, X2_simulations_training], Y_simulations_training,verbose = 0)
    validation_performance = model.evaluate([X_simulations_validation, X1_simulations_validation, Bench_validation,X2_simulations_validation], Y_simulations_validation,verbose = 0)
    
    if(len(training_log.history['val_loss']) == epoch_cnt):
       training_termination_condition = 'Max epochs reached'
    else:
        training_termination_condition = 'Validation loss increased in two successive epochs'
        
    print('Calculating performance metrics...', flush=True)
    performance_metrics = {
        'TrainingPrecision': np.round(training_performance[1], 4),
        'TrainingRecall': np.round(training_performance[2], 4),
        'TrainingAuc': np.round(training_performance[3], 4),
        'TrainingLogLoss': np.round(training_performance[0], 4),
        'ValidationPrecision': np.round(validation_performance[1], 4),
        'ValidationRecall': np.round(validation_performance[2], 4),
        'ValidationAuc': np.round(validation_performance[3], 4),
        'ValidationLogLoss': np.round(validation_performance[0], 4),
        'TrainingTerminationCondition': training_termination_condition,
        'TerminalEpoch':len(training_log.history['val_loss'])
    }

    performance_metrics_json = json.dumps(performance_metrics)

    Path(model_path).mkdir(exist_ok=True)

    print('Saving the performance metrics...', flush=True)
    with open(model_path+'perf.pkl', 'wb') as f:
        pickle.dump(performance_metrics, f)
    with open(model_path+'train_log.pkl', 'wb') as f:
        pickle.dump(training_log_json, f)
    # SQLAction(args, proc, 'TrainSuccess', [performance_metrics_json, training_log_json])

    print('Saving the model...', flush=True)
    # data = SQLAction(args, proc, 'GetModelPath')
    # model_path = data['ModelPath'][0] + '\\'
    # model_path = '\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Cronus\\Market\\MarginOptimization\\Model\\71888298\\'
    save_model(model, model_path+'Model.h5')

    print('Saving scaler...', flush=True)
    with open(model_path + 'Scaler.pkl', 'wb') as f:
        pickle.dump(scaler, f)
    
    with open(model_path + 'training_log.pkl', 'wb') as f:
        pickle.dump(training_log, f)
    # print('Saving training log...', flush=True)
    # with open(model_path + 'TrainingLog.pkl', 'wb') as f:
    #     pickle.dump(training_log.history, f)
    
    return model, X_actuals_training, actuals_training

#%%
if __name__=='__main__':
    simulations_training, simulations_validation, actuals_training,actuals_validation=load_process_data('insample_small.csv')
    train_model('production\\', simulations_training, simulations_validation, actuals_training, actuals_validation)




# %%
