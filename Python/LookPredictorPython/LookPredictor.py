#%%
from datetime import datetime

import pandas as pd 
import numpy as np
import matplotlib.pyplot as plt 
import seaborn as sns 
from statsmodels.graphics.tsaplots import plot_acf, plot_pacf
import statsmodels.api as sm 
from  sklearn.linear_model import LinearRegression
from sklearn.model_selection import TimeSeriesSplit
from scipy.stats import t as student_t
import warnings
from sklearn.preprocessing import StandardScaler
from sklearn.gaussian_process import GaussianProcessRegressor
from sklearn.gaussian_process.kernels import RBF
import tensorflow as tf
from tensorflow import keras 

warnings.simplefilter(action='ignore', category=FutureWarning)
warnings.simplefilter(action='ignore', category=UserWarning)

pd.set_option('display.max_rows', None)
class PrepareLookPredictorDataError(Exception):
    def __init__(self, message) -> None:
        self.message = message 
        
class SummarizeResultsError(Exception):
    def __init__(self, message) -> None:
        self.message = message 
        
class ModelError(Exception):
    def __init__(self, message, *args: object) -> None:
        super().__init__(*args)
        self.message = message 
        
class PrepareLookPredictorData:
    def __init__(self) -> None:
        pass

    def prep_data(self, data, object_columns, cont_columns,
                  split_date, lagged_variables_dict=None, interactions=None,train_cutoff=None):
        
        if 'Dt' not in data.columns:
            raise PrepareLookPredictorDataError('Dt not in data columns.')
        if 'LookCnt' in cont_columns:
            raise PrepareLookPredictorDataError('LookCnt cannot be a predictor.')
        interaction_cols = [] 
        model_data = data.copy()
        model_data['Dt'] = pd.to_datetime(model_data['Dt'])
        model_data[object_columns] = model_data[object_columns].astype('int')        
        model_data[object_columns] = model_data[object_columns].astype('object')
        model_data[cont_columns] = model_data[cont_columns].astype('float64')
        if lagged_variables_dict is not None:
            lagged_vars =[] 
            names = []
            max_lag = 0  
            for k,v in lagged_variables_dict.items():
                if v > max_lag:
                    max_lag=v
                for i in range(1,v+1):
                    lagged_vars.append(model_data[k].shift(i))
                    names.append(''.join([k,'_Lag_', str(i)]))
            lv = pd.concat(lagged_vars, axis=1)
            lv.columns = names
            cont_columns += names 
            model_data = pd.concat([model_data,lv], axis=1)
            model_data = model_data.iloc[max_lag:,:]            
        if train_cutoff is not None:
            model_data = model_data[model_data['Dt'] > train_cutoff]
        if len(object_columns) > 0:
            dummies = pd.get_dummies(model_data[object_columns], drop_first=True)
            dc = dummies.columns.to_list()   
        else:
            dummies = pd.DataFrame() 
            dc = [] 
        self.dummy_columns = dc          
        self.dummy_columns.append('const') 
        model_data = pd.concat([model_data['Dt'], model_data['LookCnt'],
                                dummies, model_data[cont_columns]], axis=1)
        c = model_data.columns.to_list()
        c[0] = 'Dt'
        model_data.columns = c
        model_data['const'] = 1
        other_cols = []
        frame_cols = []  
        if interactions is not None and len(interactions) > 0:
            if not isinstance(interactions[0], tuple):
                raise PrepareLookPredictorDataError('Interactions columns are not input correctly.')
            for tup in interactions:
                if tup[0] in object_columns:
                    str1 = tup[0] + '_'
                else:
                    str1 = tup[0] 
                if tup[1] in object_columns:
                    str2 = tup[1] + '_'
                else:
                    str2 = tup[1] 
                for pass1 in model_data.columns:
                    if pass1.startswith(str1):
                        for pass2 in model_data.columns:
                            if pass2.startswith(str2):
                                newcol = ''.join([pass1, 'x', pass2])
                                other_cols.append(newcol)
                                frame_cols.append(model_data[pass1] * model_data[pass2])
                            
            newframe = pd.concat(frame_cols, axis=1)
            newframe.columns = other_cols
            model_data = pd.concat([model_data, newframe], axis=1)
        
        training = model_data[model_data['Dt']<split_date]
        future = model_data[model_data['Dt']>=split_date]
        all_cols = cont_columns+other_cols+self.dummy_columns
        self.Xtrain = training[all_cols]
        self.future_time = model_data.loc[model_data['Dt']>=split_date, 'Dt']
        self.insample_time =  model_data.loc[model_data['Dt']<split_date, 'Dt']
        for i in self.Xtrain[self.dummy_columns].sum():
            if i == 0:
                raise PrepareLookPredictorDataError('Not enough data in training, this will cause singular matrix error in estimation.')
        self.ytrain = training['LookCnt']
        self.Xfuture = future[all_cols]

        self.yfuture = pd.DataFrame({'Dt':self.future_time, 
                                     'yfuture': future['LookCnt']})
        self.yfuture.reset_index(drop=True, inplace=True)
        self.column_names_in_X = self.Xtrain.columns.to_list() 
        self.future_time.reset_index(drop=True, inplace=True)
        self.insample_time.reset_index(drop=True,inplace=True)
               

