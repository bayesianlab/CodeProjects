import time
import cProfile
import re
import numpy as np
import sys
import math
import pandas as pd
from scipy import special
from scipy import stats
from scipy import sparse
from scipy.optimize import minimize
from matplotlib import pyplot as plt


class MultilevelData:
    def __init__(self, T=100, K=9, betas=[1, 1, 1],
                 InfoDict={"L1": [(0, 8)], "L2": [(0, 5), (6, 8)]},
                 gammas=np.array([.2, .2]), factorVariances=np.array([1., 1., 1.]),
                 A=np.ones((9, 3))):
        # np.random.seed(5)
        self.T = T
        self.K = K
        self.InfoDict = InfoDict
        predictors = len(betas) - 1
        self.X = np.hstack((np.ones((self.K * self.T, 1)),
                            np.random.normal(0, 1, (self.T * self.K, predictors))))
        self.Betas = np.tile(betas, (self.K,))
        self.surX = SUR_Form(self.X, self.K)
        self.Xbeta = np.reshape(self.surX @ self.Betas, (self.K, self.T), 'F')
        self.Identity = MakeObsModelIdentity(self.InfoDict)
        self.nFactors = self.Identity.shape[1]
        if self.Identity.shape[0] != self.K:
            raise ObservationModelError
        self.gammas = np.tile(gammas, (self.nFactors, 1))
        self.factorVariances = factorVariances
        if self.factorVariances.shape[0] != self.nFactors:
            raise nFactorError
        self.FactorPrecision = MakePrecision(self.gammas, self.factorVariances,
                                             InitializeArVariance(self.gammas, self.factorVariances),
                                             self.T)
        self.L = np.linalg.cholesky(self.FactorPrecision)
        self.Linv = np.linalg.solve(self.L, np.eye(self.T * self.nFactors))
        self.Factors = self.Linv.T @ np.random.normal(0, 1, self.T * self.nFactors)
        self.Factors = np.reshape(self.Factors, (self.nFactors, self.T), 'F')
        self.A = A * self.Identity
        self.AF = self.A @ self.Factors
        self.om_variances = np.ones((self.K,))
        self.b0 = np.zeros((self.Betas.shape[0],))
        self.B0 = 100. * np.eye(self.Betas.shape[0])
        self.y = self.Xbeta + self.AF + np.random.normal(0, 1, (self.K, self.T))


class Error(Exception):
    pass


class ObservationModelError(Error):
    def __init__(self, err_message="Incorrect dimensions of observation model or number of equations K."):
        self.err_message = err_message
        super().__init__(self.err_message)


class nFactorError(Error):
    def __init__(self, err_message="Incorrect number of Factors."):
        self.err_message = err_message
        super().__init__(self.err_message)


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
    xbt = np.reshape(surX @ bupdate, (K, T), 'F')
    return (bupdate, xbt, b, B)


def zeroFactorLevel(Identity, level):
    I = Identity.copy()
    I[:, level] = 0
    return I


def InitializeAprior(Identity, A0Priors):
    ishape = Identity.shape
    nFactors = ishape[1]
    K = ishape[0]
    A0mat = []
    for c in range(nFactors):
        t = np.nonzero(A0Priors[:, c])
        A0mat.append(np.diag(A0Priors[t, c][0], 0))
    return A0mat


