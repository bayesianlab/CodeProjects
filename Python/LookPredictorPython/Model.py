from tkinter import Y
import pandas as pd
import numpy as np
from sklearn.linear_model import LinearRegression
from scipy.stats import t as student_t
from LookPredictorErrors import ModelError
import warnings

warnings.filterwarnings(action='error', category=RuntimeWarning)

class ModelBase:
    def __init__(self, name):
        self.yhat = None
        self.yhatf = None
        self.name = name
    
    def forecast(self, Xtrain, ytrain):
         pass 
     
    def train(self, Xtrain, ytrain):
        pass 
        
    def make_results_dataframe(self, ytrue, ypred):
        df = pd.DataFrame({'LookCnt': ypred['yhatf'], 'MAE': np.abs(ytrue['yfuture']-ypred['yhatf']),
                           'RMSE': np.square(ytrue['yfuture']-ypred['yhatf'])})
        df['Method'] = self.name
        df['Dt'] = ytrue['Dt']
        df['LookCnt'] = df['LookCnt'].astype(float)
        df['MAE'] = df['MAE'].astype(float)
        df['RMSE'] = df['RMSE'].astype(float)
        return df


class ModelSimple(ModelBase):
    def __init__(self, name=None):
        if name is None:
            super().__init__('Unnamed Model')
        else:
            super().__init__(name)

    def _stage1_regression(self, X, y):
        X['const'] = 1
        N = len(y)
        K = X.shape[1]
        self.feature_names_in = list(X.columns)
        self.model1 = LinearRegression(fit_intercept=False)
        self.model1.fit(X, y)
        self.Beta = np.reshape(self.model1.coef_, (-1, 1))
        self.yhat = self.model1.predict(X)
        X = X.astype('float64').to_numpy()
        y = y.astype('float64').to_numpy()
        self.residuals = y - self.yhat
        if N <= K:
            raise ModelError('N cannot be less than K. Sample size too small.')
        self.sigma2hat = np.matmul(self.residuals.T, self.residuals)/(N-K)
        XX = np.matmul(X.T, X)
        XXinv = np.linalg.solve(XX, np.identity(K))
        XXinvdiag = XXinv.diagonal()
        neg_diag = (XXinvdiag < 0).sum()
        if neg_diag > 0:
            raise ModelError('XXinv ill-conditioned')
        tstats = self.model1.coef_/(np.sqrt((self.sigma2hat*XXinvdiag)))
        output = [(i, j, k) for i, j, k in zip(self.feature_names_in, self.model1.coef_.flatten(),
                                               tstats.flatten())]
        self.output = pd.DataFrame(
            output, columns=['Coef_Name', 'Coef_Val', 't-stat'])
        self.output['P-value'] = 2 * \
            (1-student_t.cdf(np.abs(self.output.iloc[:, 2]), N-K, 0, 1))
        if self.output['Coef_Val'].isna().sum() > 0:
            err_string = ''.join(['Model parameters are not estimateable,',
                                  'rank of matrix is not equal to columns of X. Rank of X ',
                                  str(self.model1.rank_),
                                  ', Columns of X ',
                                  str(X.shape[1])])
            raise ModelError(err_string)

    def train(self, Xtrain,ytrain):
        self._stage1_regression(Xtrain, ytrain)

    def forecast(self, Xfuture, yfuture, name='LR'):
        if 'Dt' not in yfuture.columns:
            raise ModelError('yfuture dataframe must contain forecast dates.')
        self.yhatf = self.model1.predict(Xfuture)
        self.yhatf = pd.concat([yfuture['Dt'], pd.Series(self.yhatf)], axis=1)
        self.yhatf.columns = ['Dt', 'yhatf']

class ModelAutoregressive(ModelSimple):

    def __init__(self, ar_lags=1, name=None):
        if name is None:
            super().__init__('AR')
        else:
            super().__init__(name)
        self.simple = 0
        if ar_lags < 1:
            warnings.warn(
                'AR lag length less than 1, defaulting to simple regression.')
            self.simple = 1
            self.ar_lags = 0
        else:
            self.ar_lags = ar_lags


    def _stage2_regression(self, ar_lag_num):
        resid_lags = []
        col_names = []
        self.residuals = pd.DataFrame(self.residuals)
        for i in range(1, ar_lag_num+1):
            resid_lags.append(self.residuals.shift(periods=i))
            col_names.append('Resid_Lag_'+str(i))
        self.ResidualMatrix = pd.concat(
            resid_lags, axis=1).iloc[ar_lag_num:, :]
        self.y_eps = self.residuals.iloc[ar_lag_num:, :]
        self.ResidualMatrix.columns = col_names
        self.model2 = LinearRegression(fit_intercept=False)
        self.model2.fit(self.ResidualMatrix.astype(
            'float64').to_numpy(), self.y_eps)
        self.Theta = np.reshape(self.model2.coef_, (-1, 1))
        self.y_eps_hat = self.model2.predict(
            self.ResidualMatrix.astype('float64'))
            
        
    def train(self, Xtrain, ytrain):
        self._stage1_regression(Xtrain, ytrain)
        if self.ar_lags > 0:
            self._stage2_regression(self.ar_lags)

    def forecast(self, Xfuture, yfuture):
        if 'Dt' not in yfuture.columns:
            raise ModelError('yfuture dataframe must contain forecast dates.')
        if self.ar_lags > 0:
            Xf = Xfuture.copy(deep=True)
            for i in self.feature_names_in:
                if i not in Xf.columns:
                    Xf[i] = 0
            Xf = Xf[self.feature_names_in]
            Xf = Xf.to_numpy()
            Rt = np.reshape(np.atleast_2d(
                self.ResidualMatrix.iloc[-1, :].to_numpy()), (-1, 1))
            yf = yfuture['yfuture'].to_numpy()
            self.yhatf = []
            p = 0
            while p < len(yfuture):
                mu = np.matmul(Xf[p, :], self.Beta).tolist()[0]
                ehat = np.matmul(Rt.T, self.Theta)
                yt1hat = (mu + ehat).squeeze()
                Rt = np.roll(Rt, 1)
                Rt[0, 0] = (yt1hat-yf[p]).flatten().tolist()[0]
                self.yhatf.append(yt1hat)
                p += 1
            self.yhatf = pd.concat([yfuture['Dt'], pd.Series(self.yhatf)], axis=1)
            self.yhatf.columns = ['Dt', 'yhatf']
        else:
            super().forecast(Xfuture, yfuture)

