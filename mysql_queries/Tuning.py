# %%
from dataclasses import replace
from random import sample
from LookPredictorErrors import LookPredictorTunerError, PrepareLookPredictorDataError, ModelError
from cronus_interface import get_data
from PrepareLookPredictorData import PrepareLookPredictorData, PrepareConfigData
from Model import ModelBase, ModelSimple, ModelAutoregressive
import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import matplotlib.pyplot as plt
import seaborn as sns
from LookPredictorErrors import ModelError
from sklearn.preprocessing import StandardScaler
import warnings
from itertools import chain, combinations, combinations_with_replacement, permutations
import random
import sys

warnings.filterwarnings("ignore", "is_categorical_dtype")
warnings.filterwarnings("ignore", "use_inf_as_na")
warnings.filterwarnings('ignore', category=UserWarning)

# %%

def powerset(iterable):
    s = list(iterable)
    return chain.from_iterable(combinations(s, r) for r in range(len(s)+1))


class LookPredictorTuner(PrepareLookPredictorData, ModelBase):

    def __init__(self, data, ranking_col=None) -> None:
        super().__init__(data)
        self.cutoff_ranking = pd.DataFrame()
        self.lag_ranking = pd.DataFrame()
        self.ar_order_ranking = pd.DataFrame()
        self.model_ranking = pd.DataFrame()
        self.lag_dictionary = {}
        self.best_truncated_dataset = None
        self.metrics = ['MAE', 'RMSE']
        self.best_arp = 0
        self.index_cutoff = 0
        self.autotune_model_ranking = pd.DataFrame()
        self._max_lag_combns = 5e5
        if ranking_col is None:
            self.ranking_col = 'MAE'
        else:
            self.ranking_col = ranking_col

    def summarize_results(self, forecast_data):
        summary = forecast_data[self.metrics].mean()
        if 'RMSE' in self.metrics:
            summary['RMSE'] = np.sqrt(summary['RMSE'])
        summary = list(summary)
        return summary

    def ModelComparison(self, data, model_dictionary, start_date, min_sample_size=100,
                        interval=10, max_out=30):
        data['Dt'] = pd.to_datetime(data['Dt'])
        for model_name, input_tuple in model_dictionary.items():
            print(model_name)
            self._model_comparison_helper(model_name, data, input_tuple, 
                                          start_date, min_sample_size, interval,max_out)

    def _model_comparison_helper(self, model_name, data, input_tuple, start_date,
                                 min_sample_size, interval, max_out):
        
        tmp = data[data['Dt'] < start_date]
        dts = data['Dt']
        if tmp.shape[0] < min_sample_size:
            plperror = ' '.join(['Start dt causing sample size to be less than min required size.',
                                 'Change one or the other.'])
            raise PrepareLookPredictorDataError(plperror)
        sd = tmp.shape[0]
        end_index = data.shape[0] - 1
        model_ranking = {}
        while sd < end_index:
            print('Model Comparison Iteraction Pct {:0.2%}'.format(
                1.0-(end_index-sd)/float(end_index)), end='\r')
            (Xtrain, ytrain, Xfuture, yfuture) = self.train_test_split(data, object_columns=input_tuple[1],
                                                                       continuous_columns=input_tuple[2].copy(),
                                                                        split_date=dts.iloc[sd], interactions=input_tuple[3],
                                                                        lagged_variables_dict=input_tuple[4])
            Xfuture = Xfuture.head(max_out)
            yfuture = yfuture.head(max_out)
            Model = input_tuple[0]
            Model.train(Xtrain, ytrain)
            Model.forecast(Xfuture, yfuture)
            forecast_data = Model.make_results_dataframe(yfuture, Model.yhatf)
            summary = self.summarize_results(forecast_data)
            summary += [model_name]
            model_ranking[dts.iloc[sd]] = summary
            sd += interval
        print() 
        model_ranking = pd.DataFrame.from_dict(model_ranking, orient='index')
        model_ranking.columns = self.metrics + ['Model Name']
        model_ranking = model_ranking.sort_values(self.ranking_col)
        model_ranking.reset_index(inplace=True)
        model_ranking.rename({'index': 'Dt'}, axis=1, inplace=True)
        if self.model_ranking.empty:
            self.model_ranking = model_ranking
        else:
            self.model_ranking = pd.concat(
                [self.model_ranking, model_ranking], axis=0)

    def TuneCutoffTime(self, data, model_dictionary, split_date, periods_in=None,
                       min_size=100, interval=1):
        print('TuneCutoffTime')
        data['Dt'] = pd.to_datetime(data['Dt'])
        for name, input_tuple in model_dictionary.items():
            if len(input_tuple) != 5:
                raise LookPredictorTunerError(
                    'input tuple needs to have all 4 inputs')
            self.tunecutofftime_helper(Model=input_tuple[0], data=data, object_cols=input_tuple[1],
                                       continuous_cols=input_tuple[2], split_date=split_date, interactions=input_tuple[3],
                                       lag_dict=input_tuple[4], periods_in=periods_in, min_size=min_size,
                                       interval=interval, name=name)
            
    def tunecutofftime_helper(self, Model, data, object_cols, continuous_cols, split_date, interactions=None,
                              lag_dict=None, periods_in=None, min_size=100, interval=1,
                              name='Model1'):
        train_cutoff = data['Dt'].min()
        if periods_in is not None:
            train_cutoff = train_cutoff + timedelta(days=periods_in)
        datacopy = data.copy()
        datacopy['Dt'] = pd.to_datetime(datacopy['Dt'])
        train_sample_size = data[data['Dt'] < split_date].shape[0] - data[data['Dt']<=train_cutoff].shape[0] 
        model_ranking = {}
        other_columns = ['SampleSize', 'ModelName']
        self.index_cutoff = train_cutoff
        if train_sample_size < min_size:
            raise LookPredictorTunerError(
                'Sample size initially less than min_size.')
        while train_sample_size > min_size:
            print('Tune cutoff time {:.2%}'.format(
                    1.0-(train_sample_size - min_size)/float(train_sample_size)), end='\r')
            try:
                (Xtrain, ytrain, Xfuture, yfuture) = self.train_test_split(datacopy, object_cols, continuous_cols.copy(),
                                                                           split_date=split_date, train_cutoff=train_cutoff,
                                                                           interactions=interactions, 
                                                                           lagged_variables_dict=lag_dict)
                Model.train(Xtrain,ytrain)
                Model.forecast(Xfuture, yfuture)
                forecast_data = Model.make_results_dataframe(yfuture, Model.yhatf)
                summary = self.summarize_results(forecast_data)
                summary += [train_sample_size, name]
                model_ranking[train_cutoff] = summary
                train_cutoff += timedelta(days=interval)
                while train_cutoff.weekday() > 5:
                    train_cutoff += timedelta(days=1)
                train_sample_size = data[data['Dt'] < split_date].shape[0] - data[data['Dt']<=train_cutoff].shape[0] 
            except (ModelError, PrepareLookPredictorDataError):
                train_cutoff += timedelta(days=interval)
                while train_cutoff.weekday() > 5:
                    train_cutoff += timedelta(days=1)
                train_sample_size = data[data['Dt'] < split_date].shape[0] - data[data['Dt']<=train_cutoff].shape[0] 
        print() 
        model_ranking = pd.DataFrame.from_dict(model_ranking, orient='index')
        model_ranking.columns = self.metrics + other_columns
        model_ranking = model_ranking.sort_values(self.ranking_col)
        model_ranking.reset_index(inplace=True)
        model_ranking.rename({'index': 'Dt'}, axis=1, inplace=True)
        if self.cutoff_ranking.empty:
            self.cutoff_ranking = model_ranking
        else:
            self.cutoff_ranking = pd.concat(
                [self.cutoff_ranking, model_ranking], axis=0)
            self.cutoff_ranking.sort_values(self.ranking_col, inplace=True)
            self.cutoff_ranking = self.cutoff_ranking.head(100)
        self.best_cutoff_date = self.cutoff_ranking.iloc[0]['Dt']
        self.best_truncated_dataset = datacopy[datacopy['Dt']
                                               > self.best_cutoff_date]

    def TuneLagLength(self, Model, data, object_cols, continuous_cols, split_date,
                      vars_to_lag, interactions=None, max_lag_length=10, samples=50):
        print('Tune lag length')
        datacopy = data.copy(deep=True)
        self.vars_to_lag = vars_to_lag
        if pow(max_lag_length+1, len(vars_to_lag)) > self._max_lag_combns:
            print('warning: possible lag combinations too large. Change the [self]._max_lag_combns if needed.')
            print('Reducing the size of the possible combinations')
            while pow(max_lag_length+1, len(vars_to_lag)) > self._max_lag_combns:
                max_lag_length-=1
            print('New max_lag_length {}'.format(max_lag_length))
        self.lag_combination_dictionary = self.all_lag_combinations(
            len(vars_to_lag), max_lag_length)

        lags = pd.DataFrame(self.lag_combination_dictionary.items(), columns=[
                            'LagsCombn', 'Times'])
        print('There are {} possible lag combinations. Exploring {:0.2%}'.format(lags.shape[0],
                                                                                 float(samples)/lags.shape[0]))
        if lags.shape[0] < samples:
            samples = len(lags)
            warnings.warn(
                'Cannot take more samples than combinations of lags. Reducing samples.')
        model_ranking = {}
        lags = lags.sample(frac=1)
        lags.reset_index(drop=True, inplace=True)
        i = 1

        while i < samples+1:
            print('Pct complete {:0.2%}'.format(float(i)/(samples+1)), end='\r')
            lag_combn = lags['LagsCombn'].iloc[i-1]
            lagged_dict = dict(zip(vars_to_lag, lag_combn))
            continuous_cols_copy = continuous_cols.copy()
            (Xtrain, ytrain, Xfuture, yfuture) = self.train_test_split(datacopy, object_cols, 
                                                                       continuous_cols_copy, split_date=split_date,
                                                                       lagged_variables_dict=lagged_dict, 
                                                                       interactions=interactions)
            try:
                Model.train(Xtrain, ytrain)
                Model.forecast(Xfuture, yfuture)
                forecast_data = Model.make_results_dataframe(yfuture, Model.yhatf)
                summary = self.summarize_results(forecast_data)
                model_ranking[lag_combn] = summary
                i += 1
            except ModelError as e:
                i+=1
                pass 
        print() 
        if len(model_ranking)==0:
            model_ranking = pd.DataFrame(columns=['Lag Lengths'] + self.metrics)
        else:
            model_ranking = pd.DataFrame.from_dict(model_ranking, orient='index')
            model_ranking.columns = self.metrics
        model_ranking = model_ranking.sort_values(self.ranking_col)
        if self.lag_ranking.empty:
            self.lag_ranking = model_ranking
            self.lag_ranking.reset_index(inplace=True)
            self.lag_ranking.rename(
                {'index': 'Lag Lengths'}, axis=1, inplace=True)
            combn_key = self.lag_ranking.iloc[0]['Lag Lengths']
            self.lag_dictionary = dict(zip(vars_to_lag, combn_key))
            self.lag_ranking.sort_values(by=self.ranking_col)
        else:
            model_ranking.reset_index(inplace=True)
            model_ranking.rename({'index': 'Lag Lengths'},
                                 axis=1, inplace=True)
            self.lag_ranking = pd.concat(
                [self.lag_ranking, model_ranking], axis=0)
            self.lag_ranking.sort_values(by=self.ranking_col, inplace=True)
            self.lag_ranking = self.lag_ranking.head(100)
            combn_key = self.lag_ranking.iloc[0]['Lag Lengths']
            self.lag_dictionary = dict(zip(vars_to_lag, combn_key))

    def TuneArLags(self, data, object_cols, continuous_cols, split_date, interactions=None,
                   lag_dictionary=None, train_cutoff=None, max_ar_lags=10):
        datacopy = data.copy()
        other_metrics = ['AR(p)']
        model_ranking = {}
        i = 1
        while i < max_ar_lags + 1:
            (Xtrain, ytrain, Xfuture, yfuture) = self.train_test_split(datacopy, object_cols, continuous_cols.copy(),
                                                                        split_date=split_date, lagged_variables_dict=lag_dictionary,
                                                                        interactions=interactions,train_cutoff=train_cutoff)
            Model = ModelAutoregressive(i)
            try:
                Model.train(Xtrain, ytrain)
                Model.forecast(Xfuture, yfuture)
                forecast_data = Model.make_results_dataframe(yfuture, Model.yhatf)
                summary = self.summarize_results(forecast_data)
                summary.append(i)
                model_ranking[i] = summary
            except ModelError as me:
                pass 
            i+=1
        print() 
        if len(model_ranking)==0:
            pd.DataFrame(columns=self.metrics+['AR(p)'])
        else:
            model_ranking = pd.DataFrame.from_dict(model_ranking, orient='index')
            model_ranking.columns = self.metrics + other_metrics
        if self.ar_order_ranking.empty:
            self.ar_order_ranking = model_ranking
        else:
            self.ar_order_ranking = pd.concat(
                [self.ar_order_ranking, model_ranking], axis=0)
        self.ar_order_ranking.reset_index(drop=True, inplace=True)
        self.ar_order_ranking.sort_values(by=self.ranking_col)
        self.ar_order_ranking = self.ar_order_ranking.head(100)
        self.best_arp = self.ar_order_ranking['AR(p)'].iloc[0]

    def all_lag_combinations(self, number_of_vars, max_lag_length):
        all_subs = {}
        for i in combinations_with_replacement(range(max_lag_length+1), number_of_vars):
            all_subs[i] = 1
            for k in permutations(i):
                if k not in all_subs.keys():
                    all_subs[k] = 1
        return all_subs

    def AutoTune(self, ModelObj, data, object_cols, continuous_cols, split_date,
                 interaction_terms=None, number_subsets=10,max_lag_length=10,
                 lag_length_samples=50, max_ar_lags=None, interval=10):
        if 'LookCnt' in continuous_cols:
            warnings.warn("LookCnt should not be in continuous columns, removing it.")
            continuous_cols.remove('LookCnt')
        ar = 0 
        is_object_dict = dict(zip(object_cols, len(object_cols)*[1]))
        is_object_dict.update(
            dict(zip(continuous_cols, len(continuous_cols)*[0])))
        AllModels = sorted(
            list(powerset(object_cols+continuous_cols)), key=len)
        AllModels.pop(0)        
        print('Trying pct {:0.2%} of total possible models '.format(
            number_subsets/float(len(AllModels))))
        subsets = random.sample(AllModels, number_subsets)
        model_ranking = {}
        for i, s in enumerate(subsets):
            print("Pct complete {:0.2%}".format(
                1.-(len(subsets) - i)/float(len(subsets))), end='\r')
            temp_object_cols = []
            temp_cont_cols = []
            for j in s:
                if is_object_dict[j]==1:
                    temp_object_cols.append(j)
                else:
                    temp_cont_cols.append(j)
            (Xtrain, ytrain, Xfuture, yfuture) = self.train_test_split(data=data, object_columns=temp_object_cols, 
                                                                       continuous_columns=temp_cont_cols,
                                                                       split_date=split_date,
                                                                       interactions=interaction_terms)
            try:
                ModelObj.train(Xtrain, ytrain)
                ModelObj.forecast(Xfuture, yfuture)
                forecast_data = ModelObj.make_results_dataframe(yfuture, ModelObj.yhatf)
                summary = self.summarize_results(forecast_data)
                model_ranking[s] = summary
            except (ModelError, RuntimeWarning):
                continue
        self.autotune_model_ranking = pd.DataFrame.from_dict(
            model_ranking, orient='index')
        self.autotune_model_ranking.reset_index(inplace=True)
        self.autotune_model_ranking.columns = ['Model'] + self.metrics
        self.autotune_model_ranking.sort_values(
            by=self.ranking_col, inplace=True, ascending=True)
        self.autotune_model_ranking.reset_index(drop=True, inplace=True)
        self.best_model_vars = self.autotune_model_ranking.iloc[0]['Model']
        names = self.autotune_model_ranking['Model']
        name_abbr = {} 
        for tup in names:
            abbr = ''
            for j in tup:
                abbr+=j[0]
            name_abbr[tup] = abbr 
        self.autotune_model_ranking['Abbr'] = name_abbr.values()
        temp_object_cols = []
        temp_laggable = []
        temp_cont_cols = []
        for i in self.best_model_vars:
            if i in self._contcols:
                temp_laggable.append(i)
                temp_cont_cols.append(i)
            elif i in self._objcols:
                temp_object_cols.append(i)
            else:
                temp_cont_cols.append(i)
        self.TuneLagLength(ModelObj, data, object_cols=temp_object_cols, continuous_cols=temp_cont_cols,
                           vars_to_lag=temp_laggable, split_date=split_date, interactions=interaction_terms,
                           max_lag_length=max_lag_length, samples=lag_length_samples)
        if max_ar_lags is not None and isinstance(max_ar_lags, int):
            self.TuneArLags(data, temp_object_cols, temp_cont_cols, split_date, interaction_terms,
                            self.lag_dictionary, max_ar_lags=max_ar_lags)
            mar = ModelAutoregressive(self.best_arp)
            ar = 1
            md = {'Model': (mar, temp_object_cols, temp_cont_cols,
                            interaction_terms, self.lag_dictionary)}
        else:
            md = {'Model': (ModelObj, temp_object_cols, temp_cont_cols, interaction_terms,
                            self.lag_dictionary)}
        self.TuneCutoffTime(data, model_dictionary=md,
                            split_date=split_date, interval=interval)
        if ar == 1:
            (Xtrain, ytrain, Xfuture, yfuture) = self.train_test_split(data=data, object_columns=temp_object_cols, 
                                                                       continuous_columns=temp_cont_cols,
                                                                        split_date=split_date, interactions=interaction_terms,
                                                                        lagged_variables_dict=self.lag_dictionary,
                                                                        train_cutoff=self.best_cutoff_date)
            mar.train(Xtrain,ytrain)
            mar.forecast(Xfuture, yfuture)
            forecast_data = ModelObj.make_results_dataframe(yfuture, mar.yhatf)
            score = forecast_data[self.metrics].mean()
            score= pd.DataFrame(score).T
            if 'RMSE' in score.columns:
                score['RMSE'] = np.sqrt(score['RMSE'].item())
        else:
            (Xtrain, ytrain, Xfuture, yfuture) = self.train_test_split(data=data, object_columns=temp_object_cols, 
                                                                       continuous_columns=temp_cont_cols,
                                                                        split_date=split_date, interactions=interaction_terms,
                                                                        lagged_variables_dict=self.lag_dictionary,
                                                                        train_cutoff=self.best_cutoff_date)
            ModelObj.train(Xtrain, ytrain)
            ModelObj.forecast(Xfuture, yfuture) 
            forecast_data = ModelObj.make_results_dataframe(yfuture, ModelObj.yhatf) 
            score= forecast_data[self.metrics].mean()
            score= pd.DataFrame(score).T
            if 'RMSE' in score.columns:
                score['RMSE'] = np.sqrt(score['RMSE'].item())
        autotune_results = {'Best Model Variables':self.best_model_vars, 'Best Cutoff Dt':self.best_cutoff_date,
                      'ARP': self.best_arp, 'Lag Dict': self.lag_dictionary, 'score':score}
        return autotune_results

    def plot_tune_cutoff(self):
        plt.figure()
        sns.lineplot(data=self.cutoff_ranking, x='Dt',
                     y=self.ranking_col, hue='ModelName')
        plt.title('Change in MAE vs Change in Cutoff Date')
        plt.xlabel('Cutoff Date')
        plt.xticks(rotation=45)
        plt.draw()

    def plot_lag_ranking(self, top=10):
        plt.figure()
        self.lag_ranking.sort_values(by=self.ranking_col, inplace=True)
        print(self.lag_ranking)
        data = self.lag_ranking.head(top)
        data = pd.melt(data[self.metrics+['Lag Lengths']], id_vars='Lag Lengths',
                       var_name='Metric Type', value_name='Metric Value')
        data['Lag Lengths'] = data['Lag Lengths'].astype(str)
        data['Metric Value'] = data['Metric Value'].astype('float64')
        sns.barplot(data=data, x='Lag Lengths',
                    y='Metric Value', hue='Metric Type')
        plt.xticks(rotation=45)
        lagged_vars_str = ' '.join(self.vars_to_lag)
        plt.title('Errors vs. Lag Lengths on:\n ' + lagged_vars_str)
        plt.draw()

    def plot_ar_order_ranking(self):
        fig, axs = plt.subplots(nrows=2, ncols=1)
        ss = StandardScaler()
        cnames = self.ar_order_ranking.columns
        data = self.ar_order_ranking.copy()
        data[['RMSE', 'MAE']] = ss.fit_transform(data[['RMSE', 'MAE']])
        data = pd.DataFrame(data, columns=cnames)
        data = pd.melt(data, id_vars='AR(p)', value_name='Metric Value',
                       var_name='Metric')
        orig_data = pd.melt(self.ar_order_ranking, id_vars='AR(p)', value_name='Metric Value',
                            var_name='Metric')
        sns.lineplot(data=data, x='AR(p)', y='Metric Value',
                     hue='Metric', ax=axs[0])
        sns.lineplot(data=orig_data, x='AR(p)',
                     y='Metric Value', hue='Metric', ax=axs[1])
        axs[0].set_title('Standardized Error versus AR(p) order')
        axs[1].set_title('Error versus AR(p) order')
        fig.tight_layout()
        plt.draw()

    def plot_model_ranking(self):
        data = pd.melt(self.model_ranking, id_vars=['Dt', 'Model Name'],
                       var_name='Metric', value_name='Metric Value')
        plt.figure()
        ax = sns.lineplot(data, x='Dt', y='Metric Value',
                     hue='Model Name', style='Metric')
        sns.move_legend(ax, "upper left", bbox_to_anchor=(1, 1))
        plt.xticks(rotation=45)
        plt.title('Model Predictive Error vs. Split Time')
        plt.draw()
        
    def plot_autotune(self):
        plt.figure() 
        plot_data = self.autotune_model_ranking.head(25)
        sns.barplot(data=plot_data, x='Abbr', y=self.ranking_col)
        plt.xticks(fontsize=8)
        plt.xticks(rotation=45)
        plt.show()


