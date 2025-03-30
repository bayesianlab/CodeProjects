#%%

import pandas as pd 
import numpy as np 
import ccxt
#%%


bitmex   = ccxt.bitmex()

# %%
m = bitmex.load_markets()

m['BTC/USDT']
