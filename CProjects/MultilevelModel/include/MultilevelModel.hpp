#pragma once
#ifndef ML_H
#define ML_H

#include <iostream>
#include <stdexcept>
#include <map>
#include <string>
#include <math.h>

#include <Eigen/Dense>
#include <eigen-3.3.9/unsupported/Eigen/KroneckerProduct>

#include "Distributions.hpp"
#include "Optimization.hpp"
#include "MultilevelModelFunctions.hpp"
#include "AutoregressiveModel.hpp"

template <typename D>
VectorXd updateVariance(const MatrixBase<D> &residuals, int v0, int D0)
{
    double parama = .5 * (residuals.cols() + v0);
    VectorXd paramb = .5 * (D0 + residuals.array().pow(2).rowwise().sum());
    paramb = 1. / paramb.array();
    return igammarnd(parama, paramb);
}

class UpdateBeta
{
public:
    VectorXd betamean; // Mean update
    MatrixXd B;        // Covariance Matrix update
    MatrixXd betanew;  // beta update
    MatrixXd xbt;      // X*beta update

    template <typename D1, typename D2, typename D3, typename D4, typename D5,
              typename D6, typename D7>
    void betaupdate(const MatrixBase<D1> &yt, const MatrixBase<D2> &surX,
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

        MatrixXd XzzPinv = (FactorPrecision + kroneckerProduct(It, AtO * A)).ldlt().solve(InFactorsT);

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

        B = B.ldlt().solve(MatrixXd::Identity(KP, KP));
        betamean = B * (B0inv * b0.transpose() + xpy - (XzzPinv * yzz));

        betanew = betamean + (B.llt().matrixL() * normrnd(0, 1, KP, 1));
        xbt = surX * betanew;
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

        MatrixXd XzzPinv = (FactorPrecision + kroneckerProduct(It, AtO * A)).ldlt().solve(InFactorsT);

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

        B = B.ldlt().solve(MatrixXd::Identity(KP, KP));
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
    void setXbeta(const MatrixBase<T1> &betastar, const MatrixBase<T2> &surX, const int &K, const int &T)
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

class LoadingsFactorUpdate
{
public:
    MatrixXd Factors;
    MatrixXd Loadings;
    double acceptance_rate;

    LoadingsFactorUpdate()
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
                     MatrixXd &Identity, double restriction)
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
        int nFactors = InfoMat.rows();
        int nrows;
        int c = 0;
        int df = 15;
        int disp_on = 1;
        double lalpha;
        double tau = 100;
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
            COM = zeroOutFactorLevel(Loadings, i);
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
            covDiag = optim.AprroximateDiagHessian(optim.x1, CLL, optim.fval1);
            Diag = covDiag.diagonal();
            Diag = Diag.array().pow(-1);
            proposalCovariance = Diag.asDiagonal();

            lower = proposalCovariance.llt().matrixL();

            proposal = proposalMean + lower * normrnd(0, 1, lower.rows(), 1);
            lalpha = -CLL(proposal) + logmvtpdf(subA.transpose(), proposalMean.transpose(), proposalCovariance, df) +
                     CLL(subA) - logmvtpdf(proposal.transpose(), proposalMean.transpose(), proposalCovariance, df);
            lalpha = min(0., lalpha);
            // cout << lalpha << endl;
            // cout << proposal << endl;
            // cout <<    CLL(proposal) << endl;
            // cout <<    logmvtpdf(subA.transpose(), proposalMean.transpose(), proposalCovariance, df) << endl;
            // cout << CLL(subA) << endl;
            // cout << logmvtpdf(proposal.transpose(), proposalMean.transpose(), proposalCovariance, df) << endl;
            if (isnan(lalpha))
            {
                throw std::domain_error("Error in update factor MH step.");
            }
            if (log(unifrnd(0, 1)) < lalpha)
            {
                acceptance_rate += 1;
                subA = proposal;
                subA(0) = 1;
                Loadings.col(i).segment(start, nrows) = subA;
            }
            Factors.row(c) = updateFactor(subytdemeaned, subA, subFp, subomPrecision, T);
        }
    }
};

