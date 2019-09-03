import numpy as np
import pandas as pd
import statsmodels.api as sm
from scipy import stats
import collections
import operator



ssize = 60
dim = 5
sims = 500
B = np.array([0,0,0,1,1.2])

X = np.random.normal(0, 1, [ssize, dim])
y = np.matmul(X, B).reshape([60,1]) + np.random.normal(0, 2.5, [ssize, 1])
Xpy = np.matmul(X.T,y)
XpX = np.matrix(X.transpose().dot(X))
XpXinv = np.matrix(np.linalg.inv(XpX))
betaLS = np.matmul(XpXinv, Xpy)
print('betals\n', betaLS.T)

resid = y - np.matmul(X,betaLS)
resid2 = np.matmul(resid.T, resid)
sigmahat = np.multiply(resid2*(1/(ssize-dim)),XpXinv)
ses = np.diag(sigmahat)
seBetaLS = np.diag(np.matrix(ses))
print('ses\n', ses)

m = sm.OLS(y, X)
fit = m.fit()

params = np.matrix(fit.params).reshape(dim,1)

print('t-statistics\n', np.matrix(np.divide(betaLS, seBetaLS)).T)
print()


cc= 10
sigsqd = np.ones([sims, 1])
ifGamma0 = np.ones([1, dim])
ifGamma1 = cc * np.ones([1, dim])


I = np.identity(dim)


p = .5
onesVect = np.ones([1, dim])
tauInit = np.ones([1,dim])

betaSample = np.zeros([sims, dim])
gammasSample = np.zeros([sims, dim])

betaSample[0, ] = params.T
gammasSample[0, ] = np.ones([1,dim])

tau = .33
tausqd = tau**2
cctautau = 100*tausqd
ctau = 10*tau
gammaUpdate = np.zeros([1, dim])

for i in range(1, sims):
    sigsqdi = sigsqd[i - 1]

    for j in range(gammasSample[i-1, ].size):
        if gammasSample[i-1, j] == 1:
            gammaUpdate[0, j] = ctau
        else:
            gammaUpdate[0, j] = tau

    D = np.diag(gammaUpdate[0])
    D2 = np.matmul(D, D)
    D2inv = np.linalg.inv(D2)

    A = np.multiply(sigsqdi, np.linalg.inv(XpX + sigsqdi*D2inv))
    AXpX = np.matmul(A, XpX)
    AXpXparams = np.divide(np.matmul(AXpX, params).A1, sigsqdi)
    mu = AXpXparams

    betaSample[i, ] = np.random.multivariate_normal(mu, np.divide(A, sigsqdi))
    betai = betaSample[i, ]
    residual = y - np.matmul(X, betai).reshape(ssize, 1)
    residualSqd = np.asscalar(np.matmul(residual.T, residual))
    sigsqd[i] = np.random.gamma(ssize/2.0, 2.0/residualSqd, 1)

    for b in range(betai.size):
        pa = stats.norm.pdf(betai[b], 0, cctautau)*p
        pb = stats.norm.pdf(betai[b], 0, tausqd)*p
        bernProb = pa / (pa + pb)
        gammasSample[i, b] = stats.bernoulli.rvs(bernProb, 1)-1

count = collections.Counter()


items = np.matmul(gammasSample, np.array([1,10, 100, 1000, 10000]))
for i in items:
    count[i] += 1
print('percents')

sorted_count = sorted(count.items(), key=operator.itemgetter(1))
for i in reversed(sorted_count):
    print(int(i[0]), i[1]/sims)










