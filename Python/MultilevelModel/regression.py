import numpy as np
import math
import pandas as pd
from scipy import sparse
from matplotlib import pyplot as plt

def MakeStateSpaceForm(params):
    lags = params.shape[1]
    rows = params.shape[0]
    p = sparse.diags(params.T, np.arange(0, rows * lags, rows),
                     shape=(rows, lags * rows)).toarray()
    eyepm1 = np.eye(rows * (lags - 1))
    empty = np.zeros((rows * (lags - 1), rows))
    bottom = np.concatenate((eyepm1, empty), 1)
    return np.vstack((p, bottom))


def InitializeArVariance(params, variances):
    """
    Needs to include check for singularity
    variances is a row!
    """
    lags = params.shape[1]
    rows = params.shape[0]
    zeromat = np.zeros((rows * (lags - 1), rows))
    SSparams = MakeStateSpaceForm(params)
    eqns = SSparams.shape[0]
    SSparams = np.kron(SSparams, SSparams)
    rows = SSparams.shape[0]
    eyep = np.eye(rows)
    varmat = np.diag(variances, 0)
    varmat = np.vstack((varmat, zeromat))
    outerp = varmat @ varmat.T
    outerp = np.array(outerp.flatten('F'))
    sol = np.linalg.solve(eyep - SSparams, outerp)
    sol = np.reshape(sol, (eqns, eqns), 'F')
    return sol


def Precision(params, variance, P0, T):
    K = params.shape[0]
    lags = params.shape[1]
    stackedParams = np.fliplr((np.tile(-params, (T, 1))))
    v = np.hstack((stackedParams, np.ones((T * K, 1))))
    H = sparse.diags(np.flipud(v.T), -np.arange(0, K * (lags + 1), K), shape=(T * K, T * K)).toarray()
    precision = variance ** (-1)
    Sinv = sparse.diags(np.tile(precision.T, (1, T)), [0], shape=(T * K, T * K)).toarray()
    Sinv[0:K * lags, 0:K * lags] = np.linalg.solve(P0, np.eye(P0.shape[0]))
    return H.T @ Sinv @ H


def MakeObsModelIdentity(InfoDict):
    levels = list(InfoDict.keys())
    t1 = InfoDict[levels[0]]
    rows = t1[0][1] + 1
    Identity = []
    for k in levels:
        tuplelist = InfoDict[k]
        for t in tuplelist:
            z = np.zeros((rows,), dtype=int)
            s = t[0]
            e = t[1]
            z[s:e + 1] = 1
            Identity.append(z)
    Identity = np.array(Identity)
    return Identity.T


def SUR_Form(stackedX, K):
    dims = stackedX.shape
    cols = dims[1]
    T = int(dims[0] / K)
    surX = np.tile(np.kron(np.eye(K), np.ones(cols)), (T, 1)) * \
           np.tile(stackedX, (1, K))
    return surX


def GenerateSimulationData(InfoDict):
    I = MakeObsModelIdentity(InfoDict)
    pass


def mldfvar_betaDraw():
    pass




T = 100
K = 9
predictors = 2
constant = np.ones(T * K)
InfoDict = {"L1": [(0, 8)], "L2": [(0, 5), (6, 8)]}
p = np.array([[.2, .1, .02], [.5, .25, .05]])
v = np.array([1., 1.])
x = np.random.normal(0, 1, (K * T, predictors))
Xstacked = np.hstack((np.reshape(constant, (K * T, 1), 'F'), x))
betas = np.array([1, .5, .5])
betas = np.tile(betas, (K,))
surX = SUR_Form(Xstacked, K)


I = MakeObsModelIdentity(InfoDict)
nFactors = I.shape[1]
gammas = [.2, .2]
gammas = np.tile(gammas, (nFactors,1))
v = np.array([1.0,1.0,1.0])
H = Precision(gammas, v, InitializeArVariance(gammas, v), T)
L = np.linalg.cholesky(H)
Linv = np.linalg.solve(L, np.eye(T*nFactors))
Factors = Linv.T@np.random.normal(0,1,T*nFactors)
Factors = np.reshape(Factors, (nFactors,T), 'F')

A = np.ones((9,3))*I

AF = A@Factors
Xbeta = np.reshape(surX@betas, (K,T), 'F')

y = Xbeta + AF + np.random.normal(0, 1, (K,T))





# plt.plot(surX@betas)
# plt.show()

# print(pd.DataFrame(Xstacked))
# print(pd.DataFrame(SUR_Form(Xstacked, 3)))
# print(MakeObsModelIdentity(InfoDict))
# print(GenerateSimulationData(InfoDict))
# print(MakeStateSpaceForm(params=p).shape)
# print(pd.DataFrame(P0))
# print(pd.DataFrame(Precision(p, v, P0, T)))
