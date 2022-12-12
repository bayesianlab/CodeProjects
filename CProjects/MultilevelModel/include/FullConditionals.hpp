#pragma once
#ifndef FULLCOND_H
#define FULLCOND_H
#include <math.h>

#include <Eigen/Dense>
#include <fstream>
#include <iostream>
#include <string>

#include "ARMA.hpp"
#include "Distributions.hpp"
#include "EigenTools.hpp"
#include "IntegratedLikelihood.hpp"
#include "MultilevelModelFunctions.hpp"
#include "TimeSeriesTools.hpp"

using namespace Eigen;
using namespace std;

class FullConditionals : public LoadingsFactorTools,
                         public BayesBetaUpdater,
                         public ARMA {
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
  RowVectorXd del0;
  MatrixXd Del0;
  string fname;

  void easySetModel(const Ref<const MatrixXd> &_yt,
                    const Ref<const MatrixXd> &_Xt,
                    const Ref<const MatrixXd> &_gammas,
                    const Ref<const MatrixXd> &_deltas,
                    const Matrix<int, Dynamic, 2> &_InfoMat) {
    yt = _yt;
    Xt = _Xt;
    gammas = _gammas.replicate(_InfoMat.rows(), 1);
    deltas = _deltas.replicate(yt.rows(), 1);
    InfoMat = _InfoMat;
    int nFactors = InfoMat.rows();
    nXs = Xt.cols();
    Factors = MatrixXd::Zero(InfoMat.rows(), yt.cols());
    b0 = RowVectorXd::Zero(nFactors + nXs);
    B0 = MatrixXd::Identity(nFactors + nXs, nFactors + nXs) * 10;
    del0 = RowVectorXd::Zero(deltas.cols());
    Del0 = createArPriorCovMat(1, deltas.cols());
    g0 = RowVectorXd::Zero(gammas.cols());
    G0 = createArPriorCovMat(1, gammas.cols());
    r0 = 6;
    R0 = 6;
    d0 = 6;
    D0 = 6;
    omVariance = VectorXd::Ones(yt.rows());
    factorVariance = VectorXd::Ones(nFactors);
    // 1 is not estimating factor variances
    id = 1;
  }

  MatrixXd createArPriorCovMat(double startvar, size_t sz) {
    vector<double> rho;
    for (int i = 0; i < sz; ++i) {
      rho.push_back(pow(startvar, i));
      startvar = startvar / 2.0;
    }
    Map<VectorXd> M(&rho[0], rho.size(), 1);
    MatrixXd Q = M.asDiagonal();
    return Q;
  }

  void setModel(const Ref<const MatrixXd> &yt, const Ref<const MatrixXd> &Xt,
                const Ref<const MatrixXd> &Ft,
                const Ref<const MatrixXd> &gammas,
                const Ref<const MatrixXd> &deltas,
                const Matrix<int, Dynamic, 2> &InfoMat, const RowVectorXd &b0,
                const MatrixXd &B0, const double &r0, const double &R0,
                const double &d0, const double &D0,
                const Ref<const RowVectorXd> &g0, const Ref<const MatrixXd> &G0,
                const Ref<const RowVectorXd> &del0,
                const Ref<const MatrixXd> &Del0, const int &id) {
    /* Has Xt */
    if ((gammas.rows() > Ft.rows()) || (gammas.rows() < Ft.rows())) {
      dim(gammas);
      dim(Ft);
      throw invalid_argument("Error in set model, gammas not correct dim.");
    }
    if (deltas.rows() != yt.rows()) {
      cout << "Dimension deltas" << endl;
      dim(deltas);
      cout << "Dimension yt" << endl;
      dim(yt);
      throw invalid_argument(
          "Error in set model, deltas or yt not set correctly.");
    }

    this->yt = yt;
    this->Xt = Xt;
    this->gammas = gammas;
    this->deltas = deltas;
    this->InfoMat = InfoMat;
    this->b0 = b0;
    this->B0 = B0;
    this->r0 = r0;
    this->R0 = R0;
    this->g0 = g0;
    this->G0 = G0;
    this->d0 = d0;
    this->D0 = D0;
    this->del0 = del0;
    this->Del0 = Del0;
    this->factorVariance = VectorXd::Ones(Ft.rows());
    this->omVariance = VectorXd::Ones(yt.rows());
    this->Identity = MakeObsModelIdentity(InfoMat, yt.rows());
    setFactors(Ft);
    int K = yt.rows();
    this->nXs = Xt.cols();
    int levels = calcLevels(InfoMat, K);
    this->id = id;
  }

  void setModel(const Ref<const MatrixXd> &yt, const Ref<const MatrixXd> &Ft,
                const Ref<const MatrixXd> &gammas,
                const Ref<const MatrixXd> &deltas,
                const Matrix<int, Dynamic, 2> &InfoMat, const RowVectorXd &b0,
                const MatrixXd &B0, const double &r0, const double &R0,
                const double &d0, const double &D0,
                const Ref<const RowVectorXd> &g0, const Ref<const MatrixXd> &G0,
                const int &id) {
    if ((gammas.rows() > Ft.rows()) || (gammas.rows() < Ft.rows())) {
      dim(gammas);
      dim(Ft);
      throw invalid_argument("Error in set model, gammas not correct dim.");
    }
    if (deltas.rows() != yt.rows()) {
      cout << "Dimension deltas" << endl;
      dim(deltas);
      cout << "Dimension yt" << endl;
      dim(yt);
      throw invalid_argument(
          "Error in set model, deltas or yt not set correctly.");
    }
    this->yt = yt;
    this->gammas = gammas;
    this->deltas = deltas;
    this->InfoMat = InfoMat;
    this->b0 = b0;
    this->B0 = B0;
    this->r0 = r0;
    this->R0 = R0;
    this->g0 = g0;
    this->G0 = G0;
    this->d0 = d0;
    this->D0 = D0;
    this->factorVariance = VectorXd::Ones(Ft.rows());
    this->omVariance = VectorXd::Ones(yt.rows());
    this->Identity = MakeObsModelIdentity(InfoMat, yt.rows());
    setFactors(Ft);
    int K = yt.rows();
    this->nXs = 0;
    int levels = calcLevels(InfoMat, K);
    this->id = id;
  }

  void updateLoadingsFullConditionals(MatrixXd &betaParams, const MatrixXd &yt,
                                      const VectorXd &omVariance,
                                      const Matrix<int, Dynamic, 2> &InfoMat,
                                      const std::vector<MatrixXd> &Xtk,
                                      MatrixXd &Factors, const MatrixXd &deltas,
                                      const RowVectorXd &b0L,
                                      const MatrixXd &B0L) {
    /// Updates loadings conditional on factors ///

    int K = yt.rows();
    int nextColumn = 0;
    int nFactors = Factors.rows();
    int T = yt.cols();
    MatrixXd factorLoadings = betaParams.rightCols(nFactors);
    int nXs = Xtk[0].cols();
    VectorXd ythat;
    VectorXd Fthat;
    for (int i = 0; i < nFactors; ++i) {
      int b = InfoMat(i, 0);
      int e = InfoMat(i, 1);
      MatrixXd A = zeroOutColumn(factorLoadings, i);
      for (int j = b; j <= e; ++j) {
        double s2 = omVariance(j);
        MatrixXd H = ReturnH(deltas.row(j), T);
        RowVectorXd ytmaf = yt.row(j) -
                            betaParams.row(j).head(nXs) * Xtk[j].transpose() -
                            A.row(j) * Factors;
        ythat = H * ytmaf.transpose();
        Fthat = H * Factors.row(i).transpose();
        betaParams(j, i + nXs) = updateBeta(ythat, Fthat, s2, b0L.segment(i, 1),
                                            B0L.block(i, i, 1, 1))
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

  void runModel(const int _Sims, const int _burnin) {
    // Assumes there are Xs in the estimation
    int arOrderOm = deltas.cols();
    if (arOrderOm + 1 >= yt.cols())

    {
      throw invalid_argument("T must be greater than lags of Om model.");
    }
    Sims = _Sims;
    burnin = _burnin;
    int K = yt.rows();
    int T = yt.cols();
    int nFactors = InfoMat.rows();
    double s2;
    std::vector<MatrixXd> Xtk;
    Xtk.resize(K);
    Xtk = groupByTime(Xt, K);
    setPosteriorSizes(Sims, burnin);
    VectorXd factorVariance = VectorXd::Ones(nFactors);
    VectorXd MeanSum;
    VectorXd factorMean;
    MatrixXd ythat(K, T);
    MatrixXi FactorInfo = createFactorInfo(InfoMat, K);
    RowVectorXd bnew(nXs);
    MatrixXd factorLoadings(K, nFactors);
    factorLoadings.setZero();
    RowVectorXd b0F =
        1 + b0.segment(b0.size() - nFactors - 1, nFactors).array();
    MatrixXd B0F = .1 * B0.block(B0.rows() - nFactors - 1,
                                 B0.cols() - nFactors - 1, nFactors, nFactors);
    RowVectorXd b02 = b0.segment(0, nXs);
    MatrixXd B02 = B0.block(0, 0, nXs, nXs);
    MatrixXd betaParams(K, nXs + nFactors);
    betaParams.setZero();
    betaParams.rightCols(nFactors) = MakeObsModelIdentity(InfoMat, K);
    residuals.resize(1, T);
    for (int i = 0; i < Sims; ++i) {
      cout << "Sim " << i + 1 << endl;
      factorLoadings = betaParams.rightCols(nFactors);
      MatrixXd ytmaf = yt - factorLoadings * Factors;
      for (int k = 0; k < K; ++k) {
        s2 = omVariance(k);
        MatrixXd H = ReturnH(deltas.row(k), T);
        ythat = H * ytmaf.row(k).transpose();
        MatrixXd Xthat = H * Xtk[k];
        // beta update
        bnew = updateBeta(ythat, Xthat, s2, b02, B02);
        RowVectorXd ytstar = ytmaf.row(k) - bnew * Xtk[k].transpose();
        betaParams.leftCols(nXs).row(k) = bnew;
        // delta update
        deltas.row(k) =
            updateArParameters(ytstar, deltas.row(k), s2, del0, Del0);
        H = ReturnH(deltas.row(k), T);
        ythat = H * ytmaf.row(k).transpose();
        ythat.transposeInPlace();
        Xthat = H * Xtk[k];
        residuals.rightCols(T - arOrderOm) =
            ythat.rightCols(T - arOrderOm) -
            bnew * Xthat.transpose().rightCols(T - arOrderOm);
        residuals.leftCols(arOrderOm) = ythat.leftCols(arOrderOm);
        // sigma update
        omVariance(k) = updateSigma2(residuals, r0, R0).value();
      }
      // Loadings update
      updateLoadingsFullConditionals(betaParams, yt, omVariance, InfoMat, Xtk,
                                     Factors, deltas, b0F, B0F);
      // factor update
      updateFactor2(Factors, yt, Xtk, InfoMat, betaParams, omVariance,
                    factorVariance, deltas, gammas);

      for (int n = 0; n < nFactors; ++n) {
        // gamma update
        gammas.row(n) = updateArParameters(Factors.row(n), gammas.row(n),
                                           factorVariance(n), g0, G0);
        if (id == 2) {
          MatrixXd H = ReturnH(gammas.row(n), T);
          MatrixXd nu = (H * Factors.row(n).transpose()).transpose();
          // factor variance update
          factorVariance(n) = updateSigma2(nu, d0, D0).value();
        }
      }

      if (i >= burnin) {
        BetaPosteriorDraws[i - burnin] = betaParams;
        FactorPosteriorDraws[i - burnin] = Factors;
        DeltasPosteriorDraws[i - burnin] = deltas;
        GammasPosteriorDraws[i - burnin] = gammas;
        OmVariancePosteriorDraws[i - burnin] = omVariance;
        FactorVariancePosteriorDraws[i - burnin] = factorVariance;
      }
    }

    MatrixXd betastar = mean(BetaPosteriorDraws);
    MatrixXd fstar = mean(FactorPosteriorDraws);
    Xtk = groupByTime(Xt, K);
    residuals.resize(K, T);
    MatrixXd fittedModel(K, T);

    for (int k = 0; k < K; ++k) {
      MatrixXd H = ReturnH(deltas.row(k), T);
      RowVectorXd Xbeta = betastar.leftCols(nXs).row(k) * Xtk[k].transpose();
      RowVectorXd Af = betastar.rightCols(nFactors).row(k) * fstar;
      residuals.row(k) = (H * (yt.row(k) - Xbeta - Af).transpose()).transpose();
    }
    std::vector<MatrixXd> Resids;
    Resids.resize(1);
    Resids[0] = residuals;
    int p = system("mkdir -p mllogfiles");
    string date = dateString();
    string version = "full_conditionals_";
    string ext = ".txt";
    string path = "mllogfiles/";
    fname = path + version + date + ext;
    storePosterior(path + version + date + "_beta.csv", BetaPosteriorDraws);
    storePosterior(path + version + date + "_deltas.csv", DeltasPosteriorDraws);
    storePosterior(path + version + date + "_gammas.csv", GammasPosteriorDraws);
    storePosterior(path + version + date + "_factors.csv",
                   FactorPosteriorDraws);
    storePosterior(path + version + date + "_factorVariance.csv",
                   FactorVariancePosteriorDraws);
    storePosterior(path + version + date + "_omVariance.csv",
                   OmVariancePosteriorDraws);
    storePosterior(path + version + date + "_residuals.csv", Resids);
    ofstream file(fname);
    if (file.is_open()) {
      file << "Full Conditional Version run with: " << Sims << " "
           << "burnin " << burnin << endl;
      file << "Beta avg" << endl;
      file << mean(BetaPosteriorDraws) << endl;
      file << "Deltas avg" << endl;
      file << mean(DeltasPosteriorDraws) << endl;
      file << "Gamma avg" << endl;
      file << mean(GammasPosteriorDraws) << endl;
      file << "Factor Variance" << endl;
      file << mean(FactorVariancePosteriorDraws).transpose() << endl;
      file << "OM Variance" << endl;
      file << (mean(OmVariancePosteriorDraws)).transpose() << endl;
      file.close();
    } else {
      cout << "something went wrong" << endl;
    }
  }

  int calculateLevels(const Matrix<int, Dynamic, 2> &InfoMat) {
    int x = -1;
    int nCols = 1;
    for (int i = 0; i < InfoMat.rows(); ++i) {
      int b = InfoMat(i, 0);
      if (x >= b) {
        ++nCols;
      }
      int e = InfoMat(i, 1);
      x = e;
    }
    return nCols;
  }

  void repackageBeta(const MatrixXd &beta,
                     const Matrix<int, Dynamic, 2> &InfoMat, int K) {
    // Gets rid of zeros
    vector<VectorXd> tempbeta;
    int col = 0;

    for (int i = 0; i < InfoMat.rows(); ++i) {
      RowVectorXi temp = InfoMat.row(i);
      VectorXd t(K);
      t.setZero();
      for (int j = temp(0); j <= temp(1); ++j) {
        t(j) = beta(j, col);
      }
      tempbeta.push_back(t);
      ++col;
    }
    MatrixXd newBeta(K, tempbeta.size());
    for (int i = 0; i < (int)tempbeta.size(); ++i) {
      newBeta.col(i) = tempbeta[i];
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
    int arOrderOm = DeltasPosteriorDraws[0].cols();
    int levels = calcLevels(InfoMat, K);
    double s2;
    double posteriorStar = 0;
    FactorPosteriorDrawsj.resize(rr);
    GammasPosteriorDrawsj.resize(rr);
    DeltasPosteriorDrawsj.resize(rr);
    OmVariancePosteriorDrawsj.resize(rr);
    FactorVariancePosteriorDrawsj.resize(rr);
    MatrixXd ythat(1, T);
    MatrixXd Xthat;
    MatrixXd ytstar(1, T);
    MatrixXd residuals(1, T);
    MatrixXd I = MakeObsModelIdentity(InfoMat, K);
    MatrixXd Ilagom = MatrixXd::Identity(arOrderOm, arOrderOm);
    MatrixXd IT = MatrixXd::Identity(T, T);
    MatrixXd piPosterior(K, rr);
    VectorXd priorBetaStar(K);
    MatrixXd H;
    MatrixXd nu;
    std::vector<MatrixXd> Xtk = groupByTime(Xt, K);
    cout << "Beta Reduced Runs" << endl;
    MatrixXi FactorInfo = createFactorInfo(InfoMat, K);
    MatrixXd betaStar = mean(BetaPosteriorDraws);
    MatrixXd factorLoadings = betaStar.rightCols(nFactors);
    RowVectorXd b02 = b0.segment(0, nXs);
    MatrixXd B02 = 100 * B0.block(0, 0, nXs, nXs);
    map<int, vector<int>> indexMap = createIndexMap(InfoMat, K);

    for (int k = 0; k < K; ++k) {
      RowVectorXi loadingselect = FactorInfo.row(k);
      vector<double> temp;
      int nrows = 0;
      for (int i = 0; i < loadingselect.size(); ++i) {
        if (loadingselect(i) != -1) {
          ++nrows;
          temp.push_back(betaStar(k, loadingselect(i) + nXs));
        }
      }
      Map<RowVectorXd> v(&temp[0], temp.size());
      RowVectorXd b0F = RowVectorXd::Zero(v.size());
      MatrixXd B0F = 100 * MatrixXd::Identity(v.size(), v.size());
      if (v.size() != 0) {
        priorBetaStar(k) = logmvnpdf(betaStar.leftCols(nXs).row(k), b02, B02) +
                           logmvnpdf(v, b0F, B0F);
      } else {
        priorBetaStar(k) = logmvnpdf(betaStar.leftCols(nXs).row(k), b02, B02);
      }
    }
    for (int j = 0; j < rr; ++j) {
      cout << "RR = " << j + 1 << endl;
      Factors = FactorPosteriorDraws[j];
      deltas = DeltasPosteriorDraws[j];
      gammas = GammasPosteriorDraws[j];
      omVariance = OmVariancePosteriorDraws[j];
      factorVariance = FactorVariancePosteriorDraws[j];
      MatrixXd ytmaf = yt - factorLoadings * Factors;
      for (int k = 0; k < K; ++k) {
        s2 = omVariance(k);
        H = ReturnH(deltas.row(k), T);
        ythat = H * ytmaf.row(k).transpose();
        RowVectorXd ytmxt =
            H * (ythat.row(k) + factorLoadings.row(k) * Factors).transpose();
        ythat.transposeInPlace();
        Xthat = H * Xtk[k];
        RowVectorXi loadingselect = FactorInfo.row(k);
        vector<double> temp;
        vector<double> fx;
        int nrows = 0;
        for (int i = 0; i < loadingselect.size(); ++i) {
          if (loadingselect(i) != -1) {
            ++nrows;
            temp.push_back(betaStar(k, loadingselect(i) + nXs));
            for (int j = 0; j < T; ++j) {
              fx.push_back(Factors(loadingselect(i), j));
            }
          }
        }
        Map<Matrix<double, Dynamic, Dynamic>> FX(&fx[0], T, nrows);
        Map<RowVectorXd> v(&temp[0], temp.size());
        RowVectorXd b0F = RowVectorXd::Zero(v.size()).array() + 1;
        MatrixXd B0F = 100 * MatrixXd::Identity(v.size(), v.size());
        FX = H*FX.transpose(); 
        if (v.size() != 0) {
          piPosterior(k, j) = betaReducedRun(betaStar.leftCols(nXs).row(k),
                                             ythat, Xthat, s2, b02, B02) +
                              betaReducedRun(v, ytmxt, FX, s2, b0F, B0F);
        } else {
          piPosterior(k, j) = betaReducedRun(betaStar.leftCols(nXs).row(k),
                                             ythat, Xthat, s2, b02, B02);
        }

        RowVectorXd ytstar =
            ytmaf.row(k) - betaStar.leftCols(nXs).row(k) * Xtk[k].transpose();

        deltas.row(k) =
            updateArParameters(ytstar, deltas.row(k), s2, del0, Del0);
        // D0 = Ilagom * (1 / s2);
        // D0 = setInitialCovar(deltas.row(k), 1);
        // D0 = D0.ldlt().solve(Ilagom);
        // D0 = D0.llt().matrixL();
        H = ReturnH(deltas.row(k), T);
        ythat = H * ytmaf.row(k).transpose();
        ythat.transposeInPlace();
        Xthat = H * Xtk[k];
        residuals.rightCols(T - arOrderOm) =
            ythat.rightCols(T - arOrderOm) -
            betaStar.leftCols(nXs).row(k) *
                Xthat.transpose().rightCols(T - arOrderOm);
        residuals.leftCols(arOrderOm) = ythat.leftCols(arOrderOm);
        omVariance(k) = updateSigma2(residuals, r0, R0).value();
      }

      updateFactor2(Factors, yt, Xtk, InfoMat, betaStar, omVariance,
                    factorVariance, deltas, gammas);

      for (int n = 0; n < nFactors; ++n) {
        gammas.row(n) = updateArParameters(Factors.row(n), gammas.row(n),
                                           factorVariance(n), g0, G0);
        if (id == 2) {
          H = ReturnH(gammas.row(n), T);
          nu = (H * Factors.row(n).transpose()).transpose();
          factorVariance(n) = updateSigma2(nu, d0, D0).value();
        }
      }
      FactorPosteriorDrawsj[j] = Factors;
      GammasPosteriorDrawsj[j] = gammas;
      DeltasPosteriorDrawsj[j] = deltas;
      OmVariancePosteriorDrawsj[j] = omVariance;
      FactorVariancePosteriorDrawsj[j] = factorVariance;
    }
    posteriorStar += logavg(piPosterior, 0).sum();
    cout << posteriorStar << endl;

    cout << "Deltas Reduced Run" << endl;
    MatrixXd deltastar = mean(DeltasPosteriorDraws);
    MatrixXd Numerator(K, rr);
    MatrixXd Denominator(K, rr);
    VectorXd priorDeltaStar(K);
    for (int k = 0; k < K; ++k) {
      priorDeltaStar(k) = logmvnpdf(deltastar.row(k), del0, Del0);
    }
    for (int j = 0; j < rr; ++j) {
      cout << "RR = " << j + 1 << endl;
      deltas = DeltasPosteriorDrawsj[j];
      gammas = GammasPosteriorDrawsj[j];
      omVariance = OmVariancePosteriorDrawsj[j];
      Factors = FactorPosteriorDrawsj[j];
      factorVariance = FactorVariancePosteriorDrawsj[j];
      MatrixXd ytmaf = yt - factorLoadings * Factors;
      for (int k = 0; k < K; ++k) {
        s2 = omVariance(k);
        ytstar =
            ytmaf.row(k) - betaStar.leftCols(nXs).row(k) * Xtk[k].transpose();
        Numerator(k, j) =
            alphag(ytstar, deltas.row(k), deltastar.row(k), s2, del0, Del0);
        Denominator(k, j) = alphaj(deltastar.row(k), ytstar, s2, del0, Del0);
        // D0 = Ilagom;
        // D0 = Ilagom * (1 / s2);
        // D0 = setInitialCovar(deltastar.row(k), 1);
        // D0 = D0.ldlt().solve(Ilagom);
        // D0 = D0.llt().matrixL();
        H = ReturnH(deltastar.row(k), T);
        ythat = H * yt.row(k).transpose();
        ythat.transposeInPlace();
        Xthat = H * Xtk[k];
        residuals.rightCols(T - arOrderOm) =
            ythat.rightCols(T - arOrderOm) -
            betaStar.leftCols(nXs).row(k) *
                Xthat.transpose().rightCols(T - arOrderOm);
        residuals.leftCols(arOrderOm) = ythat.leftCols(arOrderOm);
        omVariance(k) = updateSigma2(residuals, r0, R0).value();
      }
      updateFactor2(Factors, yt, Xtk, InfoMat, betaStar, omVariance,
                    factorVariance, deltastar, gammas);

      for (int n = 0; n < nFactors; ++n) {
        gammas.row(n) = updateArParameters(Factors.row(n), gammas.row(n),
                                           factorVariance(n), g0, G0);
        if (id == 2) {
          H = ReturnH(gammas.row(n), T);
          nu = (H * Factors.row(n).transpose()).transpose();
          factorVariance(n) = updateSigma2(nu, d0, D0).value();
        }
      }

      FactorPosteriorDrawsj[j] = Factors;
      GammasPosteriorDrawsj[j] = gammas;
      OmVariancePosteriorDrawsj[j] = omVariance;
      FactorVariancePosteriorDrawsj[j] = factorVariance;
    }
    posteriorStar += logavg(Numerator, 0).sum() - logavg(Denominator, 0).sum();
    cout << posteriorStar << endl;

    cout << "Gamma Reduced Run" << endl;
    Numerator.resize(nFactors, rr);
    Denominator.resize(nFactors, rr);
    MatrixXd gammastar = mean(GammasPosteriorDrawsj);
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
      Factors = FactorPosteriorDraws[j];
      omVariance = OmVariancePosteriorDrawsj[j];
      gammas = GammasPosteriorDrawsj[j];
      factorVariance = FactorVariancePosteriorDrawsj[j];
      MatrixXd ytmaf = yt - factorLoadings * Factors;
      for (int k = 0; k < K; ++k) {
        s2 = omVariance(k);
        ytstar =
            ytmaf.row(k) - betaStar.leftCols(nXs).row(k) * Xtk[k].transpose();
        // D0 = Ilagom * (1 / s2);
        // D0 = setInitialCovar(deltastar.row(k), 1);
        // D0 = D0.ldlt().solve(Ilagom);
        // D0 = D0.llt().matrixL();
        H = ReturnH(deltastar.row(k), T);
        ythat = H * yt.row(k).transpose();
        ythat.transposeInPlace();
        Xthat = H * Xtk[k];
        residuals.rightCols(T - arOrderOm) =
            ythat.rightCols(T - arOrderOm) -
            betaStar.leftCols(nXs).row(k) *
                Xthat.transpose().rightCols(T - arOrderOm);
        residuals.leftCols(arOrderOm) = ythat.leftCols(arOrderOm);
        omVariance(k) = updateSigma2(residuals, r0, R0).value();
      }

      updateFactor2(Factors, yt, Xtk, InfoMat, betaStar, omVariance,
                    factorVariance, deltastar, gammastar);

      for (int n = 0; n < nFactors; ++n) {
        f2 = factorVariance(n);
        Numerator(n, j) =
            alphag(Factors.row(n), gammas.row(n), gammastar.row(n), f2, g0, G0);
        Denominator(n, j) =
            alphaj(gammastar.row(n), Factors.row(n), f2, g0, G0);
        if (id == 2) {
          H = ReturnH(gammas.row(n), T);
          nu = (H * Factors.row(n).transpose()).transpose();
          factorVariance(n) = updateSigma2(nu, d0, D0).value();
        }
      }
      FactorPosteriorDrawsj[j] = Factors;
      OmVariancePosteriorDrawsj[j] = omVariance;
      FactorVariancePosteriorDrawsj[j] = factorVariance;
    }
    posteriorStar += logavg(Numerator, 0).sum() - logavg(Denominator, 0).sum();
    cout << posteriorStar << endl;

    cout << "Om Variance Reduced Run" << endl;
    MatrixXd Factorstar = mean(FactorPosteriorDrawsj);
    VectorXd omVariancestar = mean(OmVariancePosteriorDrawsj);
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
        H = ReturnH(deltastar.row(k), T);
        ythat = H * ytmaf.row(k).transpose();
        ythat.transposeInPlace();
        Xthat = H * Xtk[k];
        residuals = ythat - betaStar.leftCols(nXs).row(k) * Xthat.transpose();
        paramb = .5 * (R0 + (residuals * residuals.transpose()).value());
        piPosterior(k, j) = loginvgammapdf(s2, parama, paramb);
      }
      updateFactor2(Factors, yt, Xtk, InfoMat, betaStar, omVariancestar,
                    factorVariance, deltastar, gammastar);

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

    cout << "Factor Variance Reduced Run (if id == 2)" << endl;
    VectorXd factorVariancestar = mean(FactorVariancePosteriorDrawsj);
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
                      factorVariancestar, deltastar, gammastar);
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
    }

    cout << "Final run for factors" << endl;
    Factorstar = mean(FactorPosteriorDrawsj);
    MatrixXd fp = g0.replicate(nFactors, 1);
    VectorXd priorFactorStar =
        evalFactorPriors(Factorstar, InfoMat, factorVariancestar, fp);
    VectorXd posteriorFactorStar(nFactors, 1);
    posteriorFactorStar =
        factorReducedRun(Factorstar, yt, Xtk, InfoMat, betaStar, omVariancestar,
                         factorVariancestar, deltastar, gammastar);
    RowVectorXd Z2 = RowVectorXd::Zero(1, T);
    VectorXd likelihood(K);
    MatrixXd Covar = MatrixXd::Identity(T, T);
    for (int k = 0; k < K; ++k) {
      s2 = omVariancestar(k);
      H = ReturnH(deltastar.row(k), T);
      ythat = H * yt.row(k).transpose();
      ythat.transposeInPlace();
      Xthat = H * Xtk[k];
      residuals = ythat - betaStar.leftCols(nXs).row(k) * Xthat.transpose() -
                  factorLoadings.row(k) * Factorstar;
      likelihood(k) = logmvnpdf(residuals, Z2, s2 * Covar);
    }
    double conditionalOfFactors =
        likelihood.sum() + priorFactorStar.sum() - posteriorFactorStar.sum();
    double priorSum;

    if (id == 2) {
      cout << priorGammaStar.sum() << " " << priorBetaStar.sum() << " "
           << priorOmVarianceStar.sum() << " "
           << " " << priorDeltaStar.sum() << endl;
      priorSum = priorGammaStar.sum() + priorBetaStar.sum() +
                 priorOmVarianceStar.sum() + priorDeltaStar.sum();
    } else {
      priorSum = priorGammaStar.sum() + priorBetaStar.sum() +
                 priorOmVarianceStar.sum() + priorFactorVarianceStar.sum() +
                 priorDeltaStar.sum();
    }

    marginal_likelihood = conditionalOfFactors + priorSum - posteriorStar;
    cout << "Likelihood " << likelihood.sum() << endl;
    cout << "priorSum " << priorSum << endl;
    cout << "posteriorStar " << posteriorStar << endl;
    cout << "Marginal Likelihood " << marginal_likelihood << endl;

    std::ofstream file(fname, ios_base::app);
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

  template <typename T>
  void storePosterior(string fname, std::vector<T> &M) {
    const static Eigen::IOFormat CSVFormat(Eigen::StreamPrecision,
                                           Eigen::DontAlignCols, ", ", "\n");
    int size = M.size();
    std::ofstream file(fname.c_str());
    if (file.is_open()) {
      for (int i = 0; i < size; ++i) {
        file << M[i].format(CSVFormat) << endl;
      }
      file.close();
    }
  }

  map<int, vector<int>> createIndexMap(const Matrix<int, Dynamic, 2> &InfoMat,
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
    MatrixXd betaBar = mean(BetaPosteriorDraws);
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
      VarDecomp.row(i).head(nXs) = (betaBar.row(i).head(nXs).array() *
                                    betaBar.row(i).head(nXs).array()) *
                                   variance(Xtk[i], 1).transpose().array();
      VectorXd beta2 = betaBar.row(i).tail(nFactors).array().pow(2);
      VarDecomp.block(i, nXs, 1, nFactors) =
          (beta2.array() * variance(factorBar, 0).array()).transpose();
      double s = VarDecomp.row(i).sum();
      VarDecomp.row(i) = VarDecomp.row(i).array() / s;
    }
    std::ofstream file(fname, ios_base::app);
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
    DeltasPosteriorDraws.resize(Sims - burnin);
    GammasPosteriorDraws.resize(Sims - burnin);
    OmVariancePosteriorDraws.resize(Sims - burnin);
    FactorVariancePosteriorDraws.resize(Sims - burnin);
  }
};

#include "FullConditionalsNoAr.hpp"

#endif