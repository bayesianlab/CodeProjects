#%%
from xml.etree.ElementTree import QName
import pandas as pd 
import numpy as np
from LookPredictorErrors import PrepareLookPredictorDataError
from sqlalchemy.engine import URL, create_engine 
import warnings 
from datetime import datetime
from sklearn.linear_model import LinearRegression
#%%

class ComparisonDataContainer:
    def __init__(self) -> None:
        self.Actuals = pd.read_csv('fromsql.csv')
        self.Actuals['Dt'] = pd.to_datetime(self.Actuals['Dt'])
        self.Actuals = self.Actuals[['Dt', 'LookCnt']]
        self.Actuals['MAE'] = 0
        self.Actuals['RMSE'] = 0
        self.Actuals['Method'] = 'Actuals'
        self.Baseline = pd.read_csv('fromsheet.csv')
        self.Baseline['Dt'] = pd.to_datetime(self.Baseline['Dt'])
        self.Baseline['LookCnt'] = self.Baseline['LookCnt'].astype(float)
        dates = self.Actuals.merge(self.Baseline['Dt'], on='Dt')['Dt']
        self.Baseline = self.Baseline[self.Baseline['Dt'].isin(dates)]
        self.Actuals = self.Actuals[self.Actuals['Dt'].isin(dates)]
        self.Baseline.rename(columns={'Dt':'Dt'}, inplace=True)
        self.Baseline['MAE'] = np.abs((self.Baseline['LookCnt'].to_numpy() - self.Actuals['LookCnt'].to_numpy()))
        self.Baseline['RMSE'] = np.square(self.Baseline['LookCnt'].to_numpy() - self.Actuals['LookCnt'].to_numpy())
        self.Baseline['Method'] = 'Current Look Predictor'   
#%% 
class PrepareConfigData:

    def __init__(self) -> None:
        pass 
    
    def get_data(self, server_name, InputId):
        query = ' '.join(['exec', 'GetLookPredictorConfigData', str(InputId)])
        conn_string = 'DRIVER={SQL Server};SERVER='+server_name+';DATABASE=Market'
        conn_url = URL.create('mssql+pyodbc', query={'odbc_connect': conn_string})
        engine = create_engine(conn_url)
        with engine.begin() as conn:
            config_data = pd.read_sql(query, conn)
            config_data['training_split_date'] = pd.to_datetime(config_data['training_split_date'])
            return config_data

class PrepareLookPredictorDataBase:
    
    def __init__(self) -> None:
        self._objcols = ('DayNum', 'MonthNum', 'YearNum')
        self._boolcols = ('MarketEarlyCloseBit','FirstBusDayOfMonthBit', 'LastBusDayOfMonthBit',
                           'ShortWeek')
        self._contcols = ( 'PctWkRemaining', 'SecondaryRate30Y', 'PrimaryRate30Y', 'ps_spread',
                         'SpreadSqd', 'PrimarySqd', 'BeLockCnt', 'ConfAmt', 'GovtAmt',
                          'NonConfAmt',	'LookCnt')

class MakeOutSample(PrepareLookPredictorDataBase):
    
    def __init__(self) -> None:
        super().__init__() 

    def make_os(self, data, periods_out=1, ar=1):
        xf = data[list(self._contcols)]
        forecasts = {} 
        for c in self._contcols:
            forecasts[c] = [] 
            arp = []
            for p in range(1,ar+1):
                arp.append(xf[c].shift(p))
            lags = pd.concat(arp, axis=1)
            tmp = pd.concat([xf[c], lags, pd.Series(np.repeat(1, xf.shape[0]))], axis=1)
            tmp = tmp.to_numpy()
            tmp = tmp[ar:,:]
            features = tmp[:,1:]
            target = tmp[:,0]
            lr = LinearRegression(fit_intercept=True)
            lr.fit(features, target)
            future_features = np.reshape(features[-1,:], (1,-1))
            not_constant = list(range(0,(future_features.shape[1]-1)))
            for i in range(periods_out):
                f = lr.predict(future_features)
                forecasts[c].append(f.item())
                x = future_features[:, not_constant]
                x[:, 1:] = x[:,0:x.shape[1]-1]
                x[:,0] = f 
                future_features[:, not_constant] = x
        forecasts = pd.DataFrame(forecasts)
        forecasts['PrimarySqd'] = forecasts['PrimaryRate30Y']*forecasts['PrimaryRate30Y']
        forecasts['ps_spread'] = forecasts['PrimaryRate30Y'] - forecasts['SecondaryRate30Y']
        forecasts['SpreadSqd'] = forecasts['ps_spread']*forecasts['ps_spread']
        return forecasts
    
    def make_xy(self, osdata):
        notdt = list(set(osdata.columns.to_list()) - set(['Dt']))
        Xf = osdata[notdt]
        yf = pd.DataFrame(osdata['Dt'])
        yf['yfuture'] = np.nan
        return (Xf, yf)