class MultilevelModel : public UpdateBeta, public LoadingsFactorUpdate, public LoadingsPriorsSetup

{
public:
    std::vector<MatrixXd> LoadingsPosteriorDraws;
    std::vector<VectorXd> BetaPosteriorDraws;
    std::vector<MatrixXd> FactorPosteriorDraws;
    std::vector<MatrixXd> GammasPosteriorDraws;
    std::vector<VectorXd> ObsPrecisionPosteriorDraws;
    std::vector<VectorXd> FactorVariancePosteriorDraws;
    std::vector<VectorXd> PosteriorMeans;
    std::vector<MatrixXd> PosteriorCovariances;

    MatrixXd yt;
    MatrixXd Xt;
    MatrixXd gammas;
    MatrixXd deltas;
    RowVectorXd b0;
    MatrixXd B0;
    double r0;
    double R0;
    double marginal_likelihood;
    RowVectorXd g0;
    MatrixXd G0;
    MatrixXi InfoMat;
    MatrixXd Identity;
    int Sims;
    int burnin;
    int arOrderOm; 

    void setIntLikeModel(const Ref<const MatrixXd> &yt, const Ref<const MatrixXd> &Xt, const Ref<const MatrixXd> &A,
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
        setLoadings(A, InfoMat, Identity, 1.);
        setPriors(a0, A0, InfoMat);
    }

