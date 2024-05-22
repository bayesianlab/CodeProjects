#pragma once
#ifndef MLFUNC_H
#define MLFUNC_H
#include <math.h>
#include <stdlib.h>
#include <string.h>

#include <Eigen/Dense>
#include <Eigen/Sparse>
#include <iostream>
#include <stdexcept>
#include <unsupported/Eigen/KroneckerProduct>

#include "Distributions.hpp"
#include "EigenTools.hpp"
#include "TimeSeriesTools.hpp"

using namespace Eigen;
using namespace std;

MatrixXd packageFactorsInXt(const Matrix<int, Dynamic, 2> &InfoMat,
                            const Ref<MatrixXd> &Factors, const int &K);

MatrixXd updateFactor(const MatrixXd &residuals, const MatrixXd &Loadings,
                      const MatrixXd &FactorPrecision,
                      const VectorXd &precision, int T);

MatrixXd MakeObsModelIdentity(const Matrix<int, Dynamic, 2> &InfoMat,
                              const int eqns);

template <typename D>
MatrixXd zeroOutColumn(const MatrixBase<D> &Id, int level) {
  MatrixXd I = Id;
  I.col(level) = MatrixXd::Zero(I.rows(), 1);
  return I;
}

template <typename D1, typename D2, typename D3, typename D4, typename D5,
          typename D6, typename D7>
double ConditionalLogLikelihood(const MatrixBase<D1> &guess,
                                const MatrixBase<D2> &resids,
                                const MatrixBase<D3> &priorMeanA0,
                                const MatrixBase<D4> &priorA0,
                                const MatrixBase<D5> &obsPrecision,
                                const MatrixBase<D6> &factor,
                                const MatrixBase<D7> &FactorPrecision) {
  /* Guess comes in as a column, resids is modified inside */
  /* likelihood for one factor alone */
  /* priorMeanA0 is a row */
  int T = factor.cols();
  int K = obsPrecision.size();
  MatrixXd Avariance =
      (obsPrecision * (factor * factor.transpose())).asDiagonal();
  MatrixXd priorPrecisionA0 = priorA0.llt().solve(MatrixXd::Identity(K, K));
  Avariance = priorPrecisionA0 + Avariance;
  Avariance = Avariance.ldlt().solve(MatrixXd::Identity(K, K));
  MatrixXd Amean =
      (factor * resids.transpose()).array() * obsPrecision.transpose().array();
  Amean.resize(Amean.rows() * Amean.cols(), 1);
  Amean = Avariance * (priorPrecisionA0 * priorMeanA0.transpose() + Amean);
  double pdfA = logmvnpdf(guess.transpose(), Amean.transpose(), Avariance);
  MatrixXd AOI = guess.transpose() * obsPrecision.asDiagonal();
  MatrixXd Fvariance = (VectorXd::Ones(T) * (AOI * guess)).asDiagonal();
  Fvariance = FactorPrecision + Fvariance;
  Fvariance = (Fvariance).ldlt().solve(MatrixXd::Identity(T, T));
  MatrixXd Fmean = AOI * resids;
  Fmean.resize(T, 1);
  Fmean = Fvariance * Fmean;
  return pdfA - logmvnpdf(factor, Fmean.transpose(), Fvariance);
}

