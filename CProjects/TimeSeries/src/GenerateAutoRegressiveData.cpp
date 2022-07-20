#include "GenerateAutoRegressiveData.hpp"
GenerateAutoRegressiveData::GenerateAutoRegressiveData(int time,
                                                       const MatrixXd &params) {
  yt.setZero(params.rows(), time);
  for (int k = 0; k < params.rows(); ++k) {
    lags = params.cols();
    H = ReturnH(params.row(k), time);
    epsilon = normrnd(0, 1, time, 1);
    yt.row(k) = H.householderQr().solve(epsilon).transpose();
    G0 = 10 * MatrixXd::Identity(lags, lags);
    g0 = MatrixXd::Zero(1, lags);
    sigma2 << 1.;
  }
}

GenerateAutoRegressiveData::GenerateAutoRegressiveData(
    int time, const MatrixXd &arparams, const double &betaparams) {
  lags = arparams.cols();
  yt.setZero(time);
  RowVectorXd epst = yt;
  Xt.setZero(time, 2);
  Xt << MatrixXd::Ones(time, 1), normrnd(0, 1, time, 1);
  VectorXd beta = betaparams * VectorXd::Ones(Xt.cols());
  VectorXd mup = Xt.bottomRows(lags) * beta;
  MatrixXd D0 = setInitialCovar(arparams, 1);
  epst.leftCols(lags) = mvnrnd(RowVectorXd::Zero(lags), D0, 1);
  for (int t = lags; t < time; ++t) {
    double mut = Xt.row(t) * beta;
    double e = (epst.segment(t - lags, lags) * arparams.transpose()).value();
    yt(t) = mut + e + normrnd(0, 1);
    epst(t) = yt(t) - mut;
  }

  plotter("plot.p", yt);
}