def make_results_dataframe(ytrue, ypred, name):
    ypred = np.squeeze(np.array(ypred))
    df = pd.DataFrame({'Forecast':ypred, 'MAE':np.abs(ytrue['yfuture']-ypred),
                  'RMSE':np.square(ytrue['yfuture']-ypred) })
    df['Method'] = name 
    df['Dt'] = ytrue['Dt']
    return df 



class Model1:
    
    def __init__(self):
        self.yhat = None 
        self.var_eps_hat = None
        self.model1 = None 
        self.model2 = None 
        self.yhatf = None
        self.forecast_data = None

    def stage1_regression(self, X,y):
        X['const'] = 1
        N = len(y)
        K = X.shape[1]
        self.feature_names_in = list(X.columns)
        self.model1 = LinearRegression(fit_intercept=False)
        self.model1.fit(X, y)  
        self.Beta = np.reshape(self.model1.coef_, (-1,1))
        self.yhat = self.model1.predict(X)
        X = X.astype('float64').to_numpy() 
        y = y.astype('float64').to_numpy() 
        self.residuals = y - self.yhat
        self.sigma2hat = np.matmul(self.residuals.T, self.residuals)/(N-K) 
        XX = np.matmul(X.T,X) 
        XXinv = np.linalg.solve(XX, np.identity(K))
        tstats = self.model1.coef_/(np.sqrt((self.sigma2hat*XXinv).diagonal()))
        output = [(i,j,k) for i,j,k in zip(self.feature_names_in, self.model1.coef_.flatten(), 
                                            tstats.flatten())]
        self.output = pd.DataFrame(output, columns=['Coef_Name', 'Coef_Val', 't-stat'])
        self.output['P-value'] = 2*(1-student_t.cdf(np.abs(self.output.iloc[:,2]), N-K, 0, 1))
        pd.set_option('display.max_rows', None)
        print(self.output)
        pd.set_option('display.max_rows', 10)

    def stage2_regression(self, ar_lag_num):
        resid_lags = []
        col_names = [] 
        self.residuals = pd.DataFrame(self.residuals)
        for i in range(1,ar_lag_num+1):
            resid_lags.append(self.residuals.shift(periods=i))
            col_names.append('Resid_Lag_'+str(i))
        self.ResidualMatrix = pd.concat(resid_lags, axis=1).iloc[ar_lag_num:,:]
        self.y_eps = self.residuals.iloc[ar_lag_num:,:]
        self.ResidualMatrix.columns = col_names
        self.model2 = LinearRegression(fit_intercept=False)
        self.model2.fit(self.ResidualMatrix.astype('float64').to_numpy(),self.y_eps)
        self.Theta = np.reshape(self.model2.coef_ , (-1,1))
        self.y_eps_hat = self.model2.predict(self.ResidualMatrix.astype('float64'))
        
    def forecast_simple(self, Xtrain, ytrain, Xfuture, yfuture):
        if 'Dt' not in yfuture.columns: 
            raise ModelError('yfuture dataframe must contain forecast dates.')
        self.stage1_regression(Xtrain,ytrain)
        self.yhatf = self.model1.predict(Xfuture)
        self.forecast_data = make_results_dataframe(yfuture, self.yhatf,'LR')
        
    
    def forecast_update_parameters(self, Xtrain, ytrain, Xfuture, yfuture, ar_lags):
        if 'Dt' not in yfuture.columns: 
            raise ModelError('yfuture dataframe must contain forecast dates.')
        self.stage1_regression(Xtrain, ytrain)
        self.stage2_regression(ar_lags) 
        Xf = Xfuture.copy() 
        for i in self.feature_names_in:
            if i not in Xf.columns:
                Xf[i] = 0 
        Xf = Xf[self.feature_names_in]
        Xf = Xf.to_numpy()
        Rt = np.reshape(self.ResidualMatrix.iloc[-1,1:], 
                        (-1, self.ResidualMatrix.shape[1]-1))
        yf = yfuture.to_numpy()
        self.yhatf = [] 
        XT = Xtrain.copy()
        yT = ytrain.copy()
        yT = np.reshape(yT, (-1,1))
        p = 0
        while p < len(yfuture):
            mu = np.matmul(Xf[p, :], self.Beta).tolist()[0]
            ehat = np.matmul(Rt, self.Theta)
            yi = (mu + ehat).squeeze()
            Rt = np.roll(Rt, 1) 
            Rt[0,0] = (yi-yf[p]).flatten().tolist()[0]
            self.yhatf.append(yi)
            XT = np.concatenate( (XT, np.reshape(Xf[p,:],(1,-1)) ), axis=0)
            XT = pd.DataFrame(XT, columns=self.feature_names_in)
            yT = np.concatenate((yT, np.reshape(yf[p], (-1,1))), axis=0)
            yT = pd.DataFrame(yT)
            self.stage1_regression(XT,yT)
            self.stage2_regression(len(self.Theta))
            p+=1
        self.forecast_data = make_results_dataframe(yfuture, self.yhatf, 'Coefficient Updating')
        

    def forecast_ar(self, Xtrain, ytrain, Xfuture, yfuture, ar_lags):
        if 'Dt' not in yfuture.columns: 
            raise ModelError('yfuture dataframe must contain forecast dates.')
        self.stage1_regression(Xtrain, ytrain)
        self.stage2_regression(ar_lags)
        
        Xf = Xfuture.copy() 
        for i in self.feature_names_in:
            if i not in Xf.columns:
                Xf[i] = 0 
        Xf = Xf[self.feature_names_in]
        Xf = Xf.to_numpy() 
        Rt = np.reshape(np.atleast_2d(self.ResidualMatrix.iloc[-1,:].to_numpy()), (-1,1))
        yf = yfuture['yfuture'].to_numpy()
        self.yhatf = [] 
        XT = Xtrain.copy()
        yT = np.atleast_1d(ytrain.copy())
        yT = np.reshape(yT, (-1,1))
        p = 0
        
        while p < len(yfuture):
            mu = np.matmul(Xf[p, :], self.Beta).tolist()[0]
            ehat = np.matmul(Rt.T, self.Theta)
            yt1hat = (mu + ehat).squeeze()
            Rt = np.roll(Rt, 1) 
            Rt[0,0] = (yt1hat-yf[p]).flatten().tolist()[0]
            self.yhatf.append(yt1hat)
            p+=1
        self.forecast_data = make_results_dataframe(yfuture, self.yhatf, 'AR(10) + YL(20) + X')
        

