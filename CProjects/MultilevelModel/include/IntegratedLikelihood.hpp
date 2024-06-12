#pragma once
#ifndef INTLIKE_H
#define INTLIKE_H

#include <iostream>
#include <stdexcept>
#include <fstream>
#include <Eigen/Dense>
#include <Eigen/Sparse>
#include <unsupported/Eigen/KroneckerProduct>
#include <chrono>
#include "Optimization.hpp"
#include "MultilevelModelFunctions.hpp"
#include "EigenTools.hpp"
#include "BayesianUpdates.hpp"
#include "TimeSeriesTools.hpp"

using namespace std::chrono;

class BetaParameterTools
{
public:
    VectorXd betamean; // Mean update
    MatrixXd B;        // Covariance Matrix update
    MatrixXd betanew;  // beta update
    MatrixXd xbt;      // X*beta update

    template <typename D1, typename D2, typename D3, typename D4, typename D5,
              typename D6, typename D7>
    void betaUpdater(const MatrixBase<D1> &yt, const MatrixBase<D2> &Xt,
                     const MatrixBase<D3> &om_precision, const MatrixBase<D4> &A,
                     const MatrixBase<D5> &FactorPrecision, const MatrixBase<D6> &b0,
                     const MatrixBase<D7> &B0)
    {
        /* b0 is a column */
        int T = yt.cols();
        int K = yt.rows();
        int nFactors = A.cols();
        int nFactorsT = nFactors * T;
        int KP = Xt.cols();
        MatrixXd It = MatrixXd::Identity(T, T);
        MatrixXd InFactorsT = MatrixXd::Identity(nFactorsT, nFactorsT);
        MatrixXd Ikp = MatrixXd::Identity(KP, KP);
        MatrixXd FullPrecision = om_precision.asDiagonal();
        MatrixXd B0inv = (B0.diagonal().array().pow(-1)).matrix().asDiagonal();
        MatrixXd xpx = MatrixXd::Zero(KP, KP);
        MatrixXd xpy = MatrixXd::Zero(KP, 1);
        MatrixXd xzz = MatrixXd::Zero(nFactorsT, KP);
        MatrixXd yzz = MatrixXd::Zero(nFactorsT, 1);
        MatrixXd tx;
        MatrixXd ty;
        MatrixXd XzzPinv = (FactorPrecision + kroneckerProduct(It, (A.transpose() * FullPrecision) * A)).llt().solve(InFactorsT);
        int c1 = 0;
        int c2 = 0;
        for (int t = 0; t < T; ++t)
        {
            tx = FullPrecision * Xt.middleRows(c1, K);
            ty = FullPrecision * yt.col(t);
            xzz.middleRows(c2, nFactors) = A.transpose() * tx;
            yzz.middleRows(c2, nFactors) = A.transpose() * ty;
            xpx += Xt.middleRows(c1, K).transpose() * tx;
            xpy += Xt.middleRows(c1, K).transpose() * ty;
            c1 += K;
            c2 += nFactors;
        }
        XzzPinv = xzz.transpose() * XzzPinv;
        B = B0inv + xpx - (XzzPinv * xzz);
        B = B.llt().solve(MatrixXd::Identity(KP, KP));
        betamean = B * (B0inv * b0.transpose() + xpy - (XzzPinv * yzz));
        betanew = betamean + (B.llt().matrixL() * normrnd(0, 1, KP, 1));
        xbt = Xt * betanew;
        xbt.resize(K, T);
    }

    template <typename D1, typename D2, typename D4, typename D5,
              typename D6, typename D7>
    void betaUpdater(const MatrixBase<D1> &yt, const MatrixBase<D2> &Xt,
                     const double &om_precision, const MatrixBase<D4> &A,
                     const MatrixBase<D5> &FactorPrecision, const MatrixBase<D6> &b0,
                     const MatrixBase<D7> &B0)
    {
        /* b0 is a column */
        int T = yt.cols();
        int K = yt.rows();
        int nFactors = A.cols();
        int nFactorsT = nFactors * T;
        int KP = Xt.cols();
        MatrixXd It = MatrixXd::Identity(T, T);
        MatrixXd InFactorsT = MatrixXd::Identity(nFactorsT, nFactorsT);
        MatrixXd Ikp = MatrixXd::Identity(KP, KP);
        MatrixXd B0inv = (B0.diagonal().array().pow(-1)).matrix().asDiagonal();
        MatrixXd xpx = MatrixXd::Zero(KP, KP);
        MatrixXd xpy = MatrixXd::Zero(KP, 1);
        MatrixXd xzz = MatrixXd::Zero(nFactorsT, KP);
        MatrixXd yzz = MatrixXd::Zero(nFactorsT, 1);
        MatrixXd tx;
        MatrixXd ty;
        MatrixXd AtO = A.array() / om_precision;
        MatrixXd XzzPinv = (FactorPrecision + kroneckerProduct(It, AtO * A)).llt().solve(InFactorsT);
        int c1 = 0;
        int c2 = 0;
        for (int t = 0; t < T; ++t)
        {
            tx = om_precision * Xt.middleRows(c1, K);
            ty = om_precision * yt.col(t);
            xzz.middleRows(c2, nFactors) = A.transpose() * tx;
            yzz.middleRows(c2, nFactors) = A.transpose() * ty;
            xpx += Xt.middleRows(c1, K).transpose() * tx;
            xpy += Xt.middleRows(c1, K).transpose() * ty;
            c1 += K;
            c2 += nFactors;
        }
        XzzPinv = xzz.transpose() * XzzPinv;
        B = B0inv + xpx - (XzzPinv * xzz);
        B = B.llt().solve(MatrixXd::Identity(KP, KP));
        betamean = B * (B0inv * b0.transpose() + xpy - (XzzPinv * yzz));
        betanew = betamean + (B.llt().matrixL() * normrnd(0, 1, KP, 1));
        xbt = Xt * betanew;
        xbt.resize(K, T);
    }