# %%
if __name__ == '__main__':

    data = pd.read_csv('fromsql.csv')
    lpt = LookPredictorTuner(data)
    ms = ModelSimple()
    mar = ModelAutoregressive(ar_lags=15)
    object_cols_simple = ['DayNum',  'MonthNum', 'YearNum']
    continuous_cols = ['ShortWeek', 'MarketEarlyCloseBit', 'FirstBusDayOfMonthBit', 'LastBusDayOfMonthBit',
                        'ps_spread','BeLockCnt', 'ConfAmt', 'GovtAmt', 'NonConfAmt']
    interaction_dummies = [('DayNum', 'PrimaryRate30Y'), ('DayNum', 'ShortWeek')]
    lag_dictionary = {'SecondaryRate30Y':3, 'ps_spread':3, 'LookCnt':50}
    model_dictionary = {} 
    model_dictionary['test_simple'] = (ms, object_cols_simple, continuous_cols, interaction_dummies, lag_dictionary)
    model_dictionary['test_ar'] = (mar, object_cols_simple, continuous_cols, interaction_dummies, lag_dictionary)
    split_date = '2023-06-01'
    lpt.ModelComparison(data, model_dictionary, '2023-06-01', max_out=30)
    # lpt.plot_model_ranking()
    
    
    lpt.TuneCutoffTime(data, model_dictionary, split_date, interval=100)
    # lpt.plot_tune_cutoff()
    
    split_date = '2024-03-01'
    lpt.TuneLagLength(mar, data, object_cols_simple, continuous_cols, split_date, 
                      ['LookCnt'], interaction_dummies, 
                      max_lag_length=50)
    # lpt.plot_lag_ranking()
    
    lpt.AutoTune(ms, data, object_cols_simple, continuous_cols, split_date,
                 interaction_dummies, number_subsets=100, max_lag_length=30)
    lpt.plot_autotune()
    
    plt.show() 