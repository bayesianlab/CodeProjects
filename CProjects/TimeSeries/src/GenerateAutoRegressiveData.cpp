#include "GenerateAutoRegressiveData.hpp"
GenerateAutoRegressiveData::GenerateAutoRegressiveData(int time, const MatrixXd &params)
{
    yt.setZero(params.rows(), time);
    for (int k = 0; k < params.rows(); ++k)
    {
        lags = params.cols();
        H = ReturnH(params.row(k), time);
        epsilon = normrnd(0, 1, time, 1);
        yt.row(k) = H.householderQr().solve(epsilon).transpose();
        G0 = 10 * MatrixXd::Identity(lags, lags);
        g0 = MatrixXd::Zero(1, lags);
        sigma2 << 1.;
    }
}

GenerateAutoRegressiveData::GenerateAutoRegressiveData(int time, const MatrixXd &arparams,
                                                       const double &betaparams)
{
    lags = arparams.cols();
    int K = arparams.rows();
    yt.setZero(K, time);
    Xt.setZero(K*time, 2);
    Xt << MatrixXd::Ones(K*time, 1), normrnd(0, 1, K*time, 1);
    std::vector<MatrixXd> Xtcontainer = groupByTime(Xt, time, K); 
    VectorXd beta = betaparams*VectorXd::Ones(Xt.cols());
    MatrixXd Xbeta;
    MatrixXd D0;
    MatrixXd g(lags, 1);
    VectorXd epsilon(lags);
    VectorXd temp(lags - 1);
    for (int k = 0; k < K; ++k)
    {
        Xt = Xtcontainer[k]; 
        Xbeta = Xt * beta;
        D0 = setInitialCovar(arparams.row(k), 1);
        D0.llt().matrixL() * normrnd(0, 1, lags, 1);
        yt.row(k).leftCols(lags) = (Xbeta.topRows(lags) + D0.llt().matrixL() * normrnd(0, 1, lags, 1)).transpose();
        epsilon = yt.row(k).leftCols(lags).transpose() - Xbeta.topRows(lags); 
        for (int t = lags; t < time; ++t)
        {
            yt(k,t) = Xbeta(t) +
                    (arparams.row(k) * epsilon).value() +
                    normrnd(0, 1);
            temp = epsilon.tail(lags-1);
            epsilon.tail(1) << yt(k, t) - Xbeta(t); 
            epsilon.head(lags-1) = temp; 
        }
    }
}
