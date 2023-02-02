#pragma once
#ifndef ARMA_H
#define ARMA_H
#include <Eigen/Dense>
#include <Eigen/Sparse>
#include <eigen3/unsupported/Eigen/KroneckerProduct>
#include <iostream>
#include <stdexcept>

#include "BayesianUpdates.hpp"
#include "Distributions.hpp"
#include "Plotter.hpp"
#include "TimeSeriesTools.hpp"

using namespace Eigen;
using namespace std;

class ARMA {
 public:

  VectorXd autoCorr(const VectorXd &yt, int plot = 1) {
    double g0 = yt.transpose() * yt;
    VectorXd acf(20);
    cout << 1 << endl;
    acf(0) = 1;
    for (int i = 1; i < 20; ++i) {
      cout << yt.bottomRows(yt.rows() - i).transpose() *
                  yt.topRows(yt.rows() - i) / g0
           << endl;
      acf(i) = (yt.bottomRows(yt.rows() - i).transpose() *
                yt.topRows(yt.rows() - i) / g0)
                   .value();
    }
    if (plot) {
      cout << "plot" << endl;
      plotter("acf", acf);
    }
    return acf;
  }

  std::vector<VectorXd> GenMAData(const int lags, const RowVectorXd &thetas,
                                  const int T) {
    VectorXd yt(T);
    VectorXd epst(T);
    VectorXd negeps(lags);
    negeps.setZero();
    VectorXd ut(T);
    ut.setZero();
    std::vector<VectorXd> data;
    for (int t = 0; t < T; ++t) {
      yt(t) = normrnd(0, 1) + thetas * negeps;
      ut(t) = yt(t) - thetas * negeps;
      VectorXd temp(lags - 1);
      temp = negeps.bottomRows(lags - 1);
      negeps(lags - 1) = ut(t);
      negeps.topRows(lags - 1) = temp;
    }
    data.push_back(yt);
    data.push_back(ut);
    return data;
  }

  void MAResidualsUtil(const VectorXd &yt, VectorXd &epsilons,
                       const RowVectorXd &thetas, VectorXd &temp, int i) {
    if (i == 0) {
      epsilons(0) = yt(0);
      temp(temp.size() - 1) = epsilons(0);
      MAResidualsUtil(yt, epsilons, thetas, temp, i + 1);
    } else if (i == yt.rows() - 1) {
      epsilons(i) = yt(i) - thetas * temp;
      return;
    } else {
      epsilons(i) = yt(i) - thetas * temp;
      int lags = thetas.size();
      VectorXd t = temp.bottomRows(lags - 1);
      temp(lags - 1) = epsilons(i);
      temp.topRows(lags - 1) = t;
      MAResidualsUtil(yt, epsilons, thetas, temp, i + 1);
    }
  }

  void MAResiduals(const VectorXd &yt, VectorXd &epsilons,
                   const RowVectorXd &thetas) {
    VectorXd temp(thetas.size());
    temp.size();
    int i = 0;
    MAResidualsUtil(yt, epsilons, thetas, temp, i);
  }

  template <typename T1>
  RowVectorXd updateArParameters(const MatrixBase<T1> &epsilons,
                                 const RowVectorXd &current,
                                 const double sigma2, const RowVectorXd &g0,
                                 const MatrixXd &G0) {
    // epsilon comes in as 1 row
    // mut is 1 row of the mean function Xbeta
    if (epsilons.rows() != 1) {
      throw invalid_argument(
          "Error in updateArParams. epsilons must be == to 1 row.");
    }
    int T = epsilons.cols();
    int lags = current.cols();
    int MAX_TRIES = 25;
    int notvalid = 1;
    int count = 0;
    MatrixXd Etminus1 = lag(epsilons, current.cols(), 0);
    MatrixXd IG = MatrixXd::Identity(G0.rows(), G0.cols());
    MatrixXd G0inv = G0.llt().solve(IG);
    MatrixXd Vinv = G0inv + (Etminus1 * Etminus1.transpose()) / sigma2;
    Vinv = Vinv.llt().solve(IG);
    VectorXd v =
        Vinv * (G0inv * g0.transpose() +
                (Etminus1 * epsilons.rightCols(T - lags).transpose()) / sigma2);
    MatrixXd proposal;
    MatrixXd Test;
    VectorXd eigr(lags);
    VectorXd eigi(lags);
    VectorXd e(lags);
    int c;
    while (notvalid == 1) {
      proposal =
          (v + (Vinv.llt().matrixL() * normrnd(0, 1, lags, 1))).transpose();
      Test = makeStateSpace(proposal.rowwise().reverse());
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
        return current;
      }
      ++count;
    }
    MatrixXd P1(lags, lags);
    P1 = setInitialCovar(proposal, sigma2);
    MatrixXd P0(lags, lags);
    P0 = setInitialCovar(current, sigma2);

    RowVectorXd zeros = RowVectorXd::Zero(lags);
    double lalpha = min(0.0, logmvnpdf(epsilons.leftCols(lags), zeros, P1) -
                                 logmvnpdf(epsilons.leftCols(lags), zeros, P0));