template <typename T0, typename T1, typename T2, typename T3, typename T4>
MatrixXd fullConditionalUpdate(
    const MatrixBase<T0> &Factors, const MatrixXd &yt,
    std::vector<MatrixXd> &Xtk, const MatrixBase<T1> &betaParams,
    const double &loading, const MatrixBase<T2> &gammas,
    const MatrixBase<T3> &deltas, const VectorXd &omVariance,
    const VectorXd &factorVariance, const MatrixBase<T4> &Identity,
    const Matrix<int, 1, 2> &InfoMatRow) {
  int nFactors = Factors.rows();
  int T = Factors.cols();
  int K = deltas.rows();
  double s2;
  MatrixXd CovarSum;
  MatrixXd MeanSum;
  MatrixXd Xtemp;
  MatrixXd btemp;
  MatrixXd D0;
  MatrixXd H1;
  MatrixXd Ilagfac = MatrixXd::Identity(gammas.cols(), gammas.cols());
  MatrixXd Ilagom = MatrixXd::Identity(deltas.cols(), deltas.cols());
  MatrixXd factorMean;
  MatrixXd epsilons(1, T);
  CovarSum.setZero(T, T);
  MeanSum.setZero(T, 1);
  for (int k = InfoMatRow.head(1).value(); k <= InfoMatRow.tail(1).value();
       ++k) {
    Xtemp = Xtk[k];
    btemp = betaParams.row(k);
    btemp.rightCols(nFactors) =
        btemp.rightCols(nFactors).array() * Identity.row(k).array();
    epsilons = yt.row(k) - btemp * Xtemp.transpose();
    if (k == InfoMatRow.head(1).value()) {
      H1 = MakePrecision(gammas, factorVariance, T);
      D0 = setInitialCovar(gammas, factorVariance).ldlt().solve(Ilagfac);
      H1.topLeftCorner(gammas.cols(), gammas.cols()) = D0;
      CovarSum += H1;
    } else {
      s2 = omVariance(k);
      H1 = MakePrecision(deltas.row(k), s2, T);
      D0 = setInitialCovar(deltas.row(k), s2).ldlt().solve(Ilagom);
      H1.topLeftCorner(deltas.cols(), deltas.cols()) = D0;
      CovarSum += (loading * loading) * H1;
      MeanSum += loading * (H1 * epsilons.transpose());
    }
  }
  CovarSum = CovarSum.ldlt().solve(MatrixXd::Identity(T, T));
  factorMean = CovarSum * MeanSum;
  return (factorMean +
          CovarSum.llt().matrixL() * normrnd(0, 1, CovarSum.rows(), 1))
      .transpose();
}

template <typename T1, typename T2>
MatrixXd removeZeros(const MatrixBase<T1> &ObsModelIdentity,
                     const MatrixBase<T2> &betaParams, int nXs) {
  int c;
  int levels = (int)ObsModelIdentity.row(0).sum();
  MatrixXd tb(ObsModelIdentity.rows(), levels + nXs);
  MatrixXi Icopy = ObsModelIdentity.template cast<int>();
  for (int i = 0; i < ObsModelIdentity.rows(); ++i) {
    c = nXs;
    for (int j = nXs; j < ObsModelIdentity.cols() + nXs; ++j) {
      if (Icopy(i, j - nXs) > 0) {
        tb(i, c) = betaParams(i, j);
        ++c;
      }
    }
  }
  tb.leftCols(nXs) = betaParams.leftCols(nXs);
  return tb;
}

MatrixXi createFactorInfo(const Matrix<int, Dynamic, 2> &InfoMat, const int &K);

MatrixXi returnIdentificationRestictions(const MatrixXi &FactorInfo);

template <typename T0, typename T1, typename T2>
MatrixXd removeXtZeros(const MatrixBase<T0> &Xthat, const MatrixBase<T1> &I,
                       const Matrix<int, Dynamic, -1> &InfoMat,
                       const MatrixBase<T2> &FactorInfo) {
  int xcols = Xthat.cols();
  int T = Xthat.rows();
  int nXs = xcols - I.cols();
  int levels = (int)I.row(0).sum();
  MatrixXd tempX(T, nXs + levels);
  for (int i = 0; i < levels; ++i) {
    tempX.col(i + nXs) = Xthat.col(nXs + FactorInfo(i));
  }
  tempX.leftCols(nXs) = Xthat.leftCols(nXs);
  return tempX;
}

int calcLevels(const Matrix<int, Dynamic, 2> &InfoMat, const int &K);

template <typename T0, typename T1, typename T3, typename T4, typename T5,
          typename T6, typename T7>