class PrepareLookPredictorData(PrepareLookPredictorDataBase):
    
    def __init__(self, data) -> None:
        super().__init__() 
        data['Dt'] = pd.to_datetime(data['Dt'])
        data[list(self._objcols)] = data[list(self._objcols)].astype('int')
        data[list(self._objcols)] = data[list(self._objcols)].astype('object')
        data[list(self._contcols + self._boolcols)] = data[list(self._contcols + self._boolcols)].astype('float64')

    def check_input(self, data, continuous_columns):
        if 'Dt' not in data.columns:
            raise PrepareLookPredictorDataError('Dt not in data columns.')
        else:
            data['Dt'] = pd.to_datetime(data['Dt'])
        if 'LookCnt' in continuous_columns:
            warnings.warn("LookCnt should not be in continuous columns, removing it.")
            continuous_columns.remove('LookCnt')
            
    def shift_back_laggables(self, data, object_columns):
        lags = [] 
        bools_in = [] 
        for i in data.columns:
            # Don't shift back LookCnt
            if i in self._contcols and (i != 'LookCnt'):
                lags.append(data[i].shift(1))
            elif i in self._boolcols:
                bools_in.append(i)
        if len(lags) > 0:
            lags = pd.concat(lags, axis=1)
            data = pd.concat([data['Dt'], data['LookCnt'], data[object_columns],
                              data[bools_in], lags], axis=1) 
            data = data.iloc[1:]
            data.reset_index(inplace=True, drop=True)
        return data 
    
    def lag_variables(self, data, lag_dict):
        lagged_vars =[] 
        names = []
        max_lag = 0  
        for k,v in lag_dict.items():
            if v > max_lag:
                max_lag=v
                for i in range(1,v+1):
                    lagged_vars.append(data[k].shift(i))
                    names.append(''.join([k,'_Lag_', str(i)]))
        if len(lagged_vars) > 0:
            lv = pd.concat(lagged_vars, axis=1)
            lv.columns = names
            return lv 
        else:
            return pd.DataFrame() 
         
    def interact(self, all_data, interactions):
        other_cols = []
        frame_cols = []  
        for tup in interactions:
            if tup[0] in list(self._objcols + self._boolcols):
                str1 = tup[0] + '_'
            else:
                str1 = tup[0] 
            if tup[1] in list(self._objcols + self._boolcols):
                str2 = tup[1] + '_'
            else:
                str2 = tup[1] 
            for pass1 in all_data.columns:
                if pass1.startswith(str1):
                    for pass2 in all_data.columns:
                        if pass2.startswith(str2):
                            newcol = ''.join([pass1, 'x', pass2])
                            other_cols.append(newcol)
                            frame_cols.append(all_data[pass1] * all_data[pass2])
        newframe = pd.concat(frame_cols, axis=1)
        newframe.columns = other_cols    
        return newframe            
    
    def train_test_split(self, data, object_columns, continuous_columns,
                  split_date=None, interactions=None, lagged_variables_dict=None, 
                  train_cutoff=None):
        cont_cols = continuous_columns.copy() 
        self.check_input(data, cont_cols)
        model_data = data.copy()
        # Shift back training data 1 day
        model_data = self.shift_back_laggables(model_data, object_columns)
        all_data = pd.get_dummies(data[list(self._objcols)])
        all_data = pd.concat([all_data, data[list(self._contcols)], data[list(self._boolcols)]], axis=1)
        lag_col_names = []
        if (lagged_variables_dict is not None) and (len(lagged_variables_dict)>0):
            if not isinstance(lagged_variables_dict, dict):
                raise PrepareLookPredictorDataError('lagged_variables_dict must be dictionary')
            lags = self.lag_variables(model_data, lagged_variables_dict)
            lag_col_names = lags.columns.to_list()
            max_lag = max(lagged_variables_dict.values())
            model_data = pd.concat([model_data, lags], axis=1)
            model_data = model_data.iloc[max_lag:,:]
            model_data.reset_index(inplace=True, drop=True)
            all_data = all_data.iloc[max_lag:,:]   
            all_data.reset_index(inplace=True, drop=True)
        if train_cutoff is not None:
            model_data = model_data[model_data['Dt'] > train_cutoff]
        if len(object_columns) > 0:
            dummies = pd.get_dummies(model_data[object_columns], drop_first=True)
            dummy_column_names = dummies.columns.to_list()   
            model_data = pd.concat([model_data, dummies], axis=1)
        else:
            dummy_column_names=[]
        md_col_names = model_data.columns.to_list()
        md_col_names[0] = 'Dt'
        model_data.columns = md_col_names
        model_data['const'] = 1
        interaction_col_names = [] 
        if interactions is not None and len(interactions) > 0:
            if not isinstance(interactions[0], tuple):
                raise PrepareLookPredictorDataError('Interactions columns are not input correctly.')
            interaction_frame = self.interact(all_data, interactions)
            if not interaction_frame.empty:
                model_data = pd.concat([model_data, interaction_frame], axis=1)
                interaction_col_names = interaction_frame.columns.to_list() 
        model_data = model_data.loc[:, ~model_data.columns.duplicated()].copy()
        all_cols = cont_cols+interaction_col_names+lag_col_names+dummy_column_names+['const']
        if  split_date is None:    
            Xtrain = model_data[all_cols]
            ytrain = model_data['LookCnt']
            return (Xtrain, ytrain, None, None)
        else:
            training = model_data[model_data['Dt']<split_date]
            Xtrain = training[all_cols].copy()
            ytrain = training['LookCnt']
            future = model_data[model_data['Dt']>=split_date]
            self.insample_time =  model_data.loc[model_data['Dt']<split_date, 'Dt']
            Xfuture = future[all_cols].copy()
            check_series = Xtrain[dummy_column_names].sum()
            for cs in check_series.index:
                if check_series[cs] == 0:
                    warnings.warn('A column has 0 observations. Dropping this column.')
                    Xtrain.drop(cs, axis=1, inplace=True)
                    Xfuture.drop(cs, axis=1, inplace=True)
            self.future_time = future['Dt']
            yfuture = pd.concat([self.future_time, future['LookCnt']], axis=1, 
                                ignore_index=True)  
            yfuture.columns = ['Dt', 'yfuture']       
            yfuture.reset_index(drop=True, inplace=True)
            self.column_names_in_X = Xtrain.columns.to_list() 
            self.insample_time.reset_index(drop=True,inplace=True)
            return (Xtrain, ytrain, Xfuture, yfuture)

    def blind_split(self, data, known_future_data, object_columns, continuous_columns, 
                    interactions=None, lagged_variables_dict=None, 
                    train_cutoff=None):
        if not isinstance(future_dates, pd.DataFrame):
            raise PrepareLookPredictorDataError('must be dataframe')
        if 'Dt' not in future_dates.columns:
            raise PrepareLookPredictorDataError('future_dates must have Dt column.')
        fdata = data[data['Dt'] < known_future_data['Dt'].min()]
        split_date = future_dates['Dt'].min() 
        forecast_data = pd.concat([fdata,known_future_data], axis=0) 
        mos = MakeOutSample()       
        feature_forecasts = mos.make_os(data, known_future_data.shape[0])
        forecast_data.loc[fdata.shape[0]:,feature_forecasts.columns]=feature_forecasts.to_numpy()
        return self.train_test_split(forecast_data, object_columns, continuous_cols, split_date, 
                              interactions, lagged_variables_dict, train_cutoff)
        
