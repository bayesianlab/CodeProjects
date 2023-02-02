#include "GenerateAutoRegressiveData.hpp"


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
  yt.leftCols(lags) = epst.leftCols(lags) + mup.transpose();
  for (int t = lags; t < time; ++t) {
    double mut = Xt.row(t) * beta;
    double e = (epst.segment(t - lags, lags) * arparams.transpose()).value();
    yt(t) = mut + e + normrnd(0, 1);
    epst(t) = yt(t) - mut;
  }
}

GenerateAutoRegressiveData::GenerateAutoRegressiveData(
    int time, const MatrixXd &arparams) {
  lags = arparams.cols();
  yt.setZero(time);
  RowVectorXd epst = yt;
  Xt.setZero(time, 1);
  Xt << MatrixXd::Ones(time, 1);
  MatrixXd D0 = setInitialCovar(arparams, 1);
  epst.leftCols(lags) = mvnrnd(RowVectorXd::Zero(lags), D0, 1);
  yt.leftCols(lags) = epst.leftCols(lags) + Xt.bottomRows(lags).transpose();
  for (int t = lags; t < time; ++t) {
    double mut = Xt(t,0);
    double e = (epst.segment(t - lags, lags) * arparams.transpose()).value();
    yt(t) = mut + e + normrnd(0, 1);
    epst(t) = yt(t) - mut;
  }
}
