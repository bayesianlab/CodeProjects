import numpy as np
import scipy.stats as stats
import pandas as pd
import matplotlib.pyplot as plt
from scipy.optimize import minimize

np.random.seed(7)
eps = np.random.normal(0,1,100)
beta0 = 1.5
beta11 = 2.3
beta12 = 5
x11 = np.random.normal(0, 1, 100)
x12 = np.random.normal(0, 1, 100)


py1 = stats.bernoulli.rvs(stats.norm.cdf(beta0 + beta11*x11 + eps), size=100)
py2 = stats.bernoulli.rvs(stats.norm.cdf(beta0 + beta12*x12 + eps), size=100)

frame = pd.DataFrame({'py1':py1, 'py2':py2})
print(frame)

b0G = .5
b11G = 1
b12G = 2

Beta = pd.DataFrame({'b1':[b0G, b11G], 'b2':[b0G,b12G]})
Data = pd.DataFrame({'c1':[1]*100, 'x11':x11, 'c2':[1]*100, 'x12':x12})
Data = Data[['c1', 'x11', 'c2', 'x12']]
print(Data)
print(Beta)

print(Data[['c1', 'x11']][0:1])
t = np.dot(Data[['c1', 'x11']][0:1], Beta['b1'])
print(np.dot(Data[['c1', 'x11']][0:1], Beta['b1']))
print(stats.truncnorm.rvs(np.dot(Data[['c1', 'x11']][0:1], Beta['b1']), np.inf,1) )
print(stats.truncnorm.rvs(np.dot(Data[['c2', 'x12']][0:1], Beta['b2']), np.inf,1) )

def probitML(y, x, params):
    """
    normalPdfProbs = pdf normal all x * qi
    normalCdfProbs = cdf all normals
    element wise division
    element wise multiplication times x
    maximize
    """
    normalObject = stats.norm()
    xBeta = np.dot(x, params)
    qi = np.array([2*y - 1]).T
    num = normalObject.pdf(np.multiply(qi, xBeta))
    den = normalObject.cdf(np.multiply(qi, xBeta))
    return np.sum(np.multiply(np.multiply(np.divide(num, den), qi), x))



subData = Data[['c1', 'x11']]
subBeta = Beta[['b1']]
probitML(py1, subData, subBeta)