    if (log(unifrnd()) < lalpha) {
      return proposal;
    } else {
      return current;
    }
  }

  template <typename T1>
  double alphag(const MatrixBase<T1> &posteriorEpsilonG,
                const RowVectorXd &phig, const RowVectorXd &phistar,
                const double sigma2g, const RowVectorXd &g0,
                const MatrixXd &G0) {
    int T = posteriorEpsilonG.cols();
    int lags = phig.cols();
    MatrixXd Etminus1 = lag(posteriorEpsilonG, phig.cols(), 0);
    MatrixXd IG = MatrixXd::Identity(G0.rows(), G0.cols());
    MatrixXd G0inv = G0.ldlt().solve(IG);
    MatrixXd Vinv = G0inv + (Etminus1 * Etminus1.transpose()) / sigma2g;
    Vinv = Vinv.ldlt().solve(IG);
    VectorXd v =
        Vinv * (G0inv * g0.transpose() +
                (Etminus1 * posteriorEpsilonG.rightCols(T - lags).transpose()) /
                    sigma2g);
    MatrixXd S2new = MatrixXd::Identity(T, T);
    S2new = S2new.array() * sigma2g;
    MatrixXd S2old = S2new;
    S2new.block(0, 0, lags, lags) = setInitialCovar(phistar, sigma2g);
    S2old.block(0, 0, lags, lags) = setInitialCovar(phig, sigma2g);
    MatrixXd IT = MatrixXd::Identity(S2new.rows(), S2new.cols());
    MatrixXd S2newinv = S2new.ldlt().solve(IT);
    MatrixXd S2newinvlower = S2newinv.llt().matrixL();
    MatrixXd S2oldinv = S2old.ldlt().solve(IT);
    MatrixXd S2oldinvlower = S2oldinv.llt().matrixL();
    MatrixXd epsilonstarnew = posteriorEpsilonG;
    MatrixXd epsilonstarold = posteriorEpsilonG;
    epsilonstarnew.rightCols(T - lags) =
        posteriorEpsilonG.rightCols(T - lags) - phistar * Etminus1;
    epsilonstarold.rightCols(T - lags) =
        posteriorEpsilonG.rightCols(T - lags) - phig * Etminus1;
    epsilonstarnew = epsilonstarnew * S2newinvlower;
    epsilonstarold = epsilonstarold * S2oldinvlower;
    RowVectorXd zero = RowVectorXd::Zero(epsilonstarnew.cols());
    VectorXd dnum = S2newinvlower.diagonal();
    VectorXd dden = S2oldinvlower.diagonal();
    return min(0.0, (logmvnpdfCentered(epsilonstarnew, dnum) +
                     logmvnpdf(phistar, g0, G0) -
                     logmvnpdf(phig, v.transpose(), Vinv)) -
                        (logmvnpdfCentered(epsilonstarold, dden) +
                         logmvnpdf(phig, g0, G0) -
                         logmvnpdf(phistar, v.transpose(), Vinv))) +
           logmvnpdf(phistar, v.transpose(), Vinv);
  }

  template <typename D1, typename D2>
  double alphaj(const MatrixBase<D1> &gammastar, const MatrixBase<D2> &epsilons,
                const double &sigma2, const MatrixXd &g0, const MatrixXd &G0) {
    if (epsilons.rows() != 1) {
      throw invalid_argument(
          "Error in updateArParams. epsilons must be == to 1 row.");
    }
    int T = epsilons.cols();
    int lags = gammastar.cols();
    int MAX_TRIES = 10;
    int notvalid = 1;
    int count = 0;
    MatrixXd Etminus1 = lag(epsilons, gammastar.cols(), 0);
    MatrixXd IG = MatrixXd::Identity(G0.rows(), G0.cols());
    MatrixXd G0inv = G0.ldlt().solve(IG);
    MatrixXd Vinv = G0inv + (Etminus1 * Etminus1.transpose()) / sigma2;
    Vinv = Vinv.ldlt().solve(IG);
    VectorXd v =
        Vinv * (G0inv * g0.transpose() +
                (Etminus1 * epsilons.rightCols(T - lags).transpose()) / sigma2);
    MatrixXd proposal;
    MatrixXd P1;
    while (notvalid == 1) {
      proposal =
          (v + (Vinv.llt().matrixL() * normrnd(0, 1, lags, 1))).transpose();
      P1 = setInitialCovar(proposal, sigma2);
      if (isPD(P1)) {
        notvalid = 0;
      }
      if (count == MAX_TRIES) {
        P1 = MatrixXd::Identity(lags, lags);
        break;
      }
      ++count;
    }
    MatrixXd S2new = MatrixXd::Identity(T, T);
    S2new = S2new.array() * sigma2;
    MatrixXd S2old = S2new;
    S2new.block(0, 0, lags, lags) = P1;
    S2old.block(0, 0, lags, lags) = setInitialCovar(gammastar, sigma2);
    MatrixXd IT = MatrixXd::Identity(S2new.rows(), S2new.cols());
    MatrixXd S2newinv = S2new.ldlt().solve(IT);
    MatrixXd S2newinvlower = S2newinv.llt().matrixL();
    MatrixXd S2oldinv = S2old.ldlt().solve(IT);
    MatrixXd S2oldinvlower = S2oldinv.llt().matrixL();
    MatrixXd epsilonstarnew = epsilons;
    MatrixXd epsilonstarold = epsilons;
    epsilonstarnew.rightCols(T - lags) =
        epsilons.rightCols(T - lags) - proposal * Etminus1;
    epsilonstarold.rightCols(T - lags) =
        epsilons.rightCols(T - lags) - gammastar * Etminus1;
    epsilonstarnew = epsilonstarnew * S2newinvlower;
    epsilonstarold = epsilonstarold * S2oldinvlower;
    RowVectorXd zero = RowVectorXd::Zero(epsilonstarnew.cols());
    VectorXd dnum = S2newinvlower.diagonal();
    VectorXd dden = S2oldinvlower.diagonal();
    return min(0.0, (logmvnpdfCentered(epsilonstarnew, dnum) +
                     logmvnpdf(proposal, g0, G0) -
                     logmvnpdf(gammastar, v.transpose(), Vinv)) -
                        (logmvnpdfCentered(epsilonstarold, dden) +
                         logmvnpdf(gammastar, g0, G0) -
                         logmvnpdf(proposal, v.transpose(), Vinv)));
  }
};

#endif