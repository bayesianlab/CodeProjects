#%%
import pandas as pd
import numpy as np
from Connect import *
import os 
#%%
con = Connection(db_host, db_user, db_pass, db_name)

# %%
dir = '/home/dillon/gdrivelocal/COMMENTARY_ON_PROPHECY/Sermons/'
# %%


 
def list_files_recursive(path, path_list):
    for entry in os.listdir(path):
        full_path = os.path.join(path, entry)
        if os.path.isdir(full_path):
            list_files_recursive(full_path, path_list)
        else:
            path_list.append(full_path)
# %%
paths = [] 
list_files_recursive(dir, paths)

# %%
