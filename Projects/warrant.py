import numpy as np
from scipy import optimize

S = 9.01
W = 4.59
E = 5
SE = .09 
WE = .004
print (SE)
print(WE)

def NormalCurve(z,x,y):
    val = y - pow(pow(x,z)+ 1., (1./z)) +  1.
    return val


res = optimize.newton(NormalCurve, 3,args=(.9, .3454), full_output=True)
print(res)