def ConditionalLogLikelihood(ObsModelGuess, ytdemeaned, ObsPriorMean, ObsPriorPrecision,
                             obsPrecision, factors, factorPrecision):
    dimfactors = factors.shape
    nFactors = dimfactors[0]
    T = dimfactors[1]
    K = len(obsPrecision)
    nFactorsT = nFactors * T
    nFactorsK = nFactors * K
    OmegaInverse = np.diag(obsPrecision, 0)
    FtOF = np.kron(OmegaInverse, factors @ factors.T)
    Avariance = np.linalg.solve(ObsPriorPrecision @ ObsPriorMean.T + FtOF, np.eye(nFactorsK))
    Term = ((factors @ ytdemeaned.T) * obsPrecision.T)
    Amean = np.ravel(Avariance @ (ObsPriorPrecision @ ObsPriorMean.T + Term).T, 'F')
    pdfA = logmvnpdf(np.reshape(ObsModelGuess.T, (1, nFactorsK)), np.reshape(Amean, (1, nFactorsK)),
                     Avariance)
    AOI = ObsModelGuess.T @ OmegaInverse
    Fvariance = np.linalg.solve(factorPrecision + np.kron(np.eye(T), AOI @ ObsModelGuess),
                                np.eye(nFactorsT))
    Fmean = Fvariance @ (np.kron(np.eye(T), AOI) @ np.reshape(ytdemeaned, (T * K, 1), 'F'))
    pdfF = logmvnpdf(factors, np.ravel(Fmean, 'F'), Fvariance)
    return pdfA - pdfF


def handle_ConditionalLogLikelihood(params):
    ytdemeaned = params[0]
    ObsPriorMean = params[1]
    ObsPriorPrecision = params[2]
    obsPrecision = params[3]
    factors = params[4]
    factorPrecision = params[5]
    return lambda x0: -1. * ConditionalLogLikelihood(x0, ytdemeaned, ObsPriorMean, ObsPriorPrecision,
                                                     obsPrecision, factors, factorPrecision)


def logmvtpdf(x, mu=0, scale=1, nu=10):
    p = x.shape[1]
    logdetscale = sum(np.log(np.diag(np.linalg.cholesky(scale))))
    nuphalf = .5 * (nu + p)
    phalf = .5 * p
    demean = x - mu
    C = special.gammaln(nuphalf) - special.gammaln(nu * .5) - phalf * np.log(nu * np.pi) - \
        .5 * logdetscale
    inner = np.trace((demean.T @ demean) @ np.linalg.solve(scale, np.eye(p))) / nu
    return C - nuphalf * np.log(1 + inner)


def logmvnpdf(x, mu, sigma):
    p = x.shape[1]
    const = -.5 * p * np.log(2 * np.pi)
    sigmainv = np.linalg.solve(sigma, np.eye(p))
    xc = x - mu
    xsigmainvx = np.sum((xc@sigmainv)*xc, 1)
    inner = -0.5 * xsigmainvx
    term1 = const - 0.5 * logdet(sigma)
    return inner + term1


def handle_logmvnpdf(params):
    mu = params[0]
    sigma = params[1]
    return lambda x0: logmvnpdf(x0, mu, sigma)


def logdet(scale):
    U = np.linalg.cholesky(scale)
    return 2 * np.sum(np.log(np.diag(U)))


def handle_lmvt(params):
    mu = params[0]
    scale = params[1]
    nu = params[2]
    return lambda x0: logmvtpdf(x0, mu, scale, nu)


def updateVariance(resids, v0, r0):
    T = resids.shape[1]
    parama = 0.5*(T + v0)
    paramb = 0.5*(np.sum(resids*resids, 1) + r0)
    return 1./np.random.gamma(parama, 1./paramb)


def updateFactor(vecresids, obsModel, StatePrecision, precision):
    neqns = obsModel.shape[0]
    T = int(len(vecresids) / neqns)
    IT = np.eye(T)
    FullPrecision = np.diag(precision, 0)
    ApO = obsModel.T @ FullPrecision
    P = StatePrecision + np.kron(IT, ApO @ obsModel)
    prows = P.shape[0]
    LP = np.linalg.cholesky(P)
    LPI = np.linalg.solve(LP, np.eye(prows))
    musum = ApO @ np.reshape(vecresids, (neqns, T))
    mu = np.squeeze((LPI.T @ LPI) @ np.ravel(musum, 'F'))
    u = np.random.normal(0, 1, (prows, 1))
    x = np.squeeze(LPI.T @ u)
    return mu + x