class ModelLSTM:
    def __init__(self) -> None:
        self.yhat = None 
        self.model = None 
        self.yhatf = None
        self.forecast_data = None
    
    def forecast(self, Xtrain, ytrain, Xfuture, yfuture, dummy_columns):
        self.ssx = StandardScaler()
        self.ssy= StandardScaler() 
        continuous_columns = list(set(list(Xtrain.columns)) - set(dummy_columns))
        Xtrain[continuous_columns] = self.ssx.fit_transform(Xtrain[continuous_columns])
        ytrain = self.ssy.fit_transform(np.reshape(ytrain, (-1,1)))
        x3d = np.asarray(np.reshape(Xtrain, (Xtrain.shape[0], 1, Xtrain.shape[1]))).astype('float32')
        y3d = np.asarray(np.reshape(ytrain, (ytrain.shape[0], 1, 1))).astype('float32')
        Linput = keras.Input(shape=(x3d.shape[1], x3d.shape[2]))
        L1 = keras.layers.LSTM(units=10, activation='tanh')(Linput)
        D1 = keras.layers.Dense(units=1)(L1)
        self.model = keras.Model(inputs=Linput, outputs=D1, name='lstm_model')
        maeloss = keras.losses.MeanAbsoluteError(name='mae')
        maemetric = keras.losses.MeanAbsoluteError(name='MAE')
        self.model.compile(optimizer='adam', loss='mean_squared_error', metrics=[maemetric])
        self.model.fit(x3d, y3d, epochs=5, batch_size=1, learning_rate=1e-6, verbose=1)
        self.model.summary()
        Xfuture[continuous_columns] = self.ssx.fit_transform(Xfuture[continuous_columns])
        xf3d = np.asarray(np.reshape(Xfuture, (Xfuture.shape[0],1,  Xfuture.shape[1]))).astype('float32')
        self.yhatf = np.squeeze(self.ssy.inverse_transform(self.model.predict(xf3d)))
        self.forecast_data = make_results_dataframe(yfuture, self.yhatf, 'LSTM')

        
