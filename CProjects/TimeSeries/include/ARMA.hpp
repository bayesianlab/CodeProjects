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

  void setModel(const VectorXd &yt, const MatrixXd &Xt, const MatrixXd &g0,
                const MatrixXd &G0, const double &r0, const double &R0,
                const RowVectorXd &b0, const MatrixXd &B0) {
    this->yt = yt;
    this->Xt = Xt;
    this->b0 = b0;
    this->B0 = B0;
    this->r0 = r0;
    this->R0 = R0;
    this->g0 = g0;
    this->G0 = G0;
  }
  void runAr(const int &Sims, const int burnin) {
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
      bnew = updateBetaUnivariate(ythat, Xthat, sigma2, b0, B0);
      epsilons = yt - Xt * bnew.transpose();
      arparams = updateArParameters(epsilons.transpose(), arparams, sigma2, g0, G0);
      D0 = setInitialCovar(arparams, 1);
      D0 = D0.ldlt().solve(Ilags);
      D0 = D0.llt().matrixL();
      residuals.topRows(lags) = (epsilons.transpose().leftCols(lags) * D0).transpose();
      residuals.bottomRows(T-lags) = ythat - Xthat * bnew.transpose();
      sigma2 = updateSigma2(residuals.transpose(), r0, R0).value();
      if (i >= burnin) {
        storeBeta.row(i - burnin) = bnew.transpose();
        storeArParams.row(i - burnin) = arparams;
        storeSigma2(i - burnin) = sigma2;
      }
    }
  }
};

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