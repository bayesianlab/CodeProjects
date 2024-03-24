import seaborn as sns 
import pandas as pd 
import numpy as np 
import matplotlib.pyplot as plt 
from LookPredictorErrors import SummarizeResultsError

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
        return table 