#%%
import pandas as pd 
import numpy as np
from scipy.optimize import linprog 
#%%

c = np.array([-1,1])
A = np.array([[1,-1], 
             [1,1]], np.float64)
b_eq = np.array([2, 6])

# %%
res = linprog(c, A_eq=A, b_eq=b_eq)
print(res.x)

print(res.fun)