#%%
from dataclasses import replace
from email.mime import base
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

#%%
data = pd.read_csv('fromsql.csv')
lpt = LookPredictorTuner(data)
cdc = ComparisonDataContainer()
bdate = cdc.Baseline['Dt'].min()
ms = ModelSimple()
#%%
r = 0
days_out = 5
baseline_summary = {} 
while r < cdc.Baseline.shape[0]-1:
    tmp = cdc.Baseline[cdc.Baseline.index>r].head(5)
    summary = tmp[['MAE', 'RMSE']].mean()
    summary['RMSE'] = np.sqrt(summary['RMSE'])
    baseline_summary[tmp.iloc[0]['Dt']] = summary.to_list() 
    r+=1
baseline_summary = pd.DataFrame.from_dict(baseline_summary, orient='index')
baseline_summary.reset_index(inplace=True)
baseline_summary.columns = ['Dt', 'MAE', 'RMSE']
baseline_summary['Model Name'] = 'Sheet'
baseline_summary = pd.melt(baseline_summary, id_vars=['Dt', 'Model Name'], var_name='Metric',
                           value_name='Metric Value')
baseline_summary

#%%

lpt = LookPredictorTuner(data)
model_dict = {} 
object_columns = ['DayNum']
continuous_columns = []
model_dict = {'DayNum':(ms, object_columns, continuous_columns, None, None, None)}
object_columns = ['DayNum', 'MonthNum']
continuous_columns = []
model_dict['DayNum + MonthNum'] = (ms, object_columns, continuous_columns, None, None, None)
object_columns = ['DayNum', 'MonthNum', 'YearNum']
continuous_columns = []
model_dict['DayNum + MonthNum + YearNum'] = (ms, object_columns, continuous_columns, None, None, None)
lpt.ModelComparison(data, model_dict, bdate, interval=1, max_out=5)
mranking = pd.melt(lpt.model_ranking, id_vars=['Dt', 'Model Name'], var_name='Metric',
                   value_name='Metric Value')
cdata = pd.concat([mranking, baseline_summary])
modelstats= cdata[['Model Name', 'Metric', 'Metric Value']].groupby(['Model Name', 'Metric']).mean()
modelstats.reset_index(inplace=True)

# ax = sns.lineplot(data=cdata, x='Dt', y='Metric Value', hue='Model Name', style='Metric')
# plt.xticks(rotation=45)
# sns.move_legend(ax, "upper left", bbox_to_anchor=(1, 1))
cdata.to_csv('dataset_cell1.csv', index=False)

#%%
model_dict = {} 
lpt = LookPredictorTuner(data)
object_columns = ['DayNum', 'MonthNum', 'YearNum']
continuous_columns = ['MarketEarlyCloseBit']
model_dict['MarketEarlyClose'] = (ms, object_columns, continuous_columns, None, None, None)
object_columns = ['DayNum', 'MonthNum', 'YearNum']
continuous_columns = ['MarketEarlyCloseBit', 'FirstBusDayOfMonthBit']
model_dict['MarketEarlyClose + FirstBusDay'] = (ms, object_columns, continuous_columns, None, None, None)
object_columns = ['DayNum', 'MonthNum', 'YearNum']
continuous_columns = ['MarketEarlyCloseBit', 'FirstBusDayOfMonthBit', 'LastBusDayOfMonthBit']
model_dict['MarketEarlyClose + FirstBusDay + LastBusDay'] = (ms, object_columns, continuous_columns, None, None, None)
object_columns = ['DayNum', 'MonthNum', 'YearNum']
continuous_columns = ['MarketEarlyCloseBit', 'FirstBusDayOfMonthBit', 'LastBusDayOfMonthBit', 'ShortWeek']
model_dict['MarketEarlyClose + FirstBusDay + LastBusDay + ShortWeek'] = (ms, object_columns, continuous_columns, None, None, None)
lpt.ModelComparison(data, model_dict, bdate, interval=1, max_out=5)
mranking = pd.melt(lpt.model_ranking, id_vars=['Dt', 'Model Name'], var_name='Metric',
                   value_name='Metric Value')