void updateFactor2(MatrixBase<T0> &Factors, const MatrixBase<T1> &yt,
                   const vector<MatrixXd> &Xtk,
                   const Matrix<int, Dynamic, 2> &InfoMat,
                   const MatrixBase<T3> &betaParams,
                   const MatrixBase<T4> &omVariance,
                   const MatrixBase<T5> &factorVariance,
                   const MatrixBase<T6> &deltas, const MatrixBase<T7> &gammas) {
  // for autoregressive model
  int nFactors = InfoMat.rows();
  int K = yt.rows();
  int T = yt.cols();
  int colCount = 0;
  int arOrderFac = gammas.cols();
  int arOrderOm = deltas.cols();
  int nXs = Xtk[0].cols();
  MatrixXd CovarSum(T, T);
  VectorXd MeanSum(T, 1);
  RowVectorXd epsilons(T);
  MatrixXd IT = MatrixXd::Identity(T, T);
  MatrixXd Ilagfac = MatrixXd::Identity(arOrderFac, arOrderFac);
  MatrixXd Ilagom = MatrixXd::Identity(arOrderOm, arOrderOm);
  MatrixXd H1;
  MatrixXd Xthat;
  MatrixXd Xtemp;
  MatrixXd D0;
  RowVectorXd btemp(nXs);
  RowVectorXd loadings(nFactors);
  double f2, s2;
  for (int n = 0; n < nFactors; ++n) {
    CovarSum.setZero(T, T);
    MeanSum.setZero(T, 1);
    double start = InfoMat(n, 0);
    for (int k = InfoMat.row(n).head(1).value();
         k <= InfoMat.row(n).tail(1).value(); ++k) {
      loadings = betaParams.row(k).tail(nFactors);
      btemp = betaParams.row(k).head(nXs);
      loadings(colCount) = 0;
      s2 = omVariance(k);
      epsilons = yt.row(k) - btemp * Xtk[k].transpose() - loadings * Factors;
      if (k == start) {
        f2 = factorVariance(n);
        H1 = MakePrecision(gammas.row(n), f2, T);
        // D0 = setInitialCovar(gammas.row(n), f2).ldlt().solve(Ilagfac);
        // D0 = Ilagfac * (f2);
        // H1.topLeftCorner(arOrderFac, arOrderFac) = D0;
        CovarSum += H1;
      } else {
        s2 = omVariance(k);
        H1 = MakePrecision(deltas.row(k), s2, T);
        CovarSum +=
            (betaParams(k, nXs + colCount) * betaParams(k, nXs + colCount)) *
            H1;
        MeanSum += betaParams(k, nXs + colCount) * (H1 * epsilons.transpose());
      }
    }
    ++colCount;
    CovarSum = CovarSum.llt().solve(IT);
    MeanSum = CovarSum * MeanSum;
    Factors.row(n) =
        (MeanSum + CovarSum.llt().matrixL() * normrnd(0, 1, CovarSum.rows(), 1))
            .transpose();
  }
}

template <typename T0, typename T1, typename T3, typename T4, typename T5,
          typename T6>
void updateFactor2(MatrixBase<T0> &Factors, const MatrixBase<T1> &yt,
                   const vector<MatrixXd> &Xtk,
                   const Matrix<int, Dynamic, 2> &InfoMat,
                   const MatrixBase<T3> &betaParams,
                   const MatrixBase<T4> &omVariance,
                   const MatrixBase<T5> &factorVariance,
                   const MatrixBase<T6> &gammas) {
  // only gammas
  int nFactors = InfoMat.rows();
  int K = yt.rows();
  int T = yt.cols();
  int colCount = 0;
  int arOrderFac = gammas.cols();
  int nXs = Xtk[0].cols();
  MatrixXd CovarSum(T, T);
  VectorXd MeanSum(T, 1);
  RowVectorXd epsilons(T);
  MatrixXd Ilagfac = MatrixXd::Identity(arOrderFac, arOrderFac);
  MatrixXd H1;
  MatrixXd IT = MatrixXd::Identity(T, T);
  MatrixXd D0;
  RowVectorXd btemp(nXs);
  RowVectorXd loadings(nFactors);
  double f2, s2;
  for (int n = 0; n < nFactors; ++n) {
    CovarSum.setZero(T, T);
    MeanSum.setZero(T, 1);
    double start = InfoMat(n, 0);
    for (int k = InfoMat.row(n).head(1).value();
         k <= InfoMat.row(n).tail(1).value(); ++k) {
      s2 = omVariance(k);
      loadings = betaParams.row(k).tail(nFactors);
      btemp = betaParams.row(k).head(nXs);
      loadings(colCount) = 0;
      // break up x and factors

      epsilons = yt.row(k) - btemp * Xtk[k].transpose() - loadings * Factors;
      if (k == start) {
        f2 = factorVariance(n);
        H1 = MakePrecision(gammas.row(n), f2, T);
        // D0 = setInitialCovar(gammas.row(n), f2).ldlt().solve(Ilagfac);
        // D0 = Ilagfac * (1/f2);
        // H1.topLeftCorner(arOrderFac, arOrderFac) = D0;
        CovarSum += H1;
      } else {
        s2 = omVariance(k);
        H1 = (1.0 / s2) * IT;
        CovarSum +=
            (betaParams(k, nXs + colCount) * betaParams(k, nXs + colCount)) *
            H1;
        MeanSum += betaParams(k, nXs + colCount) * (H1 * epsilons.transpose());
      }
    }
    ++colCount;
    CovarSum = CovarSum.ldlt().solve(MatrixXd::Identity(T, T));
    MeanSum = CovarSum * MeanSum;
    Factors.row(n) =
        (MeanSum + CovarSum.llt().matrixL() * normrnd(0, 1, CovarSum.rows()))
            .transpose();
  }
}

