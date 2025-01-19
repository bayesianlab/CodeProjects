#%%
import pandas as pd 
import numpy as np
from scipy.optimize import linprog 
#%%

c = np.array([2,1,3,1])
A = np.array([[1,2,1,1], 
             [-1,0,2,1],
             [-1,1,0,0]], np.float64)
b_eq = np.array([3,0,1])

# %%
linprog(c, A_eq=A, b_eq=b_eq)