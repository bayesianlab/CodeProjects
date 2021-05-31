import numpy as np
import math
import pandas as pd
import GenerateSimulationData as gsd
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


def mldfvar_betaDraw(vecy, surX, om_precision, A, FactorPrecision, b0, B0, T):
    K = len(om_precision)
    nFactors = A.shape[1]
    KP = surX.shape[1]
    full_precision = np.diag(om_precision, 0)
    Pinv = np.linalg.solve(FactorPrecision +
                           np.kron(np.eye(T), A.T @ full_precision @ A),
                           np.eye(FactorPrecision.shape[1]))
    B0inv = np.linalg.solve(B0, np.eye(KP))
    xpx = np.zeros((KP, KP))
    xpy = np.zeros((KP, 1))
    Xzz = np.zeros((T * nFactors, KP))
    yzz = np.zeros((T * nFactors, 1))
    k1 = np.arange(K)
    k2 = np.arange(nFactors)
    for t in range(0, T):
        select1 = k1 + t * K
        select2 = k2 + t * nFactors
        tx = full_precision @ surX[select1, :]
        ty = full_precision @ vecy[select1]
        Xzz[select2, :] = A.T @ tx
        yzz[select2, :] = A.T @ ty
        xpx = xpx + (surX[select1, :].T @ tx)
        xpy = xpy + (surX[select1, :].T @ ty)
    XzzPinv = Xzz.T @ Pinv
    B = B0inv + xpx - (XzzPinv @ Xzz)
    Blowerinv = np.linalg.solve(np.linalg.cholesky(B), np.eye(KP))
    B = Blowerinv.T@Blowerinv
    b = B@(B0inv@b0 + xpy - XzzPinv@yzz)
    bupdate = b + Blowerinv.T@np.random.normal(0,1,(KP,1))
    xbt = surX@bupdate
    return (bupdate, xbt, b, B)





mld = gsd.MultilevelData()

vecy = np.reshape(mld.y, (mld.K*mld.T,1), 'F')
mldfvar_betaDraw(vecy, mld.surX, 1. / mld.om_variance, mld.A,
                 mld.FactorPrecision, mld.b0, mld.B0, mld.T)

# print(pd.DataFrame(Xstacked))
# print(pd.DataFrame(SUR_Form(Xstacked, 3)))
# print(MakeObsModelIdentity(InfoDict))
# print(GenerateSimulationData(InfoDict))
# print(MakeStateSpaceForm(params=p).shape)
# print(pd.DataFrame(P0))
# print(pd.DataFrame(Precision(p, v, P0, T)))