template <typename T0, typename T1, typename T3, typename T4, typename T5,
          typename T6>
void updateFactor2(MatrixBase<T0> &Factors, const MatrixBase<T1> &yt,
                   const Matrix<int, Dynamic, 2> &InfoMat,
                   const MatrixBase<T3> &betaParams,
                   const MatrixBase<T4> &omVariance,
                   const MatrixBase<T5> &factorVariance,
                   const MatrixBase<T6> &gammas) {
  // only gammas
  int nFactors = InfoMat.rows();
  int K = yt.rows();
  int T = yt.cols();
  int colCount = 0;
  int arOrderFac = gammas.cols();
  MatrixXd CovarSum(T, T);
  VectorXd MeanSum(T, 1);
  RowVectorXd epsilons(T);
  MatrixXd Ilagfac = MatrixXd::Identity(arOrderFac, arOrderFac);
  MatrixXd H1;
  MatrixXd IT = MatrixXd::Identity(T, T);
  MatrixXd D0;
  RowVectorXd loadings(nFactors);
  double f2, s2;
  for (int n = 0; n < nFactors; ++n) {
    CovarSum.setZero(T, T);
    MeanSum.setZero(T, 1);
    double start = InfoMat(n, 0);
    for (int k = InfoMat.row(n).head(1).value();
         k <= InfoMat.row(n).tail(1).value(); ++k) {
      s2 = omVariance(k);
      loadings = betaParams.row(k);
      loadings(colCount) = 0;
      // break up x and factors

      epsilons = yt.row(k)- loadings * Factors;
      if (k == start) {
        f2 = factorVariance(n);
        H1 = MakePrecision(gammas.row(n), f2, T);
        // D0 = setInitialCovar(gammas.row(n), f2).ldlt().solve(Ilagfac);
        // D0 = Ilagfac * (1/f2);
        // H1.topLeftCorner(arOrderFac, arOrderFac) = D0;
        CovarSum += H1;
      } else {
        s2 = omVariance(k);
        H1 = (1.0 / s2) * IT;
        CovarSum +=
            (betaParams(k, colCount) * betaParams(k, colCount)) *
            H1;
        MeanSum += betaParams(k, colCount) * (H1 * epsilons.transpose());
      }
    }
    ++colCount;
    CovarSum = CovarSum.ldlt().solve(MatrixXd::Identity(T, T));
    MeanSum = CovarSum * MeanSum;
    Factors.row(n) =
        (MeanSum + CovarSum.llt().matrixL() * normrnd(0, 1, CovarSum.rows()))
            .transpose();
  }
}

template <typename T1, typename T3, typename T4, typename T5, typename T6,
          typename T7>
