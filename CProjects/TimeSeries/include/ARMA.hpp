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

  void setModel(const VectorXd &_yt, const MatrixXd &_Xt, const MatrixXd &_g0,
                const MatrixXd &_G0, const double &_r0, const double &_R0,
                const RowVectorXd &_b0, const MatrixXd &_B0) {
    yt = yt;
    Xt = Xt;
    b0 = b0;
    B0 = B0;
    r0 = r0;
    R0 = R0;
    g0 = g0;
    G0 = G0;
    estMean = 0;
  }

  void setModel(const VectorXd &_yt, const MatrixXd &_g0, const MatrixXd &_G0,
                const double &_r0, const double &_R0) {
    yt = yt;
    r0 = r0;
    R0 = R0;
    g0 = g0;
    G0 = G0;
    estMean = 1;
  }

  void runAr(const int &_Sims, const int _burnin) {
    Sims = _Sims;
    burnin = _burnin;
    if (estMean == 1) {
      runNoMeanAr();
    }
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

  void runNoMeanAr() {
    int T = yt.rows();
    int lags = g0.cols();
    RowVectorXd arparams = RowVectorXd::Zero(lags);
    MatrixXd Xthat = lagPolynomial(Xt, arparams, lags, 1);
    VectorXd ythat = lagPolynomial(yt, arparams, lags, 1);
    VectorXd epsilons(T);
    VectorXd residuals(T);
    MatrixXd D0(lags, lags);
    MatrixXd Ilags = MatrixXd::Identity(lags, lags);
    storeArParams.resize(Sims - burnin, lags);
    storeSigma2.resize(Sims - burnin);
    double sigma2 = 1;
    for (int i = 0; i < Sims; ++i) {
      cout << "Sim " << i << endl;
      ythat = lagPolynomial(yt, arparams, lags, 1);
      arparams =
          updateArParameters(ythat.transpose(), arparams, sigma2, g0, G0);
      ythat = lagPolynomial(yt, arparams, lags, 1);
      D0 = setInitialCovar(arparams, sigma2);
      D0 = D0.ldlt().solve(Ilags);
      D0 = D0.llt().matrixL();
      residuals.topRows(lags) =
          (epsilons.transpose().leftCols(lags) * D0).transpose();
      residuals.bottomRows(T - lags) = ythat;
      sigma2 = updateSigma2(residuals.transpose(), r0, R0).value();
      if (i >= burnin) {
        storeArParams.row(i - burnin) = arparams;
        storeSigma2(i - burnin) = sigma2;
      }
    }
  }

  void bayesFit(){
    plotter("yt", yt); 
  }
};

#endif