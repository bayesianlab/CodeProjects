#%%

import pandas as pd 
import numpy as np

#%%

def sq(n):
    h = n 
    l = 0 
    g = .5*(l+h)
    eps = .001
    while abs(g*g - n) > eps:
        
        if g*g > n:
            h = g      
        else:
            l = g 

        g = .5*(l + h)
            
    return g 

sq(9)