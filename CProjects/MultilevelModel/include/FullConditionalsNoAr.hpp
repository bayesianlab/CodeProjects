#pragma once
#ifndef FULLCONDNOAR_H
#define FULLCONDNOAR_H
#include <Eigen/Dense>
#include <fstream>
#include <iostream>
#include <string>

#include "ARMA.hpp"
#include "BayesianUpdates.hpp"
#include "Distributions.hpp"
#include "EigenTools.hpp"
#include "FullConditionals.hpp"
#include "IntegratedLikelihood.hpp"
#include "MultilevelModelFunctions.hpp"
#include "TimeSeriesTools.hpp"
using namespace Eigen;
using namespace std;

class FullConditionalsNoAr : public FullConditionals {
 public:
  std::vector<MatrixXd> BetaPosteriorDraws;
  std::vector<MatrixXd> FactorPosteriorDraws;
  std::vector<MatrixXd> GammasPosteriorDraws;
  std::vector<MatrixXd> DeltasPosteriorDraws;
  std::vector<VectorXd> OmVariancePosteriorDraws;
  std::vector<VectorXd> FactorVariancePosteriorDraws;

  std::vector<MatrixXd> FactorPosteriorDrawsj;
  std::vector<MatrixXd> GammasPosteriorDrawsj;
  std::vector<MatrixXd> DeltasPosteriorDrawsj;
  std::vector<VectorXd> OmVariancePosteriorDrawsj;
  std::vector<VectorXd> FactorVariancePosteriorDrawsj;

  int Sims;
  int burnin;
  int noAr;
  int id;
  int nXs;
  double r0;
  double R0;
  double d0;
  double D0;
  double marginal_likelihood;
  RowVectorXd b0;
  RowVectorXd g0;
  VectorXd omVariance;
  VectorXd omPrecision;
  VectorXd factorVariance;
  MatrixXd G0;
  MatrixXi InfoMat;
  MatrixXd Identity;
  MatrixXd yt;
  MatrixXd Xt;
  MatrixXd gammas;
  MatrixXd deltas;
  MatrixXd B0;
  MatrixXd fittedModel;
  MatrixXd residuals;
  string fname;

  MatrixXd Factors;

  void easySetModel(const Ref<const MatrixXd> &_yt,
                    const Ref<const MatrixXd> &_Xt,
                    const Ref<const MatrixXd> &_gammas,
                    const Matrix<int, Dynamic, 2> &_InfoMat) {
    yt = _yt;
    Xt = _Xt;
    gammas = _gammas.replicate(_InfoMat.rows(), 1);
    InfoMat = _InfoMat;
    int nFactors = InfoMat.rows();
    nXs = Xt.cols();
    Factors = MatrixXd::Zero(InfoMat.rows(), yt.cols());
    b0 = RowVectorXd::Zero(nFactors + nXs).array() + 1;
    B0 = MatrixXd::Identity(nFactors + nXs, nFactors + nXs) * 10;
    g0 = RowVectorXd::Zero(gammas.cols());
    G0 = createArPriorCovMat(1, gammas.cols());
    r0 = 6;
    R0 = 6;
    d0 = 6;
    D0 = 6;
    omVariance = VectorXd::Ones(yt.rows());
    factorVariance = VectorXd::Ones(nFactors);
    id = 1;
  }

