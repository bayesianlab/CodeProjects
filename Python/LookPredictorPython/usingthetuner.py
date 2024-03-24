
# %%
from dataclasses import replace
from random import sample
from cronus_interface import get_data
from PrepareLookPredictorData import PrepareLookPredictorData, PrepareConfigData, ComparisonDataContainer
from Model import ModelSimple, ModelAutoregressive 
import pandas as pd 
import numpy as np 
import matplotlib.pyplot as plt 
import seaborn as sns 
from Tuning import LookPredictorTuner
from SummarizeResults import SummarizeResults
import warnings 
warnings.simplefilter(action='ignore', category=FutureWarning)
# %%
data = pd.read_csv('fromsql.csv')
split_date = '2023-02-01'
model_dictionary = {}
object_cols_simple = ['DayNum',  'MonthNum', 'YearNum']
continuous_cols = ['ShortWeek', 'MarketEarlyCloseBit', 'FirstBusDayOfMonthBit', 'LastBusDayOfMonthBit',
                    'PrimaryRate30Y', 'ps_spread','BeLockCnt', 'ConfAmt', 'GovtAmt', 'NonConfAmt']
interaction_dummies = [('DayNum', 'PrimaryRate30Y'), 
                       ('DayNum', 'ShortWeek')]
plp = PrepareLookPredictorData(data)
(Xtrain, ytrain, Xfuture, yfuture) = plp.train_test_split(data, object_cols_simple, continuous_cols, split_date)

cdc = ComparisonDataContainer()

ms = ModelSimple()
lpt = LookPredictorTuner(data)

#%%
lpt.TuneLagLength(ms, data, object_cols_simple, continuous_cols, split_date,
                    vars_to_lag=['LookCnt', 'PrimaryRate30Y', 'ps_spread'], interactions=interaction_dummies,
                    max_lag_length=50, samples=150)
lpt.plot_lag_ranking()

#%%
lpt.TuneArLags(data, object_cols_simple, continuous_cols, split_date, interactions=interaction_dummies,
                lag_dictionary=lpt.lag_dictionary, max_ar_lags=100)

lpt.plot_ar_order_ranking()

#%%
marbest1 = ModelAutoregressive(lpt.best_arp, 'AR')
marbest1.train(Xtrain, ytrain)
marbest1.forecast(Xfuture, yfuture)
forecast_data1 = marbest1.make_results_dataframe(yfuture, marbest1.yhatf)

#%% 
# Trying other models 
object_cols_yr = ['DayNum', 'MonthNum',  'YearNum']
continuous_cols = ['ShortWeek', 'MarketEarlyCloseBit', 'FirstBusDayOfMonthBit', 'LastBusDayOfMonthBit',
                    'PrimaryRate30Y', 'ps_spread','BeLockCnt', 'ConfAmt', 'GovtAmt', 'NonConfAmt']
interaction_dummies = [('DayNum', 'PrimaryRate30Y'), ('DayNum', 'ShortWeek')]
(Xtrain, ytrain, Xfuture, yfuture) = plp.train_test_split(data, object_cols_yr, continuous_cols, split_date, interactions=interaction_dummies,
                     lagged_variables_dict=lpt.lag_dictionary)

#%%
marbest2 = ModelAutoregressive(lpt.best_arp, 'AR+YearNum')
marbest2.train(Xtrain, ytrain)
marbest2.forecast(Xfuture, yfuture)
forecast_data2 = marbest2.make_results_dataframe(yfuture, marbest2.yhatf)

#%%
continuous_cols = ['ShortWeek', 'MarketEarlyCloseBit', 'FirstBusDayOfMonthBit', 'LastBusDayOfMonthBit',
                     'ps_spread']
interaction_dummies = [('DayNum', 'PrimaryRate30Y'), ('DayNum', 'ShortWeek')]
(Xtrain, ytrain, Xfuture, yfuture) = plp.train_test_split(data, object_cols_yr, continuous_cols, split_date, interactions=interaction_dummies,
                     lagged_variables_dict=lpt.lag_dictionary)
