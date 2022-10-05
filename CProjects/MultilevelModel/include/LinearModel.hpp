#pragma once
#ifndef LM_H
#define LM_H

#include <Eigen/Dense>
#include <iostream>
#include <stdexcept>

#include "Distributions.hpp"
#include "BayesianUpdates.hpp"
using namespace Eigen;
using namespace std;

class GenerateRegressionData {
 public:
  MatrixXd yt;
  MatrixXd Xt;
  GenerateRegressionData(int N, const VectorXd &beta) {
    int K = beta.size();
    MatrixXd G(N, K); 
    G << VectorXd::Ones(N), normrnd(0, 1, N, K-1); 
    Xt = G;
    yt = Xt * beta + normrnd(0, 1, N, 1);
  }
};


class LinearModel : BayesBetaUpdater {
 public:
  VectorXd yt;
  MatrixXd Xt;
  VectorXd residuals;
  RowVectorXd b0;
  MatrixXd B0;
  double s0;
  double S0;
  vector<VectorXd> betaPosterior;
  VectorXd sigmaPosterior; 
  void setModel(const VectorXd &yt, const MatrixXd &Xt, const RowVectorXd &b0,
                const MatrixXd &B0, const double s0, const double S0) {
    this->yt = yt;
    this->Xt = Xt;
    this->b0 = b0;
    this->B0 = B0;
    this->s0 = s0;
    this->S0 = S0;
    residuals = VectorXd::Zero(yt.size());
  }
  void runModel(int Sims, int burnin) {
    betaPosterior.resize(Sims - burnin);
    sigmaPosterior.resize(Sims-burnin); 
    RowVectorXd bnew(b0.size());
    double s2 = 1;
    for (int i = 0; i < Sims; ++i) {
      bnew = updateBeta(yt, Xt, s2, b0, B0);
      residuals = yt - Xt * bnew.transpose();
      s2 = updateSigma2(residuals.transpose(), s0, S0).value();

      if (i >= burnin) {
        betaPosterior[i - burnin] = bnew.transpose();
        sigmaPosterior[i - burnin] = s2;
      }
    }
  }
};