cdata = pd.concat([mranking, baseline_summary])
# ax = sns.lineplot(data=cdata, x='Dt', y='Metric Value', hue='Model Name', style='Metric')
# plt.xticks(rotation=45)
# plt.title('All Dummy Time Features + Bit Columns')
# sns.move_legend(ax, "upper left", bbox_to_anchor=(1, 1))
# plt.show() 
cdata.to_csv('dataset_cell2.csv', index=False)
# %%

model_dict = {} 
lpt = LookPredictorTuner(data)
object_columns = ['DayNum', 'MonthNum', 'YearNum']
continuous_columns = ['MarketEarlyCloseBit', 'FirstBusDayOfMonthBit', 'LastBusDayOfMonthBit',
                      'SecondaryRate30Y', 'PrimaryRate30Y']
model_dict['Model8'] = (ms, object_columns, continuous_columns, None, None, None)
object_columns = ['DayNum', 'MonthNum', 'YearNum']
continuous_columns = ['MarketEarlyCloseBit', 'FirstBusDayOfMonthBit', 'LastBusDayOfMonthBit',
                      'SecondaryRate30Y',  'ps_spread']
model_dict['Model9'] = (ms, object_columns, continuous_columns, None, None, None)
object_columns = ['DayNum', 'MonthNum', 'YearNum']
continuous_columns = ['MarketEarlyCloseBit', 'FirstBusDayOfMonthBit', 'LastBusDayOfMonthBit',
                      'SecondaryRate30Y',  'ps_spread',  'BeLockCnt']
model_dict['Model10'] = (ms, object_columns, continuous_columns, None, None, None)
object_columns = ['DayNum', 'MonthNum', 'YearNum']
continuous_columns = ['MarketEarlyCloseBit', 'FirstBusDayOfMonthBit', 'LastBusDayOfMonthBit',
                      'SecondaryRate30Y',  'ps_spread',  'BeLockCnt','ConfAmt']
model_dict['Model11'] = (ms, object_columns, continuous_columns, None, None, None)
object_columns = ['DayNum', 'MonthNum', 'YearNum']
continuous_columns = ['MarketEarlyCloseBit', 'FirstBusDayOfMonthBit', 'LastBusDayOfMonthBit',
                      'SecondaryRate30Y',  'ps_spread', 'BeLockCnt', 'ConfAmt', 'GovtAmt',
                          'NonConfAmt']
model_dict['Model12'] = (ms, object_columns, continuous_columns, None, None, None)
lpt.ModelComparison(data, model_dict, bdate, interval=1, max_out=5)
mranking = pd.melt(lpt.model_ranking, id_vars=['Dt', 'Model Name'], var_name='Metric',
                   value_name='Metric Value')
cdata = pd.concat([mranking, baseline_summary])
ax = sns.lineplot(data=cdata, x='Dt', y='Metric Value', hue='Model Name', style='Metric')
plt.xticks(rotation=45)
plt.title('All Dummy Time Features + Bit Columns + Continuous Columns')
sns.move_legend(ax, "upper left", bbox_to_anchor=(1, 1))
plt.show() 

#%%

model_dict = {} 
lpt = LookPredictorTuner(data)
object_columns = ['DayNum', 'MonthNum', 'YearNum']
continuous_columns = ['MarketEarlyCloseBit', 'FirstBusDayOfMonthBit', 'LastBusDayOfMonthBit',
                      'SecondaryRate30Y',  'ps_spread', 'BeLockCnt', 'ConfAmt', 'GovtAmt',
                      'NonConfAmt', 'SpreadSqd']