VectorXd factorReducedRun(MatrixXd &Factorstar, const MatrixBase<T1> &yt,
                          const std::vector<MatrixXd> &Xtk,
                          const Matrix<int, Dynamic, 2> &InfoMat,
                          const MatrixBase<T3> &betaParams,
                          const MatrixBase<T4> &omVariance,
                          const MatrixBase<T5> &factorVariance,
                          const MatrixBase<T6> &deltas,
                          const MatrixBase<T7> &gammas) {
  // deltas and gammas
  int nFactors = InfoMat.rows();
  int K = yt.rows();
  int T = yt.cols();
  int levels = calcLevels(InfoMat, K);
  int nXs = Xtk[0].cols();
  int colCount = 0;
  int arOrderFac = gammas.cols();
  int arOrderOm = deltas.cols();
  MatrixXd CovarSum(T, T);
  VectorXd MeanSum(T, 1);
  RowVectorXd epsilons(T);
  MatrixXd Ilagfac = MatrixXd::Identity(arOrderFac, arOrderFac);
  MatrixXd Ilagom = MatrixXd::Identity(arOrderOm, arOrderOm);
  MatrixXd H1;
  MatrixXd IT = MatrixXd::Identity(T, T);
  MatrixXd Xthat;
  MatrixXd Xtemp;
  MatrixXd D0;
  RowVectorXd btemp;
  double f2, s2;
  VectorXd rrvals(nFactors);
  for (int n = 0; n < nFactors; ++n) {
    CovarSum.setZero(T, T);
    MeanSum.setZero(T, 1);
    for (int k = InfoMat.row(n).head(1).value();
         k <= InfoMat.row(n).tail(1).value(); ++k) {
      s2 = omVariance(k);
      Xtemp = Xtk[k];
      RowVectorXd loadings = betaParams.row(k).tail(nFactors);
      btemp = betaParams.row(k).head(nXs);
      loadings(colCount) = 0;
      epsilons = yt.row(k) - btemp * Xtemp.transpose() - loadings * Factorstar;
      if (k == InfoMat.row(n).head(1).value()) {
        f2 = factorVariance(n);
        H1 = MakePrecision(gammas.row(n), f2, T);
        // D0 = setInitialCovar(gammas.row(n), f2).ldlt().solve(Ilagfac);
        // D0 = Ilagfac * (f2);
        // H1.topLeftCorner(arOrderFac, arOrderFac) = D0;
        CovarSum += H1;
      } else {
        s2 = omVariance(k);
        H1 = MakePrecision(deltas.row(k), s2, T);
        CovarSum +=
            (betaParams(k, nXs + colCount) * betaParams(k, nXs + colCount)) *
            H1;
        MeanSum += betaParams(k, nXs + colCount) * (H1 * epsilons.transpose());
      }
    }
    if (K - 1 == InfoMat.row(n).tail(1).value()) {
      ++colCount;
    }
    CovarSum = CovarSum.ldlt().solve(MatrixXd::Identity(T, T));
    // MeanSum = CovarSum * MeanSum;
    // rrvals(n) = logmvnpdf(Factorstar.row(n), MeanSum, CovarSum);
    rrvals(n) = logmvnpdf(Factorstar.row(n), Factorstar.row(n), CovarSum);
  }
  return rrvals;
}

template <typename T1, typename T3, typename T4, typename T5, typename T6>
VectorXd factorReducedRun(MatrixXd &Factorstar, const MatrixBase<T1> &yt,
                          const vector<MatrixXd> &Xtk,
                          const Matrix<int, Dynamic, 2> &InfoMat,
                          const MatrixBase<T3> &betaParams,
                          const MatrixBase<T4> &omVariance,
                          const MatrixBase<T5> &factorVariance,
                          const MatrixBase<T6> &gammas) {
  int nFactors = InfoMat.rows();
  int K = yt.rows();
  int T = yt.cols();
  int colCount = 0;
  int arOrderFac = gammas.cols();
  int levels = calcLevels(InfoMat, K);
  int nXs = Xtk[0].cols();
  MatrixXd CovarSum(T, T);
  VectorXd MeanSum(T, 1);
  RowVectorXd epsilons(T);
  MatrixXd Ilagfac = MatrixXd::Identity(arOrderFac, arOrderFac);
  MatrixXd H1;
  MatrixXd IT = MatrixXd::Identity(T, T);
  MatrixXd Xthat;
  MatrixXd D0;
  RowVectorXd btemp;
  RowVectorXd loadings(nFactors);
  double f2, s2;
  VectorXd rrvals(nFactors);
  for (int n = 0; n < nFactors; ++n) {
    CovarSum.setZero(T, T);
    MeanSum.setZero(T, 1);
    for (int k = InfoMat.row(n).head(1).value();
         k <= InfoMat.row(n).tail(1).value(); ++k) {
      s2 = omVariance(k);
      Xthat = Xtk[k];
      btemp = betaParams.row(k);
      loadings = betaParams.row(k).tail(nFactors);
      btemp = betaParams.row(k).head(nXs);
      loadings(colCount) = 0;
      // break up x and factors
      epsilons =
          yt.row(k) - (btemp * Xthat.transpose() + loadings * Factorstar);
      if (k == InfoMat.row(n).head(1).value()) {
        f2 = factorVariance(n);
        H1 = MakePrecision(gammas.row(n), f2, T);
        // D0 = setInitialCovar(gammas.row(n), f2).ldlt().solve(Ilagfac);
        D0 = Ilagfac * (1 / f2);
        H1.topLeftCorner(arOrderFac, arOrderFac) = D0;
        CovarSum += H1;
      } else {
        s2 = omVariance(k);
        H1 = (1 / s2) * IT;
        CovarSum +=
            (betaParams(k, nXs + colCount) * betaParams(k, nXs + colCount)) *
            H1;
        MeanSum += betaParams(k, nXs + colCount) * (H1 * epsilons.transpose());
      }
    }
    ++colCount;
    CovarSum = CovarSum.ldlt().solve(MatrixXd::Identity(T, T));
    MeanSum = CovarSum * MeanSum;
    rrvals(n) = logmvnpdf(MeanSum, MeanSum, CovarSum);
  }
  return rrvals;
}

