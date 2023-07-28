#%%
from hptune import load_process_data2
from hptune import TimeHistory

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

# %%
def train_model(model_path, simulations_training, simulations_validation, actuals_training,actuals_validation, batch_size=64, 
                epoch_cnt=30, learning_rate=1e-5):

    drop_col = ['SimulatedWinBit','ObjectiveWt', \
                'WinAboveObjectiveWt','WinBelowObjectiveWt',
                'LossAboveObjectiveWt','LossBelowObjectiveWt', 'MarginPrice']

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
    X_actuals_training['SimulatedMarginPrice'] = X_actuals_training['MarginPrice']
    X_actuals_training.drop(columns=['MarginPrice'], inplace=True)
    X_actuals_validation = actuals_validation.drop(columns=drop_col)
    X_actuals_validation['SimulatedMarginPrice'] = X_actuals_validation['MarginPrice']
    X_actuals_validation.drop(columns=['MarginPrice'], inplace=True)
    
    print('Number of features included: ' + f"{X_actuals_training.shape[1]:,}", flush=True)
    
    class_weight = {0: 1,
                    1: 1}
    
    print('Normalizing data...', flush=True)

    scaler = StandardScaler(copy=False)
    scaler.fit(X_actuals_training)

    X_simulations_training = scaler.transform(X_simulations_training, copy=False)
    X_simulations_validation = scaler.transform(X_simulations_validation, copy=False)

    X_actuals_training = scaler.transform(X_actuals_training, copy=False)
    X_actuals_validation = scaler.transform(X_actuals_validation, copy=False)

    print('Setting up NN architecture...', flush=True)
    calc_metrics = [
        keras.metrics.Precision(name='Precision'),
        keras.metrics.Recall(name='Recall'),
        keras.metrics.AUC(name='Auc'),
        # keras.metrics.AUC(name='prc', curve='PR'),
        keras.metrics.BinaryCrossentropy(name='LogLoss')
    ]

    inputA = Input(shape=X_simulations_training.shape[1:])
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


    layer1 = keras.layers.Dense(units=1500, kernel_initializer='glorot_uniform', 
                                kernel_regularizer=keras.regularizers.l2(.01))(inputA)
    a1 = keras.layers.Activation(activation='relu')(layer1)
    
    out = Dense(1, activation='sigmoid')(a1)
    
    model = keras.models.Model(inputs=[inputA], outputs=out)
    model.compile(loss='binary_crossentropy', optimizer=keras.optimizers.Adam(
        learning_rate=learning_rate), metrics=calc_metrics)
    model.layers[-1].trainable = True
    model.summary()

    print('Training the model...', flush=True)

    training_log = model.fit([X_simulations_training], Y_simulations_training, validation_data=(
        [X_simulations_validation], Y_simulations_validation),
        batch_size=batch_size, epochs=epoch_cnt,callbacks=my_callbacks, class_weight=class_weight,verbose = 1)
    
    # epoch_number = [epoch for epoch in range(1,len(training_log.history['loss'])+1)]
    training_loss = training_log.history['loss']
    validation_loss = training_log.history['val_loss']
    training_log_json = json.dumps({'TrainingLoss':[round(elem,4) for elem in training_loss],
                                'ValidationLoss': [round(elem,4) for elem in validation_loss],
                                'TimePerEpoch(s)':[round(elem,2) for elem in call_back.times]})

        
    training_performance = model.evaluate([X_simulations_training], Y_simulations_training,verbose = 1)
    validation_performance = model.evaluate([X_simulations_validation], Y_simulations_validation,verbose = 1)
    
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
    print(model_path)
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

if __name__=='__main__':
    simulations_training, simulations_validation, actuals_training,actuals_validation=load_process_data2('insample_small.csv')
    train_model('C:\\Users\\dflanner\\qed\\Aspen\\MarginOptimization\\dev\\hptuning\\wide_relu\\', simulations_training, simulations_validation, actuals_training, actuals_validation)


