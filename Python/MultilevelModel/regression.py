import numpy as np
import math
import pandas as pd
import GenerateSimulationData as gsd
from scipy import stats
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


def MakePrecision(params, variance, P0, T):
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
    B = Blowerinv.T @ Blowerinv
    b = B @ (np.reshape(B0inv @ b0, (KP, 1)) + xpy - XzzPinv @ yzz)
    bupdate = b + Blowerinv.T @ np.random.normal(0, 1, (KP, 1))
    xbt = np.reshape(surX @ bupdate, (K,T), 'F')
    return (bupdate, xbt, b, B)

def zeroFactorLevel(Identity, level):
    I = Identity.copy()
    I[:,level] = 0
    return I

def InitializeAprior(Identity, A0Priors):
    ishape = Identity.shape
    nFactors = ishape[1]
    K = ishape[0]
    A0mat = []
    for c in range(nFactors):
        t = np.nonzero(A0Priors[:,c])
        A0mat.append(np.diag(A0Priors[t, c][0],0))
    return A0mat

def ConditionalLogLikelihood(ytdemeaned, ObsModel, ObsPriorMean, ObsPriorPrecision,
                             obsPrecision, factors, factorPrecision):
    dimfactors = factors.shape
    nFactors = dimfactors[0]
    T = dimfactors[1]
    K = len(obsPrecision)
    nFactorsT = nFactors*T
    nFactorsK = nFactors*K
    OmegaInverse = np.diag(obsPrecision,0)
    FtOF = np.kron(OmegaInverse, factors@factors.T)
    Avariance = np.linalg.solve(ObsPriorPrecision@ObsPriorMean.T + FtOF, np.eye(nFactorsK))
    Term = ((factors@ytdemeaned.T)*obsPrecision.T)
    Amean = np.ravel(Avariance@(ObsPriorPrecision@ObsPriorMean.T + Term).T, 'F')
    pdfA = stats.multivariate_normal.logpdf(ObsModel.T, Amean, Avariance)
    AOI = ObsModel.T@OmegaInverse
    Fvariance = np.linalg.solve(factorPrecision + np.kron(np.eye(T), AOI@ObsModel),
                                np.eye(nFactorsT))
    Fmean = Fvariance@(np.kron(np.eye(T), AOI)@np.reshape(ytdemeaned, (T*K, 1), 'F'))
    pdfF = stats.multivariate_normal.logpdf(factors, np.ravel(Fmean, 'F'), Fvariance)
    print(pdfA - pdfF)


def LoadingFactorUpdate(yt, Xbeta, Ft, A, gammas, om_variances, factorVariances,
                        Identity, InfoDict, a0, A0):
    dimyt = yt.shape
    T = dimyt[1]
    levels = InfoDict.keys()
    index = -1
    factor = -1
    lags = gammas.shape[1]
    for i in levels:
        index += 1
        AF = (A*zeroFactorLevel(Identity, index))@Ft
        mut = Xbeta + AF
        ytdemeaned = yt - mut
        equationRange = InfoDict[i]
        r = -1
        for k in range(len(InfoDict[i])):
            factor += 1
            r += 1
            eqns = np.arange(equationRange[r][0], equationRange[r][1]+1)
            subY = ytdemeaned[eqns,:]
            subA = A[eqns, factor]
            suba0 = a0[eqns, factor]
            subFt = np.reshape(Ft[factor,:], (1,T))
            subg = np.reshape(gammas[factor,:], (1, lags))
            subfv = np.reshape(factorVariances[factor], (1,1))
            subvar = om_variances[eqns]
            subFtP = MakePrecision(subg, subvar, InitializeArVariance(subg, subfv), T)
            subA0 = np.linalg.inv(A0[factor])
            subpre = 1./subvar

            ConditionalLogLikelihood(subY, subA, suba0, subA0, subpre, subFt, subFtP)
            # eqns = np.arange(equationRange[factor][0], equationRange[factor][1]+1)
            # ytdemeaned[eqns,:]


def ML_EfficientFactorModel(yt, xt, om_variances, A, Factors, gammas, factorVariances,
                            b0, B0, InfoDict, sims=1000, burnin=100):
    dims = yt.shape
    K = dims[0]
    T = dims[1]
    nFactors = A.shape[1]
    Identity = MakeObsModelIdentity(InfoDict)
    P0 = InitializeArVariance(gammas, factorVariances)
    FactorPrecision = MakePrecision(gammas, om_variances, P0, T)
    vecy = np.reshape(yt, (T * K, 1), 'F')
    surX = SUR_Form(xt, K)
    KP = surX.shape[1]
    betaCols = surX.shape[1]
    om_precision = 1. / om_variances
    a0 = np.zeros((K, nFactors))
    A0 = InitializeAprior(Identity, 10*Identity)

    storeBeta = np.zeros((betaCols, sims - burnin))
    for s in range(sims):
        update = mldfvar_betaDraw(vecy, surX, om_precision, A, FactorPrecision,
                                  b0, B0, T)
        betas = update[0]
        Xbeta = update[1]

        LoadingFactorUpdate(yt, Xbeta, Factors, A, gammas, om_variances, factorVariances,
                            Identity, InfoDict, a0, A0)
        ytdemeaned = yt - Xbeta
        if s >= burnin:
            storeBeta[:, s - burnin] = betas[:, 0].copy()

    print(np.average(storeBeta, axis=1))


mld = gsd.MultilevelData()

sims = 1
burnin = 0
y = mld.y
x = mld.X
K = mld.K
T = mld.T
om_variances = mld.om_variances
Factors = mld.Factors
gammas = mld.gammas
factorVariances = mld.factorVariances
A = mld.A
InfoDict = mld.InfoDict

b0 = mld.b0
B0 = mld.B0

# pd.DataFrame(y).to_csv('y_data.csv')
# pd.DataFrame(x).to_csv('x_data.csv')


ML_EfficientFactorModel(y, x, om_variances, A, Factors, gammas,
                        factorVariances, b0, B0, InfoDict, sims, burnin)

# print(pd.DataFrame(Xstacked))
# print(pd.DataFrame(SUR_Form(Xstacked, 3)))
# print(MakeObsModelIdentity(InfoDict))
# print(GenerateSimulationData(InfoDict))
# print(MakeStateSpaceForm(params=p).shape)
# print(pd.DataFrame(P0))
# print(pd.DataFrame(Precision(p, v, P0, T)))