template <typename T1, typename T3, typename T4, typename T5, typename T6>
VectorXd factorReducedRun(MatrixXd &Factorstar, const MatrixBase<T1> &yt,
                          const Matrix<int, Dynamic, 2> &InfoMat,
                          const MatrixBase<T3> &betaParams,
                          const MatrixBase<T4> &omVariance,
                          const MatrixBase<T5> &factorVariance,
                          const MatrixBase<T6> &gammas) {
  int nFactors = InfoMat.rows();
  int K = yt.rows();
  int T = yt.cols();
  int colCount = 0;
  int arOrderFac = gammas.cols();
  int levels = calcLevels(InfoMat, K);
  MatrixXd CovarSum(T, T);
  VectorXd MeanSum(T, 1);
  RowVectorXd epsilons(T);
  MatrixXd Ilagfac = MatrixXd::Identity(arOrderFac, arOrderFac);
  MatrixXd H1;
  MatrixXd IT = MatrixXd::Identity(T, T);
  MatrixXd Xthat;
  MatrixXd D0;
  RowVectorXd btemp;
  RowVectorXd loadings(nFactors);
  double f2, s2;
  VectorXd rrvals(nFactors);
  for (int n = 0; n < nFactors; ++n) {
    CovarSum.setZero(T, T);
    MeanSum.setZero(T, 1);
    for (int k = InfoMat.row(n).head(1).value();
         k <= InfoMat.row(n).tail(1).value(); ++k) {
      s2 = omVariance(k);
      btemp = betaParams.row(k);
      loadings = betaParams.row(k);
      loadings(colCount) = 0;
      // break up x and factors
      epsilons =
          yt.row(k)  + loadings * Factorstar;
      if (k == InfoMat.row(n).head(1).value()) {
        f2 = factorVariance(n);
        H1 = MakePrecision(gammas.row(n), f2, T);
        // D0 = setInitialCovar(gammas.row(n), f2).ldlt().solve(Ilagfac);
        D0 = Ilagfac * (1 / f2);
        H1.topLeftCorner(arOrderFac, arOrderFac) = D0;
        CovarSum += H1;
      } else {
        s2 = omVariance(k);
        H1 = (1 / s2) * IT;
        CovarSum +=
            (betaParams(k, colCount) * betaParams(k, colCount)) *
            H1;
        MeanSum += betaParams(k, colCount) * (H1 * epsilons.transpose());
      }
    }
    ++colCount;
    CovarSum = CovarSum.ldlt().solve(MatrixXd::Identity(T, T));
    MeanSum = CovarSum * MeanSum;
    rrvals(n) = logmvnpdf(MeanSum, MeanSum, CovarSum);
  }
  return rrvals;
}

template <typename T1, typename T2>
VectorXd evalFactorPriors(const Ref<MatrixXd> &Factorstar,
                          const Matrix<int, Dynamic, 2> &InfoMat,
                          const MatrixBase<T1> &factorVariance,
                          const MatrixBase<T2> &gammas) {
  int nFactors = InfoMat.rows();
  int T = Factorstar.cols();
  MatrixXd CovarSum(T, T);
  double subfv;
  VectorXd priorFactorStar(nFactors);
  MatrixXd subFp;
  RowVectorXd Z1 = RowVectorXd::Zero(T);
  MatrixXd IT = MatrixXd::Identity(T, T);
  for (int n = 0; n < nFactors; ++n) {
    subfv = (double)factorVariance(n);
    subFp = MakePrecision(gammas.row(n), subfv, T);
    CovarSum = subFp.ldlt().solve(IT);
    priorFactorStar(n) = logmvnpdf(Factorstar.row(n), Z1, CovarSum);
  }
  return priorFactorStar;
}

string dateString();
#endif
