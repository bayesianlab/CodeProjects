import numpy as np
from numpy.linalg import inv

N = 300
dim = 3
X = np.random.normal(0,1, [N,dim])
trueB = np.array([1,.75, .5])

noise = np.random.normal(0,1, [N,1])
measurementError = np.random.normal(0,.5, [N,1])
y = X*np.mat(trueB).transpose() + noise
y2 = y + measurementError


def bols(y,X):
    return inv(np.matmul(X.transpose(),X)) * np.matmul(X.transpose(), y)

def sebeta(e,X):
    XpXinv = inv(np.matmul(X.transpose(), X))
    epe = np.matmul(e.transpose(), e) / (e.shape[0] - XpXinv.shape[1])
    return  np.multiply(XpXinv, epe)

bols1 = bols(y,X)
bols2 = bols(y2, X)
e1 = y - X*bols1
e2 = y2 - X*bols2
print("Beta OLS")
print(bols1.transpose())
print(bols2.transpose())
print ()
print("Standard Error of Beta OLS")
print(sebeta(e1, X).diagonal())
print(sebeta(e2, X).diagonal())