
#%%
from keras.layers import BatchNormalization
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
import numpy as np
import seaborn as sns
from sklearn.model_selection import train_test_split
from pdHelper import selectData
from MizerTrain_verbatim import error_handler, TimeHistory
from pdHelper import execQuery
from keras.callbacks import LambdaCallback
from pathlib import Path 
tf.keras.utils.set_random_seed(4)
warnings.filterwarnings('ignore')
from functools import partial
import keras_tuner

def load_process_data(file, win_simulation_cnt=25, loss_simulation_cnt=25, simulation_step_price_chg=.01):
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
    # data = data.head(1000)
    data=pd.read_csv(file)
    drop_cols=[]
    print('Number of looks loaded: ' + f"{data.shape[0]:,}", flush=True)

    if (bool(drop_cols)):
        print('Removing not needed features:' + str(drop_cols).strip('[]'), flush=True)
        data.drop(columns=drop_cols, inplace = True, errors=False)

    categorical_features = data.select_dtypes(include=['object']).columns.to_list()

    print('Number of columns included: ' + f"{data.shape[1]:,}", flush=True)

    print('Performing OHE...', flush=True)
    dummy_cols_data = pd.get_dummies(data, columns=categorical_features)
    data.drop(columns=categorical_features, inplace=True)

    try:
        data = data.merge(dummy_cols_data)
    except:
        error_handler('DataType Issues encountered while doing one hot encoding...')

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


def model_build(hp,inputA,inputB,inputC,inputD):
    
        
    calc_metrics = [
        keras.metrics.Precision(name='Precision'),
        keras.metrics.Recall(name='Recall'),
        keras.metrics.AUC(name='Auc'),
        keras.metrics.BinaryCrossentropy(name='LogLoss')
    ]

    
    S = Dense(hp.Int('dense_start_'+'S',min_value = 100, max_value = 1000, step=5), activation='sigmoid')(inputA)
    S = BatchNormalization()(S)
    # S = Dropout(hp.Choice('dropout_start_'+'S', values = [0.1,0.2,0.3,0.4,0.5]))(S)
    for j in range(hp.Int('layersS',min_value=1, max_value=3, step=1)):
        S = Dense(units=hp.Int('dense_' + str(j)+'S', min_value=100, max_value=1000, step=50), activation='sigmoid')(S)
        S = BatchNormalization()(S)
        # S = Dropout(hp.Choice('dropout_'+str(j)+'S', values = [0.1,0.2,0.3,0.4,0.5]))(S)
    S = Dense(1, name='S')(S)
    
    
    dM = Dense(hp.Int('dense_start_'+'dM',min_value = 100, max_value = 1000, step=5), activation='sigmoid')(inputA)
    dM = BatchNormalization()(dM)
    # dM = Dropout(hp.Choice('dropout_start_'+'dM', values = [0.1,0.2,0.3,0.4,0.5]))(dM)
    for j in range(hp.Int('layersM',min_value=1, max_value=3, step=1)):
        dM = Dense(units=hp.Int('dense_' + str(j)+'dM', min_value=100, max_value=1000, step=50), activation='sigmoid')(dM)
        dM = BatchNormalization()(dM)
        # dM = Dropout(hp.Choice('dropout_'+str(j)+'dM', values = [0.1,0.2,0.3,0.4,0.5]))(dM)
    dM = Dense(1, name='dM')(dM)
    
    W = Dense(units = hp.Int('dense_start_'+'W', min_value=100, max_value=1000, step=5),activation = 'sigmoid')(inputA)
    W = BatchNormalization()(W)
    # W = Dropout(hp.Choice('dropout_start_'+'W', values = [0.1,0.2,0.3,0.4,0.5]))(W)
    for i in range(hp.Int('layersW',min_value=1, max_value=3, step=1)):
        W = Dense(hp.Int('units_'+str(i)+'W',min_value = 100, max_value = 1000, step=5), activation='sigmoid')(W)
        W = BatchNormalization()(W)
        # W = Dropout(hp.Choice('dropout_'+str(i)+'W', values = [0.1,0.2,0.3,0.4,0.5]))(W)
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
        #learning_rate=hp.Float("learning_rate",min_value = 1e-8, max_value = 1e-2,sampling = 'log')), 
        learning_rate=1e-6), 
                  metrics=calc_metrics)
    model.layers[-1].trainable = True
    return model



def tune_hyperpara(model_path, simulations_training, simulations_validation, actuals_training,
                   actuals_validation, batch_size=64, epoch_cnt=30, learning_rate=1e-5,max_trials=250):

    drop_col = ['SimulatedWinBit','ObjectiveWt', \
                'SimulatedMarginPrice','WinAboveObjectiveWt','WinBelowObjectiveWt','LossAboveObjectiveWt','LossBelowObjectiveWt']

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

  
    drop_col =['LookId','WinAboveObjectiveWt','WinBelowObjectiveWt','LossAboveObjectiveWt','LossBelowObjectiveWt']

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
        error_handler('Memory errors encountered while normalizing the data...')

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
        error_handler('Memory errors encountered while casting into numpy arrays...')
    
    
    #max_trials = 200
    build_model = partial(model_build,inputA = inputA,inputB = inputB,inputC = inputC,inputD = inputD)

    tuner = keras_tuner.BayesianOptimization(build_model,
                          objective='val_loss',
                          max_trials = max_trials,
                          tune_new_entries = True,
                          overwrite = True,
                          directory=model_path+"newhp_test_0710_no_0_dropout",
                          project_name="tune_hypermodel")
         
    stop_early = tf.keras.callbacks.EarlyStopping(monitor='val_loss', patience=2)
    tuner.search_space_summary()
    tuner.search([X_simulations_training, X1_simulations_training, Bench_training, X2_simulations_training], Y_simulations_training, validation_data=(
                [X_simulations_validation, X1_simulations_validation, Bench_validation,X2_simulations_validation], Y_simulations_validation),
                 batch_size=batch_size, epochs=epoch_cnt, callbacks=[stop_early], class_weight=class_weight,verbose = 1)
      
         # Get the optimal hyperparameters
    best_hps=tuner.get_best_hyperparameters(num_trials=1)[0]
    best_model = tuner.get_best_models(1)[0]  
    #tuner.results_summary()
    #best_model.summary()
    
    trials = tuner.oracle.get_best_trials(num_trials=max_trials)
    HP_list = []
    for trial in trials:
        HP_list.append(trial.hyperparameters.get_config()["values"] | {"Score": trial.score})
    HP_df = pd.DataFrame(HP_list)
    Path(model_path).mkdir(exist_ok=True)
    keras.models.save_model(best_model, model_path+"Model.h5")
    with open(model_path+"Scaler.kl", 'wb') as f:
        pickle.dump(scaler, f)
    HP_df.to_csv(model_path+"hptune_shallow.csv", index=False, na_rep='0')
    
    return HP_df

#%%
if __name__=='__main__':
    simulations_training, simulations_validation, actuals_training,actuals_validation=load_process_data('insample_small.csv')
    tune_hyperpara("shallow_wide\\", simulations_training, simulations_validation, actuals_training,
                   actuals_validation)

# %%