  void setModel(const Ref<const MatrixXd> &yt, const Ref<const MatrixXd> &Xt,
                const Ref<const MatrixXd> &Ft,
                const Ref<const MatrixXd> &gammas,
                const Matrix<int, Dynamic, 2> &InfoMat, const RowVectorXd &b0,
                const MatrixXd &B0, const double &r0, const double &R0,
                double d0, double D0, const Ref<const RowVectorXd> &g0,
                const Ref<const MatrixXd> &G0, int &id) {
    noAr = 1;
    if ((gammas.rows() > Ft.rows()) || (gammas.rows() < Ft.rows())) {
      dim(gammas);
      dim(Ft);
      throw invalid_argument("Error in set model, gammas not correct dim.");
    }
    this->yt = yt;
    this->Xt = Xt;
    this->gammas = gammas;
    this->deltas = gammas;
    this->InfoMat = InfoMat;
    this->b0 = b0;
    this->B0 = B0;
    this->r0 = r0;
    this->R0 = R0;
    this->d0 = d0;
    this->D0 = D0;
    this->g0 = g0;
    this->G0 = G0;
    this->omPrecision = VectorXd::Ones(this->yt.rows());
    this->factorVariance = VectorXd::Ones(Ft.rows());
    this->omVariance = 1. / this->omPrecision.array();
    this->Identity = MakeObsModelIdentity(InfoMat, yt.rows());
    setFactors(Ft);
    int K = yt.rows();
    this->nXs = Xt.cols();
    int levels = calcLevels(InfoMat, K);
    this->id = id;
  }

  void updateLoadingsFullConditionals(MatrixXd &betaParams, const MatrixXd &yt,
                                      const VectorXd &omVariance,
                                      const Matrix<int, Dynamic, 2> &InfoMat,
                                      const std::vector<MatrixXd> &Xtk,
                                      MatrixXd &Factors, const RowVectorXd &b0L,
                                      const MatrixXd &B0L) {
    /// Updates loadings conditional on factors ///

    int K = yt.rows();
    int nextColumn = 0;
    int nFactors = Factors.rows();
    MatrixXd factorLoadings = betaParams.rightCols(nFactors);
    int nXs = Xtk[0].cols();
    for (int i = 0; i < nFactors; ++i) {
      int b = InfoMat(i, 0);
      int e = InfoMat(i, 1);
      MatrixXd A = zeroOutColumn(factorLoadings, i);
      for (int j = b; j <= e; ++j) {
        double s2 = omVariance(j);
        RowVectorXd ytmaf = yt.row(j) -
                            betaParams.row(j).head(nXs) * Xtk[j].transpose() -
                            A.row(j) * Factors;
        betaParams(j, i + nXs) =
            updateBeta(ytmaf.transpose(), Factors.row(i).transpose(), s2,
                       b0L.segment(i, 1), B0L.block(i, i, 1, 1))
                .value();
      }
      if (betaParams(b, i + nXs) < 0) {
        for (int j = b; j <= e; ++j) {
          betaParams(j, i + nXs) = -betaParams(j, i + nXs);
        }
      }
      factorLoadings = betaParams.rightCols(nFactors);
    }
  }

