#pragma once
#ifndef BUP_H
#define BUP_H

#include <Eigen/Dense>
#include <iostream>
#include <stdexcept>

#include "Distributions.hpp"
#include "MultilevelModelFunctions.hpp"
using namespace Eigen;
using namespace std;

class BayesBetaUpdater {
 public:
  MatrixXd B;
  RowVectorXd bmean;
  template <typename T1, typename T2, typename T3, typename T4>
  RowVectorXd updateBeta(const MatrixBase<T1> &yt, const MatrixBase<T2> &Xt,
                         const double &s2, const MatrixBase<T3> &b0,
                         const MatrixBase<T4> &B0) {
    RowVectorXd bnew(b0.size());
    MatrixXd Ix = MatrixXd::Identity(B0.rows(), B0.cols());
    MatrixXd B0inv = B0.llt().solve(Ix);
    B = B0inv + ((Xt.transpose() * Xt) / s2);
    B = B.llt().solve(Ix);
    MatrixXd Blower = B.llt().matrixL();
    bmean =
        (B * (B0inv * b0.transpose() + (Xt.transpose() * yt) / s2)).transpose();
    bnew =
        (bmean.transpose() + Blower * normrnd(0, 1, B.rows(), 1)).transpose();
    return bnew;
  }

  template <typename T0, typename T1, typename T2, typename T3, typename T4>
  double betaReducedRun(const MatrixBase<T0> &betaStar,
                        const MatrixBase<T1> &yt, const MatrixBase<T2> &Xt,
                        const double &s2, const MatrixBase<T3> &b0,
                        const MatrixBase<T4> &B0) {
    MatrixXd Ix = MatrixXd::Identity(B0.rows(), B0.cols());
    MatrixXd B0inv = B0.llt().solve(Ix);
    B = B0inv + ((Xt.transpose() * Xt) / s2);
    B = B.ldlt().solve(Ix);
    bmean =
        (B * (B0inv * b0.transpose() + (Xt.transpose() * yt.transpose()) / s2))
            .transpose();
    return logmvnpdf(bmean, bmean, B);
  }
};

class SurBetaUpdater {
 public:
  MatrixXd B;
  RowVectorXd bmean;
  RowVectorXd bnew;

  template <typename T1, typename T2, typename T3, typename T4, typename T5>
  void updateSurBeta(const MatrixBase<T1> &yt, const MatrixBase<T2> &Xt,
                     const MatrixBase<T3> &Sigma, const MatrixBase<T4> &b0,
                     const MatrixBase<T5> &B0) {
    int K = yt.rows();
    int T = yt.cols();
    MatrixXd Ix = MatrixXd::Identity(B0.rows(), B0.cols());
    MatrixXd B0inv = B0.llt().solve(Ix);
    MatrixXd Precision =
        Sigma.llt().solve(MatrixXd::Identity(Sigma.rows(), Sigma.cols()));
    MatrixXd tx(K, Xt.cols());
    VectorXd ty(K);
    MatrixXd sumX(B0.rows(), B0.rows());
    VectorXd sumY(B0.rows());
    sumY.setZero();
    sumX.setZero();
    int c1 = 0;
    for (int t = 0; t < T; ++t) {
      tx = Xt.middleRows(c1, K);
      ty = yt.col(t);
      sumX += tx.transpose() * Precision * tx;
      sumY += tx.transpose() * Precision * ty;
      c1 += K;
    }
    B = B0inv + sumX;
    B = B.llt().solve(Ix);
    MatrixXd Blower = B.llt().matrixL();
    bmean = (B * (B0inv * b0.transpose() + sumY)).transpose();
    bnew =
        (bmean.transpose() + Blower * normrnd(0, 1, B.rows(), 1)).transpose();
  }

  template <typename T1, typename T2, typename T3, typename T4, typename T5>
  double surBetaReducedRun(const MatrixBase<T1> &betaStar,
                           const MatrixBase<T2> &yt, const MatrixBase<T3> &Xt,
                           const MatrixBase<T3> &Sigma,
                           const MatrixBase<T4> &b0, const MatrixBase<T5> &B0) {
    int K = yt.rows();
    int T = yt.cols();
    MatrixXd Ix = MatrixXd::Identity(B0.rows(), B0.cols());
    MatrixXd B0inv = B0.llt().solve(Ix);
    MatrixXd Precision =
        Sigma.llt().solve(MatrixXd::Identity(Sigma.rows(), Sigma.cols()));
    MatrixXd tx(K, Xt.cols());
    VectorXd ty(K);
    MatrixXd sumX(B0.rows(), B0.rows());
    VectorXd sumY(B0.rows());
    sumY.setZero();
    sumX.setZero();
    int c1 = 0;
    for (int t = 0; t < T; ++t) {
      tx = Xt.middleRows(c1, K);
      ty = yt.col(t);
      sumX += tx.transpose() * Precision * tx;
      sumY += tx.transpose() * Precision * ty;
      c1 += K;
    }
    B = B0inv + sumX;
    B = B.llt().solve(Ix);
    MatrixXd Blower = B.llt().matrixL();
    bmean = (B * (B0inv * b0.transpose() + sumY)).transpose();
    return logmvnpdf(betaStar, bmean, B);
  }

  template <typename T1, typename T2>
  double surLikelihood(const MatrixBase<T1> &mustar,
                       const MatrixBase<T2> &SigmaStar) {
    int K = mustar.rows();
    int T = mustar.cols();
    RowVectorXd z = RowVectorXd::Zero(K);
    VectorXd like(T);
    for (int t = 0; t < T; ++t) {
      like(t) = logmvnpdf(mustar.col(t).transpose(), z, SigmaStar);
    }
    return like.sum();
  }
};

template <typename D>
VectorXd updateSigma2(const MatrixBase<D> &residuals, const int &v0,
                      const int &D0) {
  // residuals must come in as a row
  double parama = .5 * (residuals.cols() + v0);
  VectorXd paramb =
      .5 * (D0 + (residuals.array() * residuals.array()).rowwise().sum());
  paramb = 1. / paramb.array();
  return igammarnd(parama, paramb);
}



#endif