def lag(xt, lags):
    dims = xt.shape
    K = dims[0]
    T = dims[1]
    y = np.zeros((K*lags, T-lags))
    inds = np.arange(1,K+1)
    c = 0
    for p in range(lags):
        rows = inds + (p-1)*K
        y[rows, :] = xt[:, p:T-lags+c]
        c += 1
    return y


def updateAR(cur, yt, sigma2, g0, G0):
    K = yt.shape[0]
    T = yt.shape[1]
    lags = cur.shape[1]
    Xt = lag(yt, 2)
    ytstar = yt[:, lags:T]
    Ip = np.eye(lags)
    G1 = np.linalg.solve( (np.linalg.solve(G0,Ip) + (Xt@Xt.T)/sigma2 ), Ip)
    G1lower = np.linalg.cholesky(G1)
    g1 = G1@( np.linalg.solve(G0, g0.T) + (Xt@ytstar.T)/sigma2 )
    P0 = InitializeArVariance(cur, sigma2)
    notvalid = 1
    while notvalid == 1:
        proposal = (g1 + G1lower @ np.random.normal(0,1, (lags,1))).T
        P1 = InitializeArVariance(proposal, sigma2)
        if np.linalg.cond(P1) < (1. / sys.float_info.epsilon):
            notvalid = 0
    Xp = np.zeros((lags, lags))
    for i in range(1,lags):
        Xp[np.arange(lags-i, lags), i] = np.ravel(yt[:,np.arange(0,i)], 'F')
    Scur = np.diag(np.squeeze(np.tile(sigma2, T)), 0)
    Snew = Scur
    Scur[0:lags, 0:lags] = P0
    Snew[0:lags, 0:lags] = P1
    Xss = np.hstack((Xp, Xt))
    Num = logmvnpdf((yt - proposal @ Xss), np.zeros((1,T)), Snew) + \
          logmvnpdf(proposal, g0, G0) + logmvnpdf(cur, g1.T, G1)
    Den = logmvnpdf((yt - cur @ Xss), np.zeros((1, T)), Scur) + \
          logmvnpdf(cur, g0, G0) + logmvnpdf(proposal, g1.T, G1)
    lalpha = min(0, Num-Den)
    if np.log(np.random.uniform(0,1)) < Num - Den:
        return proposal
    else:
        return cur


def LoadingFactorUpdate(yt, Xbeta, Ft, A, gammas, om_variances, factorVariances,
                        Identity, InfoDict, a0, A0, tau):
    dimyt = yt.shape
    T = dimyt[1]
    levels = InfoDict.keys()
    index = -1
    factor = -1
    lags = gammas.shape[1]
    options = {'gtol': 1e-2, 'maxiter': 20, 'disp': False}
    for i in levels:
        index += 1
        equationRange = InfoDict[i]
        r = -1
        for k in range(len(InfoDict[i])):
            factor += 1
            r += 1
            AF = (A * zeroFactorLevel(Identity, factor)) @ Ft
            mut = Xbeta + AF
            ytdemeaned = yt - mut
            eqns = np.arange(equationRange[r][0], equationRange[r][1] + 1)
            subY = ytdemeaned[eqns, :]
            subA = np.reshape(A[eqns, factor], (len(eqns), 1))
            suba0 = a0[eqns, factor]
            subFt = np.reshape(Ft[factor, :], (1, T))
            subg = np.reshape(gammas[factor, :], (1, lags))
            subfv = np.reshape(factorVariances[factor], (1, 1))
            subvar = om_variances[eqns]
            subFtP = MakePrecision(subg, subvar, InitializeArVariance(subg, subfv), T)
            subA0 = np.linalg.inv(A0[factor])
            subpre = 1. / subvar
            ll_params = (subY, suba0, subA0, subpre, subFt, subFtP)
            hloglikelihood = handle_ConditionalLogLikelihood(ll_params)
            update = minimize(hloglikelihood, subA, method='BFGS', options=options)
            Amean = update.x
            Acovar = update.hess_inv
            if np.linalg.cond(Acovar) > 1. / sys.float_info.epsilon:
                Acovar = np.eye(len(eqns))
            else:
                Achol = np.linalg.cholesky(Acovar)
                w1 = np.sqrt(np.random.chisquare(tau) / tau)
                proposal = np.reshape(Amean, (len(eqns), 1)) + (Achol @ np.random.normal(0, 1, (len(eqns), 1))) / w1
                prop_params = (np.reshape(Amean, (1, len(eqns))), Acovar, tau)
                hproposal = handle_lmvt(prop_params)
                hloglikelihood = handle_ConditionalLogLikelihood(ll_params)
                Num = hproposal(subA.T) - hloglikelihood(proposal)
                Den = hproposal(proposal.T) - hloglikelihood(subA)

                lalpha = np.min(Num - Den, 0)
                if np.log(np.random.uniform(0, 1)) < lalpha:
                    A[eqns, factor] = np.squeeze(np.vstack((1, proposal[1:])))
            Factors[factor,:] = updateFactor(np.ravel(subY,'F'), subA, subFtP, subpre)