  void runModel(const int &Sims, const int &burnin) {
    // Assumes there are Xs in the estimation
    int K = yt.rows();
    int T = yt.cols();
    int nFactors = InfoMat.rows();
    int levels = calcLevels(InfoMat, K);
    double s2;
    setPosteriorSizes(Sims, burnin);
    MatrixXd betaParams(K, nXs + nFactors);
    MatrixXd epsilons(K, T);
    MatrixXd H;
    MatrixXd nu;
    std::vector<MatrixXd> Xtk;
    Xtk.resize(K);
    Xtk = groupByTime(Xt, K);
    MatrixXi FactorInfo = createFactorInfo(InfoMat, K);
    MatrixXd factorLoadings(K, nFactors);
    RowVectorXd b0F =
        1 + b0.segment(b0.size() - nFactors - 1, nFactors).array();
    MatrixXd B0F = .1 * B0.block(B0.rows() - nFactors - 1,
                                 B0.cols() - nFactors - 1, nFactors, nFactors);
    RowVectorXd b02 = b0.segment(0, nXs);
    MatrixXd B02 = B0.block(0, 0, nXs, nXs);
    betaParams.leftCols(nXs) = MatrixXd::Ones(K, nXs);
    betaParams.rightCols(nFactors) = MakeObsModelIdentity(InfoMat, K);

    for (int i = 0; i < Sims; ++i) {
      cout << "Sim " << i + 1 << endl;
      factorLoadings = betaParams.rightCols(nFactors);
      MatrixXd ytmaf = yt - factorLoadings * Factors;
      for (int k = 0; k < K; ++k) {
        s2 = omVariance(k);
        // Beta update
        RowVectorXd bnew =
            updateBeta(ytmaf.row(k).transpose(), Xtk[k], s2, b02, B02);
        RowVectorXd rhat = ytmaf.row(k) - bnew * Xtk[k].transpose();
        // s2 update
        omVariance(k) = updateSigma2(rhat, r0, R0).value();
        betaParams.row(k).leftCols(nXs) = bnew;
      }
      // Loadings update
      updateLoadingsFullConditionals(betaParams, yt, omVariance, InfoMat, Xtk,
                                     Factors, b0F, B0F);
      // Factor update
      updateFactor2(Factors, yt, Xtk, InfoMat, betaParams, omVariance,
                    factorVariance, gammas);
      for (int n = 0; n < nFactors; ++n) {
        // Factor dynamic multipliers update
        gammas.row(n) = updateArParameters(Factors.row(n), gammas.row(n),
                                           factorVariance(n), g0, G0);
        if (id == 2) {
          H = ReturnH(gammas.row(n), T);
          nu = (H * Factors.row(n).transpose()).transpose();
          // factor variance update
          factorVariance(n) = updateSigma2(nu, d0, D0).value();
        }
      }
      if (i >= burnin) {
        BetaPosteriorDraws[i - burnin] = betaParams;
        FactorPosteriorDraws[i - burnin] = Factors;
        GammasPosteriorDraws[i - burnin] = gammas;
        OmVariancePosteriorDraws[i - burnin] = omVariance;
        FactorVariancePosteriorDraws[i - burnin] = factorVariance;
      }
    }
    residuals.resize(K, T);
    MatrixXd fstar = mean(FactorPosteriorDraws);
    MatrixXd bstar = mean(BetaPosteriorDraws);
    fittedModel.resize(K, T);
    for (int k = 0; k < K; ++k) {
      residuals.row(k) = yt.row(k) -
                         bstar.row(k).head(nXs) * Xtk[k].transpose() -
                         bstar.row(k).tail(nFactors) * Factors;
      fittedModel.row(k) = bstar.row(k).head(nXs) * Xtk[k].transpose() +
                           bstar.row(k).tail(nFactors) * Factors;
    }
    std::vector<MatrixXd> R;
    std::vector<MatrixXd> Fit;
    Fit.resize(1);
    R.resize(1);
    Fit[0] = fittedModel;
    R[0] = residuals;
    this->Sims = Sims;
    this->burnin = burnin;
    int p = std::system("mkdir -p mllogfiles");
    string date = dateString();
    string version = "full_conditionals_";
    string ext = ".txt";
    string path = "mllogfiles/";
    fname = path + version + date + ext;
    std::ofstream file;
    file.open(fname);
    if (file.is_open()) {
      storePosterior(path + version + date + "_beta.csv", BetaPosteriorDraws);
      storePosterior(path + version + date + "_gammas.csv",
                     GammasPosteriorDraws);
      storePosterior(path + version + date + "_factors.csv",
                     FactorPosteriorDraws);
      storePosterior(path + version + date + "_factorVariance.csv",
                     FactorVariancePosteriorDraws);
      storePosterior(path + version + date + "_omVariance.csv",
                     OmVariancePosteriorDraws);
      storePosterior(path + version + date + "_residuals.csv", R);
      storePosterior(path + version + date + "_fittedModel.csv", Fit);
      file << "Full Conditional Version run with: " << Sims << " "
           << "burnin " << burnin << endl;
      file << "Beta avg" << endl;
      file << mean(BetaPosteriorDraws) << endl;
      file << "Gamma avg" << endl;
      file << mean(GammasPosteriorDraws) << endl;
      file << "Factor Variance" << endl;
      file << mean(FactorVariancePosteriorDraws).transpose() << endl;
      file << "OM Variance" << endl;
      file << (mean(OmVariancePosteriorDraws)).transpose() << endl;
      file.close();
    } else {
      cout << "Error, file not written" << endl;
    }
  }