class SummarizeResults:
     
    def __init__(self, ActualsFrame, BaselineFrame, other_results=[]):
        if not isinstance(other_results, list):
            raise SummarizeResultsError('other_results must be dataframes in a list.')
        for i in ActualsFrame.columns:
            if i not in BaselineFrame.columns:
                raise SummarizeResultsError('Columns must match in Baseline and ActualsFrame.')
        self.Actuals= ActualsFrame
        self.Baseline= BaselineFrame
        for frame in other_results:
            for j in frame.columns:
                if j not in self.Baseline.columns:
                    raise SummarizeResultsError('All frame must have same columns.')
        other_results.append(self.Actuals)
        other_results.append(self.Baseline)
        self.all_results = pd.concat(other_results, axis=0)

    def plot(self):
        hue_order = list(np.sort(pd.unique(self.all_results['Method'])))
        print(self.all_results.dtypes)
        if hue_order[0] != 'Actuals':
            other = hue_order[0]        
            hue_order[0] = 'Actuals'
            i = hue_order[1:].index('Actuals') + 1
            hue_order[i] = other
        sns.lineplot(data=self.all_results, 
                     x='Dt', 
                     y='Forecast', 
                     hue='Method',
                     hue_order=hue_order,
                     style='Method',
                     style_order=hue_order,
                     marker='o')
        plt.xticks(rotation=45)
        plt.show() 
    
    def show_table(self):
        table = pd.DataFrame(self.all_results.groupby('Method').mean().sort_values('MAE'))
        table.reset_index(inplace=True)
        table['RMSE'] = np.sqrt(table['RMSE'])
        print(table[['Method', 'MAE', 'RMSE']])
    
            
#%% 
if __name__=='__main__':
    alldata = pd.read_csv('data.csv')

    split_date = '2024-02-07'
    train_cutoff = None
    lpd = PrepareLookPredictorData()
    lpd.prep_data(alldata, 
                  [ 'DayNum', 'WeekNum', 'ShortWeek', 'LastBusDayOfMonthBit', 
                   'FirstBusDayOfMonthBit', 'MarketEarlyCloseBit'], 
                  [ 'PctMonRemaining', 'PctYrRemaining',
                   'PrimaryRate30Y', 'ps_spread', 'PrimarySqd'], 
                  split_date,
                  train_cutoff=train_cutoff,
                  lagged_variables_dict={'LookCnt':20, 
                                         'PrimaryRate30Y':4,
                                         'ps_spread':3},
                  interactions=[('DayNum', 'PrimaryRate30Y'), 
                                ('DayNum', 'ShortWeek')])
    
    fm1 = Model1()
    fm1.forecast_ar(lpd.Xtrain, lpd.ytrain, lpd.Xfuture, lpd.yfuture, 10)


    lpd.yfuture.reset_index(drop=True, inplace=True)
    Actuals = lpd.yfuture.copy()
    Actuals.rename({'yfuture':'Forecast'}, inplace=True, axis=1)
    Actuals['MAE'] = 0
    Actuals['RMSE'] = 0
    Actuals['Method'] = 'Actuals'
    Actuals.rename({'LookCnt':'Forecast'}, axis=1, inplace=True)
    bl = pd.read_csv('forecasted_values.csv')
    bl.loc[:,'Dt'] = pd.to_datetime(bl['Dt'])
    Baseline = bl[bl['Dt']>=datetime.strptime(split_date,'%Y-%m-%d')].copy()
    Baseline.rename(columns={'Dt':'Dt', 'LookCnt':'Forecast'}, inplace=True)
    Baseline['MAE'] = np.abs((Baseline['Forecast'].to_numpy() - lpd.yfuture['yfuture'].to_numpy()))
    Baseline['RMSE'] = np.square(Baseline['Forecast'].to_numpy() - lpd.yfuture['yfuture'].to_numpy())
    Baseline['Method'] = 'Current Look Predictor'
    sr = SummarizeResults(Actuals, Baseline, [ fm1.forecast_data])
    sr.plot()
    sr.show_table()
    
    

# %%