    template <typename D1, typename D2, typename D3, typename D4, typename D5,
              typename D6, typename D7>
    void computeParameters(const MatrixBase<D1> &yt, const MatrixBase<D2> &surX,
                           const MatrixBase<D3> &om_precision, const MatrixBase<D4> &A,
                           const MatrixBase<D5> &FactorPrecision, const MatrixBase<D6> &b0,
                           const MatrixBase<D7> &B0)
    {
        /* b0 is a column */
        int T = yt.cols();
        int K = yt.rows();
        int nFactors = A.cols();
        int nFactorsT = nFactors * T;
        int KP = surX.cols();
        MatrixXd It = MatrixXd::Identity(T, T);
        MatrixXd InFactorsT = MatrixXd::Identity(nFactorsT, nFactorsT);
        MatrixXd Ikp = MatrixXd::Identity(KP, KP);
        MatrixXd FullPrecision = om_precision.asDiagonal();
        MatrixXd B0inv = (B0.diagonal().array().pow(-1)).matrix().asDiagonal();
        MatrixXd xpx = MatrixXd::Zero(KP, KP);
        MatrixXd xpy = MatrixXd::Zero(KP, 1);
        MatrixXd xzz = MatrixXd::Zero(nFactorsT, KP);
        MatrixXd yzz = MatrixXd::Zero(nFactorsT, 1);
        MatrixXd tx;
        MatrixXd ty;
        MatrixXd AtO = A.transpose() * FullPrecision;

        MatrixXd XzzPinv = (FactorPrecision + kroneckerProduct(It, AtO * A)).llt().solve(InFactorsT);

        int c1 = 0;
        int c2 = 0;
        for (int t = 0; t < T; ++t)
        {
            tx = FullPrecision * surX.middleRows(c1, K);
            ty = FullPrecision * yt.col(t);
            xzz.middleRows(c2, nFactors) = A.transpose() * tx;
            yzz.middleRows(c2, nFactors) = A.transpose() * ty;
            xpx += surX.middleRows(c1, K).transpose() * tx;
            xpy += surX.middleRows(c1, K).transpose() * ty;

            c1 += K;
            c2 += nFactors;
        }

        XzzPinv = xzz.transpose() * XzzPinv;
        B = B0inv + xpx - (XzzPinv * xzz);

        B = B.llt().solve(MatrixXd::Identity(KP, KP));
        betamean = B * (B0inv * b0.transpose() + xpy - (XzzPinv * yzz));
    }

    template <typename D0, typename D1, typename D2, typename D3, typename D4, typename D5,
              typename D6, typename D7>
    double betapdf(const MatrixBase<D0> &betastar, const MatrixBase<D1> &yt, const MatrixBase<D2> &surX,
                   const MatrixBase<D3> &om_precision, const MatrixBase<D4> &A,
                   const MatrixBase<D5> &FactorPrecision, const MatrixBase<D6> &b0,
                   const MatrixBase<D7> &B0)
    {
        computeParameters(yt, surX, om_precision, A, FactorPrecision, b0, B0);
        return logmvnpdf(betastar, betamean.transpose(), B);
    }

    template <typename T1, typename T2>
    void setXbeta(const MatrixBase<T2> &surX, const MatrixBase<T1> &betastar, const int &K, const int &T)
    {
        xbt = surX * betastar;
        xbt.resize(K, T);
    }
};

class LoadingsPriorsSetup
{
public:
    std::vector<VectorXd> loadingsPriorMeans;
    std::vector<MatrixXd> loadingsPriorPrecision;

    void setPriors(const double &priorMean, const double &priorPrecision, const Matrix<int, Dynamic, 2> &InfoMat)
    {
        loadingsPriorMeans.resize(InfoMat.rows());
        loadingsPriorPrecision.resize(InfoMat.rows());
        for (int i = 0; i < InfoMat.rows(); ++i)
        {
            int d = InfoMat.row(i).tail(1).value() - InfoMat.row(i).head(1).value() + 1;
            VectorXd pm;
            pm = priorMean * VectorXd::Ones(d);
            MatrixXd cov = priorPrecision * MatrixXd::Identity(d, d);
            loadingsPriorMeans[i] = pm;
            loadingsPriorPrecision[i] = cov;
        }
    }
};

class LoadingsFactorTools
{
public:
    MatrixXd Factors;
    MatrixXd Loadings;
    double acceptance_rate;

    LoadingsFactorTools()
    {
        acceptance_rate = 0;
    }

    void getAcceptanceRate(double nRuns)
    {
        acceptance_rate = acceptance_rate / nRuns;
    }

    void setFactors(const Ref<const MatrixXd> &F)
    {
        Factors = F;
    }

    void setLoadings(const Ref<const MatrixXd> &A, const Matrix<int, Dynamic, 2> &InfoMat,
                     double restriction)
    {
        Loadings = A;
        for (int i = 0; i < InfoMat.rows(); ++i)
        {
            Loadings(InfoMat.row(i).head(1).value(), i) = restriction;
        }
    }

    void updateLoadingsFactors(const Ref<const MatrixXd> &yt, const Ref<const MatrixXd> &Xbeta,
                               const Ref<const MatrixXd> &gammas, const Ref<const VectorXd> &obsPrecision,
                               const Ref<const VectorXd> &factorVariance, const Matrix<int, Dynamic, 2> &InfoMat,
                               vector<VectorXd> &loadingsPriorMeanMap, vector<MatrixXd> &loadingsPriorPrecisionMap,
                               Optimize &optim)
    {

        int T = yt.cols();
        int nrows;
        
        int disp_on = 1;
        double lalpha;
        double tau;
        MatrixXd ytdemeaned;
        MatrixXd subytdemeaned;
        MatrixXd subgammas;
        MatrixXd subFp;
        MatrixXd subFt;
        MatrixXd COM;
        MatrixXd mut;
        MatrixXd subPriorMean;
        MatrixXd subPriorPrecision;
        MatrixXd proposalCovariance;
        MatrixXd lower;
        MatrixXd covDiag;
        MatrixXd Diag;

        VectorXd subA;
        VectorXd subfv;
        VectorXd subomPrecision;
        VectorXd proposalMean;
        VectorXd proposal;
        int start;
        for (int i = 0; i < InfoMat.rows(); ++i)
        {
            cout << "Factor level " << i + 1 << endl;
            COM = zeroOutColumn(Loadings, i);
            mut = Xbeta + COM * Factors;
            ytdemeaned = yt - mut;
            start = InfoMat.row(i).head(1).value();
            nrows = InfoMat.row(i).tail(1).value() - start + 1;
            subytdemeaned = ytdemeaned.middleRows(start, nrows);
            subomPrecision = obsPrecision.segment(start, nrows);
            subA = Loadings.col(i).segment(start, nrows);
            subgammas = gammas.row(i);
            subfv = factorVariance.row(i);
            subFp = MakePrecision(subgammas, subfv, T);
            subFt = Factors.row(i);
            subPriorMean = loadingsPriorMeanMap[i].transpose();
            subPriorPrecision = loadingsPriorPrecisionMap[i];

            auto CLL = [&subytdemeaned, &subPriorMean, &subPriorPrecision,
                        &subomPrecision, &subFt, &subFp](const VectorXd &x0)
            {
                return -ConditionalLogLikelihood(x0, subytdemeaned, subPriorMean, subPriorPrecision,
                                                 subomPrecision, subFt, subFp);
            };

            optim.BFGS(subA, CLL, disp_on);
            proposalMean = optim.x1;
            covDiag = optim.AprroximateDiagHessian(optim.x1, CLL);
            Diag = covDiag.diagonal();
            Diag = Diag.array().pow(-1);
            proposalCovariance = Diag.asDiagonal();

            lower = proposalCovariance.llt().matrixL();

            proposal = proposalMean + lower * normrnd(0, 1, lower.rows(), 1);
            if (proposalCovariance.cols() > 100)
            {
                tau = 1;
            }
            else if ((proposalCovariance.cols() <= 100) && (proposalCovariance.cols() > 10))
            {
                tau = 1;
            }
            else
            {
                tau = 1;
            }

            lalpha = -CLL(proposal) + logmvnpdf(subA.transpose(), proposalMean.transpose(), tau * proposalCovariance) +
                     CLL(subA) - logmvnpdf(proposal.transpose(), proposalMean.transpose(), tau * proposalCovariance);
            lalpha = min(0., lalpha);
            if (isnan(lalpha))
            {
                throw std::domain_error("Error in update factor MH step.");
            }
            if (log(unifrnd()) < lalpha)
            {
                acceptance_rate += 1;
                subA = proposal;
                subA(0) = 1;
                Loadings.col(i).segment(start, nrows) = subA;
            }
            MatrixXd omP = subomPrecision.asDiagonal(); 
            Factors.row(i) = updateFactor(subytdemeaned, subA, subFp, omP);
        }
    }
};

