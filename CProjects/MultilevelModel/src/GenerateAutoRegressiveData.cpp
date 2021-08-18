#include "GenerateAutoRegressiveData.hpp"
GenerateAutoRegressiveData::GenerateAutoRegressiveData(int time, const MatrixXd &params)
{
    lags = params.cols();
    H = ReturnH(params, time);
    epsilon = normrnd(0, 1, time, 1);
    yt = H.householderQr().solve(epsilon).transpose();
    G0 = 10 * MatrixXd::Identity(lags, lags);
    g0 = MatrixXd::Zero(1, lags);
    ythat = yt.rightCols(time - lags);
    Xthat = lag(yt, lags);
    sigma2 = 1.;
}
