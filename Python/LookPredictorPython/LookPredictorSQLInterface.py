#%% 
from http import server
from Model import ModelAR, ModelSimple
from cronus_interface import get_data
import ast 
from PrepareLookPredictorData import PrepareLookPredictorData
from datetime import datetime, timedelta
import numpy as np 
import pandas as pd 
import re 

#%%
class ConfigParser:
    
    def __init__(self, data):
        self.arp = 0
        self.periods_out = 0 
        self.data = data
        self.object_cols = []
        self.continuous_cols = [] 
        self.interactions = []  
        self.lag_dict = {}
        self.train_cutoff = None 
        self.autotune = None 
        self.parse_object_continuous_cols()  
    
    def parse_object_continuous_cols(self):
        self.arp = int(self.data['arp'].item())
        self.periods_out = self.data['periods_out'].item()
        objs = self.data['object_cols'].item()
        conts = self.data['continuous_cols'].item() 
        xs = self.data['interactions'].item() 
        lags = self.data['lag_dictionary'].item()
        tc = self.data['train_cutoff'].item() 
        ab = self.data['autotunebit'].item() 
        self.object_cols = objs.split(',')
        self.object_cols = [i.replace(' ', '') for i in self.object_cols]
        self.continuous_cols = conts.split(',')
        self.continuous_cols = [i.replace(' ', '') for i in self.continuous_cols]
        tuple_strings = re.findall('\((.*?)\)', xs)
        self.interactions =  [] 
        for t in tuple_strings:
            s = list(t.split(','))
            for i in range(len(s)):
                s[i] = s[i].replace(' ', '')
            s = tuple(s)
            self.interactions.append(s)
        lags = lags.split(',')
        c = 1
        keys = [] 
        values = [] 
        for i in lags:
            if c%2 == 1:
                n = i.replace('(', '')
                n = n.replace(')', '')
                n = n.replace(' ', '')
                keys.append(n)
            else:
                n = i.replace('(', '')
                n = n.replace(')', '')
                n = n.replace(' ', '')
                values.append(int(n))
            c+=1
        self.lag_dict = dict(zip(keys,values))
        if tc is not None:
            self.train_cutoff=tc 
        self.autotune = bool(ab)
        
def prep_os_dates(start_date, periods):
    yfuture = {'Dt':[], 'yfuture':[]}
    d = start_date 
    for i in range(periods):
        d += timedelta(days=1)
        yfuture['Dt'].append(d)
        yfuture['yfuture'].append(np.nan)
    yfuture = pd.DataFrame.from_dict(yfuture)
    
#%%

if __name__=='__main__':
    
    print('Interface')
    proc = 'LookPredictorAction'
    server_name = 'awsdevsql013'
    input_id = 90594758
    # d= get_data(proc, server_name, 'GetInSample', input_id)
    config_data = get_data(proc, server_name, 'GetConfig', input_id)
    cp = ConfigParser(config_data)
    if not cp.autotune:
        print('Fixed Model')
        # data = get_data(proc, server_name, 'GetData', input_id)
        data = pd.read_csv('fromsql.csv')
        prepobj = PrepareLookPredictorData(data)
        mos = MakeOutSample()
        Xfuture = mos.make_os(data, periods_out=3)
        osdates = get_data(proc, server_name, 'GetOsDates', input_id)
        osdates['Dt'] = pd.to_datetime(osdates['Dt'])
        yfuture = pd.DataFrame()
        yfuture['Dt'] = osdates['Dt'].head(cp.periods_out)
        yfuture['yfuture'] = np.nan
        if cp.arp!=0:
            mar = ModelAR(cp.arp)
            (Xtrain, ytrain, u, t) = prepobj.train_test_split(data, cp.object_cols, cp.continuous_cols, 
                                                              interactions=cp.interactions,
                                                              lagged_variables_dict=cp.lag_dict)
            print(Xtrain[Xtrain.isna()])
            # mar.forecast(Xtrain, ytrain, Xfuture, yfuture)
            
        else:
            ms = ModelSimple(cp.arp)
        
        
        
    
    
# %%