class MultilevelModel : public BetaParameterTools, public LoadingsFactorTools, public LoadingsPriorsSetup
{
public:
    std::vector<MatrixXd> LoadingsPosteriorDraws;
    std::vector<MatrixXd> BetaPosteriorDraws;
    std::vector<MatrixXd> FactorPosteriorDraws;
    std::vector<MatrixXd> GammasPosteriorDraws;
    std::vector<MatrixXd> DeltasPosteriorDraws;
    std::vector<VectorXd> ObsPrecisionPosteriorDraws;
    std::vector<VectorXd> FactorVariancePosteriorDraws;
    std::vector<VectorXd> PosteriorMeans;
    std::vector<MatrixXd> PosteriorCovariances;

    int Sims;
    int burnin;
    double r0;
    double R0;
    double marginal_likelihood;
    RowVectorXd b0;
    RowVectorXd g0;
    MatrixXd G0;
    MatrixXi InfoMat;
    MatrixXd Identity;
    MatrixXd yt;
    MatrixXd Xt;
    MatrixXd gammas;
    MatrixXd deltas;
    MatrixXd B0;
    string fname;

    void setModel(const Ref<const MatrixXd> &yt, const Ref<const MatrixXd> &Xt, const Ref<const MatrixXd> &A,
                  const Ref<const MatrixXd> &Ft, const Ref<const MatrixXd> &gammas, const Matrix<int, Dynamic, 2> &InfoMat,
                  const RowVectorXd &b0, const MatrixXd &B0, const double &a0, const double &A0, const double &r0,
                  const double &R0, const Ref<const RowVectorXd> &g0, const Ref<const MatrixXd> &G0)
    {
        if ((gammas.rows() > Ft.rows()) || (gammas.rows() < Ft.rows()))
        {
            dim(gammas);
            dim(Ft);
            throw invalid_argument("Error in set model, gammas not correct dim.");
        }
        if (g0.cols() != gammas.cols())
        {
            dim(g0);
            dim(gammas);
            throw invalid_argument("Error in set model, gammas and g0 rows not correct.");
        }
        if ((b0.cols() / yt.rows()) != Xt.cols())
        {
            dim(b0);
            dim(Xt);
            throw invalid_argument("Error in set model, b0 not correct.");
        }
        this->yt = yt;
        this->Xt = Xt;
        this->gammas = gammas;
        this->InfoMat = InfoMat;
        this->b0 = b0;
        this->B0 = B0;
        this->r0 = r0;
        this->R0 = R0;
        this->g0 = g0;
        this->G0 = G0;
        this->Identity = MakeObsModelIdentity(InfoMat, yt.rows());
        setFactors(Ft);
        setLoadings(A, InfoMat, 1.);
        setPriors(a0, A0, InfoMat);
    }

    void setPostMeansAndCovars(const Ref<const MatrixXd> &A, const Ref<const MatrixXd> &Xbeta, MatrixXd &Ft,
                               const Ref<const MatrixXd> &gammas, const Ref<const VectorXd> &obsPrecision,
                               const Ref<const VectorXd> &factorVariance, Optimize &optim)
    {
        int T = yt.cols();
        int nFactors = InfoMat.rows();
        PosteriorMeans.resize(nFactors);
        PosteriorCovariances.resize(nFactors);
        MatrixXd ytdemeaned;
        MatrixXd subytdemeaned;
        MatrixXd subgammas;
        MatrixXd subFp;
        MatrixXd subFt;
        MatrixXd COM;
        MatrixXd mut;
        MatrixXd subPriorMean;
        MatrixXd subPriorPrecision;
        MatrixXd lower;
        MatrixXd postCovar;

        VectorXd subA;
        VectorXd subfv;
        VectorXd subomPrecision;

        int disp_on = 0;

        int nrows;
        int start;
        int c = 0;
        for (int i = 0; i < nFactors; ++i)
        {
            nrows = InfoMat.row(i).tail(1).value() - InfoMat.row(i).head(1).value() + 1;
            start = InfoMat.row(i).head(1).value();
            COM = zeroOutColumn(A, c);
            mut = Xbeta + COM * Ft;
            ytdemeaned = yt - mut;
            subytdemeaned = ytdemeaned.middleRows(start, nrows);
            subomPrecision = obsPrecision.segment(start, nrows);
            subA = A.col(i).segment(start, nrows);
            subgammas = gammas.row(i);
            subfv = factorVariance.row(i);
            subFp = MakePrecision(subgammas, subfv, T);
            subFt = Ft.row(i);
            subPriorMean = loadingsPriorMeans[i].transpose();
            subPriorPrecision = loadingsPriorPrecision[i];

            auto CLL = [&subytdemeaned, &subPriorMean, &subPriorPrecision,
                        &subomPrecision, &subFt, &subFp](const VectorXd &x0)
            {
                return -ConditionalLogLikelihood(x0, subytdemeaned, subPriorMean, subPriorPrecision,
                                                 subomPrecision, subFt, subFp);
            };
            optim.BFGS(subA, CLL, disp_on);
            postCovar = optim.AprroximateDiagHessian(optim.x1, CLL);
            postCovar = postCovar.llt().solve(MatrixXd::Identity(nrows, nrows));
            PosteriorMeans[i] = subA.transpose();
            PosteriorCovariances[i] = postCovar;
        }
    }

