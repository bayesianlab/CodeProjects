#pragma once
#ifndef armodel_h
#define armodel_h
#include <Eigen/Dense>
#include <Eigen/Sparse>
#include <eigen3/unsupported/Eigen/KroneckerProduct>
#include <iostream>
#include <stdexcept>

#include "ARMA.hpp"
#include "BayesianUpdates.hpp"
#include "Distributions.hpp"
#include "Plotter.hpp"
#include "TimeSeriesTools.hpp"

using namespace Eigen;
using namespace std;
class AutoregressiveModel : public BayesBetaUpdater, public ARMA {
 public:
  VectorXd yt;
  MatrixXd Xt;
  RowVectorXd b0;
  MatrixXd B0;
  RowVectorXd g0;
  MatrixXd G0;
  MatrixXd arparams;
  VectorXd sigma2;
  double r0;
  double R0;
  MatrixXd storeBeta;
  MatrixXd storeArParams;
  VectorXd storeSigma2;
  int Sims;
  int burnin;
  int estMean;
  VectorXd residuals;

  void setModel(const VectorXd &_yt, const MatrixXd &_Xt, const MatrixXd &_g0,
                const MatrixXd &_G0, const double &_r0, const double &_R0,
                const RowVectorXd &_b0, const MatrixXd &_B0) {
    yt = _yt;
    Xt = _Xt;
    b0 = _b0;
    B0 = _B0;
    r0 = _r0;
    R0 = _R0;
    g0 = _g0;
    G0 = _G0;
  }

  void runAr(const int &_Sims, const int _burnin) {
    Sims = _Sims;
    burnin = _burnin;
    int T = yt.rows();
    int lags = g0.cols();
    RowVectorXd arparams = RowVectorXd::Zero(lags);
    MatrixXd Xthat = lagPolynomial(Xt, arparams, lags, 1);
    VectorXd ythat = lagPolynomial(yt, arparams, lags, 1);
    VectorXd epsilons(T);
    VectorXd residuals(T);
    MatrixXd D0(lags, lags);
    MatrixXd Ilags = MatrixXd::Identity(lags, lags);
    storeBeta.resize(Sims - burnin, Xt.cols());
    storeArParams.resize(Sims - burnin, lags);
    storeSigma2.resize(Sims - burnin);
    double sigma2 = 1;
    RowVectorXd bnew(b0.size());
    for (int i = 0; i < Sims; ++i) {
      cout << "Sim " << i << endl;
      ythat = lagPolynomial(yt, arparams, lags, 1);
      Xthat = lagPolynomial(Xt, arparams, lags, 1);
      bnew = updateBeta(ythat, Xthat, sigma2, b0, B0);
      epsilons = yt - Xt * bnew.transpose();
      arparams =
          updateArParameters(epsilons.transpose(), arparams, sigma2, g0, G0);
      D0 = setInitialCovar(arparams, sigma2);
      D0 = D0.ldlt().solve(Ilags);
      D0 = D0.llt().matrixL();
      residuals.topRows(lags) =
          (epsilons.transpose().leftCols(lags) * D0).transpose();
      residuals.bottomRows(T - lags) = ythat - Xthat * bnew.transpose();
      sigma2 = updateSigma2(residuals.transpose(), r0, R0).value();
      if (i >= burnin) {
        storeBeta.row(i - burnin) = bnew.transpose();
        storeArParams.row(i - burnin) = arparams;
        storeSigma2(i - burnin) = sigma2;
      }
    }
  }

  void bayesFit() {
    int lags = storeArParams.cols();
    int T = yt.rows();
    int StationarySims = Sims - burnin;
    MatrixXd Ilags = MatrixXd::Identity(lags, lags);
    MatrixXd ys(StationarySims, T);
    MatrixXd eps_t(StationarySims, T);
    RowVectorXd residuals(T);
    ys.setZero();
    eps_t.setZero();
    residuals.setZero();
    for (int i = 0; i < StationarySims; ++i) {
      RowVectorXd b = storeBeta.row(i);
      RowVectorXd g = storeArParams.row(i);
      double sigma2 = storeSigma2(i);
      for (int p = 0; p < T; ++p) {
        residuals(p) = yt(p) - Xt.row(p) * b.transpose();
      }
      for (int p = 0; p < lags; ++p) {
        eps_t(i, p) = (residuals(p) * g.transpose()).value();
        ys(i, p) = Xt.row(p) * b.transpose() + eps_t(i, p);
      }
      for (int t = lags; t < T; ++t) {
        eps_t(i, t) =
            (residuals.segment(t - lags, lags) * g.transpose()).value();
        ys(i, t) = Xt.row(t) * b.transpose() + eps_t(i, t);
      }
    }
    VectorXd ysmean = ys.colwise().mean(); 
    residuals = yt - ysmean; 
    plotter("yt", yt, ysmean); 
  }
};
#endif