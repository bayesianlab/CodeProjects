#pragma once
#ifndef MA_H
#define MA_H
#include <Eigen/Dense>
#include <Eigen/Sparse>
#include <eigen3/unsupported/Eigen/KroneckerProduct>
#include <iostream>
#include <stdexcept>

#include "BayesianUpdates.hpp"
#include "Distributions.hpp"
#include "Plotter.hpp"
#include "TimeSeriesTools.hpp"
#include "ARMA.hpp"

using namespace Eigen;
using namespace std;
class MovingAverageModel : ARMA {
 public:
  VectorXd yt;
  VectorXd epsilons;
  RowVectorXd theta0;
  MatrixXd Theta0;
  MatrixXd Theta0Inv;
  MatrixXd storeThetas;
  VectorXd storeSigma2;
  int v0;
  int V0;
  double sigma2;

  RowVectorXd thetas;
  int modelSet = -1;

  RowVectorXd updateMA(const VectorXd Y, VectorXd &ep,
                       const RowVectorXd &thetas, const RowVectorXd &theta0,
                       const MatrixXd &Theta0, double sigma2) {
    MAResiduals(Y, ep, thetas);
    int T = Y.size();
    int lags = thetas.size();
    MatrixXd Etm1;
    MatrixXd Sinv;
    MatrixXd S;
    VectorXd mu;
    int notvalid = 1;
    RowVectorXd proposal(lags);
    VectorXd eigr(lags);
    VectorXd eigi(lags);
    VectorXd epcopy = ep;
    VectorXd e(lags);
    int c = 0;
    int count = 0;
    int MAX_TRIES = 25;
    while (notvalid == 1) {
      Etm1 = lag(ep, thetas.size(), 1);
      Sinv = ((Etm1.transpose() * Etm1) / sigma2) + Theta0Inv;
      S = Sinv.llt().solve(MatrixXd::Identity(Sinv.rows(), Sinv.rows()));
      mu = S * (((Etm1.transpose() * Y.bottomRows(T - lags)) / sigma2) +
                Theta0Inv * theta0.transpose());
      proposal = mu.transpose() +
                 (S.llt().matrixL() * normrnd(0, 1, mu.rows(), 1)).transpose();
      MAResiduals(Y, epcopy, proposal);
      MatrixXd Test = makeStateSpace(proposal);
      eigr = Test.eigenvalues().real();
      eigi = Test.eigenvalues().imag();
      e = eigr.array() * eigr.array() + eigi.array() * eigi.array();
      e = e.array().sqrt();
      c = 0;
      for (int i = 0; i < lags; ++i) {
        if (e(i) < 1) {
          ++c;
        }
      }
      if (c == lags) {
        notvalid = 0;
      }
      if (count == MAX_TRIES) {
        return thetas;
      }
      ++count;
    }

    double LLn = 0;
    double LLd = 0;
    for (int it = 0; it < ep.size(); ++it) {
      RowVectorXd x(1);
      RowVectorXd y(1);
      x << ep(it);
      y << epcopy(it);
      RowVectorXd m = RowVectorXd::Zero(1);
      MatrixXd S(1, 1);
      S << 1;
      LLn += logmvnpdf(x, m, S);
      LLd += logmvnpdf(y, m, S);
    }
    double priord = logmvnpdf(thetas, theta0, Theta0);
    double priorn = logmvnpdf(proposal, theta0, Theta0);
    double propn = logmvnpdf(thetas, theta0, Theta0);
    double propd = logmvnpdf(proposal, theta0, Theta0);
    double lalpha = min(0.0, LLn + priorn + propn - LLd - priord - propd);
    if (log(unifrnd(0, 1)) < lalpha) {
      MAResiduals(Y, ep, proposal);
      return proposal;
    } else {
      return thetas;
    }
  }

  void genData(size_t lags, const RowVectorXd &_thetas, size_t T) {
    modelSet = 1;
    std::vector<VectorXd> data = GenMAData(lags, _thetas, T);
    yt = data[0];
    thetas = _thetas;
    epsilons.resize(yt.size());
    epsilons.setZero();
    theta0 = RowVectorXd::Zero(thetas.size());
    Theta0 = 10 * MatrixXd::Identity(thetas.size(), thetas.size());
    Theta0Inv = .01 * MatrixXd::Identity(thetas.size(), thetas.size());
    v0 = 6;
    V0 = 10;
    sigma2 = 1.;
  }

  void setModel(const MatrixXd &_yt, const RowVectorXd &_thetas,
                const RowVectorXd &_theta0, const MatrixXd &_Theta0, int _v0,
                int _V0) {
    modelSet = 1;
    yt = _yt;
    epsilons.resize(yt.size());
    epsilons.setZero();
    thetas = _thetas;
    theta0 = _theta0;
    Theta0 = _Theta0;
    Theta0Inv =
        Theta0.llt().solve(MatrixXd::Identity(thetas.size(), thetas.size()));
    v0 = _v0;
    V0 = _V0;
    sigma2 = 1.;
  }

  void runModel(size_t sims, size_t burnin) {
    if (modelSet == -1) {
      cout << "Model Not Set" << endl;
      return;
    }
    storeThetas.resize(sims - burnin, thetas.size());
    storeSigma2.resize(sims - burnin);
    for (size_t i = 0; i < sims; ++i) {
      cout << "Sim " << i << endl;
      thetas = updateMA(yt, epsilons, thetas, theta0, Theta0, sigma2);
      sigma2 = updateSigma2(epsilons.transpose(), v0, V0).value();
      if (i > burnin) {
        storeThetas.row(i - burnin) = thetas;
        storeSigma2(i - burnin) = sigma2;
      }
    }
  }
};

#endif 