    void setFullCondModel(const Ref<const MatrixXd> &yt, const Ref<const MatrixXd> &Xt,
                          const Ref<const MatrixXd> &Ft, const Ref<const MatrixXd> &gammas, const Ref<const MatrixXd> &deltas,
                          const Matrix<int, Dynamic, 2> &InfoMat,
                          const RowVectorXd &b0, const MatrixXd &B0, const double &r0,
                          const double &R0, const Ref<const RowVectorXd> &g0, const Ref<const MatrixXd> &G0)
    {
        if ((gammas.rows() > Ft.rows()) || (gammas.rows() < Ft.rows()))
        {
            dim(gammas);
            dim(Ft);
            throw invalid_argument("Error in set model, gammas not correct dim.");
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
        this->Identity = MakeObsModelIdentity(InfoMat, yt.rows());
        setFactors(Ft);
        this->arOrderOm = deltas.cols();
    }

    void fullConditionals(int Sims)
    {
        // Assumes there are Xs in the estimation
        if (arOrderOm + 1 >= yt.cols())

        {
            throw invalid_argument("T must be greater than lags of Om model.");
        }
        cout << arOrderOm << endl;
        int arOrderFac = 3;
        int K = yt.rows();
        int T = yt.cols();
        int nFactors = InfoMat.cols();
        MatrixXd Q;
        MatrixXd XrightCols;
        MatrixXd Xtfull(Xt.rows(), Xt.cols() + nFactors);
        Xtfull.leftCols(Xt.cols()) = Xt;
        Xtfull.rightCols(nFactors) = makeOtrokXt(InfoMat, Factors, Xt.cols(), K);

        betanew = MatrixXd::Ones(Xtfull.cols(), K);
        // MatrixXd Xbeta = Xtfull * betanew;
        // Xbeta.resize(K, T);
        VectorXd omPrecision = VectorXd::Ones(K);
        VectorXd omVariance = 1. / omPrecision.array();
        MatrixXd P0;
        MatrixXd P0lower;
        MatrixXd P0lowerinv;
        double s2;
        MatrixXd y1;
        MatrixXd ytemp(1, T - arOrderOm);
        MatrixXd y1star;
        MatrixXd x1star;
        MatrixXd x1;
        ArrayXi indices = sequence(0, K * T, K);
        ArrayXi all = sequence(0, K * T);
        ArrayXi indexshift;
        std::vector<MatrixXd> Xtk;
        Xtk.resize(K);
        MatrixXd Xtemp;
        Xtemp.setZero(T, Xtfull.cols());
        for (int k = 0; k < K; ++k)
        {
            indexshift = indices + k;
            for (int t = 0; t < T; ++t)
            {
                Xtemp.row(t) = Xtfull.row(indexshift(t));
            }
            Xtk[k] = Xtemp;
        }
        cout << yt << endl;
        cout << endl;
        for (int i = 0; i < Sims; ++i)
        {
            for (int k = 0; k < K; ++k)
            {
                cout << deltas.row(k) * lag(yt.row(k), arOrderOm) << endl;
                cout << endl;
                s2 = omVariance(k);
                P0 = setCovar(deltas.row(k), s2);
                P0 = omPrecision(k) * P0.array();
                P0lower = P0.llt().matrixL();
                y1 = yt.row(k).leftCols(arOrderOm);

                x1 = Xtk[k].topRows(arOrderOm);
                y1star = P0lower.ldlt().solve(y1.transpose());
                x1star = P0lower.ldlt().solve(x1);
            }
        }
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
        int N = LoadingsPosteriorDraws.size();

        int nrows;
        int start;
        int c = 0;
        for (int i = 0; i < nFactors; ++i)
        {
            nrows = InfoMat.row(i).tail(1).value() - InfoMat.row(i).head(1).value() + 1;
            start = InfoMat.row(i).head(1).value();
            COM = zeroOutFactorLevel(A, c);
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
            postCovar = optim.AprroximateDiagHessian(optim.x1, CLL, optim.fval1);
            postCovar = postCovar.ldlt().solve(MatrixXd::Identity(nrows, nrows));
            PosteriorMeans[i] = subA.transpose();
            PosteriorCovariances[i] = postCovar;
        }
    }

    void integratedLikelihood(int Sims, int burnin)
    {
        this->Sims = Sims;
        this->burnin = burnin;
        int T = yt.cols();
        int K = yt.rows();
        int nFactors = InfoMat.rows();

        VectorXd omVariance = VectorXd::Ones(K);
        VectorXd omPrecision = 0.5 * omVariance.array().pow(-1);
        VectorXd factorVariance = VectorXd::Ones(nFactors);

        MatrixXd surX = surForm(Xt, K);

        betanew = .5 * VectorXd::Ones(surX.cols());
        MatrixXd xbt = surX * betanew;
        xbt.resize(K, T);

        MatrixXd FactorPrecision = MakePrecision(gammas, factorVariance, T);
        MatrixXd resids;
        MatrixXd H;
        VectorXd Hf;

        double optim_options[5] = {1e-4, 1e-4, 1e-4, 1e-4, 5};
        double parama = .5 * (r0 + T);
        double paramb;
        Optimize optim(optim_options);
        int stationarySims = Sims - (burnin);

        LoadingsPosteriorDraws.resize(stationarySims);
        BetaPosteriorDraws.resize(stationarySims);
        FactorPosteriorDraws.resize(stationarySims);
        GammasPosteriorDraws.resize(stationarySims);
        ObsPrecisionPosteriorDraws.resize(stationarySims);
        FactorVariancePosteriorDraws.resize(stationarySims);

        for (int i = 0; i < Sims; ++i)
        {

            cout << "Sim " << i + 1 << endl;

            betaupdate(yt, surX, omPrecision, Loadings, FactorPrecision, b0, B0);

            updateLoadingsFactors(yt, xbt, gammas, omPrecision,
                                  factorVariance, InfoMat, loadingsPriorMeans,
                                  loadingsPriorPrecision, optim);

            for (int j = 0; j < nFactors; ++j)
            {
                gammas.row(j) = updateAR(gammas.row(j), Factors.row(j), factorVariance(j), g0, G0);
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

            FactorPrecision = MakePrecision(gammas, factorVariance, T);

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
    }

    VectorXd AStarReducedRun_G(int rr, Optimize optim)
    {

        if (rr > (Sims - burnin))
        {
            throw std::invalid_argument("Error in AStarReducedRun_G. N reduced runs cannot be greater than Sims - burnin - 1.");
        }
        int T = yt.cols();
        int K = yt.rows();
        int nFactors = InfoMat.rows();
        int nrows;
        int c;
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
            c = 0;

            for (int j = 0; j < nFactors; ++j)
            {
                cout << "Factor level " << j + 1 << endl;
                start = InfoMat.row(j).head(1).value();
                nrows = InfoMat.row(j).tail(1).value() - start + 1;
                COM = zeroOutFactorLevel(Astar, j);
                mut = Xbetag + COM * Factorg;
                ytdemeaned = yt - mut;
                subytdemeanedstar = ytdemeaned.middleRows(start, nrows);

                COM = zeroOutFactorLevel(Ag, j);
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
                postCovar = optim.AprroximateDiagHessian(optim.x1, CLLg, optim.fval1);
                postCovar = postCovar.ldlt().solve(MatrixXd::Identity(nrows, nrows));
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
        int K = yt.rows();
        int nFactors = InfoMat.rows();
        int nrows;
        int c = 0;
        int d = 0;
        int df = 15;
        int disp_on = 0;
        double lalpha;
        double qg;
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
            cout << "Factor level " << c + 1 << endl;
            start = InfoMat.row(i).head(1).value();
            nrows = InfoMat.row(i).tail(1).value() - start + 1;
            MeanStar = PosteriorMeans[i].transpose();
            CovarianceStar = PosteriorCovariances[i];
            lower = CovarianceStar.llt().matrixL();
            proposalj = MeanStar + lower * normrnd(0, 1, lower.rows(), 1);
            proposalj(1) = 1;
            Loadings.col(i).segment(start, nrows) = proposalj;

            COM = zeroOutFactorLevel(Astar, c);
            mut = Xbetaj + COM * Factors;
            ytdemeaned = yt - mut;
            subytdemeanedstar = ytdemeaned.middleRows(start, nrows);

            COM = zeroOutFactorLevel(Loadings, c);

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
            jCovar = optim.AprroximateDiagHessian(optim.x1, CLLj, optim.fval1);
            jCovar = jCovar.ldlt().solve(MatrixXd::Identity(nrows, nrows));
            lalpha = -CLLj(subA) + logmvtpdf(subAstar.transpose(), MeanStar.transpose(), CovarianceStar, df) +
                     CLLstar(subAstar) - logmvtpdf(subA.transpose(), jmean.transpose(), jCovar, df);
            lalpha = min(0., lalpha);
            denominator(i) = lalpha;

            Factors.row(i) = updateFactor(subytdemeanedstar, subAstar, subFp, subomPrecision, T);
        }
        return denominator;
    }

    double ml(int rr)
    {
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
        MatrixXd FactorPrecision = MakePrecision(gammastar, factorVariancestar, T);

        VectorXd omPrecisionstar = mean(ObsPrecisionPosteriorDraws);
        VectorXd omPrecision = omPrecisionstar;
        VectorXd omVariance = 1. / omPrecision.array();
        VectorXd factorVariance = factorVariancestar;
        VectorXd Numerator;
        MatrixXd Denominator;
        Denominator.setZero(nFactors, rr);
        Xbeta.resize(K, T);
        setPostMeansAndCovars(Astar, Xbeta, FactorStar, gammastar, omPrecisionstar,
                              factorVariancestar, optim);
        /* Loadings Reduced Run */
        Numerator = AStarReducedRun_G(rr, optim);
        double posteriorStar = 0;
        for (int j = 0; j < rr; ++j)
        {
            cout << "Loading Reduced Run " << j + 1 << endl;
            betaupdate(yt, surX, omPrecision, Loadings, FactorPrecision, b0, B0);
            Denominator.col(j) = AStarReducedRun_J(xbt, gammas, omPrecision, factorVariance, optim);

            for (int i = 0; i < nFactors; ++i)
            {
                gammas.row(i) = updateAR(gammas.row(i), Factors.row(i), factorVariance(i), g0, G0);
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

            FactorPrecision = MakePrecision(gammas, factorVariance, T);

            BetaRRj[j] = betanew;
            FactorRRj[j] = Factors;
            gammasRRj[j] = gammas;
            omPrecisionRRj[j] = omPrecision;
            factorVarianceRRj[j] = factorVariance;
        }
        Denominator.resize(nFactors * rr, 1);
        posteriorStar = logavg(Numerator) - logavg(Denominator);

        /* Beta Reduced Run */
        betastar = mean(BetaRRj);
        setXbeta(betastar, surX, K, T);
        VectorXd pibeta;
        pibeta.setZero(rr);
        gammastar = mean(gammasRRj);
        factorVariancestar = mean(factorVarianceRRj);
        FactorPrecision = MakePrecision(gammastar, factorVariancestar, T);
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
        for (int j = 0; j < rr; ++j)
        {
            cout << "Beta Reduced Run " << j + 1 << endl;
            omPrecision = omPrecisionRRj[j];
            pibeta(j) = betapdf(betastar.transpose(), yt, surX, omPrecision, Astar, FactorPrecision, b0, B0);
            factorVariance = factorVarianceRRj[j];
            gammas = gammasRRj[j];
            n = 0;
            for (int i = 0; i < nFactors; ++i)
            {
                start = InfoMat.row(i).head(1).value();
                nrows = InfoMat.row(i).tail(1).value() - start + 1;
                COM = zeroOutFactorLevel(Astar, n);
                mut = xbt + COM * Factors;
                ytdemeaned = yt - mut;
                subA = Astar.col(i).segment(start, nrows);
                subgammas = gammas.row(i);
                subfv = factorVariance.row(i);
                subFp = MakePrecision(subgammas, subfv, T);
                subytdemeaned = ytdemeaned.middleRows(start, nrows);
                subomPrecision = omPrecision.segment(start, nrows);
                Factors.row(i) = updateFactor(subytdemeaned, subA, subFp, subomPrecision, T);
                gammas.row(i) = updateAR(gammas.row(i), Factors.row(i), factorVariance(n), g0, G0);
                H = ReturnH(gammas.row(i), T);
                Hf = H * Factors.row(i).transpose();
                paramb = (.5 * (R0 + Hf.transpose() * Hf));
                factorVariance(n) = igammarnd(parama, 1.0 / paramb);
            }

            resids = yt - (Astar * Factors) - xbt;
            for (int i = 0; i < K; ++i)
            {
                paramb = 0.5 * (R0 + (resids.row(i) * resids.row(i).transpose()));
                omVariance(i) = igammarnd(parama, 1.0 / paramb);
            }
            omPrecision = omVariance.array().pow(-1.0);

            FactorPrecision = MakePrecision(gammasRRj[j], factorVarianceRRj[j], T);

            FactorRRj[j] = Factors;
            gammasRRj[j] = gammas;
            omPrecisionRRj[j] = omPrecision;
            factorVarianceRRj[j] = factorVariance;
        }
        posteriorStar += logavg(pibeta);

        /* Gamma Reduced Run */
        gammastar = mean(gammasRRj);
        Numerator = gamma_G(rr, gammastar, gammasRRj, FactorRRj, factorVarianceRRj, g0, G0);
        int d = 0;
        for (int j = 0; j < rr; ++j)
        {
            cout << "Gamma Reduced Run " << j + 1 << endl;
            omPrecision = omPrecisionRRj[j];
            factorVariance = factorVarianceRRj[j];
            n = 0;
            for (int i = 0; i < nFactors; ++i)
            {
                start = InfoMat.row(i).head(1).value();
                nrows = InfoMat.row(i).tail(1).value() - start + 1;
                COM = zeroOutFactorLevel(Astar, i);
                mut = xbt + COM * Factors;
                ytdemeaned = yt - mut;
                subA = Astar.col(i).segment(start, nrows);
                subgammas = gammastar.row(i);
                subfv = factorVariance.row(i);
                subFp = MakePrecision(subgammas, subfv, T);
                subytdemeaned = ytdemeaned.middleRows(start, nrows);
                subomPrecision = omPrecision.segment(start, nrows);
                Factors.row(i) = updateFactor(subytdemeaned, subA, subFp, subomPrecision, T);
                Denominator(d) = gamma_J(gammastar.row(i), Factors.row(i), factorVariance(i), g0, G0);
                H = ReturnH(gammastar.row(i), T);
                Hf = H * Factors.row(i).transpose();
                paramb = (.5 * (R0 + Hf.transpose() * Hf));
                factorVariance(i) = igammarnd(parama, 1.0 / paramb);
                ++d;
            }

            resids = yt - (Astar * Factors) - xbt;
            for (int i = 0; i < K; ++i)
            {
                paramb = 0.5 * (R0 + (resids.row(i) * resids.row(i).transpose()));
                omVariance(i) = igammarnd(parama, 1.0 / paramb);
            }
            omPrecision = omVariance.array().pow(-1.0);

            FactorPrecision = MakePrecision(gammastar, factorVarianceRRj[j], T);

            FactorRRj[j] = Factors;
            omPrecisionRRj[j] = omPrecision;
            factorVarianceRRj[j] = factorVariance;
        }
        posteriorStar += logavg(Numerator) - logavg(Denominator);

        /* Om Precision Reduced Run */
        omPrecisionstar = mean(omPrecisionRRj);
        VectorXd piOmPrecision(rr * K);
        d = 0;
        for (int j = 0; j < rr; ++j)
        {
            cout << "Om Precision Reduced Run " << j + 1 << endl;
            n = 0;
            for (int i = 0; i < nFactors; ++i)
            {
                start = InfoMat.row(i).head(1).value();
                nrows = InfoMat.row(i).tail(1).value() - start + 1;
                COM = zeroOutFactorLevel(Astar, i);
                mut = xbt + COM * Factors;
                ytdemeaned = yt - mut;
                subA = Astar.col(i).segment(start, nrows);
                subgammas = gammastar.row(i);
                subfv = factorVariance.row(i);
                subFp = MakePrecision(subgammas, subfv, T);
                subytdemeaned = ytdemeaned.middleRows(start, nrows);
                subomPrecision = omPrecisionstar.segment(start, nrows);
                Factors.row(i) = updateFactor(subytdemeaned, subA, subFp, subomPrecision, T);
                H = ReturnH(gammastar.row(i), T);
                Hf = H * Factors.row(i).transpose();
                paramb = (.5 * (R0 + Hf.transpose() * Hf));
                factorVariance(i) = igammarnd(parama, 1.0 / paramb);
            }

            resids = yt - (Astar * Factors) - xbt;

            for (int i = 0; i < K; ++i)
            {
                paramb = 0.5 * (R0 + (resids.row(i) * resids.row(i).transpose()));
                piOmPrecision(d) = loginvgammapdf(1.0 / omPrecisionstar(i), parama, 1.0 / paramb);
                ++d;
            }
            FactorPrecision = MakePrecision(gammastar, factorVariancestar, T);

            FactorRRj[j] = Factors;
            factorVarianceRRj[j] = factorVariance;
        }
        posteriorStar += logavg(piOmPrecision);

        /* Factor Variance Reduced Run */
        factorVariancestar = mean(factorVarianceRRj);
        VectorXd pifactorVariancestar(nFactors * rr);
        d = 0;
        for (int j = 0; j < rr; ++j)
        {
            cout << "Factor Variance Reduced Run " << j + 1 << endl;

            n = 0;
            for (int i = 0; i < nFactors; ++i)
            {
                start = InfoMat.row(i).head(1).value();
                nrows = InfoMat.row(i).tail(1).value() - start + 1;
                COM = zeroOutFactorLevel(Astar, i);
                mut = xbt + COM * Factors;
                ytdemeaned = yt - mut;
                subA = Astar.col(n).segment(start, nrows);
                subgammas = gammastar.row(i);
                subfv = factorVariancestar.row(i);
                subFp = MakePrecision(subgammas, subfv, T);
                subytdemeaned = ytdemeaned.middleRows(start, nrows);
                subomPrecision = omPrecisionstar.segment(start, nrows);
                Factors.row(i) = updateFactor(subytdemeaned, subA, subFp, subomPrecision, T);
                H = ReturnH(gammastar.row(i), T);
                Hf = H * Factors.row(n).transpose();
                paramb = (.5 * (R0 + Hf.transpose() * Hf));
                pifactorVariancestar(d) = loginvgammapdf(factorVariancestar(i), parama, 1.0 / paramb);
                ++d;
            }
            resids = yt - (Astar * Factors) - xbt;

            FactorPrecision = MakePrecision(gammastar, factorVariancestar, T);

            FactorRRj[j] = Factors;
        }
        posteriorStar += logavg(pifactorVariancestar);

        FactorStar = mean(FactorRRj);
        MatrixXd IT = MatrixXd::Identity(T, T);
        MatrixXd GpOmegaInv = Astar.transpose() * omPrecisionstar.asDiagonal();
        MatrixXd G = kroneckerProduct(IT, GpOmegaInv * Astar);
        MatrixXd Kprecision = MakePrecision(gammastar, factorVariancestar, T);
        MatrixXd Pinv = Kprecision + G;
        RowVectorXd ZeroVec1 = RowVectorXd::Zero(nFactors * T);
        RowVectorXd ZeroVec2 = RowVectorXd::Zero(K * T);
        Pinv = Pinv.ldlt().solve(MatrixXd::Identity(Pinv.rows(), Pinv.rows()));
        resids.resize(K, T);
        resids = (yt - xbt);
        resids.resize(K * T, 1);
        VectorXd mu = Pinv * kroneckerProduct(IT, GpOmegaInv) * resids;
        FactorStar.resize(nFactors * T, 1);

        double post = logmvnpdf(FactorStar.transpose(), mu.transpose(), Pinv);
        double prior = logmvnpdf(FactorStar.transpose(), ZeroVec1, Kprecision);
        resids.resize(K, T);
        FactorStar.resize(nFactors, T);
        resids = yt - xbt - Astar * FactorStar;
        resids.resize(K * T, 1);
        VectorXd omVariancestar = omPrecisionstar.array().pow(-1);
        MatrixXd Covariance = omVariancestar.asDiagonal();

        MatrixXd OmegaInverse = kroneckerProduct(IT, Covariance);
        double like = logmvnpdf(resids.transpose(), ZeroVec2, OmegaInverse);
        double conditionalOfFactors = like + prior - post;
        double priorbeta = logmvnpdf(betastar.transpose(), RowVectorXd::Zero(betastar.size()),
                                     MatrixXd::Identity(betastar.size(), betastar.size()));
        VectorXd priorA(nFactors);
        VectorXd priorGammas(nFactors);
        VectorXd priorfactorVariances(nFactors);
        VectorXd priorOmVariances(K);
        RowVectorXd subPriorMean;
        MatrixXd subPriorPrecision;
        for (int i = 0; i < nFactors; ++i)
        {
            start = InfoMat.row(i).head(1).value();
            nrows = InfoMat.row(i).tail(1).value() - start + 1;
            COM = zeroOutFactorLevel(Astar, i);
            mut = xbt + COM * Factors;
            ytdemeaned = yt - mut;
            subA = Astar.col(i).segment(start, nrows);
            subgammas = gammas.row(i);
            subfv = factorVariance.row(i);
            subFp = MakePrecision(subgammas, subfv, T);
            subytdemeaned = ytdemeaned.middleRows(start, nrows);
            subomPrecision = omPrecision.segment(start, nrows);
            subPriorMean = loadingsPriorMeans[i].transpose();
            subPriorPrecision = loadingsPriorPrecision[i];
            subPriorPrecision.ldlt().solve(MatrixXd::Identity(subPriorPrecision.rows(),
                                                              subPriorPrecision.rows()));

            priorfactorVariances(n) = loginvgammapdf(factorVariancestar(n), .5 * r0, 1. / (.5 * R0));
            priorA(n) = logmvnpdf(subA.transpose(), subPriorMean, subPriorPrecision);
            priorGammas(n) = logmvnpdf(gammastar.row(n), g0, G0);
        }
        resids.resize(K, T);
        n = 0;
        for (int i = 0; i < K; ++i)
        {

            priorOmVariances(n) = loginvgammapdf(1.0 / omPrecisionstar(i), .5 * r0, 1.0 / (.5 * R0));
            ++n;
        }
        double priorSum = priorA.sum() + priorGammas.sum() + priorfactorVariances.sum() +
                          priorOmVariances.sum();
        marginal_likelihood = conditionalOfFactors + priorSum - posteriorStar;
        cout << marginal_likelihood << endl;
        return marginal_likelihood;
    }
};

#endif