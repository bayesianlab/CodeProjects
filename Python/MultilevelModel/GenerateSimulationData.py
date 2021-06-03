import numpy as np
import regression as reg

class MultilevelData:
    def __init__(self, T=100, K=9, betas=[1, 1, 1],
                 InfoDict={"L1": [(0, 8)], "L2": [(0, 5), (6, 8)]},
                 gammas=np.array([.2, .2]), factorVariances=np.array([1., 1., 1.]),
                 A=np.ones((9, 3))):
        np.random.seed(5)
        self.T = T
        self.K = K
        self.InfoDict = InfoDict
        predictors = len(betas) - 1
        self.X = np.hstack((np.ones((self.K * self.T, 1)),
                            np.random.normal(0, 1, (self.T * self.K, predictors))))
        self.Betas = np.tile(betas, (self.K,))
        self.surX = reg.SUR_Form(self.X, self.K)
        self.Xbeta = np.reshape(self.surX @ self.Betas, (self.K, self.T), 'F')
        self.Identity = reg.MakeObsModelIdentity(self.InfoDict)
        self.nFactors = self.Identity.shape[1]
        if self.Identity.shape[0] != self.K:
            raise ObservationModelError
        self.gammas = np.tile(gammas, (self.nFactors, 1))
        self.factorVariances = factorVariances
        if self.factorVariances.shape[0] != self.nFactors:
            raise nFactorError
        self.FactorPrecision = reg.MakePrecision(self.gammas, self.factorVariances,
                                                 reg.InitializeArVariance(self.gammas, self.factorVariances),
                                                 self.T)
        self.L = np.linalg.cholesky(self.FactorPrecision)
        self.Linv = np.linalg.solve(self.L, np.eye(self.T * self.nFactors))
        self.Factors = self.Linv.T @ np.random.normal(0, 1, self.T * self.nFactors)
        self.Factors = np.reshape(self.Factors, (self.nFactors, self.T), 'F')
        self.A = A * self.Identity
        self.AF = self.A @ self.Factors
        self.om_variances = np.ones((self.K,))
        self.b0 = np.zeros((self.Betas.shape[0],))
        self.B0 = 100.*np.eye(self.Betas.shape[0])
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
