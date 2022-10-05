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

  void updateLoadingsFullConditionals(
      MatrixXd &betaParams, const MatrixXd &yt, const VectorXd &omVariance,
      const Matrix<int, Dynamic, 2> &InfoMat, const std::vector<MatrixXd> &Xtk,
      const MatrixXd &Factors, const RowVectorXd &b0L, const MatrixXd &B0L) {
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
        if (j == b) {
          betaParams(j, i + nXs) = 1;
        }
      }
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
    VectorXd factorVariance = VectorXd::Ones(nFactors);
    MatrixXd ythat(K, T);
    MatrixXd betaParams(K, nXs + nFactors);
    MatrixXd epsilons(K, T);
    MatrixXd H;
    MatrixXd nu;
    std::vector<MatrixXd> Xtk;
    Xtk.resize(K);
    Xtk = groupByTime(Xt, K);
    MatrixXi FactorInfo = createFactorInfo(InfoMat, K);
    RowVectorXd bnew;
    MatrixXd factorLoadings(K, nFactors);
    factorLoadings.setZero();
    RowVectorXd b0F = b0.segment(b0.size() - nFactors - 1, nFactors);
    MatrixXd B0F = B0.block(B0.rows() - nFactors - 1, B0.cols() - nFactors - 1,
                            nFactors, nFactors);
    RowVectorXd b02 = b0.segment(0, nXs);
    MatrixXd B02 = B0.block(0, 0, nXs, nXs);
    betaParams.rightCols(nFactors) = MakeObsModelIdentity(InfoMat, K);
    for (int i = 0; i < Sims; ++i) {
      cout << "Sim " << i + 1 << endl;
      MatrixXd ytmaf = yt - factorLoadings * Factors;
      for (int k = 0; k < K; ++k) {
        s2 = omVariance(k);
        // Beta update
        bnew = updateBeta(ytmaf.row(k).transpose(), Xtk[k], s2, b02, B02);
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
        if (id == 1) {
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
    this->residuals.resize(K, T);
    MatrixXd fstar = mean(FactorPosteriorDraws);
    MatrixXd bstar = mean(BetaPosteriorDraws);
    fittedModel.resize(K, T);
    for (int k = 0; k < K; ++k) {
      (this->residuals).row(k) = yt.row(k) -
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
    MatrixXd ythat(K, T);

    MatrixXd Xthat;
    MatrixXd epsilons(1, T);
    MatrixXd residuals(1, T);
    MatrixXd D0;
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
    std::vector<MatrixXd> Xtk;
    Xtk.resize(K);

    ythat = yt;
    cout << "Beta Reduced Runs" << endl;
    MatrixXd tempX(T, nXs + levels);
    MatrixXd betaStar = mean(BetaPosteriorDraws);
    repackageBeta(betaStar.rightCols(nFactors), InfoMat, K);

    return 1.;
    if (id == 1) {
      factorVariance = mean(FactorVariancePosteriorDraws);
    } else {
      factorVariance = VectorXd::Ones(nFactors);
    }
    for (int k = 0; k < K; ++k) {
      priorBetaStar(k) = logmvnpdf(betaStar.row(k), b0, B0);
    }
    Xtk = groupByTime(Xt, K);
    for (int j = 0; j < rr; ++j) {
      cout << "RR = " << j + 1 << endl;
      Factors = FactorPosteriorDraws[j];
      gammas = GammasPosteriorDraws[j];
      omVariance = OmVariancePosteriorDraws[j];
      for (int k = 0; k < K; ++k) {
        s2 = omVariance(k);
        piPosterior(k, j) =
            betaReducedRun(betaStar.row(k), yt.row(k), Xtk[k], s2, b0, B0);
        epsilons = yt.row(k) - betaStar.row(k) * Xtk[k].transpose();
        omVariance(k) = updateSigma2(epsilons, r0, R0).value();
      }

      updateFactor2(Factors, yt, Xtk, InfoMat, betaStar, omVariance,
                    factorVariance, gammas);

      for (int n = 0; n < nFactors; ++n) {
        gammas.row(n) = updateArParameters(Factors.row(n), gammas.row(n),
                                           factorVariance(n), g0, G0);
        if (id == 1) {
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
    Xtk = groupByTime(Xt, K);
    for (int j = 0; j < rr; ++j) {
      cout << "RR = " << j + 1 << endl;
      Factors = FactorPosteriorDrawsj[j];
      omVariance = OmVariancePosteriorDrawsj[j];
      gammas = GammasPosteriorDrawsj[j];
      for (int k = 0; k < K; ++k) {
        s2 = omVariance(k);
        epsilons = yt.row(k) - betaStar.row(k) * Xtk[k].transpose();
        omVariance(k) = updateSigma2(epsilons, r0, R0).value();
      }

      updateFactor2(Factors, yt, Xtk, InfoMat, betaStar, omVariance,
                    factorVariance, gammastar);

      for (int n = 0; n < nFactors; ++n) {
        f2 = factorVariance(n);
        Numerator(n, j) =
            alphag(Factors.row(n), gammas.row(n), gammastar.row(n), f2, g0, G0);
        Denominator(n, j) =
            alphaj(gammastar.row(n), Factors.row(n), f2, g0, G0);
        if (id == 1) {
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
    cout << "Om Variance Reduced Run" << endl;
    VectorXd omVariancestar = mean(OmVariancePosteriorDrawsj);
    double parama = .5 * (T + r0);
    double paramb;
    piPosterior.resize(K, rr);
    MatrixXd Factorstar = mean(FactorPosteriorDrawsj);
    Xtk = groupByTime(Xt, K);
    VectorXd priorOmVarianceStar(K);
    for (int k = 0; k < K; ++k) {
      s2 = omVariancestar(k);
      priorOmVarianceStar(k) = loginvgammapdf(s2, .5 * r0, .5 * R0);
    }
    for (int j = 0; j < rr; ++j) {
      cout << "RR = " << j + 1 << endl;

      for (int k = 0; k < K; ++k) {
        s2 = omVariancestar(k);
        residuals = yt.row(k) - betaStar.row(k) * Xtk[k].transpose();
        paramb = .5 * (R0 + (residuals * residuals.transpose()).value());
        piPosterior(k, j) = loginvgammapdf(s2, parama, paramb);
      }
      updateFactor2(Factors, yt, Xtk, InfoMat, betaStar, omVariancestar,
                    factorVariance, gammastar);
      if (id == 1) {
        for (int n = 0; n < nFactors; ++n) {
          H = StoreH[n];
          nu = (H * Factors.row(n).transpose()).transpose();
          factorVariance(n) = updateSigma2(nu, r0, R0).value();
        }
      }
      FactorPosteriorDrawsj[j] = Factors;
      FactorVariancePosteriorDrawsj[j] = factorVariance;
    }
    posteriorStar += logavg(piPosterior, 0).sum();
    double priorSum = 0;
    VectorXd factorVariancestar = mean(FactorVariancePosteriorDrawsj);
    if (id == 1) {
      cout << "Factor Variance Reduced Run" << endl;
      parama = .5 * (T + r0);
      piPosterior.resize(nFactors, rr);
      Factors = mean(FactorPosteriorDrawsj);
      VectorXd priorFactorVarianceStar(nFactors);
      for (int n = 0; n < nFactors; ++n) {
        f2 = factorVariancestar(n);
        priorFactorVarianceStar(n) = loginvgammapdf(f2, .5 * r0, (.5 * R0));
      }
      priorSum += priorFactorVarianceStar.sum();
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
        FactorVariancePosteriorDrawsj[j] = factorVariance;
      }
      posteriorStar += logavg(piPosterior, 0).sum();
    }
    cout << "Final run for factors" << endl;
    Factorstar = mean(FactorPosteriorDrawsj);
    VectorXd priorFactorStar =
        evalFactorPriors(Factorstar, InfoMat, factorVariance, gammastar);
    VectorXd posteriorFactorStar =
        factorReducedRun(Factorstar, yt, Xtk, InfoMat, betaStar, omVariancestar,
                         factorVariancestar, gammastar);

    Xtk = groupByTime(Xt, K);

    VectorXd likelihood(K);
    RowVectorXd Z2 = RowVectorXd::Zero(1, T);
    MatrixXd Covar(T, T);
    for (int k = 0; k < K; ++k) {
      s2 = omVariancestar(k);
      Covar = (omVariancestar(k) * MatrixXd::Identity(T, T));
      likelihood(k) = logmvnpdf(
          yt.row(k) - (betaStar.row(k).head(nXs) * Xtk[k].transpose()) -
              (betaStar.row(k).tail(nFactors) * Factorstar),
          Z2, Covar);
    }

    cout << likelihood.sum() << endl;
    cout << priorFactorStar.sum() << endl;
    cout << posteriorFactorStar.sum() << endl;
    double conditionalOfFactors =
        likelihood.sum() + priorFactorStar.sum() - posteriorFactorStar.sum();
    priorSum =
        priorGammaStar.sum() + priorBetaStar.sum() + priorOmVarianceStar.sum();

    cout << priorSum << endl;
    cout << posteriorStar << endl;

    marginal_likelihood = conditionalOfFactors + priorSum - posteriorStar;
    cout << "Marginal Likelihood " << marginal_likelihood << endl;
    std::ofstream file(fname, ios_base::app | ios_base::out);
    if (file.is_open()) {
      file << "Marginal Likelihood: " << marginal_likelihood << endl;
    }
    return marginal_likelihood;
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
      VarDecomp.row(i).head(nXs) =
          betaBar.row(i).head(nXs).array() * variance(Xtk[i], 1).array();
      VectorXd beta2 = betaBar.row(i).tail(nFactors).array().pow(2);
      VarDecomp.block(i, nXs, 1, nFactors) =
          (beta2.array() * variance(factorBar, 0).array()).transpose();
      double s = VarDecomp.row(i).sum();
      VarDecomp.row(i) = VarDecomp.row(i).array() / s;
    }
    cout << VarDecomp << endl;
    std::ofstream file;
    file.open(fname);
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