    void runModel(int Sims, int burnin)
    {
        this->Sims = Sims;
        this->burnin = burnin;
        const int T = yt.cols();
        const int K = yt.rows();
        const int nFactors = InfoMat.rows();
        const int sxtcols = Xt.cols() * K;
        VectorXd omVariance = VectorXd::Ones(K);
        VectorXd omPrecision = 10 * omVariance.array().pow(-1);
        VectorXd factorVariance = .1 * VectorXd::Ones(nFactors);

        MatrixXd surX(sxtcols, Xt.rows());
        surX = surForm(Xt, K);
        betanew = VectorXd::Ones(surX.cols());
        setXbeta(surX, betanew, K, T);
        MatrixXd FactorPrecision(nFactors * T, nFactors * T);
        FactorPrecision = MakePrecisionBig(gammas, factorVariance, T);
        MatrixXd resids;
        MatrixXd H;
        VectorXd Hf;
        double optim_options[5] = {1e-5, 1e-4, 1e-4, 1e-4, 20};
        double parama = .5 * (r0 + T);
        double paramb;
        double f2;
        Optimize optim(optim_options);
        int stationarySims = Sims - (burnin);
        MatrixXd omidentity = MakeObsModelIdentity(InfoMat, K);

        LoadingsPosteriorDraws.resize(stationarySims);
        FactorPosteriorDraws.resize(stationarySims);
        BetaPosteriorDraws.resize(stationarySims);
        FactorPosteriorDraws.resize(stationarySims);
        GammasPosteriorDraws.resize(stationarySims);
        ObsPrecisionPosteriorDraws.resize(stationarySims);
        FactorVariancePosteriorDraws.resize(stationarySims);
        ArParameterTools apt;
        for (int i = 0; i < Sims; ++i)
        {

            cout << "Sim " << i + 1 << endl;
            betaUpdater(yt, surX, omPrecision, Loadings, FactorPrecision, b0, B0);

            updateLoadingsFactors(yt, xbt, gammas, omPrecision, factorVariance, InfoMat,
                                  loadingsPriorMeans, loadingsPriorPrecision, optim);

            for (int j = 0; j < nFactors; ++j)
            {
                f2 = factorVariance(j);
                apt.updateArParameters(Factors.row(j), gammas.row(j), f2, g0, G0);
                gammas.row(j) = apt.phinew;
                H = ReturnH(gammas.row(j), T);
                Hf = H * Factors.row(j).transpose();
                paramb = (.5 * (R0 + Hf.transpose() * Hf));
                factorVariance(j) = igammarnd(parama, 1.0 / paramb);
            }
            resids = yt - (Loadings * Factors) - xbt;
            for (int j = 0; j < K; ++j)
            {
                paramb = 0.5 * ((R0 + (resids.row(j) * resids.row(j).transpose())));
                omVariance(j) = igammarnd(parama, 1.0 / paramb);
            }
            omPrecision = omVariance.array().pow(-1.0);
            FactorPrecision = MakePrecisionBig(gammas, factorVariance, T);
            if (i >= burnin)
            {
                BetaPosteriorDraws[i - (burnin)] = betanew;
                FactorPosteriorDraws[i - (burnin)] = Factors;
                LoadingsPosteriorDraws[i - (burnin)] = Loadings;
                GammasPosteriorDraws[i - (burnin)] = gammas;
                ObsPrecisionPosteriorDraws[i - (burnin)] = omPrecision;
                FactorVariancePosteriorDraws[i - (burnin)] = factorVariance;
            }
        }
        getAcceptanceRate(nFactors * Sims);
        cout << "Acceptance Rate " << acceptance_rate << endl;
        std::system("mkdir -p mllogfiles");
        string date = dateString();
        string version = "integrate_likelihood_";
        string ext = ".txt";
        string path = "mllogfiles/";
        fname = path + version + date + ext;
        std::ofstream file;
        file.open(fname);
        if (file.is_open())
        {
            storePosterior(path + version + date + "_beta.csv", BetaPosteriorDraws);
            storePosterior(path + version + date + "_loadings.csv", LoadingsPosteriorDraws);
            storePosterior(path + version + date + "_gammas.csv", GammasPosteriorDraws);
            storePosterior(path + version + date + "_factors.csv", FactorPosteriorDraws);
            storePosterior(path + version + date + "_factorVariance.csv", FactorVariancePosteriorDraws);
            storePosterior(path + version + date + "_omPrecision.csv", ObsPrecisionPosteriorDraws);
            file << "Integrated Likelihood Version run with: " << Sims << " "
                 << "burnin " << burnin << endl;
            file << "Beta avg" << endl;
            file << mean(BetaPosteriorDraws).transpose() << endl;
            file << "Loadings avg" << endl;
            file << mean(LoadingsPosteriorDraws) << endl;
            file << "Gamma avg" << endl;
            file << mean(GammasPosteriorDraws) << endl;
            file << "Factor Variance" << endl;
            file << mean(FactorVariancePosteriorDraws).transpose() << endl;
            file << "OM Variance" << endl;
            file << (1.0 / mean(ObsPrecisionPosteriorDraws).array()).transpose() << endl;
            file << "Acceptance Rate" << endl;
            file << acceptance_rate << endl;
            file.close();
        }
    }

