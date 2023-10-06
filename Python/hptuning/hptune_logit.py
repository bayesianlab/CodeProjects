from hptune import load_process_data2
from hptune import TimeHistory

from sklearn.linear_model import LogisticRegression
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
    
    data = pd.concat([X_simulations_training, X1_simulations_training, Bench_training], axis=1)
    

    model = LogisticRegression()
    X = np.concatenate([X_simulations_training, np.reshape(X1_simulations_training.to_numpy(), (X_simulations_training.shape[0],1)), 
                        np.reshape(Bench_training.to_numpy(), (X_simulations_training.shape[0],1))], axis=1)
    model.fit(X, Y_simulations_training)


    Path(model_path).mkdir(exist_ok=True)

    # SQLAction(args, proc, 'TrainSuccess', [performance_metrics_json, training_log_json])

    print('Saving the model...', flush=True)
    # data = SQLAction(args, proc, 'GetModelPath')
    # model_path = data['ModelPath'][0] + '\\'
    # model_path = '\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Cronus\\Market\\MarginOptimization\\Model\\71888298\\'
    with open(model_path + 'Model.pkl', 'wb') as f:
        pickle.dump(model, f)

    with open(model_path + 'feature_names_in.pkl', 'wb') as f:
        pickle.dump(data.columns.to_list(), f)

    # print('Saving training log...', flush=True)
    # with open(model_path + 'TrainingLog.pkl', 'wb') as f:
    #     pickle.dump(training_log.history, f)
    
    return model, X_actuals_training, actuals_training


if __name__=='__main__':
    simulations_training, simulations_validation, actuals_training,actuals_validation=load_process_data2('insample_small.csv')
    train_model('C:\\Users\\dflanner\\qed\\Aspen\\MarginOptimization\\dev\\hptuning\\logit\\', simulations_training, simulations_validation, actuals_training, actuals_validation)