marbest3 = ModelAutoregressive(lpt.best_arp, 'AR-Amts')
marbest3.train(Xtrain, ytrain)
marbest3.forecast(Xfuture, yfuture)
forecast_data3 = marbest3.make_results_dataframe(yfuture, marbest3.yhatf)

#%%
continuous_cols = ['ShortWeek', 'MarketEarlyCloseBit', 'FirstBusDayOfMonthBit', 'LastBusDayOfMonthBit',
                    'PrimaryRate30Y', 'ps_spread','BeLockCnt', 'ConfAmt', 'GovtAmt', 'NonConfAmt']
interaction_dummies = None
(Xtrain, ytrain, Xfuture, yfuture) = plp.train_test_split(data, object_cols_yr, continuous_cols, split_date, interactions=interaction_dummies,
                     lagged_variables_dict=lpt.lag_dictionary)
marbest4 = ModelAutoregressive(lpt.best_arp, 'AR-Xs')
marbest4.train(Xtrain,ytrain)
marbest4.forecast(Xfuture, yfuture)
forecast_data4 = marbest4.make_results_dataframe(yfuture, marbest4.yhatf)

#%%
continuous_cols = ['ShortWeek', 'MarketEarlyCloseBit', 'FirstBusDayOfMonthBit', 'LastBusDayOfMonthBit',
                    'SecondaryRate30Y', 'BeLockCnt', 'ConfAmt', 'GovtAmt', 'NonConfAmt']
interaction_dummies =[('DayNum', 'SecondaryRate30Y'), ('DayNum', 'ShortWeek'), ('DayNum', 'ps_spread')]
lag_dict = {'PrimaryRate30Y':30, 'LookCnt':10, 'GotAmt':5}
(Xtrain, ytrain, Xfuture, yfuture) = plp.train_test_split(data, object_cols_simple, continuous_cols, split_date, 
                                                          interactions=interaction_dummies,
                                                          lagged_variables_dict=lag_dict)
marbest5 = ModelSimple('Simple+ExtraXs')
marbest5.train(Xtrain,ytrain)
marbest5.forecast(Xfuture, yfuture)
forecast_data5 = marbest5.make_results_dataframe(yfuture, marbest5.yhatf)

#%%
continuous_cols = ['ShortWeek', 'MarketEarlyCloseBit', 'FirstBusDayOfMonthBit', 'LastBusDayOfMonthBit',
                     'ps_spread','BeLockCnt', 'ConfAmt', 'GovtAmt', 'NonConfAmt',
                     'PrimarySqd']
interaction_dummies =[('DayNum', 'PrimaryRate30Y'), ('DayNum', 'ShortWeek')]
(Xtrain, ytrain, Xfuture, yfuture) = plp.train_test_split(data, object_cols_yr, continuous_cols, split_date, interactions=interaction_dummies,
                     lagged_variables_dict=lpt.lag_dictionary)
marbest6 = ModelAutoregressive(lpt.best_arp, 'AR+TimeTrend+Poly')
marbest6.train(Xtrain, ytrain)
marbest6.forecast(Xfuture, yfuture)
forecast_data6 = marbest6.make_results_dataframe(yfuture, marbest6.yhatf)

#%%
continuous_cols = ['ShortWeek', 'MarketEarlyCloseBit', 'FirstBusDayOfMonthBit', 'LastBusDayOfMonthBit',
                    'PrimaryRate30Y', 'ps_spread','BeLockCnt', 'ConfAmt', 'GovtAmt', 'NonConfAmt']
interaction_dummies =[('DayNum', 'PrimaryRate30Y'), ('DayNum', 'ShortWeek')]
(Xtrain, ytrain, Xfuture, yfuture) = plp.train_test_split(data, object_cols_yr, continuous_cols, split_date, interactions=interaction_dummies,
                     lagged_variables_dict=lpt.lag_dictionary)
