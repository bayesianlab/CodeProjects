#pragma once
#ifndef FULLCOND_H
#define FULLCOND_H
#include <Eigen/Dense>
#include <iostream>
#include <fstream>
#include <string>
#include "Distributions.hpp"
#include "IntegratedLikelihood.hpp"
#include "MultilevelModelFunctions.hpp"
#include "TimeSeriesTools.hpp"
#include "EigenTools.hpp"

using namespace Eigen;
using namespace std;

class FullConditionals : public LoadingsFactorTools
{
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
    std::vector<MatrixXd> Xtk;

    int Sims;
    int burnin;
    int noAr;
    double r0;
    double R0;
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
    void setModel(const Ref<const MatrixXd> &yt, const Ref<const MatrixXd> &Xt,
                  const Ref<const MatrixXd> &Ft, const Ref<const MatrixXd> &gammas, const Ref<const MatrixXd> &deltas,
                  const Matrix<int, Dynamic, 2> &InfoMat, const RowVectorXd &b0, const MatrixXd &B0, const double &r0,
                  const double &R0, const Ref<const RowVectorXd> &g0, const Ref<const MatrixXd> &G0,
                  const Ref<const RowVectorXd> &delta0, const Ref<const MatrixXd> &Delta0)
    {
        noAr = 0;
        if ((gammas.rows() > Ft.rows()) || (gammas.rows() < Ft.rows()))
        {
            dim(gammas);
            dim(Ft);
            throw invalid_argument("Error in set model, gammas not correct dim.");
        }
        if (deltas.rows() != yt.rows())
        {
            cout << "Dimension deltas" << endl;
            dim(deltas);
            cout << "Dimension yt" << endl;
            dim(yt);
            throw invalid_argument("Error in set model, deltas or yt not set correctly.");
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
        this->omPrecision = VectorXd::Ones(this->yt.rows());
        this->factorVariance = VectorXd::Ones(Ft.rows());
        this->omVariance = 1. / this->omPrecision.array();
        this->Identity = MakeObsModelIdentity(InfoMat, yt.rows());
        setFactors(Ft);
    }

    void setModel(const Ref<const MatrixXd> &yt, const Ref<const MatrixXd> &Xt,
                  const Ref<const MatrixXd> &Ft, const Ref<const MatrixXd> &gammas,
                  const Matrix<int, Dynamic, 2> &InfoMat, const RowVectorXd &b0, const MatrixXd &B0, const double &r0,
                  const double &R0, const Ref<const RowVectorXd> &g0, const Ref<const MatrixXd> &G0)
    {
        noAr = 1;
        if ((gammas.rows() > Ft.rows()) || (gammas.rows() < Ft.rows()))
        {
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
        this->g0 = g0;
        this->G0 = G0;
        this->omPrecision = VectorXd::Ones(this->yt.rows());
        this->factorVariance = VectorXd::Ones(Ft.rows());
        this->omVariance = 1. / this->omPrecision.array();
        this->Identity = MakeObsModelIdentity(InfoMat, yt.rows());
        setFactors(Ft);
        int check = Xt.cols() + Factors.rows();
        if (b0.cols() != check)
        {
            throw invalid_argument("Error in set model. prior b0 must have equal columns to stacked Xt + nFactors.");
        }
        if (B0.rows() != check || B0.cols() != check)
            throw invalid_argument("Error in set model. prior B0 must have equal columns and rows to stacked Xt + nFactors.");
    }

    void runModelNoAr(const int &Sims, const int &burnin)
    {
        // Assumes there are Xs in the estimation
        int arOrderFac = gammas.cols();
        int K = yt.rows();
        int T = yt.cols();
        int nXs = Xt.cols();
        int nFactors = InfoMat.rows();
        double s2, f2, betai, parama, paramb, loading;
        Xtk.resize(K);
        BetaPosteriorDraws.resize(Sims - burnin);
        FactorPosteriorDraws.resize(Sims - burnin);
        GammasPosteriorDraws.resize(Sims - burnin);
        OmVariancePosteriorDraws.resize(Sims - burnin);
        FactorVariancePosteriorDraws.resize(Sims - burnin);
        UnivariateBeta ub;
        ArParameterTools arupdater;
        ub.initializeBeta(b0);

        VectorXd factorVariance = omPrecision;
        VectorXd MeanSum;
        VectorXd factorMean;
        ArrayXi indices = sequence(0, K * T, K);
        ArrayXi all = sequence(0, K * T);
        ArrayXi indexshift;
        MatrixXd ythat(K, T);
        MatrixXd Xtfull(Xt.rows(), Xt.cols() + nFactors);
        Xtfull.leftCols(nXs) = Xt;
        Xtfull.rightCols(nFactors) = makeOtrokXt(InfoMat, Factors, K);
        MatrixXd btemp(1, Xtfull.cols());
        MatrixXd betaParams(K, Xtfull.cols());
        MatrixXd Xtemp(T, Xtfull.cols());
        MatrixXd Xthat(T, Xtfull.cols());
        MatrixXd epsilons(K, T);
        MatrixXd D0;
        MatrixXd IT = MatrixXd::Identity(T, T);
        MatrixXd residuals(1, T);
        MatrixXd H1;
        MatrixXd H2;
        MatrixXd CovarSum;
        MatrixXd I = MakeObsModelIdentity(InfoMat, K);
        MatrixXd Icopy = I;
        MatrixXd P0;
        MatrixXd P0lower;
        MatrixXd P0lowerinv;
        MatrixXd Ilagfac = MatrixXd::Identity(arOrderFac, arOrderFac);
        ythat = yt;
        int levels = (int)I.row(0).sum();

        int colCount;
        for (int i = 0; i < Sims; ++i)
        {
            cout << "Sim " << i + 1 << endl;
            Xtfull.rightCols(nFactors) = makeOtrokXt(InfoMat, Factors, K);
            Xtk = groupByTime(Xtfull, T, K);
            for (int k = 0; k < K; ++k)
            {
                Xthat = Xtk[k];
                s2 = omVariance(k);
                ub.updateBetaUnivariate(ythat.row(k), Xthat, s2, b0, B0);
                ub.bnew.rightCols(nFactors) = ub.bnew.rightCols(nFactors).array() * I.row(k).array();
                betaParams.row(k) = ub.bnew;
                for (int n = 0; n < nFactors; ++n)
                {
                    if (k == InfoMat.row(n).head(1).value())
                    {
                        betaParams(k, nXs + n) = 1;
                    }
                }
                residuals = ythat.row(k) - betaParams.row(k) * Xthat.transpose();
                omVariance(k) = updateVariance(residuals, r0, R0).value();
            }
            colCount = 0;
            for (int n = 0; n < nFactors; ++n)
            {
                CovarSum.setZero(T, T);
                MeanSum.setZero(T, 1);
                for (int k = InfoMat.row(n).head(1).value(); k <= InfoMat.row(n).tail(1).value(); ++k)
                {
                    Xtemp = Xtk[k];
                    btemp = betaParams.row(k);
                    btemp(nXs + colCount) = 0;
                    epsilons.row(k) = yt.row(k) - btemp * Xtemp.transpose();
                    if (k == InfoMat.row(n).head(1).value())
                    {
                        f2 = factorVariance(n);
                        H1 = MakePrecision(gammas.row(n), f2, T);
                        // D0 = setInitialCovar(gammas.row(n), f2).ldlt().solve(Ilagfac);
                        D0 = Ilagfac * (1 / f2);
                        H1.topLeftCorner(arOrderFac, arOrderFac) = D0;
                        CovarSum += H1;
                    }
                    else
                    {
                        s2 = omVariance(k);
                        s2 = 1 / s2;
                        H1 = s2 * IT;
                        CovarSum += (betaParams(k, nXs + colCount) * betaParams(k, nXs + colCount)) * H1;
                        MeanSum += betaParams(k, nXs + colCount) * (H1 * epsilons.transpose());
                    }
                }
                if (K - 1 == InfoMat.row(n).tail(1).value())
                {
                    ++colCount;
                }
                CovarSum = CovarSum.ldlt().solve(MatrixXd::Identity(T, T));
                factorMean = CovarSum * MeanSum;
                Factors.row(n) = (factorMean + CovarSum.llt().matrixL() * normrnd(0, 1, CovarSum.rows())).transpose();
                factorVariance(n) = updateVariance(Factors.row(n), r0, R0).value();
                arupdater.updateArParameters(Factors.row(n), gammas.row(n), factorVariance(n), g0, G0);
                gammas.row(n) = arupdater.phinew;
            }
            if (i >= burnin)
            {
                BetaPosteriorDraws[i - burnin] = betaParams;
                FactorPosteriorDraws[i - burnin] = Factors;
                GammasPosteriorDraws[i - burnin] = gammas;
                OmVariancePosteriorDraws[i - burnin] = omVariance;
                FactorVariancePosteriorDraws[i - burnin] = factorVariance;
            }
        }
        this->Sims = Sims;
        this->burnin = burnin;
    }

    void runModel(const int &Sims, const int &burnin)
    {
        if (noAr)
        {
            cout << "Running No Ar Version" << endl;
            runModelNoAr(Sims, burnin);
            return;
        }
        // Assumes there are Xs in the estimation
        int arOrderOm = deltas.cols();
        if (arOrderOm + 1 >= yt.cols())

        {
            throw invalid_argument("T must be greater than lags of Om model.");
        }

        int arOrderFac = gammas.cols();
        int K = yt.rows();
        int T = yt.cols();
        int nXs = Xt.cols();
        int nFactors = InfoMat.rows();
        double s2, f2, betai, parama, paramb, loading;
        Xtk.resize(K);
        BetaPosteriorDraws.resize(Sims - burnin);
        FactorPosteriorDraws.resize(Sims - burnin);
        DeltasPosteriorDraws.resize(Sims - burnin);
        GammasPosteriorDraws.resize(Sims - burnin);
        OmVariancePosteriorDraws.resize(Sims - burnin);
        FactorVariancePosteriorDraws.resize(Sims - burnin);

        UnivariateBeta ub;
        ArParameterTools arupdater;
        ub.initializeBeta(b0);

        VectorXd factorVariance = VectorXd::Ones(nFactors);
        VectorXd MeanSum;
        VectorXd factorMean;

        ArrayXi indices = sequence(0, K * T, K);
        ArrayXi all = sequence(0, K * T);
        ArrayXi indexshift;

        MatrixXd ythat(K, T);
        MatrixXd Xtfull(Xt.rows(), Xt.cols() + nFactors);
        Xtfull.leftCols(nXs) = Xt;
        Xtfull.rightCols(nFactors) = makeOtrokXt(InfoMat, Factors, K);

        MatrixXd Xtemp(T, Xtfull.cols());
        MatrixXd Xthat(T, Xtfull.cols());
        MatrixXd epsilons(1, T);
        MatrixXd D0;
        MatrixXd Ilagom = MatrixXd::Identity(arOrderOm, arOrderOm);
        MatrixXd residuals(1, T);
        MatrixXd H1;
        MatrixXd H2;
        MatrixXd CovarSum;
        MatrixXd I = MakeObsModelIdentity(InfoMat, K);
        MatrixXd Icopy = I;
        MatrixXd P0;
        MatrixXd P0lower;
        MatrixXd P0lowerinv;
        MatrixXd H;
        MatrixXd nu;
        MatrixXd Ilagfac = MatrixXd::Identity(arOrderFac, arOrderFac);
        MatrixXi FactorInfo = createFactorInfo(I, InfoMat);
        int levels = (int)I.row(0).sum();

        MatrixXd betaParams(K, nXs + levels);
        MatrixXd btemp(1, nXs + levels);
        int colCount;
        MatrixXi IdentificationMat = returnIdentificationRestictions(FactorInfo);
        for (int i = 0; i < Sims; ++i)
        {
            cout << "Sim " << i + 1 << endl;
            Xtfull.rightCols(nFactors) = makeOtrokXt(InfoMat, Factors, K);
            Xtk = groupByTime(Xtfull, T, K);
            ythat = makeStationary(yt, deltas, omVariance, 0);
            for (int k = 0; k < K; ++k)
            {
                Xtemp = removeXtZeros(Xtk[k], I, InfoMat, FactorInfo.row(k));
                Xthat = makeStationary(Xtemp, deltas.row(k), s2, 1);

                s2 = omVariance(k);
                ub.updateBetaUnivariate(ythat.row(k), Xthat, s2, b0, B0);
                betaParams.row(k) = ub.bnew;
                for (int t = 0; t < IdentificationMat.row(k).cols(); ++t)
                {
                    if (IdentificationMat(k, t) == 1)
                    {
                        // Identification scheme 1
                        betaParams(k, nXs + t) = 1;
                        // Identification scheme 2
                        // betaParams(k, nXs + t) = abs(betaParams(k, nXs + t));
                    }
                }

                epsilons = yt.row(k) - betaParams.row(k) * Xtemp.transpose();
                arupdater.updateArParameters(epsilons, deltas.row(k), s2, g0, G0);
                deltas.row(k) = arupdater.phinew;

                D0 = Ilagom * (1 / s2);
                // D0 = setInitialCovar(deltas.row(k), s2);
                // cout << D0 << endl;
                // D0 = Ilagom;
                // D0 = D0.ldlt().solve(Ilagom);
                // D0 = D0.llt().matrixL();
                residuals.rightCols(T - arOrderOm) = ythat.row(k).rightCols(T - arOrderOm) -
                                                     betaParams.row(k) * Xthat.transpose().rightCols(T - arOrderOm);
                residuals.leftCols(arOrderOm) = (D0 * epsilons.leftCols(arOrderOm).transpose()).transpose();
                omVariance(k) = updateVariance(residuals, r0, R0).value();
            }
            colCount = 0;
            for (int n = 0; n < nFactors; ++n)
            {
                Xtfull.rightCols(nFactors) = makeOtrokXt(InfoMat, Factors, K);
                Xtk = groupByTime(Xtfull, T, K);
                CovarSum.setZero(T, T);
                MeanSum.setZero(T, 1);
                for (int k = InfoMat.row(n).head(1).value(); k <= InfoMat.row(n).tail(1).value(); ++k)
                {
                    Xtemp = removeXtZeros(Xtk[k], I, InfoMat, FactorInfo.row(k));
                    btemp = betaParams.row(k);
                    btemp(nXs + colCount) = 0;
                    epsilons = yt.row(k) - btemp * Xtemp.transpose();
                    if (k == InfoMat.row(n).head(1).value())
                    {
                        f2 = factorVariance(n);
                        H1 = MakePrecision(gammas.row(n), f2, T);
                        // D0 = setInitialCovar(gammas.row(n), f2).ldlt().solve(Ilagfac);
                        D0 = Ilagfac * (1 / f2);
                        // H1.topLeftCorner(arOrderFac, arOrderFac) = D0;
                        CovarSum += H1;
                    }
                    else
                    {
                        s2 = omVariance(k);
                        H1 = MakePrecision(deltas.row(k), s2, T);
                        // D0 = setInitialCovar(deltas.row(k), s2).ldlt().solve(Ilagom);
                        D0 = Ilagom * (1 / s2);
                        // H1.topLeftCorner(arOrderOm, arOrderOm) = D0;
                        CovarSum += (betaParams(k, nXs + colCount) * betaParams(k, nXs + colCount)) * H1;
                        MeanSum += betaParams(k, nXs + colCount) * (H1 * epsilons.transpose());
                    }
                }
                if (K - 1 == InfoMat.row(n).tail(1).value())
                {
                    ++colCount;
                }
                CovarSum = CovarSum.ldlt().solve(MatrixXd::Identity(T, T));
                factorMean = CovarSum * MeanSum;
                Factors.row(n) = (factorMean + CovarSum.llt().matrixL() * normrnd(0, 1, CovarSum.rows())).transpose();
                arupdater.updateArParameters(Factors.row(n), gammas.row(n), factorVariance(n), g0, G0);
                gammas.row(n) = arupdater.phinew;
                H = ReturnH(gammas.row(n), T);
                nu = (H * Factors.row(n).transpose()).transpose();
                factorVariance(n) = updateVariance(nu, r0, R0).value();
            }
            cout << factorVariance.transpose() << endl;
            if (i >= burnin)
            {
                BetaPosteriorDraws[i - burnin] = betaParams;
                FactorPosteriorDraws[i - burnin] = Factors;
                DeltasPosteriorDraws[i - burnin] = deltas;
                GammasPosteriorDraws[i - burnin] = gammas;
                OmVariancePosteriorDraws[i - burnin] = omVariance;
                FactorVariancePosteriorDraws[i - burnin] = factorVariance;
            }
        }
        this->Sims = Sims;
        this->burnin = burnin;
    }

    double ml()
    {
        /* Marginal likelihood. 
        * Reduced runs for betas, OM Ar parameters, Factors, Factor Variance, 
        * Factors Ar parameters. 
        */
        if (noAr)
        {
            cout << "Running No Ar Version" << endl;
            return mlNoAr();
        }
        int rr = Sims - burnin;
        int T = yt.cols();
        int K = yt.rows();
        int nFactors = Factors.rows();
        int nXs = Xt.cols();
        int arOrderOm = DeltasPosteriorDraws[0].cols();
        int arOrderFac = GammasPosteriorDraws[0].cols();
        double s2, parama, paramb, f2, loading;
        double posteriorStar = 0;
        FactorPosteriorDrawsj.resize(rr);
        GammasPosteriorDrawsj.resize(rr);
        DeltasPosteriorDrawsj.resize(rr);
        OmVariancePosteriorDrawsj.resize(rr);
        FactorVariancePosteriorDrawsj.resize(rr);
        MatrixXd ythat(K, T);
        MatrixXd Xtfull(Xt.rows(), nXs + nFactors);
        MatrixXd Xtemp;
        MatrixXd Xthat;
        MatrixXd epsilons(1, T);
        MatrixXd residuals(1, T);
        MatrixXd D0(arOrderOm, arOrderOm);
        MatrixXd H1;
        MatrixXd H2;
        MatrixXd CovarSum;
        VectorXd MeanSum;
        MatrixXd I = MakeObsModelIdentity(InfoMat, K);
        MatrixXd Icopy = I;
        MatrixXd btemp(1, Xtfull.cols());
        VectorXd factorMean;
        MatrixXd Ilagom = MatrixXd::Identity(arOrderOm, arOrderOm);
        MatrixXd Ilagfac = MatrixXd::Identity(arOrderFac, arOrderFac);
        RowVectorXd Z1 = RowVectorXd::Zero(T);
        MatrixXd IT = MatrixXd::Identity(T, T);
        Xtfull.leftCols(nXs) = Xt;
        Xtfull.rightCols(nFactors) = makeOtrokXt(InfoMat, Factors, K);
        UnivariateBeta ub;
        MatrixXd piPosterior(K, rr);
        ArParameterTools arupdater;
        VectorXd priorBetaStar(K);

        cout << "Beta Reduced Runs" << endl;
        int levels = (int)I.row(0).sum();
        MatrixXi FactorInfo = createFactorInfo(I, InfoMat);
        MatrixXd tempX(T, nXs + levels);
        MatrixXd betaStar = mean(BetaPosteriorDraws);
        int colCount;
        for (int j = 0; j < rr; ++j)
        {
            cout << "RR = " << j + 1 << endl;
            Factors = FactorPosteriorDraws[j];
            deltas = DeltasPosteriorDraws[j];
            gammas = GammasPosteriorDraws[j];
            omVariance = OmVariancePosteriorDraws[j];
            Xtfull.rightCols(nFactors) = makeOtrokXt(InfoMat, Factors, K);
            Xtk = groupByTime(Xtfull, T, K);
            ythat = makeStationary(yt, deltas, omVariance, 0);
            for (int k = 0; k < K; ++k)
            {
                s2 = omVariance(k);
                Xtemp = removeXtZeros(Xtk[k], I, InfoMat, FactorInfo.row(k));
                Xthat = makeStationary(Xtemp, deltas.row(k), s2, 1);

                piPosterior(k, j) = ub.betaReducedRun(betaStar.row(k), ythat.row(k), Xthat, s2, b0, B0);

                epsilons = yt.row(k) - betaStar.row(k) * Xtemp.transpose();
                arupdater.updateArParameters(epsilons, deltas.row(k), s2, g0, G0);
                deltas.row(k) = arupdater.phinew;

                D0 = Ilagom * s2;
                // D0 = setInitialCovar(deltas.row(k), 1);
                // D0 = D0.ldlt().solve(Ilagom);
                // D0 = D0.llt().matrixL();
                residuals.rightCols(T - arOrderOm) = ythat.row(k).rightCols(T - arOrderOm) -
                                                     betaStar.row(k) * Xthat.transpose().rightCols(T - arOrderOm);
                residuals.leftCols(arOrderOm) = epsilons.leftCols(arOrderOm) * D0;
                omVariance(k) = updateVariance(residuals, r0, R0).value();

                priorBetaStar(k) = logmvnpdf(betaStar.row(k), b0, B0);
            }
            colCount = 0;

            for (int n = 0; n < nFactors; ++n)
            {
                Xtfull.rightCols(nFactors) = makeOtrokXt(InfoMat, Factors, K);
                Xtk = groupByTime(Xtfull, T, K);
                CovarSum.setZero(T, T);
                MeanSum.setZero(T, 1);
                for (int k = InfoMat.row(n).head(1).value(); k <= InfoMat.row(n).tail(1).value(); ++k)
                {
                    Xtemp = removeXtZeros(Xtk[k], I, InfoMat, FactorInfo.row(k));
                    btemp = betaStar.row(k);
                    btemp(nXs + colCount) = 0;
                    epsilons.row(k) = yt.row(k) - btemp * Xtemp.transpose();
                    if (k == InfoMat.row(n).head(1).value())
                    {
                        f2 = factorVariance(n);
                        H1 = MakePrecision(gammas.row(n), f2, T);
                        // D0 = setInitialCovar(gammas.row(n), f2).ldlt().solve(Ilagfac);
                        D0 = Ilagfac * f2;
                        H1.topLeftCorner(arOrderFac, arOrderFac) = D0;
                        CovarSum += H1;
                    }
                    else
                    {
                        s2 = omVariance(k);
                        H1 = MakePrecision(deltas.row(k), s2, T);
                        // D0 = setInitialCovar(deltas.row(k), s2).ldlt().solve(Ilagom);
                        D0 = Ilagom * s2;
                        H1.topLeftCorner(arOrderOm, arOrderOm) = D0;
                        CovarSum += (betaStar(k, nXs + colCount) * betaStar(k, nXs + colCount)) * H1;
                        MeanSum += betaStar(k, nXs + colCount) * (H1 * epsilons.transpose());
                    }
                }
                if (K - 1 == InfoMat.row(n).tail(1).value())
                {
                    ++colCount;
                }
                CovarSum = CovarSum.ldlt().solve(MatrixXd::Identity(T, T));
                factorMean = CovarSum * MeanSum;
                Factors.row(n) = (factorMean + CovarSum.llt().matrixL() * normrnd(0, 1, CovarSum.rows())).transpose();
                factorVariance(n) = updateVariance(Factors.row(n), r0, R0).value();
                arupdater.updateArParameters(Factors.row(n), gammas.row(n), factorVariance(n), g0, G0);
                gammas.row(n) = arupdater.phinew;
            }

            FactorPosteriorDrawsj[j] = Factors;
            GammasPosteriorDrawsj[j] = gammas;
            DeltasPosteriorDrawsj[j] = deltas;
            OmVariancePosteriorDrawsj[j] = omVariance;
            FactorVariancePosteriorDrawsj[j] = factorVariance;
        }
        cout << piPosterior << endl;
        posteriorStar += logavg(piPosterior, 0).sum();
        cout << posteriorStar << endl;
        MatrixXd deltastar = mean(DeltasPosteriorDraws);
        MatrixXd Numerator(K, rr);
        MatrixXd Denominator(K, rr);
        VectorXd priorDeltaStar(K);

        cout << "Deltas Reduced Run" << endl;
        for (int k = 0; k < K; ++k)
        {
            priorDeltaStar(k) = logmvnpdf(deltastar.row(k), g0, G0);
        }
        for (int j = 0; j < rr; ++j)
        {
            cout << "RR = " << j + 1 << endl;
            deltas = DeltasPosteriorDrawsj[j];
            gammas = GammasPosteriorDrawsj[j];
            omVariance = OmVariancePosteriorDrawsj[j];
            Factors = FactorPosteriorDraws[j];
            Xtfull.rightCols(nFactors) = makeOtrokXt(InfoMat, Factors, K);
            Xtk = groupByTime(Xtfull, T, K);
            ythat = makeStationary(yt, deltastar, omVariance, 0);
            for (int k = 0; k < K; ++k)
            {
                s2 = omVariance(k);
                Xtemp = Xtk[k];
                Xthat = makeStationary(Xtemp, deltas.row(k), s2, 1);
                epsilons.row(k) = yt.row(k) - betaStar.row(k) * Xtemp.transpose();
                Numerator(k, j) = arupdater.alphag(epsilons.row(k), deltas.row(k), deltastar.row(k), s2, g0, G0);
                Denominator(k, j) = arupdater.alphaj(deltastar.row(k), epsilons.row(k), s2, g0, G0);

                D0 = setInitialCovar(deltastar.row(k), 1);
                D0 = D0.ldlt().solve(Ilagom);
                D0 = D0.llt().matrixL();
                residuals.rightCols(T - arOrderOm) = ythat.row(k).rightCols(T - arOrderOm) -
                                                     betaStar.row(k) * Xthat.transpose().rightCols(T - arOrderOm);
                residuals.leftCols(arOrderOm) = epsilons.row(k).leftCols(arOrderOm) * D0;
                omVariance(k) = updateVariance(residuals, r0, R0).value();
            }
            for (int n = 0; n < nFactors; ++n)
            {
                CovarSum.setZero(T, T);
                MeanSum.setZero(T, 1);
                Icopy = zeroOutFactorLevel(I, n);
                for (int k = InfoMat.row(n).head(1).value(); k <= InfoMat.row(n).tail(1).value(); ++k)
                {
                    Xtemp = Xtk[k];
                    btemp = betaStar.row(k);
                    btemp.rightCols(nFactors) = btemp.rightCols(nFactors).array() * Icopy.row(k).array();
                    epsilons.row(k) = yt.row(k) - btemp * Xtemp.transpose();
                    if (k == InfoMat.row(n).head(1).value())
                    {
                        f2 = factorVariance(n);
                        H1 = MakePrecision(gammas.row(n), f2, T);
                        D0 = setInitialCovar(gammas.row(n), f2).ldlt().solve(Ilagfac);
                        H1.topLeftCorner(arOrderFac, arOrderFac) = D0;
                        CovarSum += H1;
                    }
                    else
                    {
                        s2 = omVariance(k);
                        H1 = MakePrecision(deltastar.row(k), s2, T);
                        D0 = setInitialCovar(deltastar.row(k), s2).ldlt().solve(Ilagom);
                        H1.topLeftCorner(arOrderOm, arOrderOm) = D0;
                        CovarSum += (betaStar(k, nXs + n) * betaStar(k, nXs + n)) * H1;
                        MeanSum += betaStar(k, nXs + n) * (H1 * epsilons.row(k).transpose());
                    }
                }
                CovarSum = CovarSum.ldlt().solve(MatrixXd::Identity(T, T));
                factorMean = CovarSum * MeanSum;
                Factors.row(n) = (factorMean + CovarSum.llt().matrixL() * normrnd(0, 1, CovarSum.rows())).transpose();
                factorVariance(n) = updateVariance(Factors.row(n), r0, R0).value();
                arupdater.updateArParameters(Factors.row(n), gammas.row(n), factorVariance(n), g0, G0);
                gammas.row(n) = arupdater.phinew;
            }
            FactorPosteriorDrawsj[j] = Factors;
            GammasPosteriorDrawsj[j] = gammas;
            OmVariancePosteriorDrawsj[j] = omVariance;
            FactorVariancePosteriorDrawsj[j] = factorVariance;
        }
        posteriorStar += logavg(Numerator, 0).sum() - logavg(Denominator, 0).sum();
        cout << posteriorStar << endl;
        Numerator.resize(nFactors, rr);
        Denominator.resize(nFactors, rr);
        MatrixXd gammastar = mean(GammasPosteriorDrawsj);

        cout << "Gamma Reduced Run" << endl;
        VectorXd priorGammaStar(nFactors);
        for (int j = 0; j < rr; ++j)
        {
            cout << "RR = " << j + 1 << endl;
            Factors = FactorPosteriorDraws[j];
            omVariance = OmVariancePosteriorDrawsj[j];
            gammas = GammasPosteriorDrawsj[j];
            Xtfull.rightCols(nFactors) = makeOtrokXt(InfoMat, Factors, K);
            Xtk = groupByTime(Xtfull, T, K);
            ythat = makeStationary(yt, deltastar, omVariance, 0);
            for (int k = 0; k < K; ++k)
            {
                s2 = omVariance(k);
                Xtemp = Xtk[k];
                Xthat = makeStationary(Xtemp, deltastar.row(k), s2, 1);
                epsilons.row(k) = yt.row(k) - betaStar.row(k) * Xtemp.transpose();

                D0 = setInitialCovar(deltastar.row(k), 1);
                D0 = D0.ldlt().solve(Ilagom);
                D0 = D0.llt().matrixL();
                residuals.rightCols(T - arOrderOm) = ythat.row(k).rightCols(T - arOrderOm) -
                                                     betaStar.row(k) * Xthat.transpose().rightCols(T - arOrderOm);
                residuals.leftCols(arOrderOm) = epsilons.row(k).leftCols(arOrderOm) * D0;
                omVariance(k) = updateVariance(residuals, r0, R0).value();
            }
            for (int n = 0; n < nFactors; ++n)
            {
                CovarSum.setZero(T, T);
                MeanSum.setZero(T, 1);
                Icopy = zeroOutFactorLevel(I, n);
                for (int k = InfoMat.row(n).head(1).value(); k <= InfoMat.row(n).tail(1).value(); ++k)
                {
                    Xtemp = Xtk[k];
                    btemp = betaStar.row(k);
                    btemp.rightCols(nFactors) = btemp.rightCols(nFactors).array() * Icopy.row(k).array();
                    epsilons.row(k) = yt.row(k) - btemp * Xtemp.transpose();
                    if (k == InfoMat.row(n).head(1).value())
                    {
                        f2 = factorVariance(n);
                        H1 = MakePrecision(gammastar.row(n), f2, T);
                        D0 = setInitialCovar(gammastar.row(n), f2).ldlt().solve(Ilagfac);
                        H1.topLeftCorner(arOrderFac, arOrderFac) = D0;
                        CovarSum += H1;
                    }
                    else
                    {
                        s2 = omVariance(k);
                        H1 = MakePrecision(deltastar.row(k), s2, T);
                        D0 = setInitialCovar(deltastar.row(k), s2).ldlt().solve(Ilagom);
                        H1.topLeftCorner(arOrderOm, arOrderOm) = D0;
                        CovarSum += (betaStar(k, nXs + n) * betaStar(k, nXs + n)) * H1;
                        MeanSum += betaStar(k, nXs + n) * (H1 * epsilons.row(k).transpose());
                    }
                }
                CovarSum = CovarSum.ldlt().solve(MatrixXd::Identity(T, T));
                factorMean = CovarSum * MeanSum;
                Factors.row(n) = (factorMean + CovarSum.llt().matrixL() * normrnd(0, 1, CovarSum.rows())).transpose();
                factorVariance(n) = updateVariance(Factors.row(n), r0, R0).value();
                Numerator(n, j) = arupdater.alphag(Factors.row(n), gammas.row(n), gammastar.row(n), f2, g0, G0);
                Denominator(n, j) = arupdater.alphaj(gammastar.row(n), Factors.row(n), f2, g0, G0);
                priorGammaStar(n) = logmvnpdf(gammastar.row(n), g0, G0);
            }
            FactorPosteriorDrawsj[j] = Factors;
            OmVariancePosteriorDrawsj[j] = omVariance;
            FactorVariancePosteriorDrawsj[j] = factorVariance;
        }
        posteriorStar += logavg(Numerator, 0).sum() - logavg(Denominator, 0).sum();
        cout << posteriorStar << endl;
        piPosterior.resize(nFactors, rr);

        cout << "Om Variance Reduced Run" << endl;
        MatrixXd Factorstar = mean(FactorPosteriorDrawsj);
        VectorXd omVariancestar = mean(OmVariancePosteriorDrawsj);
        parama = .5 * (T + r0);
        piPosterior.resize(K, rr);
        Xtfull.rightCols(nFactors) = makeOtrokXt(InfoMat, Factorstar, K);
        Xtk = groupByTime(Xtfull, T, K);
        VectorXd priorOmVarianceStar(K);
        for (int k = 0; k < K; ++k)
        {
            s2 = omVariancestar(k);
            priorOmVarianceStar(k) = loginvgammapdf(s2, .5 * r0, 1.0 / (.5 * R0));
        }
        for (int j = 0; j < rr; ++j)
        {
            cout << "RR = " << j + 1 << endl;
            for (int k = 0; k < K; ++k)
            {
                Xtemp = Xtk[k];
                s2 = omVariancestar(k);
                residuals = ythat.row(k) - betaStar.row(k) * Xtemp.transpose();
                paramb = .5 * (R0 + (residuals * residuals.transpose()).value());
                piPosterior(k, j) = loginvgammapdf(s2, parama, 1.0 / paramb);
            }
            for (int n = 0; n < nFactors; ++n)
            {
                CovarSum.setZero(T, T);
                MeanSum.setZero(T, 1);
                Icopy = zeroOutFactorLevel(I, n);
                for (int k = InfoMat.row(n).head(1).value(); k <= InfoMat.row(n).tail(1).value(); ++k)
                {
                    Xtemp = Xtk[k];
                    btemp = betaStar.row(k);
                    btemp.rightCols(nFactors) = btemp.rightCols(nFactors).array() * Icopy.row(k).array();
                    epsilons.row(k) = yt.row(k) - btemp * Xtemp.transpose();
                    if (k == InfoMat.row(n).head(1).value())
                    {
                        f2 = factorVariance(n);
                        H1 = MakePrecision(gammastar.row(n), f2, T);
                        D0 = setInitialCovar(gammastar.row(n), f2).ldlt().solve(Ilagfac);
                        H1.topLeftCorner(arOrderFac, arOrderFac) = D0;
                        CovarSum += H1;
                    }
                    else
                    {
                        s2 = omVariancestar(k);
                        s2 = 1 / s2;
                        H1 = s2 * IT;
                        CovarSum += (betaStar(k, nXs + n) * betaStar(k, nXs + n)) * H1;
                        MeanSum += betaStar(k, nXs + n) * (H1 * epsilons.row(k).transpose());
                    }
                }
                CovarSum = CovarSum.ldlt().solve(MatrixXd::Identity(T, T));
                factorMean = CovarSum * MeanSum;
                CovarSum = CovarSum.ldlt().solve(MatrixXd::Identity(T, T));
                factorMean = CovarSum * MeanSum;
                Factors.row(n) = (factorMean + CovarSum.llt().matrixL() * normrnd(0, 1, CovarSum.rows())).transpose();
                factorVariance(n) = updateVariance(Factors.row(n), r0, R0).value();
            }
            Xtfull.rightCols(nFactors) = makeOtrokXt(InfoMat, Factors, K);
            Xtk = groupByTime(Xtfull, T, K);
            FactorPosteriorDrawsj[j] = Factors;
            FactorVariancePosteriorDrawsj[j] = factorVariance;
        }
        posteriorStar += logavg(piPosterior, 0).sum();
        cout << posteriorStar << endl;
        cout << "Factor Variance Reduced Run" << endl;
        VectorXd factorVariancestar = mean(FactorVariancePosteriorDrawsj);
        parama = .5 * (T + r0);
        piPosterior.resize(nFactors, rr);
        Factorstar = mean(FactorPosteriorDrawsj);
        Xtfull.rightCols(nFactors) = makeOtrokXt(InfoMat, Factorstar, K);
        Xtk = groupByTime(Xtfull, T, K);
        VectorXd priorFactorVarianceStar(nFactors);
        VectorXd priorFactorStar(nFactors);
        for (int n = 0; n < nFactors; ++n)
        {
            f2 = factorVariancestar(n);
            priorFactorVarianceStar(n) = loginvgammapdf(f2, .5 * r0, 1.0 / (.5 * R0));
        }
        for (int j = 0; j < rr; ++j)
        {
            cout << "RR = " << j + 1 << endl;
            for (int n = 0; n < nFactors; ++n)
            {
                CovarSum.setZero(T, T);
                MeanSum.setZero(T, 1);
                Icopy = zeroOutFactorLevel(I, n);
                for (int k = InfoMat.row(n).head(1).value(); k <= InfoMat.row(n).tail(1).value(); ++k)
                {
                    Xtemp = Xtk[k];
                    btemp = betaStar.row(k);
                    epsilons.row(k) = yt.row(k) - btemp * Xtemp.transpose();
                    if (k == InfoMat.row(n).head(1).value())
                    {
                        f2 = factorVariancestar(n);
                        H1 = MakePrecision(gammastar.row(n), f2, T);
                        D0 = setInitialCovar(gammastar.row(n), f2).ldlt().solve(Ilagfac);
                        H1.topLeftCorner(arOrderFac, arOrderFac) = D0;
                        CovarSum += H1;
                    }
                    else
                    {
                        s2 = omVariancestar(k);
                        s2 = 1 / s2;
                        H1 = s2 * IT;
                        CovarSum += (betaStar(k, nXs + n) * betaStar(k, nXs + n)) * H1;
                        MeanSum += betaStar(k, nXs + n) * (H1 * epsilons.row(k).transpose());
                    }
                }
                CovarSum = CovarSum.ldlt().solve(MatrixXd::Identity(T, T));
                factorMean = CovarSum * MeanSum;
                Factors.row(n) = (factorMean + CovarSum.llt().matrixL() * normrnd(0, 1, CovarSum.rows())).transpose();
                paramb = R0 + (Factors.row(n) * Factors.row(n).transpose());
                piPosterior(n, j) = loginvgammapdf(factorVariancestar(n), parama, 1.0 / paramb);
            }
            Xtfull.rightCols(nFactors) = makeOtrokXt(InfoMat, Factors, K);
            Xtk = groupByTime(Xtfull, T, K);
            FactorPosteriorDrawsj[j] = Factors;
        }
        posteriorStar += logavg(piPosterior, 0).sum();
        cout << posteriorStar << endl;
        cout << "Final run for factors" << endl;
        Factorstar = mean(FactorPosteriorDrawsj);
        for (int n = 0; n < nFactors; ++n)
        {
            CovarSum.setZero(T, T);
            MeanSum.setZero(T, 1);
            Icopy = zeroOutFactorLevel(I, n);
            for (int k = InfoMat.row(n).head(1).value(); k <= InfoMat.row(n).tail(1).value(); ++k)
            {
                Xtemp = Xtk[k];
                btemp = betaStar.row(k);
                btemp.rightCols(nFactors) = btemp.rightCols(nFactors).array() * Icopy.row(k).array();
                epsilons.row(k) = yt.row(k) - btemp * Xtemp.transpose();
                if (k == InfoMat.row(n).head(1).value())
                {
                    f2 = factorVariancestar(n);
                    H1 = MakePrecision(gammastar.row(n), f2, T);
                    D0 = setInitialCovar(gammastar.row(n), f2).ldlt().solve(Ilagfac);
                    H1.topLeftCorner(arOrderFac, arOrderFac) = D0;
                    CovarSum += H1;
                }
                else
                {
                    s2 = omVariancestar(k);
                    s2 = 1 / s2;
                    H1 = s2 * IT;
                    CovarSum += (betaStar(k, nXs + n) * betaStar(k, nXs + n)) * H1;
                    MeanSum += betaStar(k, nXs + n) * (H1 * epsilons.row(k).transpose());
                }
            }
            CovarSum = CovarSum.ldlt().solve(MatrixXd::Identity(T, T));
            priorFactorStar(n) = logmvnpdf(Factorstar, Z1, CovarSum);
        }
        VectorXd posteriorFactorStar(nFactors, 1);
        for (int n = 0; n < nFactors; ++n)
        {
            CovarSum.setZero(T, T);
            MeanSum.setZero(T, 1);
            Icopy = zeroOutFactorLevel(I, n);
            for (int k = InfoMat.row(n).head(1).value(); k <= InfoMat.row(n).tail(1).value(); ++k)
            {
                Xtemp = Xtk[k];
                btemp = betaStar.row(k);
                btemp.rightCols(nFactors) = btemp.rightCols(nFactors).array() * Icopy.row(k).array();
                epsilons.row(k) = yt.row(k) - btemp * Xtemp.transpose();
                if (k == InfoMat.row(n).head(1).value())
                {
                    f2 = factorVariancestar(n);
                    H1 = MakePrecision(gammastar.row(n), f2, T);
                    D0 = setInitialCovar(gammastar.row(n), f2).ldlt().solve(Ilagfac);
                    H1.topLeftCorner(arOrderFac, arOrderFac) = D0;
                    CovarSum += H1;
                }
                else
                {
                    s2 = omVariancestar(k);
                    s2 = 1 / s2;
                    H1 = s2 * IT;
                    CovarSum += (betaStar(k, nXs + n) * betaStar(k, nXs + n)) * H1;
                    MeanSum += betaStar(k, nXs + n) * (H1 * epsilons.row(k).transpose());
                }
            }
            CovarSum = CovarSum.ldlt().solve(MatrixXd::Identity(T, T));
            factorMean = CovarSum * MeanSum;
            posteriorFactorStar(n) = logmvnpdf(Factorstar.row(n), factorMean.transpose(), CovarSum);
        }

        RowVectorXd Z2 = RowVectorXd::Zero(1, T);
        Xtfull.rightCols(nFactors) = makeOtrokXt(InfoMat, Factorstar, K);
        Xtk = groupByTime(Xtfull, T, K);
        VectorXd likelihood(K);
        MatrixXd Covar = MatrixXd::Identity(T, T);
        for (int k = 0; k < K; ++k)
        {
            s2 = omVariancestar(k);
            Xtemp = Xtk[k];
            residuals = ythat.row(k) - betaStar.row(k) * Xtemp.transpose();
            likelihood(k) = logmvnpdf(residuals, Z2, s2 * Covar);
        }
        double conditionalOfFactors = likelihood.sum() + priorFactorStar.sum() - posteriorFactorStar.sum();
        double priorSum = priorGammaStar.sum() + priorBetaStar.sum() + priorOmVarianceStar.sum() +
                          priorFactorVarianceStar.sum() + priorDeltaStar.sum();
        marginal_likelihood = conditionalOfFactors + priorSum - posteriorStar;
        cout << "Marginal Likelihood " << marginal_likelihood << endl;
        return marginal_likelihood;
    }

    double mlNoAr()
    {
        /* Marginal likelihood. 
        * Reduced runs for betas, OM Ar parameters, Factors, Factor Variance, 
        * Factors Ar parameters. 
        */
        int rr = Sims - burnin;
        int T = yt.cols();
        int K = yt.rows();
        int nFactors = Factors.rows();
        int nXs = Xt.cols();
        int arOrderFac = GammasPosteriorDraws[0].cols();
        double s2, parama, paramb, f2, loading;
        double posteriorStar = 0;
        FactorPosteriorDrawsj.resize(rr);
        GammasPosteriorDrawsj.resize(rr);
        OmVariancePosteriorDrawsj.resize(rr);
        FactorVariancePosteriorDrawsj.resize(rr);
        MatrixXd ythat(K, T);
        MatrixXd Xtfull(Xt.rows(), nXs + nFactors);
        MatrixXd Xtemp;
        MatrixXd Xthat;
        MatrixXd epsilons(1, T);
        MatrixXd residuals(1, T);
        MatrixXd D0;
        MatrixXd H1;
        MatrixXd H2;
        MatrixXd CovarSum;
        VectorXd MeanSum;
        MatrixXd I = MakeObsModelIdentity(InfoMat, K);
        MatrixXd Icopy = I;
        MatrixXd btemp(1, Xtfull.cols());
        VectorXd factorMean;
        MatrixXd Ilagfac = MatrixXd::Identity(arOrderFac, arOrderFac);
        RowVectorXd Z1 = RowVectorXd::Zero(T);
        MatrixXd IT = MatrixXd::Identity(T, T);

        Xtfull.leftCols(nXs) = Xt;
        Xtfull.rightCols(nFactors) = makeOtrokXt(InfoMat, Factors, K);
        UnivariateBeta ub;
        MatrixXd betaStar = mean(BetaPosteriorDraws);
        MatrixXd piPosterior(K, rr);
        ArParameterTools arupdater;
        VectorXd priorBetaStar(K);
        for (int k = 0; k < K; ++k)
        {
            priorBetaStar(k) = logmvnpdf(betaStar.row(k), b0, B0);
        }
        cout << priorBetaStar << endl;
        ythat = yt;
        cout << "Beta Reduced Runs" << endl;

        for (int j = 0; j < rr; ++j)
        {
            cout << "RR = " << j + 1 << endl;
            Factors = FactorPosteriorDraws[j];
            gammas = GammasPosteriorDraws[j];
            omVariance = OmVariancePosteriorDraws[j];

            for (int k = 0; k < K; ++k)
            {
                s2 = omVariance(k);
                Xtemp = Xtk[k];
                piPosterior(k, j) = ub.betaReducedRun(betaStar.row(k), ythat.row(k), Xtemp, s2, b0, B0);
                epsilons = yt.row(k) - betaStar.row(k) * Xtemp.transpose();
                residuals = ythat.row(k) - betaStar.row(k) * Xtemp.transpose();
                omVariance(k) = updateVariance(residuals, r0, R0).value();
            }
            for (int n = 0; n < nFactors; ++n)
            {
                CovarSum.setZero(T, T);
                MeanSum.setZero(T, 1);
                Icopy = zeroOutFactorLevel(I, n);
                for (int k = InfoMat.row(n).head(1).value(); k <= InfoMat.row(n).tail(1).value(); ++k)
                {
                    Xtemp = Xtk[k];
                    btemp = betaStar.row(k);
                    btemp.rightCols(nFactors) = btemp.rightCols(nFactors).array() * Icopy.row(k).array();
                    epsilons = yt.row(k) - btemp * Xtemp.transpose();
                    if (k == InfoMat.row(n).head(1).value())
                    {
                        f2 = factorVariance(n);
                        H1 = MakePrecision(gammas.row(n), f2, T);
                        D0 = setInitialCovar(gammas.row(n), f2).ldlt().solve(Ilagfac);
                        H1.topLeftCorner(arOrderFac, arOrderFac) = D0;
                        CovarSum += H1;
                    }
                    else
                    {
                        s2 = omVariance(k);
                        s2 = 1 / s2;
                        H1 = s2 * IT;
                        CovarSum += (betaStar(k, nXs + n) * betaStar(k, nXs + n)) * H1;
                        MeanSum += betaStar(k, nXs + n) * (H1 * epsilons.transpose());
                    }
                }
                CovarSum = CovarSum.ldlt().solve(MatrixXd::Identity(T, T));
                factorMean = CovarSum * MeanSum;
                Factors.row(n) = (factorMean + CovarSum.llt().matrixL() * normrnd(0, 1, CovarSum.rows())).transpose();

                factorVariance(n) = updateVariance(Factors.row(n), r0, R0).value();
                arupdater.updateArParameters(Factors.row(n), gammas.row(n), factorVariance(n), g0, G0);
                gammas.row(n) = arupdater.phinew;
            }
            Xtfull.rightCols(nFactors) = makeOtrokXt(InfoMat, Factors, K);
            Xtk = groupByTime(Xtfull, T, K);
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
        for (int n = 0; n < nFactors; ++n)
        {
            priorGammaStar(n) = logmvnpdf(gammastar.row(n), g0, G0);
        }
        for (int j = 0; j < rr; ++j)
        {
            cout << "RR = " << j + 1 << endl;
            Factors = FactorPosteriorDraws[j];
            omVariance = OmVariancePosteriorDrawsj[j];
            gammas = GammasPosteriorDrawsj[j];

            for (int k = 0; k < K; ++k)
            {
                s2 = omVariance(k);
                Xtemp = Xtk[k];
                epsilons.row(k) = yt.row(k) - betaStar.row(k) * Xtemp.transpose();
                residuals = ythat.row(k) - betaStar.row(k) * Xtemp.transpose();
                omVariance(k) = updateVariance(residuals, r0, R0).value();
            }
            for (int n = 0; n < nFactors; ++n)
            {
                CovarSum.setZero(T, T);
                MeanSum.setZero(T, 1);
                Icopy = zeroOutFactorLevel(I, n);
                for (int k = InfoMat.row(n).head(1).value(); k <= InfoMat.row(n).tail(1).value(); ++k)
                {
                    Xtemp = Xtk[k];
                    btemp = betaStar.row(k);
                    btemp.rightCols(nFactors) = btemp.rightCols(nFactors).array() * Icopy.row(k).array();
                    epsilons.row(k) = yt.row(k) - btemp * Xtemp.transpose();
                    if (k == InfoMat.row(n).head(1).value())
                    {
                        f2 = factorVariance(n);
                        H1 = MakePrecision(gammastar.row(n), f2, T);
                        D0 = setInitialCovar(gammastar.row(n), f2).ldlt().solve(Ilagfac);
                        H1.topLeftCorner(arOrderFac, arOrderFac) = D0;
                        CovarSum += H1;
                    }
                    else
                    {
                        s2 = omVariance(k);
                        s2 = 1 / s2;
                        H1 = s2 * IT;
                        CovarSum += (betaStar(k, nXs + n) * betaStar(k, nXs + n)) * H1;
                        MeanSum += betaStar(k, nXs + n) * (H1 * epsilons.row(k).transpose());
                    }
                }
                CovarSum = CovarSum.ldlt().solve(MatrixXd::Identity(T, T));
                factorMean = CovarSum * MeanSum;
                Factors.row(n) = (factorMean + CovarSum.llt().matrixL() * normrnd(0, 1, CovarSum.rows())).transpose();

                factorVariance(n) = updateVariance(Factors.row(n), r0, R0).value();
                Numerator(n, j) = arupdater.alphag(Factors.row(n), gammas.row(n), gammastar.row(n), f2, g0, G0);
                Denominator(n, j) = arupdater.alphaj(gammastar.row(n), Factors.row(n), f2, g0, G0);
            }
            Xtfull.rightCols(nFactors) = makeOtrokXt(InfoMat, Factors, K);
            Xtk = groupByTime(Xtfull, T, K);
            FactorPosteriorDrawsj[j] = Factors;
            OmVariancePosteriorDrawsj[j] = omVariance;
            FactorVariancePosteriorDrawsj[j] = factorVariance;
        }
        posteriorStar += logavg(Numerator, 0).sum() - logavg(Denominator, 0).sum();

        cout << "Om Variance Reduced Run" << endl;
        VectorXd omVariancestar = mean(OmVariancePosteriorDrawsj);
        parama = .5 * (T + r0);
        piPosterior.resize(K, rr);
        MatrixXd Factorstar = mean(FactorPosteriorDrawsj);
        Xtfull.rightCols(nFactors) = makeOtrokXt(InfoMat, Factorstar, K);
        Xtk = groupByTime(Xtfull, T, K);
        VectorXd priorOmVarianceStar(K);
        for (int k = 0; k < K; ++k)
        {
            s2 = omVariancestar(k);
            priorOmVarianceStar(k) = loginvgammapdf(s2, .5 * r0, 1.0 / (.5 * R0));
        }
        for (int j = 0; j < rr; ++j)
        {
            cout << "RR = " << j + 1 << endl;
            for (int k = 0; k < K; ++k)
            {
                Xtemp = Xtk[k];
                s2 = omVariancestar(k);
                residuals = ythat.row(k) - betaStar.row(k) * Xtemp.transpose();
                paramb = .5 * (R0 + (residuals * residuals.transpose()).value());
                piPosterior(k, j) = loginvgammapdf(s2, parama, 1.0 / paramb);
            }
            for (int n = 0; n < nFactors; ++n)
            {
                CovarSum.setZero(T, T);
                MeanSum.setZero(T, 1);
                Icopy = zeroOutFactorLevel(I, n);
                for (int k = InfoMat.row(n).head(1).value(); k <= InfoMat.row(n).tail(1).value(); ++k)
                {
                    Xtemp = Xtk[k];
                    btemp = betaStar.row(k);
                    btemp.rightCols(nFactors) = btemp.rightCols(nFactors).array() * Icopy.row(k).array();
                    epsilons.row(k) = yt.row(k) - btemp * Xtemp.transpose();
                    if (k == InfoMat.row(n).head(1).value())
                    {
                        f2 = factorVariance(n);
                        H1 = MakePrecision(gammastar.row(n), f2, T);
                        D0 = setInitialCovar(gammastar.row(n), f2).ldlt().solve(Ilagfac);
                        H1.topLeftCorner(arOrderFac, arOrderFac) = D0;
                        CovarSum += H1;
                    }
                    else
                    {
                        s2 = omVariancestar(k);
                        s2 = 1 / s2;
                        H1 = s2 * IT;
                        CovarSum += (betaStar(k, nXs + n) * betaStar(k, nXs + n)) * H1;
                        MeanSum += betaStar(k, nXs + n) * (H1 * epsilons.row(k).transpose());
                    }
                }
                CovarSum = CovarSum.ldlt().solve(MatrixXd::Identity(T, T));
                factorMean = CovarSum * MeanSum;
                CovarSum = CovarSum.ldlt().solve(MatrixXd::Identity(T, T));
                factorMean = CovarSum * MeanSum;
                Factors.row(n) = (factorMean + CovarSum.llt().matrixL() * normrnd(0, 1, CovarSum.rows())).transpose();
                factorVariance(n) = updateVariance(Factors.row(n), r0, R0).value();
            }
            Xtfull.rightCols(nFactors) = makeOtrokXt(InfoMat, Factors, K);
            Xtk = groupByTime(Xtfull, T, K);
            FactorPosteriorDrawsj[j] = Factors;
            FactorVariancePosteriorDrawsj[j] = factorVariance;
        }
        posteriorStar += logavg(piPosterior, 0).sum();

        cout << "Factor Variance Reduced Run" << endl;
        VectorXd factorVariancestar = mean(FactorVariancePosteriorDrawsj);
        parama = .5 * (T + r0);
        piPosterior.resize(nFactors, rr);
        Factorstar = mean(FactorPosteriorDrawsj);
        Xtfull.rightCols(nFactors) = makeOtrokXt(InfoMat, Factorstar, K);
        Xtk = groupByTime(Xtfull, T, K);
        VectorXd priorFactorVarianceStar(nFactors);
        VectorXd priorFactorStar(nFactors);
        for (int n = 0; n < nFactors; ++n)
        {
            f2 = factorVariancestar(n);
            priorFactorVarianceStar(n) = loginvgammapdf(f2, .5 * r0, 1.0 / (.5 * R0));
        }
        for (int j = 0; j < rr; ++j)
        {
            cout << "RR = " << j + 1 << endl;
            for (int n = 0; n < nFactors; ++n)
            {
                CovarSum.setZero(T, T);
                MeanSum.setZero(T, 1);
                Icopy = zeroOutFactorLevel(I, n);
                for (int k = InfoMat.row(n).head(1).value(); k <= InfoMat.row(n).tail(1).value(); ++k)
                {
                    Xtemp = Xtk[k];
                    btemp = betaStar.row(k);
                    btemp.rightCols(nFactors) = btemp.rightCols(nFactors).array() * Icopy.row(k).array();
                    epsilons.row(k) = yt.row(k) - btemp * Xtemp.transpose();
                    if (k == InfoMat.row(n).head(1).value())
                    {
                        f2 = factorVariancestar(n);
                        H1 = MakePrecision(gammastar.row(n), f2, T);
                        D0 = setInitialCovar(gammastar.row(n), f2).ldlt().solve(Ilagfac);
                        H1.topLeftCorner(arOrderFac, arOrderFac) = D0;
                        CovarSum += H1;
                    }
                    else
                    {
                        s2 = omVariancestar(k);
                        s2 = 1 / s2;
                        H1 = s2 * IT;
                        CovarSum += (betaStar(k, nXs + n) * betaStar(k, nXs + n)) * H1;
                        MeanSum += betaStar(k, nXs + n) * (H1 * epsilons.row(k).transpose());
                    }
                }
                CovarSum = CovarSum.ldlt().solve(MatrixXd::Identity(T, T));
                factorMean = CovarSum * MeanSum;
                Factors.row(n) = (factorMean + CovarSum.llt().matrixL() * normrnd(0, 1, CovarSum.rows())).transpose();
                paramb = R0 + (Factors.row(n) * Factors.row(n).transpose());
                piPosterior(n, j) = loginvgammapdf(factorVariancestar(n), parama, 1.0 / paramb);
            }
            Xtfull.rightCols(nFactors) = makeOtrokXt(InfoMat, Factors, K);
            Xtk = groupByTime(Xtfull, T, K);
            FactorPosteriorDrawsj[j] = Factors;
        }
        posteriorStar += logavg(piPosterior, 0).sum();

        cout << "Final run for factors" << endl;
        Factorstar = mean(FactorPosteriorDrawsj);
        for (int n = 0; n < nFactors; ++n)
        {
            CovarSum.setZero(T, T);
            MeanSum.setZero(T, 1);
            Icopy = zeroOutFactorLevel(I, n);
            for (int k = InfoMat.row(n).head(1).value(); k <= InfoMat.row(n).tail(1).value(); ++k)
            {
                Xtemp = Xtk[k];
                btemp = betaStar.row(k);
                btemp.rightCols(nFactors) = btemp.rightCols(nFactors).array() * Icopy.row(k).array();
                epsilons.row(k) = yt.row(k) - btemp * Xtemp.transpose();
                if (k == InfoMat.row(n).head(1).value())
                {
                    f2 = factorVariancestar(n);
                    H1 = MakePrecision(gammastar.row(n), f2, T);
                    D0 = setInitialCovar(gammastar.row(n), f2).ldlt().solve(Ilagfac);
                    H1.topLeftCorner(arOrderFac, arOrderFac) = D0;
                    CovarSum += H1;
                }
                else
                {
                    s2 = omVariancestar(k);
                    s2 = 1 / s2;
                    H1 = s2 * IT;
                    CovarSum += (betaStar(k, nXs + n) * betaStar(k, nXs + n)) * H1;
                    MeanSum += betaStar(k, nXs + n) * (H1 * epsilons.row(k).transpose());
                }
            }
            CovarSum = CovarSum.ldlt().solve(MatrixXd::Identity(T, T));
            priorFactorStar(n) = logmvnpdf(Factorstar, Z1, CovarSum);
        }

        VectorXd posteriorFactorStar(nFactors, 1);
        for (int n = 0; n < nFactors; ++n)
        {
            CovarSum.setZero(T, T);
            MeanSum.setZero(T, 1);
            Icopy = zeroOutFactorLevel(I, n);
            for (int k = InfoMat.row(n).head(1).value(); k <= InfoMat.row(n).tail(1).value(); ++k)
            {
                Xtemp = Xtk[k];
                btemp = betaStar.row(k);
                btemp.rightCols(nFactors) = btemp.rightCols(nFactors).array() * Icopy.row(k).array();
                epsilons.row(k) = yt.row(k) - btemp * Xtemp.transpose();
                if (k == InfoMat.row(n).head(1).value())
                {
                    f2 = factorVariancestar(n);
                    H1 = MakePrecision(gammastar.row(n), f2, T);
                    D0 = setInitialCovar(gammastar.row(n), f2).ldlt().solve(Ilagfac);
                    H1.topLeftCorner(arOrderFac, arOrderFac) = D0;
                    CovarSum += H1;
                }
                else
                {
                    s2 = omVariancestar(k);
                    s2 = 1 / s2;
                    H1 = s2 * IT;
                    CovarSum += (betaStar(k, nXs + n) * betaStar(k, nXs + n)) * H1;
                    MeanSum += betaStar(k, nXs + n) * (H1 * epsilons.row(k).transpose());
                }
            }
            CovarSum = CovarSum.ldlt().solve(MatrixXd::Identity(T, T));
            factorMean = CovarSum * MeanSum;
            posteriorFactorStar(n) = logmvnpdf(Factorstar.row(n), factorMean.transpose(), CovarSum);
        }

        RowVectorXd Z2 = RowVectorXd::Zero(1, T);
        Xtfull.rightCols(nFactors) = makeOtrokXt(InfoMat, Factorstar, K);
        Xtk = groupByTime(Xtfull, T, K);
        VectorXd likelihood(K);
        MatrixXd Covar = MatrixXd::Identity(T, T);
        for (int k = 0; k < K; ++k)
        {
            s2 = omVariancestar(k);
            Xtemp = Xtk[k];
            residuals = ythat.row(k) - betaStar.row(k) * Xtemp.transpose();
            likelihood(k) = logmvnpdf(residuals, Z2, s2 * Covar);
        }
        double conditionalOfFactors = likelihood.sum() + priorFactorStar.sum() - posteriorFactorStar.sum();
        double priorSum = priorGammaStar.sum() + priorBetaStar.sum() + priorOmVarianceStar.sum() +
                          priorFactorVarianceStar.sum();
        marginal_likelihood = conditionalOfFactors + priorSum - posteriorStar;
        cout << "Marginal Likelihood " << marginal_likelihood << endl;
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
};
#endif