    VectorXd AStarReducedRun_G(int rr, Optimize optim)
    {

        if (rr > (Sims - burnin))
        {
            throw std::invalid_argument("Error in AStarReducedRun_G. Reduced runs cannot be greater than Sims - burnin - 1.");
        }
        int T = yt.cols();
        int K = yt.rows();
        int nFactors = InfoMat.rows();
        int nrows;
        int d = 0;
        int df = 15;
        int disp_on = 0;
        double lalpha;
        double qg;
        MatrixXd ytdemeaned;
        MatrixXd subytdemeanedstar;
        MatrixXd subytdemeanedg;
        MatrixXd subgammas;
        MatrixXd subFp;
        MatrixXd subFt;
        MatrixXd COM;
        MatrixXd mut;
        MatrixXd subPriorMean;
        MatrixXd subPriorPrecision;
        MatrixXd CovarianceStar;
        MatrixXd Diag;
        MatrixXd Ag;
        MatrixXd Factorg;
        MatrixXd gammag;
        MatrixXd surX = surForm(Xt, K);
        MatrixXd Xbetag;
        MatrixXd Astar = mean(LoadingsPosteriorDraws);
        MatrixXd postCovar;

        VectorXd betag;
        VectorXd obsPrecisiong;
        VectorXd factorVarianceg;
        VectorXd subA;
        VectorXd subfv;
        VectorXd subomPrecision;
        VectorXd MeanStar;
        VectorXd covDiag;
        VectorXd subAstar;
        VectorXd numerator(rr * nFactors);
        VectorXd postMean;
        int start;
        for (int i = 0; i < rr; ++i)
        {
            betag = BetaPosteriorDraws[i];
            Ag = LoadingsPosteriorDraws[i];
            gammag = GammasPosteriorDraws[i];
            obsPrecisiong = ObsPrecisionPosteriorDraws[i];
            factorVarianceg = FactorVariancePosteriorDraws[i];
            Factorg = FactorPosteriorDraws[i];
            Xbetag = surX * betag;
            Xbetag.resize(K, T);

            for (int j = 0; j < nFactors; ++j)
            {
                cout << "Factor level " << j + 1 << endl;
                start = InfoMat.row(j).head(1).value();
                nrows = InfoMat.row(j).tail(1).value() - start + 1;
                COM = zeroOutColumn(Astar, j);
                mut = Xbetag + COM * Factorg;
                ytdemeaned = yt - mut;
                subytdemeanedstar = ytdemeaned.middleRows(start, nrows);

                COM = zeroOutColumn(Ag, j);
                mut = Xbetag + COM * Factorg;
                ytdemeaned = yt - mut;
                subytdemeanedg = ytdemeaned.middleRows(start, nrows);

                subomPrecision = obsPrecisiong.segment(start, nrows);
                subA = Ag.col(j).segment(start, nrows);
                subAstar = Astar.col(j).segment(start, nrows);
                subgammas = gammag.row(j);
                subfv = factorVarianceg.row(j);
                subFp = MakePrecision(subgammas, subfv, T);
                subFt = Factorg.row(j);
                subPriorMean = loadingsPriorMeans[j].transpose();
                subPriorPrecision = loadingsPriorPrecision[j];

                MeanStar = PosteriorMeans[j];
                CovarianceStar = PosteriorCovariances[j];

                auto CLLstar = [&subytdemeanedstar, &subPriorMean, &subPriorPrecision,
                                &subomPrecision, &subFt, &subFp](const VectorXd &x0)
                {
                    return -ConditionalLogLikelihood(x0, subytdemeanedstar, subPriorMean, subPriorPrecision,
                                                     subomPrecision, subFt, subFp);
                };
                auto CLLg = [&subytdemeanedg, &subPriorMean, &subPriorPrecision,
                             &subomPrecision, &subFt, &subFp](const VectorXd &x0)
                {
                    return -ConditionalLogLikelihood(x0, subytdemeanedg, subPriorMean, subPriorPrecision,
                                                     subomPrecision, subFt, subFp);
                };
                optim.BFGS(subA, CLLg, disp_on);
                postMean = optim.x1;
                postCovar = optim.AprroximateDiagHessian(postMean, CLLg);
                postCovar = postCovar.llt().solve(MatrixXd::Identity(nrows, nrows));
                qg = logmvtpdf(subAstar.transpose(), postMean.transpose(), postCovar, df);
                lalpha = -CLLstar(subAstar) + logmvtpdf(subA.transpose(), MeanStar.transpose(), CovarianceStar, df) +
                         CLLg(subA) - qg;
                lalpha = min(0., lalpha);
                numerator(d) = lalpha + qg;
                ++d;
            }
        }
        return numerator;
    }

    VectorXd AStarReducedRun_J(const Ref<const MatrixXd> &Xbetaj,
                               const Ref<const MatrixXd> &gammasj, const Ref<const VectorXd> &obsPrecisionj,
                               const Ref<const VectorXd> &factorVariancej, Optimize &optim)
    {

        int T = yt.cols();
        int nFactors = InfoMat.rows();
        int nrows;
        int df = 15;
        int disp_on = 0;
        double lalpha;
        MatrixXd ytdemeaned;
        MatrixXd subytdemeanedstar;
        MatrixXd subytdemeanedj;
        MatrixXd subgammas;
        MatrixXd subFp;
        MatrixXd subFt;
        MatrixXd COM;
        MatrixXd mut;
        MatrixXd subPriorMean;
        MatrixXd subPriorPrecision;
        MatrixXd CovarianceStar;
        MatrixXd Diag;
        MatrixXd Astar = mean(LoadingsPosteriorDraws);
        MatrixXd postCovar;
        MatrixXd lower;
        MatrixXd jCovar;

        VectorXd subA;
        VectorXd subfv;
        VectorXd subomPrecision;
        VectorXd MeanStar;
        VectorXd covDiag;
        VectorXd subAstar;
        VectorXd denominator;
        VectorXd jmean;
        VectorXd proposalj;

        denominator.setZero(nFactors);
        int start;

        for (int i = 0; i < nFactors; ++i)
        {
            cout << "Factor level " << i + 1 << endl;
            start = InfoMat.row(i).head(1).value();
            nrows = InfoMat.row(i).tail(1).value() - start + 1;
            MeanStar = PosteriorMeans[i].transpose();
            CovarianceStar = PosteriorCovariances[i];
            lower = CovarianceStar.llt().matrixL();
            proposalj = MeanStar + lower * normrnd(0, 1, lower.rows(), 1);
            proposalj(1) = 1;
            Loadings.col(i).segment(start, nrows) = proposalj;

            COM = zeroOutColumn(Astar, i);
            mut = Xbetaj + COM * Factors;
            ytdemeaned = yt - mut;
            subytdemeanedstar = ytdemeaned.middleRows(start, nrows);

            COM = zeroOutColumn(Loadings, i);

            mut = Xbetaj + COM * Factors;
            ytdemeaned = yt - mut;
            subytdemeanedj = ytdemeaned.middleRows(start, nrows);
            subomPrecision = obsPrecisionj.segment(start, nrows);
            subA = Loadings.col(i).segment(start, nrows);
            subAstar = Astar.col(i).segment(start, nrows);
            subgammas = gammasj.row(i);
            subfv = factorVariancej.row(i);
            subFp = MakePrecision(subgammas, subfv, T);
            subFt = Factors.row(i);
            subPriorMean = loadingsPriorMeans[i].transpose();
            subPriorPrecision = loadingsPriorPrecision[i];

            auto CLLstar = [&subytdemeanedstar, &subPriorMean, &subPriorPrecision,
                            &subomPrecision, &subFt, &subFp](const VectorXd &x0)
            {
                return -ConditionalLogLikelihood(x0, subytdemeanedstar, subPriorMean, subPriorPrecision,
                                                 subomPrecision, subFt, subFp);
            };
            auto CLLj = [&subytdemeanedj, &subPriorMean, &subPriorPrecision,
                         &subomPrecision, &subFt, &subFp](const VectorXd &x0)
            {
                return -ConditionalLogLikelihood(x0, subytdemeanedj, subPriorMean, subPriorPrecision,
                                                 subomPrecision, subFt, subFp);
            };
            optim.BFGS(subA, CLLj, disp_on);
            jmean = optim.x1;
            jCovar = optim.AprroximateDiagHessian(optim.x1, CLLj);
            jCovar = jCovar.llt().solve(MatrixXd::Identity(nrows, nrows));
            lalpha = -CLLj(subA) + logmvtpdf(subAstar.transpose(), MeanStar.transpose(), CovarianceStar, df) +
                     CLLstar(subAstar) - logmvtpdf(subA.transpose(), jmean.transpose(), jCovar, df);
            lalpha = min(0., lalpha);
            denominator(i) = lalpha;
            MatrixXd omP = subomPrecision.asDiagonal(); 
            Factors.row(i) = updateFactor(subytdemeanedstar, subAstar, subFp, omP);
        }
        return denominator;
    }