model_dict['Model13'] = (ms, object_columns, continuous_columns, None, None, None)
object_columns = ['DayNum', 'MonthNum', 'YearNum']
continuous_columns = ['MarketEarlyCloseBit', 'FirstBusDayOfMonthBit', 'LastBusDayOfMonthBit',
                      'SecondaryRate30Y',  'ps_spread', 'BeLockCnt', 'ConfAmt', 'GovtAmt',
                      'NonConfAmt', 'SpreadSqd', 'PrimarySqd']
model_dict['Model14'] = (ms, object_columns, continuous_columns, None, None, None)
lpt.ModelComparison(data, model_dict, bdate, interval=1, max_out=5)
mranking = pd.melt(lpt.model_ranking, id_vars=['Dt', 'Model Name'], var_name='Metric',
                   value_name='Metric Value')
cdata = pd.concat([mranking, baseline_summary])
ax = sns.lineplot(data=cdata, x='Dt', y='Metric Value', hue='Model Name', style='Metric')
plt.xticks(rotation=45)
plt.title('Dummies + Bits + Continuous + Derivatives')
sns.move_legend(ax, "upper left", bbox_to_anchor=(1, 1))
plt.show() 

#%%
model_dict = {} 
lpt = LookPredictorTuner(data)
object_columns = ['DayNum', 'MonthNum', 'YearNum']
continuous_columns = ['ShortWeek', 'MarketEarlyCloseBit', 'FirstBusDayOfMonthBit', 'LastBusDayOfMonthBit',
                      'SecondaryRate30Y', 'BeLockCnt', 'ConfAmt', 'GovtAmt',
                      'NonConfAmt', 'SpreadSqd']
model_dict['Model14'] = (ms, object_columns, continuous_columns, None, None )
interactions = [('DayNum', 'PrimaryRate30Y')]
model_dict['Model15'] = (ms, object_columns, continuous_columns, interactions, None )
interactions = [('DayNum', 'PrimaryRate30Y'), ('DayNum', 'ShortWeek')]
model_dict['Model16'] = (ms, object_columns, continuous_columns, interactions, None )
interactions = [('DayNum', 'PrimaryRate30Y'), ('DayNum', 'ShortWeek'), 
                ('DayNum', 'LastBusDayOfMonthBit')]
model_dict['Model17'] = (ms, object_columns, continuous_columns, interactions, None)

lpt.ModelComparison(data, model_dict, bdate, interval=1, max_out=5)
mranking = pd.melt(lpt.model_ranking, id_vars=['Dt', 'Model Name'], var_name='Metric',
                   value_name='Metric Value')
cdata = pd.concat([mranking, baseline_summary])
mranking = mranking[mranking['Metric']=='MAE']
cdata = cdata[cdata['Metric']=='MAE']
ax = sns.lineplot(data=cdata, x='Dt', y='Metric Value', hue='Model Name')
plt.xticks(rotation=45)
plt.title('Dummies + Bits + Continuous + Derivatives + Interactions')
sns.move_legend(ax, "upper left", bbox_to_anchor=(1, 1))
plt.show() 
# %%
object_columns = ['DayNum', 'MonthNum']
continuous_columns = [ 'PctWkRemaining' ]
interactions = [('DayNum', 'SecondaryRate30Y'), 
                ('DayNum', 'PrimaryRate30Y'),
                ('DayNum', 'ShortWeek'),
                ('DayNum', 'MarketEarlyCloseBit'),
                ('DayNum', 'FirstBusDayOfMonthBit'),
                ('DayNum', 'LastBusDayOfMonthBit'),
                ('DayNum', 'GovtAmt'),
                ('DayNum', 'ConfAmt')]

split_date = '2024-01-15'
lpt.TuneLagLength(ms, data, object_columns, continuous_columns, split_date, ['LookCnt', 'PrimaryRate30Y'],
                  interactions=None, max_lag_length=175, samples=1000)
lags = lpt.lag_dictionary
lpt.plot_lag_ranking()
#%%

