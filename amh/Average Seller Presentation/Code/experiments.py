#%%
import pandas as pd 
import numpy as np 
from MizerEval import * 
import pathlib 
#%%
# model_path = r'\\corp.lan\shares\TradingDesk\Analytics\Aspen\Margin Optimization\Presentation\Average Seller Presentation\Data\79747158'
model_path = '/home/dillon/CodeProjects/amh/Average Seller Presentation/Data/79747158'
# data=pd.read_csv('\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Data\\data_with_marginprice_winbit_2801.csv')
data = pd.read_csv( '/home/dillon/CodeProjects/amh/Average Seller Presentation/Data/data_with_marginprice_winbit_2801.csv')
with open('\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Code\\dtypes.pkl', 'rb') as f:
    dt = pickle.load(f)
data=data.astype(dt)
data_copy = data.copy()
args=[]
proc=[]
out_file = 'Experiments/dseller.csv'
run_model_experiments(data, model_path, out_file)
# %%

# model_path = r'\\corp.lan\shares\TradingDesk\Analytics\Aspen\Margin Optimization\Presentation\Average Seller Presentation\Data\79747158'
model_path = '/home/dillon/CodeProjects/amh/Average Seller Presentation/Data/79747158'
# data=pd.read_csv('\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Data\\data_with_marginprice_winbit_2801.csv')
data = pd.read_csv( '/home/dillon/CodeProjects/amh/Average Seller Presentation/Data/data_with_marginprice_winbit_2801.csv')
# with open('\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Code\\dtypes.pkl', 'rb') as f:
#     dt = pickle.load(f)
with open('/home/dillon/CodeProjects/amh/Average Seller Presentation/Code/dtypes.pkl', 'rb') as f:
    dt = pickle.load(f)
data=data.astype(dt)
data_copy = data.copy()
args=[]
proc=[]
out_file = 'Experiments/.csv'
seller_weight_file_name = pathlib.Path('/home/dillon/CodeProjects/amh/Average Seller Presentation/Data/seller_weights.csv')
seller_weight_frame = pd.read_csv(seller_weight_file_name)
run_model_weighted_average_predictions(data, model_path, seller_weight_frame, out_file)
# %%
