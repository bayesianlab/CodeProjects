import numpy as np
import math
import pandas as pd
from scipy import sparse

def MakeStateSpaceForm(params):
    lags = params.shape[1]
    rows = params.shape[0]
    p = sparse.diags(params.T, np.arange(0, rows * lags, rows),
                     shape=(rows,lags*rows)).toarray()
    eyepm1 = np.eye(rows*(lags-1))
    empty = np.zeros( (rows*(lags-1), rows) )
    bottom = np.concatenate((eyepm1, empty), 1)
    return np.vstack((p, bottom))

def InitializeArVariance(params, variances):
    """
    Needs to include check for singularity
    """
    lags = params.shape[1]
    rows = params.shape[0]
    zeromat = np.zeros((rows*(lags-1), rows))
    SSparams = MakeStateSpaceForm(params)
    eqns = SSparams.shape[0]
    SSparams = np.kron(SSparams, SSparams)
    rows = SSparams.shape[0]
    eyep = np.eye(rows)
    varmat = np.diag(variances, 0)
    varmat = np.vstack((varmat, zeromat))
    outerp = varmat@varmat.T
    outerp = np.array(outerp.flatten('F'))
    sol = np.linalg.solve(eyep - SSparams, outerp)
    sol = np.reshape(sol, (eqns,eqns), 'F')
    return sol


def Precision(params, variance, P0, T):
    K = params.shape[0]
    lags = params.shape[1]
    stackedParams = np.fliplr((np.tile(-params, (T, 1))))
    v = np.hstack((stackedParams, np.ones((T*K, 1))))
    H = sparse.diags(np.flipud(v.T), -np.arange(0,K*(lags+1),K), shape=(T*K, T*K)).toarray()
    precision = variance**(-1)
    Sinv = sparse.diags(np.tile(precision.T, (1,T)), [0], shape=(T*K, T*K)).toarray()
    Sinv[0:K*lags, 0:K*lags] = np.linalg.solve(P0, np.eye(P0.shape[0]))
    return H.T@Sinv@H



p = np.array( [[.2,.1,.02],[.5,.25,.05]] )
v = np.array([1.,1.])
T = 4
P0 = InitializeArVariance(p, v)
#print(MakeStateSpaceForm(params=p).shape)
#print(pd.DataFrame(P0))

print(pd.DataFrame(Precision(p, v, P0, T)))