    double ml()
    {
        int rr = Sims - burnin;
        std::vector<VectorXd> BetaRRj;
        std::vector<MatrixXd> FactorRRj;
        std::vector<MatrixXd> gammasRRj;
        std::vector<VectorXd> omPrecisionRRj;
        std::vector<VectorXd> factorVarianceRRj;
        BetaRRj.resize(rr);
        FactorRRj.resize(rr);
        gammasRRj.resize(rr);
        omPrecisionRRj.resize(rr);
        factorVarianceRRj.resize(rr);
        int K = yt.rows();
        int T = yt.cols();
        int nFactors = InfoMat.rows();
        double optim_options[5] = {1e-4, 1e-5, 1e-5, 1e-4, 25};
        double parama = .5 * (T + r0);
        double paramb;
        Optimize optim(optim_options);
        MatrixXd FactorStar = mean(FactorPosteriorDraws);
        MatrixXd Astar = mean(LoadingsPosteriorDraws);
        MatrixXd betastar = mean(BetaPosteriorDraws);
        MatrixXd gammastar = mean(GammasPosteriorDraws);
        MatrixXd gammas = gammastar;
        MatrixXd surX = surForm(Xt, K);
        MatrixXd Xbeta = surX * betastar;
        MatrixXd H;
        MatrixXd resids;

        VectorXd Hf;
        VectorXd factorVariancestar = mean(FactorVariancePosteriorDraws);
        MatrixXd FactorPrecision(nFactors * T, nFactors * T);
        VectorXd omPrecisionstar = mean(ObsPrecisionPosteriorDraws);
        VectorXd omPrecision = omPrecisionstar;
        VectorXd omVariance = 1. / omPrecision.array();
        VectorXd factorVariance = factorVariancestar;
        FactorPrecision = MakePrecisionBig(gammas, factorVariance, T);
        MatrixXd Numerator;
        MatrixXd Denominator;
        Denominator.setZero(nFactors, rr);
        Xbeta.resize(K, T);
        setPostMeansAndCovars(Astar, Xbeta, FactorStar, gammastar, omPrecisionstar,
                              factorVariancestar, optim);

        ArParameterTools apt;
        double f2;
        Numerator = AStarReducedRun_G(rr, optim);
        cout << "Loadings Reduced Runs" << endl;
        double posteriorStar = 0;
        for (int j = 0; j < rr; ++j)
        {
            cout << "Loading Reduced Run " << j + 1 << endl;
            betaUpdater(yt, surX, omPrecision, Loadings, FactorPrecision, b0, B0);
            // change this someday to not have factors be mutable, should return as argument
            Denominator.col(j) = AStarReducedRun_J(xbt, gammas, omPrecision, factorVariance, optim);
            for (int i = 0; i < nFactors; ++i)
            {
                f2 = factorVariance(i);
                apt.updateArParameters(Factors.row(i), gammas.row(i), f2, g0, G0);
                gammas.row(i) = apt.phinew;
                H = ReturnH(gammas.row(i), T);
                Hf = H * Factors.row(i).transpose();
                paramb = (.5 * (R0 + Hf.transpose() * Hf));
                factorVariance(i) = igammarnd(parama, 1.0 / paramb);
            }

            resids = yt - (Astar * Factors) - xbt;
            for (int i = 0; i < K; ++i)
            {
                paramb = 0.5 * (R0 + (resids.row(i) * resids.row(i).transpose()));
                omVariance(i) = igammarnd(parama, 1.0 / paramb);
            }
            omPrecision = omVariance.array().pow(-1.0);
            FactorPrecision = MakePrecisionBig(gammas, factorVariance, T);
            BetaRRj[j] = betanew;
            FactorRRj[j] = Factors;
            gammasRRj[j] = gammas;
            omPrecisionRRj[j] = omPrecision;
            factorVarianceRRj[j] = factorVariance;
        }
        Numerator.resize(nFactors, rr);
        posteriorStar += logavg(Numerator, 0).sum() - logavg(Denominator, 0).sum();

        /* Beta Reduced Run */
        betastar = mean(BetaRRj);
        setXbeta(surX, betastar, K, T);
        VectorXd pibeta;
        pibeta.setZero(rr);
        gammastar = mean(gammasRRj);
        factorVariancestar = mean(factorVarianceRRj);
        FactorPrecision = MakePrecisionBig(gammastar, factorVariance, T);
        MatrixXd ytdemeaned;
        MatrixXd subytdemeaned;
        MatrixXd subgammas;
        MatrixXd subFp;
        MatrixXd COM;
        MatrixXd mut;
        VectorXd subA;
        VectorXd subfv;
        VectorXd subomPrecision;

        int nrows;
        int n;
        int start;
        cout << "Beta Reduced Run " << endl;
        for (int j = 0; j < rr; ++j)
        {
            omPrecision = omPrecisionRRj[j];
            pibeta(j) = betapdf(betastar.transpose(), yt, surX, omPrecision, Astar, FactorPrecision, b0, B0);
            factorVariance = factorVarianceRRj[j];
            gammas = gammasRRj[j];
            n = 0;
            cout << "RR = " << j + 1 << endl;

            for (int n = 0; n < nFactors; ++n)
            {
                start = InfoMat.row(n).head(1).value();
                nrows = InfoMat.row(n).tail(1).value() - start + 1;
                COM = zeroOutColumn(Astar, n);
                mut = xbt + COM * Factors;
                ytdemeaned = yt - mut;
                subA = Astar.col(n).segment(start, nrows);
                subgammas = gammas.row(n);
                subfv = factorVariance.row(n);
                subFp = MakePrecision(subgammas, subfv, T);
                subytdemeaned = ytdemeaned.middleRows(start, nrows);
                MatrixXd omP = omPrecisionstar.segment(start, nrows).asDiagonal();
                Factors.row(n) = updateFactor(subytdemeaned, subA, subFp, omP);
                f2 = factorVariance(n);
                apt.updateArParameters(Factors.row(n), gammas.row(n), f2, g0, G0);
                gammas.row(n) = apt.phinew;
                H = ReturnH(gammas.row(n), T);
                Hf = H * Factors.row(n).transpose();
                paramb = (.5 * (R0 + Hf.transpose() * Hf));
                factorVariance(n) = igammarnd(parama, 1.0 / paramb);
            }

            resids = yt - (Astar * Factors) - xbt;
            for (int k = 0; k < K; ++k)
            {
                paramb = 0.5 * (R0 + (resids.row(k) * resids.row(k).transpose()));
                omVariance(k) = igammarnd(parama, 1.0 / paramb);
            }
            omPrecision = omVariance.array().pow(-1.0);
            FactorPrecision = MakePrecisionBig(gammasRRj[j], factorVarianceRRj[j], T);

            FactorRRj[j] = Factors;
            gammasRRj[j] = gammas;
            omPrecisionRRj[j] = omPrecision;
            factorVarianceRRj[j] = factorVariance;
        }
        posteriorStar += logavg(pibeta);

        gammastar = mean(gammasRRj);
        Numerator.resize(nFactors, rr);
        Denominator.resize(nFactors, rr);
        MatrixXd residuals(K, T);
        int d = 0;
        cout << "Gamma Reduced Run" << endl;
        for (int j = 0; j < rr; ++j)
        {
            cout << "RR = " << j + 1 << endl;
            Factors = FactorRRj[j];
            gammas = gammasRRj[j];
            omPrecision = omPrecisionRRj[j];
            factorVariance = factorVarianceRRj[j];
            for (int n = 0; n < nFactors; ++n)
            {
                Numerator(d) = apt.alphag(Factors.row(n), gammas.row(n), gammastar.row(n), f2, g0, G0);
                start = InfoMat.row(n).head(1).value();
                nrows = InfoMat.row(n).tail(1).value() - start + 1;
                COM = zeroOutColumn(Astar, n);
                mut = xbt + COM * Factors;
                ytdemeaned = yt - mut;
                subA = Astar.col(n).segment(start, nrows);
                subgammas = gammastar.row(n);
                subfv = factorVariance.row(n);
                subFp = MakePrecision(subgammas, subfv, T);
                subytdemeaned = ytdemeaned.middleRows(start, nrows);
                MatrixXd omP = omPrecisionstar.segment(start, nrows).asDiagonal();
                Factors.row(n) = updateFactor(subytdemeaned, subA, subFp, omP);
                Denominator(n, j) = apt.alphaj(gammastar.row(n), Factors.row(n), f2, g0, G0);
            }
            resids = yt - (Astar * Factors) - xbt;
            for (int k = 0; k < K; ++k)
            {
                paramb = 0.5 * (R0 + (resids.row(k) * resids.row(k).transpose()));
                omVariance(k) = igammarnd(parama, 1.0 / paramb);
            }
            omPrecision = omVariance.array().pow(-1.0);
            FactorPrecision = MakePrecisionBig(gammastar, factorVarianceRRj[j], T);
            FactorRRj[j] = Factors;
            omPrecisionRRj[j] = omPrecision;
            factorVarianceRRj[j] = factorVariance;
        }

        posteriorStar += logavg(Numerator, 0).sum() - logavg(Denominator, 0).sum();
        omPrecisionstar = mean(omPrecisionRRj);
        MatrixXd piOmPrecision(K, rr);
        d = 0;
        cout << "Om Precision Reduced Run" << endl;
        FactorPrecision = MakePrecision(gammastar, factorVariancestar, T);
        for (int j = 0; j < rr; ++j)
        {
            cout << "RR = " << j + 1 << endl;
            n = 0;
            for (int n = 0; n < nFactors; ++n)
            {
                start = InfoMat.row(n).head(1).value();
                nrows = InfoMat.row(n).tail(1).value() - start + 1;
                COM = zeroOutColumn(Astar, n);
                mut = xbt + COM * Factors;
                ytdemeaned = yt - mut;
                subA = Astar.col(n).segment(start, nrows);
                subgammas = gammastar.row(n);
                subfv = factorVariance.row(n);
                subFp = MakePrecision(subgammas, subfv, T);
                subytdemeaned = ytdemeaned.middleRows(start, nrows);
                MatrixXd omP = omPrecisionstar.segment(start, nrows).asDiagonal();
                Factors.row(n) = updateFactor(subytdemeaned, subA, subFp, omP);
                H = ReturnH(gammastar.row(n), T);
                Hf = H * Factors.row(n).transpose();
                paramb = (.5 * (R0 + Hf.transpose() * Hf));
                factorVariance(n) = igammarnd(parama, 1.0 / paramb);
            }
            resids = yt - (Astar * Factors) - xbt;

            for (int k = 0; k < K; ++k)
            {
                paramb = 0.5 * (R0 + (resids.row(k) * resids.row(k).transpose()));
                piOmPrecision(k, j) = loginvgammapdf(1.0 / omPrecisionstar(k), parama, paramb);
            }

            FactorRRj[j] = Factors;
            factorVarianceRRj[j] = factorVariance;
        }
        piOmPrecision.resize(K, rr);
        posteriorStar += logavg(piOmPrecision, 0).sum();

        factorVariancestar = mean(factorVarianceRRj);
        MatrixXd pifactorVariancestar(nFactors, rr);
        cout << "Factor Variance Reduced Run" << endl;
        for (int j = 0; j < rr; ++j)
        {
            cout << "RR = " << j + 1 << endl;

            n = 0;
            for (int n = 0; n < nFactors; ++n)
            {
                start = InfoMat.row(n).head(1).value();
                nrows = InfoMat.row(n).tail(1).value() - start + 1;
                COM = zeroOutColumn(Astar, n);
                mut = xbt + COM * Factors;
                ytdemeaned = yt - mut;
                subA = Astar.col(n).segment(start, nrows);
                subgammas = gammastar.row(n);
                subfv = factorVariancestar.row(n);
                subFp = MakePrecision(subgammas, subfv, T);
                subytdemeaned = ytdemeaned.middleRows(start, nrows);
                MatrixXd omP = omPrecisionstar.segment(start, nrows).asDiagonal();
                Factors.row(n) = updateFactor(subytdemeaned, subA, subFp, omP);
                H = ReturnH(gammastar.row(n), T);
                Hf = H * Factors.row(n).transpose();
                paramb = (.5 * (R0 + Hf.transpose() * Hf));
                pifactorVariancestar(n, j) = loginvgammapdf(factorVariancestar(n), parama, paramb);
            }
            resids = yt - (Astar * Factors) - xbt;
            FactorRRj[j] = Factors;
        }
        posteriorStar += logavg(pifactorVariancestar, 0).sum();
        RowVectorXd Z1 = RowVectorXd::Zero(T);
        MatrixXd Covar(T, T);
        VectorXd priorFactorStar(nFactors);
        MatrixXd P(T, T);
        MatrixXd IT = MatrixXd::Identity(T, T);
        RowVectorXd factorMean;
        VectorXd posteriorFactorStar(nFactors);
        FactorStar = mean(FactorRRj);
        for (int n = 0; n < nFactors; ++n)
        {
            start = InfoMat.row(n).head(1).value();
            nrows = InfoMat.row(n).tail(1).value() - start + 1;
            COM = zeroOutColumn(Astar, n);
            mut = xbt + COM * FactorStar;
            ytdemeaned = yt - mut;
            subA = Astar.col(n).segment(start, nrows);
            subgammas = gammastar.row(n);
            subfv = factorVariancestar.row(n);
            subFp = MakePrecision(subgammas, subfv, T);
            subytdemeaned = ytdemeaned.middleRows(start, nrows);
            subomPrecision = omPrecisionstar.segment(start, nrows);
            Covar = subFp.llt().solve(IT);
            priorFactorStar(n) = logmvnpdf(FactorStar.row(n), Z1, Covar);
            P = subFp + (subA.transpose() * subomPrecision.asDiagonal() * subA) * IT;
            P = P.llt().solve(IT);
            posteriorFactorStar(n) = logmvnpdf(FactorStar.row(n), FactorStar.row(n), P);
        }

        resids.resize(K, T);
        FactorStar.resize(nFactors, T);
        resids = yt - xbt - Astar * FactorStar;
        VectorXd omVariancestar = omPrecisionstar.array().pow(-1);
        VectorXd likelihood(K);
        RowVectorXd Z2 = RowVectorXd::Zero(T);
        for (int k = 0; k < K; ++k)
        {
            likelihood(k) = logmvnpdf(resids.row(k), Z2, omVariancestar(k) * IT);
        }
        cout << "likelihood" << endl;
        cout << likelihood << endl;
        cout << "priorFactorStar" << endl;
        cout << priorFactorStar << endl;
        cout << "posteriorFactorStar" << endl;
        cout << posteriorFactorStar << endl;
        double conditionalOfFactors = likelihood.sum() + priorFactorStar.sum() - posteriorFactorStar.sum();
        double priorbeta = logmvnpdf(betastar.transpose(), b0, B0);
        VectorXd priorA(nFactors);
        VectorXd priorGammas(nFactors);
        VectorXd priorfactorVariances(nFactors);
        VectorXd priorOmVariances(K);
        RowVectorXd subPriorMean;
        MatrixXd subPriorPrecision;
        for (int n = 0; n < nFactors; ++n)
        {
            start = InfoMat.row(n).head(1).value();
            nrows = InfoMat.row(n).tail(1).value() - start + 1;
            COM = zeroOutColumn(Astar, n);
            mut = xbt + COM * Factors;
            ytdemeaned = yt - mut;
            subA = Astar.col(n).segment(start, nrows);
            subgammas = gammas.row(n);
            subfv = factorVariance.row(n);
            subFp = MakePrecision(subgammas, subfv, T);
            subytdemeaned = ytdemeaned.middleRows(start, nrows);
            subomPrecision = omPrecision.segment(start, nrows);
            subPriorMean = loadingsPriorMeans[n].transpose();
            subPriorPrecision = loadingsPriorPrecision[n];
            subPriorPrecision.llt().solve(MatrixXd::Identity(subPriorPrecision.rows(),
                                                             subPriorPrecision.rows()));
            priorfactorVariances(n) = loginvgammapdf(factorVariancestar(n), .5 * r0, (.5 * R0));
            priorA(n) = logmvnpdf(subA.transpose(), subPriorMean, subPriorPrecision);
            priorGammas(n) = logmvnpdf(gammastar.row(n), g0, G0);
        }
        resids.resize(K, T);
        n = 0;
        for (int k = 0; k < K; ++k)
        {
            priorOmVariances(n) = loginvgammapdf(1.0 / omPrecisionstar(k), .5 * r0, (.5 * R0));
            ++n;
        }
        double priorSum = priorbeta + priorA.sum() + priorGammas.sum() + priorfactorVariances.sum() +
                          priorOmVariances.sum();
        cout << "priorSum" << endl;
        cout << priorSum << endl;
        cout << "posteriorStar" << endl;
        cout << posteriorStar << endl;

        marginal_likelihood = conditionalOfFactors + priorSum - posteriorStar;
        cout << "Marginal Likelihood " << marginal_likelihood << endl;
        std::ofstream file(fname, ios_base::app | ios_base::out);
        if (file.is_open())
        {
            file << "Marginal Likelihood: " << marginal_likelihood << endl;
        }

        return marginal_likelihood;
    }

    void storePosterior(string fname, std::vector<MatrixXd> &M)
    {
        const static Eigen::IOFormat CSVFormat(Eigen::StreamPrecision, Eigen::DontAlignCols, ", ", "\n");
        int size = M.size();
        ofstream file(fname.c_str());
        if (file.is_open())
        {
            for (int i = 0; i < size; ++i)
            {
                file << M[i].format(CSVFormat) << endl;
            }
        }
    }

    void storePosterior(string fname, std::vector<VectorXd> &M)
    {
        const static Eigen::IOFormat CSVFormat(Eigen::StreamPrecision, Eigen::DontAlignCols, ", ", "\n");
        int size = M.size();
        ofstream file(fname.c_str());
        if (file.is_open())
        {
            for (int i = 0; i < size; ++i)
            {
                file << M[i].format(CSVFormat) << endl;
            }
        }
    }
};

#endif