# %%
if __name__=='__main__':
    bdate = '2024-02-07'
    edate = '2024-03-08'
    cdc = ComparisonDataContainer(bdate, edate)
    data = pd.read_csv('fromsql.csv')
    known_future_data = pd.read_csv('fromsql.csv')
    known_future_data['Dt'] = pd.to_datetime(known_future_data['Dt'])
    known_future_data = known_future_data.loc[known_future_data['Dt']>='2024-03-07',
                      ['Dt', 'DayNum', 'MonthNum', 'YearNum', 'ShortWeek', 'MarketEarlyCloseBit',
                       'FirstBusDayOfMonthBit', 'LastBusDayOfMonthBit', 'PctWkRemaining']]
    plp = PrepareLookPredictorData(data)
    future_dates = pd.DataFrame(data[data['Dt'] >= '2024-03-07']['Dt'])
    object_cols_simple = ['DayNum',  'MonthNum', 'YearNum']
    continuous_cols = ['ShortWeek', 'MarketEarlyCloseBit', 'FirstBusDayOfMonthBit', 'LastBusDayOfMonthBit',
                        'PrimaryRate30Y', 'ps_spread','BeLockCnt', 'ConfAmt', 'GovtAmt', 'NonConfAmt']
    interaction_dummies = [('DayNum', 'PrimaryRate30Y'), 
                        ('DayNum', 'ShortWeek')]
    plp.blind_split(data, known_future_data, object_cols_simple, continuous_cols, interactions=interaction_dummies)
    
# %%

# %%