model_dict = {} 
lpt = LookPredictorTuner(data)
object_columns = []
continuous_columns = ['ShortWeek', 'MarketEarlyCloseBit', 'FirstBusDayOfMonthBit', 'LastBusDayOfMonthBit',
                      'SecondaryRate30Y', 'PrimaryRate30Y']
model_dict['Model18'] = (ms, object_columns, continuous_columns, None, lags)
object_columns = ['YearNum']
continuous_columns = ['ShortWeek', 'MarketEarlyCloseBit', 'FirstBusDayOfMonthBit', 'LastBusDayOfMonthBit',
                      'SecondaryRate30Y', 'PrimaryRate30Y']
model_dict['Model19'] = (ms, object_columns, continuous_columns, None, lags)
object_columns = ['MonthNum', 'YearNum']
continuous_columns = ['ShortWeek', 'MarketEarlyCloseBit', 'FirstBusDayOfMonthBit', 'LastBusDayOfMonthBit',
                      'SecondaryRate30Y', 'PrimaryRate30Y']
model_dict['Model20'] = (ms, object_columns, continuous_columns, None, lags)
object_columns = ['DayNum', 'MonthNum', 'YearNum']
continuous_columns = ['ShortWeek', 'MarketEarlyCloseBit', 'FirstBusDayOfMonthBit', 'LastBusDayOfMonthBit',
                      'SecondaryRate30Y', 'PrimaryRate30Y']
model_dict['Model21'] = (ms, object_columns, continuous_columns, None, lags)
lpt.ModelComparison(data, model_dict, bdate, interval=1, max_out=5)
mranking = pd.melt(lpt.model_ranking, id_vars=['Dt', 'Model Name'], var_name='Metric',
                   value_name='Metric Value')
cdata = pd.concat([mranking, baseline_summary])
cdata = cdata[cdata['Metric']=='MAE' ]
plt.figure() 
ax = sns.lineplot(data=cdata, x='Dt', y='Metric Value', hue='Model Name', style='Metric')
plt.xticks(rotation=45)
plt.title('Long Lag LookCnt + []/Year/Month/Day Nums')
sns.move_legend(ax, "upper left", bbox_to_anchor=(1, 1))
plt.show() 

# %%
model_dict = {} 
lpt = LookPredictorTuner(data)
object_columns = ['DayNum', 'MonthNum']
continuous_columns = [ 'PctWkRemaining' ]
interactions = [('DayNum', 'SecondaryRate30Y'), 
                ('DayNum', 'PrimaryRate30Y'),
                ('DayNum', 'ShortWeek'),
                ('DayNum', 'MarketEarlyCloseBit'),
                ('DayNum', 'FirstBusDayOfMonthBit'),
                ('DayNum', 'LastBusDayOfMonthBit'),
                ('DayNum', 'GovtAmt'),
                ('DayNum', 'ConfAmt')]
mylags = lags.copy()
mylags['LookCnt'] = 150

model_dict['Model22'] = (ms, object_columns, continuous_columns, interactions, mylags, None)
# mar = ModelAutoregressive(10)
# model_dict['ModelAR'] = (mar, object_columns, continuous_columns, interactions, mylags, None)
lpt.ModelComparison(data, model_dict, bdate, interval=1, max_out=5)
mranking = pd.melt(lpt.model_ranking, id_vars=['Dt', 'Model Name'], var_name='Metric',
                   value_name='Metric Value')
cdata = pd.concat([mranking, baseline_summary])
cdata = cdata[cdata['Metric']=='MAE' ]
cdata = cdata[cdata['Dt'] > '2023-10-01']
print(cdata[['Model Name', 'Metric', 'Metric Value']].groupby(['Model Name', 'Metric']).mean())
plt.figure() 
ax = sns.lineplot(data=cdata, x='Dt', y='Metric Value', hue='Model Name', style='Metric')
plt.xticks(rotation=45)
plt.title('Tuned Model')
sns.move_legend(ax, "upper left", bbox_to_anchor=(1, 1))
plt.show() 
# %%