marbest7 = ModelAutoregressive(lpt.best_arp, 'AR+TimeTrend+TimeSqd')
marbest7.train(Xtrain, ytrain)
marbest7.forecast(Xfuture, yfuture)
forecast_data7 = marbest7.make_results_dataframe(yfuture, marbest7.yhatf)

#%%
continuous_cols = ['ShortWeek', 'MarketEarlyCloseBit', 'FirstBusDayOfMonthBit', 'LastBusDayOfMonthBit',
                    'BeLockCnt', 'ConfAmt', 'GovtAmt', 'NonConfAmt']
interaction_dummies =[('DayNum', 'PrimaryRate30Y'), ('DayNum', 'ShortWeek'), ('DayNum', 'ps_spread'),
                      ('DayNum', 'ShortWeek')]
(Xtrain, ytrain, Xfuture, yfuture) = plp.train_test_split(data, object_cols_yr, continuous_cols, split_date, interactions=interaction_dummies,
                     lagged_variables_dict=lpt.lag_dictionary)
marbest8 = ModelAutoregressive(lpt.best_arp, 'AR+MoreExtraXs')
marbest8.train(Xtrain, ytrain)
marbest8.forecast( Xfuture, yfuture)

forecast_data8 = marbest5.make_results_dataframe(yfuture, marbest8.yhatf)

#%%
forecast_data5 = marbest5.make_results_dataframe(yfuture, marbest5.yhatf)
CompareData = pd.concat([forecast_data5, cdc.Baseline, cdc.Actuals], axis=0)
forecast_data5
CompareData
plt.figure()
sns.lineplot(data=CompareData, x='Dt', y='LookCnt', hue='Method')
plt.xticks(rotation=45)

#%%
sr = SummarizeResults(cdc.Actuals, cdc.Baseline, [forecast_data1, forecast_data2, forecast_data3,
                                                  forecast_data4, forecast_data5, forecast_data6,
                                                  forecast_data7, forecast_data8])
table = sr.show_table()
table.to_csv('table.csv', index=False)
# %%

ms = ModelSimple('Simple')
interaction_dummies_1 =[('DayNum', 'PrimaryRate30Y'), ('DayNum', 'ShortWeek'), ('DayNum', 'ps_spread'),
                      ('DayNum', 'ShortWeek')]
model_dictionary['Model1'] = (marbest5, object_cols_simple, continuous_cols, interaction_dummies_1, {'LookCnt':1})
model_dictionary['Model2'] = (ms, object_cols_simple, continuous_cols, None, None)
interaction_dummies_2 =[('DayNum', 'PrimaryRate30Y'), ('DayNum', 'ShortWeek'), ('DayNum', 'ps_spread')]
model_dictionary['Model3'] = (marbest1, object_cols_simple, continuous_cols, interaction_dummies_2, lpt.lag_dictionary)
start_date = data['Dt'].iloc[int(data.shape[0]/2)]
lpt.model_ranking = pd.DataFrame()
lpt.ModelComparison(data, model_dictionary=model_dictionary, start_date=start_date, min_sample_size=250,
                    interval=5)
#%%
simple = ModelSimple()
object_cols_all = ['DayNum', 'MonthNum', 'YearNum']
continuous_cols_all = ['ShortWeek','MarketEarlyCloseBit', 'FirstBusDayOfMonthBit', 'LastBusDayOfMonthBit',
                          'SecondaryRate30Y', 'PrimaryRate30Y', 'ps_spread', 'SpreadSqd',
                        'PrimarySqd', 'BeLockCnt', 'ConfAmt', 'GovtAmt',
                        'NonConfAmt', 'LookCnt']
interaction_dummies_2 =[('DayNum', 'PrimaryRate30Y'), ('DayNum', 'ShortWeek'), ('DayNum', 'ps_spread')]
result = lpt.AutoTune(simple, data=data, object_cols=object_cols_all, continuous_cols=continuous_cols_all,
             split_date=split_date, interaction_terms=interaction_dummies_2, number_subsets=100,
             max_lag_length=10, lag_length_samples=10, max_ar_lags=5, interval=50)
lpt.plot_autotune()
plt.show()
print(result)