  double ml() {
    /* Marginal likelihood.
     * Reduced runs for betas, OM Ar parameters, Factors, Factor Variance,
     * Factors Ar parameters.
     */
    int rr = Sims - burnin;
    int T = yt.cols();
    int K = yt.rows();
    int nFactors = Factors.rows();
    int levels = calcLevels(InfoMat, K);
    double s2;
    double posteriorStar = 0;
    FactorPosteriorDrawsj.resize(rr);
    GammasPosteriorDrawsj.resize(rr);
    OmVariancePosteriorDrawsj.resize(rr);
    FactorVariancePosteriorDrawsj.resize(rr);
    MatrixXd Xthat;
    MatrixXd epsilons(1, T);
    MatrixXd residuals(1, T);
    MatrixXd H1;
    MatrixXd H2;
    MatrixXd I = MakeObsModelIdentity(InfoMat, K);
    VectorXd factorMean;
    MatrixXd IT = MatrixXd::Identity(T, T);
    MatrixXd H(T, T);
    MatrixXd nu(1, T);
    MatrixXd piPosterior(K, rr);
    VectorXd priorBetaStar(K);
    MatrixXi FactorInfo = createFactorInfo(InfoMat, K);
    vector<MatrixXd> Xtk = groupByTime(Xt, K);
    map<int, vector<int>> indexMap = createIndexMap(InfoMat, K);
    cout << "Beta Reduced Runs" << endl;
    MatrixXd tempX(T, nXs + levels);
    MatrixXd betaStar = mean(BetaPosteriorDraws);
    MatrixXd factorLoadings = betaStar.rightCols(nFactors);
    RowVectorXd b02 = b0.segment(0, nXs);
    MatrixXd B02 = B0.block(0, 0, nXs, nXs);
    factorVariance = mean(FactorVariancePosteriorDraws);
    for (int k = 0; k < K; ++k) {
      vector<double> temp;
      int nrows = 0;
      RowVectorXi loadingselect = FactorInfo.row(k);
      for (int i = 0; i < loadingselect.size(); ++i) {
        if (loadingselect(i) != -1) {
          temp.push_back(betaStar(k, loadingselect(i) + nXs));
        }
        Map<RowVectorXd> v(&temp[0], temp.size());
        RowVectorXd b0F = RowVectorXd::Zero(v.size());
        MatrixXd B0F = MatrixXd::Identity(v.size(), v.size());
        if (v.size() != 0) {
          priorBetaStar(k) =
              logmvnpdf(betaStar.leftCols(nXs).row(k), b02, 100*B02) +
              logmvnpdf(v, b0F, 100*B0F);
        } else {
          priorBetaStar(k) = logmvnpdf(betaStar.leftCols(nXs).row(k), b02, B02);
        }
      }
    }
    for (int j = 0; j < rr; ++j) {
      cout << "RR = " << j + 1 << endl;
      Factors = FactorPosteriorDraws[j];
      gammas = GammasPosteriorDraws[j];
      omVariance = OmVariancePosteriorDraws[j];
      factorVariance = FactorVariancePosteriorDraws[j];
      factorLoadings = betaStar.rightCols(nFactors);
      MatrixXd ytmaf = yt - factorLoadings * Factors;
      for (int k = 0; k < K; ++k) {
        s2 = omVariance(k);
        RowVectorXi loadingselect = FactorInfo.row(k);
        vector<double> temp;
        vector<double> fx;
        int nrows = 0;
        for (int i = 0; i < loadingselect.size(); ++i) {
          ++nrows;
          if (loadingselect(i) != -1) {
            temp.push_back(betaStar(k, loadingselect(i) + nXs));
          }
          for (int j = 0; j < T; ++j) {
            fx.push_back(Factors(loadingselect(i), j));
          }
        }
        Map<Matrix<double, Dynamic, Dynamic>> FX(&fx[0], T, nrows);
        Map<RowVectorXd> v(&temp[0], temp.size());
        RowVectorXd b0F = RowVectorXd::Zero(v.size());
        MatrixXd B0F = MatrixXd::Identity(v.size(), v.size());
        if (v.size() != 0) {
          RowVectorXd ytmxt = ytmaf.row(k) + factorLoadings.row(k) * Factors;
          piPosterior(k, j) =
              betaReducedRun(betaStar.leftCols(nXs).row(k), ytmaf.row(k),
                             Xtk[k], s2, b02, B02) +
              betaReducedRun(v, ytmxt, FX, s2, b0F, B0F);
        } else {
          piPosterior(k, j) =
              betaReducedRun(betaStar.leftCols(nXs).row(k), ytmaf.row(k),
                             Xtk[k], s2, b02, B02);
        }
        residuals =
            ytmaf.row(k) - betaStar.leftCols(nXs).row(k) * Xtk[k].transpose();
        omVariance(k) = updateSigma2(residuals, r0, R0).value();
      }
      updateFactor2(Factors, yt, Xtk, InfoMat, betaStar, omVariance,
                    factorVariance, gammas);
      for (int n = 0; n < nFactors; ++n) {
        gammas.row(n) = updateArParameters(Factors.row(n), gammas.row(n),
                                           factorVariance(n), g0, G0);
        if (id == 2) {
          H = ReturnH(gammas.row(n), T);
          nu = (H * Factors.row(n).transpose()).transpose();
          H = ReturnH(gammas.row(n), T);
          nu = (H * Factors.row(n).transpose()).transpose();
          factorVariance(n) = updateSigma2(nu, r0, R0).value();
        }
      }
      FactorPosteriorDrawsj[j] = Factors;
      GammasPosteriorDrawsj[j] = gammas;
      OmVariancePosteriorDrawsj[j] = omVariance;
      FactorVariancePosteriorDrawsj[j] = factorVariance;
    }
    posteriorStar += logavg(piPosterior, 0).sum();
    cout << posteriorStar << endl;
    MatrixXd Numerator(nFactors, rr);
    MatrixXd Denominator(nFactors, rr);
    MatrixXd gammastar = mean(GammasPosteriorDrawsj);

    cout << "Gamma Reduced Run" << endl;
    VectorXd priorGammaStar(nFactors);
    std::vector<MatrixXd> StoreH;
    StoreH.resize(nFactors);
    double f2;
    for (int n = 0; n < nFactors; ++n) {
      priorGammaStar(n) = logmvnpdf(gammastar.row(n), g0, G0);
      StoreH[n] = ReturnH(gammastar.row(n), T);
    }
    for (int j = 0; j < rr; ++j) {
      cout << "RR = " << j + 1 << endl;
      Factors = FactorPosteriorDrawsj[j];
      omVariance = OmVariancePosteriorDrawsj[j];
      gammas = GammasPosteriorDrawsj[j];
      factorVariance = FactorVariancePosteriorDraws[j];
      factorLoadings = betaStar.rightCols(nFactors);
      MatrixXd ytmaf = yt - factorLoadings * Factors;
      for (int k = 0; k < K; ++k) {
        s2 = omVariance(k);
        residuals =
            ytmaf.row(k) - betaStar.leftCols(nXs).row(k) * Xtk[k].transpose();
        omVariance(k) = updateSigma2(residuals, r0, R0).value();
      }
      updateFactor2(Factors, yt, Xtk, InfoMat, betaStar, omVariance,
                    factorVariance, gammastar);
      for (int n = 0; n < nFactors; ++n) {
        f2 = factorVariance(n);
        Numerator(n, j) =
            alphag(Factors.row(n), gammas.row(n), gammastar.row(n), f2, g0, G0);
        Denominator(n, j) =
            alphaj(gammastar.row(n), Factors.row(n), f2, g0, G0);
        if (id == 2) {
          H = ReturnH(gammastar.row(n), T);
          nu = (H * Factors.row(n).transpose()).transpose();
          H = ReturnH(gammas.row(n), T);
          nu = (H * Factors.row(n).transpose()).transpose();
          factorVariance(n) = updateSigma2(nu, r0, R0).value();
        }
      }
      FactorPosteriorDrawsj[j] = Factors;
      OmVariancePosteriorDrawsj[j] = omVariance;
      FactorVariancePosteriorDrawsj[j] = factorVariance;
    }
    posteriorStar += logavg(Numerator, 0).sum() - logavg(Denominator, 0).sum();
    cout << posteriorStar << endl;

    cout << "Om Variance Reduced Run" << endl;
    double priorSum = 0;
    VectorXd factorVariancestar = mean(FactorVariancePosteriorDrawsj);
    MatrixXd Factorstar = mean(FactorPosteriorDrawsj);
    VectorXd omVariancestar = mean(OmVariancePosteriorDrawsj);
    factorLoadings = betaStar.rightCols(nFactors);
    MatrixXd ytmaf = yt - factorLoadings * Factorstar;
    piPosterior.resize(K, rr);
    double parama = .5 * (T + r0);
    double paramb;
    VectorXd priorOmVarianceStar(K);
    for (int k = 0; k < K; ++k) {
      s2 = omVariancestar(k);
      priorOmVarianceStar(k) = loginvgammapdf(s2, .5 * r0, .5 * R0);
    }
    for (int j = 0; j < rr; ++j) {
      cout << "RR = " << j + 1 << endl;
      factorVariance = FactorVariancePosteriorDrawsj[j];
      Factors = FactorPosteriorDraws[j];
      MatrixXd ytmaf = yt - factorLoadings * Factors;
      for (int k = 0; k < K; ++k) {
        s2 = omVariancestar(k);
        residuals =
            ytmaf.row(k) - betaStar.leftCols(nXs).row(k) * Xtk[k].transpose();
        paramb = .5 * (R0 + (residuals * residuals.transpose()).value());
        piPosterior(k, j) = loginvgammapdf(s2, parama, paramb);
      }

      updateFactor2(Factors, yt, Xtk, InfoMat, betaStar, omVariancestar,
                    factorVariance, gammastar);
      for (int n = 0; n < nFactors; ++n) {
        if (id == 2) {
          H = StoreH[n];
          nu = (H * Factors.row(n).transpose()).transpose();
          factorVariance(n) = updateSigma2(nu, d0, D0).value();
        }
      }
      FactorPosteriorDrawsj[j] = Factors;
      FactorVariancePosteriorDrawsj[j] = factorVariance;
    }
    posteriorStar += logavg(piPosterior, 0).sum();
    cout << posteriorStar << endl;

    cout << "Factor Variance Reduced Run (if id == 2)" << endl;
    factorVariancestar = mean(FactorVariancePosteriorDrawsj);
    VectorXd priorFactorVarianceStar(nFactors);
    if (id == 2) {
      parama = .5 * (T + r0);
      piPosterior.resize(nFactors, rr);
      Factorstar = mean(FactorPosteriorDrawsj);
      Factors = Factorstar;
      for (int n = 0; n < nFactors; ++n) {
        f2 = factorVariancestar(n);
        priorFactorVarianceStar(n) = loginvgammapdf(f2, .5 * d0, .5 * D0);
      }
      for (int j = 0; j < rr; ++j) {
        cout << "RR = " << j + 1 << endl;
        updateFactor2(Factors, yt, Xtk, InfoMat, betaStar, omVariancestar,
                      factorVariancestar, gammastar);
        for (int n = 0; n < nFactors; ++n) {
          H = StoreH[n];
          nu = (H * Factors.row(n).transpose()).transpose();
          paramb = .5 * (R0 + (nu * nu.transpose()).value());
          piPosterior(n, j) =
              loginvgammapdf(factorVariancestar(n), parama, paramb);
        }
        FactorPosteriorDrawsj[j] = Factors;
      }
      posteriorStar += logavg(piPosterior, 0).sum();
      cout << posteriorStar << endl;
    }

    cout << "Final run for factors" << endl;
    Factorstar = mean(FactorPosteriorDrawsj);
    VectorXd priorFactorStar = evalFactorPriors(
        Factorstar, InfoMat, factorVariance, g0.replicate(nFactors, 1));
    VectorXd posteriorFactorStar =
        factorReducedRun(Factorstar, yt, Xtk, InfoMat, betaStar, omVariancestar,
                         factorVariancestar, gammastar);
    VectorXd likelihood(K);
    RowVectorXd Z2 = RowVectorXd::Zero(1, T);
    MatrixXd Covar(T, T);
    for (int k = 0; k < K; ++k) {
      s2 = omVariancestar(k);
      Covar = (omVariancestar(k) * MatrixXd::Identity(T, T));
      residuals = yt.row(k) -
                  betaStar.leftCols(nXs).row(k) * Xtk[k].transpose() -
                  factorLoadings.row(k) * Factorstar;
      likelihood(k) = logmvnpdf(residuals, Z2, Covar);
    }

    double conditionalOfFactors =
        likelihood.sum() + priorFactorStar.sum() - posteriorFactorStar.sum();
    priorSum =
        priorGammaStar.sum() + priorBetaStar.sum() + priorOmVarianceStar.sum();
    if (id == 2) {
      priorSum += priorFactorVarianceStar.sum();
    }
    marginal_likelihood = conditionalOfFactors + priorSum - posteriorStar;
    cout << "Likelihood " << likelihood.sum() << endl;
    cout << "Priors " << priorSum << endl;
    cout << "Posteriors " << posteriorStar << endl;
    cout << "Marginal Likelihood " << marginal_likelihood << endl;
    std::ofstream file(fname, ios_base::app | ios_base::out);
    if (file.is_open()) {
      file << "Likelihood " << likelihood.sum() << endl;
      file << "Prior factor " << priorFactorStar.sum() << endl;
      file << "Priors " << priorSum << endl;
      file << "Conditional of factors " << conditionalOfFactors << endl;
      file << "Posteriors " << posteriorStar << endl;
      file << "Marginal Likelihood: " << marginal_likelihood << endl;
    }
    return marginal_likelihood;
  }