def ML_EfficientFactorModel(yt, xt, om_variances, A, Factors, gammas, factorVariances,
                            b0, B0, v0, r0, g0, G0, InfoDict, sims=1000, burnin=100):
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
    a0 = np.ones((K, nFactors))
    A0 = InitializeAprior(Identity, 10 * Identity)
    tau = 15
    storeBeta = np.zeros((betaCols, sims - burnin))
    storeVariances = np.zeros((K, sims - burnin))

    Xbeta = np.reshape(surX @ np.ones((KP, 1)), (K, T), 'F')

    for s in range(sims):
        # update = mldfvar_betaDraw(vecy, surX, om_precision, A, FactorPrecision,
        #                           b0, B0, T)
        # betas = update[0]
        # Xbeta = update[1]
        # LoadingFactorUpdate(yt, Xbeta, Factors, A, gammas, om_variances, factorVariances,
        #                     Identity, InfoDict, a0, A0, tau)


        resids = yt - Xbeta - A@Factors
        om_variances = updateVariance(resids, v0, r0)
        om_precision = 1./om_variances

        updateAR(np.reshape(gammas[1,:], (1,2)), np.reshape(Factors[1,:], (1,T)),
                       np.reshape(factorVariances[0], (1,1)), g0, G0)
        pd.DataFrame(Factors[1,:])
        if s >= burnin:
            # storeBeta[:, s - burnin] = betas[:, 0].copy()
            storeVariances[:, s-burnin] = om_variances


mld = MultilevelData()

sims = 1
burnin = 0
y = mld.y
x = mld.X
K = mld.K
T = mld.T
om_variances = mld.om_variances
Factors = mld.Factors
gammas = .1*mld.gammas
factorVariances = mld.factorVariances
A =  np.ones((mld.K, mld.nFactors)) * mld.Identity
InfoDict = mld.InfoDict

b0 = mld.b0
B0 = mld.B0
v0 = 6
r0 = 12
g0 = np.zeros((1, 2))
G0 = 10*np.eye(2)
pd.DataFrame(y).to_csv('y_data.csv')
pd.DataFrame(x).to_csv('x_data.csv')
pd.DataFrame(Factors).to_csv('f_data.csv')


ML_EfficientFactorModel(y, x, om_variances, A, Factors, gammas,
                        factorVariances, b0, B0, v0, r0, g0, G0, InfoDict, sims, burnin)
print(sys.version_info)
# print(pd.DataFrame(Xstacked))
# print(pd.DataFrame(SUR_Form(Xstacked, 3)))
# print(MakeObsModelIdentity(InfoDict))
# print(GenerateSimulationData(InfoDict))
# print(MakeStateSpaceForm(params=p).shape)
# print(pd.DataFrame(P0))
# print(pd.DataFrame(Precision(p, v, P0, T)))