  map<int, vector<int>> indexMap(const Matrix<int, Dynamic, 2> &InfoMat,
                                 int K) {
    map<int, vector<int>> im;
    for (int i = 0; i < K; ++i) {
      im[i];
    }
    for (int i = 0; i < InfoMat.rows(); ++i) {
      im[InfoMat(i, 0)].push_back(i);
    }
    return im;
  }

  void summary() {
    // Variance decompositions
    // Last column is residuals
    MatrixXd betaBar = mean(BetaPosteriorDraws);
    cout << "Average beta" << endl;
    cout << betaBar << endl;
    int K = yt.rows();
    MatrixXd factorBar = mean(FactorPosteriorDraws);
    int nFactors = factorBar.rows();
    VectorXd factorVariances = variance(factorBar, 0);
    int levels = calcLevels(InfoMat, K);
    MatrixXd VarDecomp(K, nXs + nFactors + 1);
    VarDecomp.setZero();

    vector<MatrixXd> Xtk = groupByTime(Xt, K);
    VarDecomp.col(nXs + nFactors) = variance(residuals, 0);
    for (int i = 0; i < Xtk.size(); ++i) {
      VectorXd b2 =
          betaBar.row(i).head(nXs).array() * betaBar.row(i).head(nXs).array();
      VarDecomp.row(i).head(nXs) = b2.array() * variance(Xtk[i], 1).array();
      VectorXd beta2 = betaBar.row(i).tail(nFactors).array().pow(2);
      VarDecomp.block(i, nXs, 1, nFactors) =
          (beta2.array() * variance(factorBar, 0).array()).transpose();
      double s = VarDecomp.row(i).sum();
      VarDecomp.row(i) = VarDecomp.row(i).array() / s;
    }
    std::ofstream file;
    file.open(fname, ios::app);
    if (file.is_open()) {
      file << "Variance Decomposition" << endl;
      file << VarDecomp << endl;
      file.close();
    }
  }

 private:
  void setPosteriorSizes(int Sims, int burnin) {
    BetaPosteriorDraws.resize(Sims - burnin);
    FactorPosteriorDraws.resize(Sims - burnin);
    GammasPosteriorDraws.resize(Sims - burnin);
    OmVariancePosteriorDraws.resize(Sims - burnin);
    FactorVariancePosteriorDraws.resize(Sims - burnin);
  }
};

#endif