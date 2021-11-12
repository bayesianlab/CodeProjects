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
    string fname;
    void setModel(const Ref<const MatrixXd> &yt, const Ref<const MatrixXd> &Xt,
                  const Ref<const MatrixXd> &Ft, const Ref<const MatrixXd> &gammas, const Ref<const MatrixXd> &deltas,
                  const Matrix<int, Dynamic, 2> &InfoMat, const RowVectorXd &b0, const MatrixXd &B0, const double &r0,
                  const double &R0, const double &d0, const double &D0, const Ref<const RowVectorXd> &g0, const Ref<const MatrixXd> &G0,
                  const Ref<const RowVectorXd> &delta0, const Ref<const MatrixXd> &Delta0, const int &id)
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
        this->d0 = d0;
        this->D0 = D0;
        this->omPrecision = VectorXd::Ones(this->yt.rows());
        this->factorVariance = VectorXd::Ones(Ft.rows());
        this->omVariance = 1. / this->omPrecision.array();
        this->Identity = MakeObsModelIdentity(InfoMat, yt.rows());
        setFactors(Ft);
        int K = yt.rows();
        this->nXs = Xt.cols();
        int levels = calcLevels(InfoMat, K);
        this->id = id;
        if (nXs + levels != b0.cols())
        {
            throw invalid_argument("Error in set model, number of b0 cols must equal number of levels + nXs");
        }
    }

    void setModel(const Ref<const MatrixXd> &yt, const Ref<const MatrixXd> &Ft, const Ref<const MatrixXd> &gammas,
                  const Ref<const MatrixXd> &deltas, const Matrix<int, Dynamic, 2> &InfoMat, const RowVectorXd &b0,
                  const MatrixXd &B0, const double &r0, const double &R0, const double &d0, const double &D0,
                  const Ref<const RowVectorXd> &g0, const Ref<const MatrixXd> &G0, const Ref<const RowVectorXd> &delta0,
                  const Ref<const MatrixXd> &Delta0, const int &id)
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
        this->omPrecision = VectorXd::Ones(this->yt.rows());
        this->factorVariance = VectorXd::Ones(Ft.rows());
        this->omVariance = 1. / this->omPrecision.array();
        this->Identity = MakeObsModelIdentity(InfoMat, yt.rows());
        setFactors(Ft);
        int K = yt.rows();
        this->nXs = 0;
        int levels = calcLevels(InfoMat, K);
        this->id = id;
        if (nXs + levels != b0.cols())
        {
            throw invalid_argument("Error in set model, number of b0 cols must equal number of levels + nXs");
        }
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
        int K = yt.rows();
        this->nXs = Xt.cols();
        int levels = calcLevels(InfoMat, K);
        if (nXs + levels != b0.cols())
        {
            throw invalid_argument("Error in set model, number of b0 cols must equal number of levels + nXs");
        }
    }

    void runModelNoAr(const int &Sims, const int &burnin)
    {
        // Assumes there are Xs in the estimation
        int arOrderFac = gammas.cols();
        int K = yt.rows();
        int T = yt.cols();
        int nFactors = InfoMat.rows();
        int levels = calcLevels(InfoMat, K);
        double s2;
        BetaPosteriorDraws.resize(Sims - burnin);
        FactorPosteriorDraws.resize(Sims - burnin);
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
        MatrixXd Xtfull(K * T, Xt.cols() + levels);
        if (nXs > 0)
        {
            Xtfull.leftCols(nXs) = Xt;
        }
        Xtfull.rightCols(levels) = makeOtrokXt(InfoMat, Factors, K);
        MatrixXd btemp(1, Xtfull.cols());
        MatrixXd betaParams(K, Xtfull.cols());

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
        MatrixXd H;
        MatrixXd nu;
        MatrixXd Ilagfac = MatrixXd::Identity(arOrderFac, arOrderFac);
        std::vector<MatrixXd> Xtk;
        Xtk.resize(K);
        Xtfull.rightCols(nFactors) = makeOtrokXt(InfoMat, Factors, K);

        for (int i = 0; i < Sims; ++i)
        {
            cout << "Sim " << i + 1 << endl;
            Xtk = groupByTime(Xtfull, K);
            for (int k = 0; k < K; ++k)
            {
                Xthat = Xtk[k];
                s2 = omVariance(k);
                ub.updateBetaUnivariate(yt.row(k), Xthat, s2, b0, B0);
                betaParams.row(k) = ub.bnew;
                for (int n = 0; n < nFactors; ++n)
                {
                    if (k == InfoMat.row(n).head(1).value())
                    {
                        betaParams(k, nXs + n) = 1;
                    }
                }
                residuals = yt.row(k) - betaParams.row(k) * Xthat.transpose();
                omVariance(k) = updateVariance(residuals, r0, R0).value();
            }

            updateFactor2(Factors, yt, Xtfull, InfoMat, betaParams, omVariance, factorVariance, gammas);

            for (int n = 0; n < nFactors; ++n)
            {
                arupdater.updateArParameters(Factors.row(n), gammas.row(n), factorVariance(n), g0, G0);
                gammas.row(n) = arupdater.phinew;
                H = ReturnH(gammas.row(n), T);
                nu = (H * Factors.row(n).transpose()).transpose();
                factorVariance(n) = updateVariance(nu, r0, R0).value();
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

        int p = std::system("mkdir -p mllogfiles");
        string date = dateString();
        string version = "full_conditionals_";
        string ext = ".txt";
        string path = "mllogfiles/";
        fname = path + version + date + ext;
        std::ofstream file;
        file.open(fname);
        if (file.is_open())
        {
            storePosterior(path + version + "_beta.csv", BetaPosteriorDraws);
            // storePosterior(path + version + "deltas.csv", DeltasPosteriorDraws);
            storePosterior(path + version + date + "_gammas.csv", GammasPosteriorDraws);
            storePosterior(path + version + date + "_factors.csv", FactorPosteriorDraws);
            storePosterior(path + version + date + "_factorVariance.csv", FactorVariancePosteriorDraws);
            storePosterior(path + version + date + "_omVariance.csv", OmVariancePosteriorDraws);
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
        }
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
        int nFactors = InfoMat.rows();
        int levels = calcLevels(InfoMat, K);
        double s2;
        std::vector<MatrixXd> Xtk;

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
        MatrixXd Xtfull(K * T, nXs + levels);
        if (nXs > 0)
        {
            Xtfull.leftCols(nXs) = Xt;
        }
        Xtfull.rightCols(levels) = makeOtrokXt(InfoMat, Factors, K);
        MatrixXd Xthat(T, Xtfull.cols());
        MatrixXd epsilons(1, T);
        MatrixXd Ilagom = MatrixXd::Identity(arOrderOm, arOrderOm);
        MatrixXd residuals(1, T);
        MatrixXd I = MakeObsModelIdentity(InfoMat, K);
        MatrixXd nu;
        MatrixXd Ilagfac = MatrixXd::Identity(arOrderFac, arOrderFac);
        MatrixXi FactorInfo = createFactorInfo(InfoMat, K);

        MatrixXd betaParams(K, nXs + levels);
        betaParams.setZero(K, nXs + levels);

        betaParams = MatrixXd::Ones(K, nXs + levels) * .5;

        RowVectorXd btemp(nXs + levels);
        MatrixXi IdentificationMat = returnIdentificationRestictions(FactorInfo);
        MatrixXd H;
        int id2;
        for (int i = 0; i < Sims; ++i)
        {
            cout << "Sim " << i + 1 << endl;
            Xtk = groupByTime(Xtfull, K);
            for (int k = 0; k < K; ++k)
            {
                H = ReturnH(deltas.row(k), T);
                // ythat = makeStationary(yt.row(k), deltas.row(k), s2, 1);
                ythat = H * yt.row(k).transpose();
                ythat.transposeInPlace();
                Xthat = H * Xtk[k];

                // Xthat = makeStationary(Xtk[k], deltas.row(k), s2, 1);

                s2 = omVariance(k);
                ub.updateBetaUnivariate(ythat, Xthat, s2, b0, B0);
                betaParams.row(k) = ub.bnew;
                for (int t = 0; t < IdentificationMat.row(k).cols(); ++t)
                {
                    if (IdentificationMat(k, t) == 1)
                    {
                        // Identification scheme 1
                        if (id == 1)
                        {
                            betaParams(k, nXs + t) = 1;
                        }
                        // Identification scheme 2
                        if (id == 2)
                        {
                            if (betaParams(k, nXs + t) < 0)
                            {
                                id2 = 0;
                                while (betaParams(k, nXs + t) < 0)
                                {
                                    ub.updateBetaUnivariate(ythat, Xthat, s2, b0, B0);
                                    betaParams.row(k) = ub.bnew;
                                    id2++;
                                    if (id2 == 20)
                                    {
                                        betaParams(k, nXs + t) = abs(betaParams(k, nXs + t));
                                        break;
                                    }
                                }
                            }
                        }
                    }
                }
                epsilons = yt.row(k) - betaParams.row(k) * Xtk[k].transpose();
                arupdater.updateArParameters(epsilons, deltas.row(k), s2, g0, G0);
                deltas.row(k) = arupdater.phinew;
                // D0 = Ilagom;
                // D0 = Ilagom * (1 / s2);
                // D0 = setInitialCovar(deltas.row(k), s2);
                // D0 = D0.ldlt().solve(Ilagom);
                // D0 = D0.llt().matrixL();
                H = ReturnH(deltas.row(k), T);
                ythat = H * yt.row(k).transpose();
                ythat.transposeInPlace();
                Xthat = H * Xtk[k];
                residuals.rightCols(T - arOrderOm) = ythat.rightCols(T - arOrderOm) -
                                                     betaParams.row(k) * Xthat.transpose().rightCols(T - arOrderOm);
                residuals.leftCols(arOrderOm) = ythat.leftCols(arOrderOm);
                omVariance(k) = updateVariance(residuals, r0, R0).value();
            }

            updateFactor2(Factors, yt, Xtfull, InfoMat, betaParams, omVariance, factorVariance, deltas, gammas);

            for (int n = 0; n < nFactors; ++n)
            {
                arupdater.updateArParameters(Factors.row(n), gammas.row(n), factorVariance(n), g0, G0);
                gammas.row(n) = arupdater.phinew;
                if (id == 1)
                {
                    H = ReturnH(gammas.row(n), T);
                    nu = (H * Factors.row(n).transpose()).transpose();
                    factorVariance(n) = updateVariance(nu, d0, D0).value();
                }
            }

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

        int p = system("mkdir -p mllogfiles");
        string date = dateString();
        string version = "full_conditionals_";
        string ext = ".txt";
        string path = "mllogfiles/";
        fname = path + version + date + ext;
        std::ofstream file;
        file.open(fname);
        if (file.is_open())
        {
            storePosterior(path + version + date + "_beta.csv", BetaPosteriorDraws);
            storePosterior(path + version + date + "_deltas.csv", DeltasPosteriorDraws);
            storePosterior(path + version + date + "_gammas.csv", GammasPosteriorDraws);
            storePosterior(path + version + date + "_factors.csv", FactorPosteriorDraws);
            storePosterior(path + version + date + "_factorVariance.csv", FactorVariancePosteriorDraws);
            storePosterior(path + version + date + "_omVariance.csv", OmVariancePosteriorDraws);
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
        }
    }

    double ml()
    {
        /* Marginal likelihood. 
        * Reduced runs for betas, OM Ar parameters, Factors, Factor Variance, 
        * Factors Ar parameters. 
        */
        if (noAr)
        {
            cout << "Running No Ar Version of ml" << endl;
            return mlNoAr();
        }
        int rr = Sims - burnin;
        int T = yt.cols();
        int K = yt.rows();
        int nFactors = Factors.rows();
        int arOrderOm = DeltasPosteriorDraws[0].cols();
        int arOrderFac = GammasPosteriorDraws[0].cols();
        int levels = calcLevels(InfoMat, K);
        double s2;
        double posteriorStar = 0;
        FactorPosteriorDrawsj.resize(rr);
        GammasPosteriorDrawsj.resize(rr);
        DeltasPosteriorDrawsj.resize(rr);
        OmVariancePosteriorDrawsj.resize(rr);
        FactorVariancePosteriorDrawsj.resize(rr);
        MatrixXd ythat(1, T);
        MatrixXd Xtfull(K * T, nXs + levels);

        MatrixXd Xthat;
        MatrixXd epsilons(1, T);
        MatrixXd residuals(1, T);
        MatrixXd H1;
        MatrixXd H2;
        MatrixXd CovarSum;
        VectorXd MeanSum;
        MatrixXd I = MakeObsModelIdentity(InfoMat, K);
        MatrixXd Icopy = I;

        VectorXd factorMean;
        MatrixXd Ilagom = MatrixXd::Identity(arOrderOm, arOrderOm);
        MatrixXd Ilagfac = MatrixXd::Identity(arOrderFac, arOrderFac);
        RowVectorXd Z1 = RowVectorXd::Zero(T);
        MatrixXd IT = MatrixXd::Identity(T, T);
        if (nXs > 0)
        {
            Xtfull.leftCols(nXs) = Xt;
        }
        Xtfull.rightCols(levels) = makeOtrokXt(InfoMat, Factors, K);
        UnivariateBeta ub;
        MatrixXd piPosterior(K, rr);
        ArParameterTools arupdater;
        VectorXd priorBetaStar(K);
        MatrixXd H;
        MatrixXd nu;
        std::vector<MatrixXd> Xtk;
        Xtk.resize(K);

        cout << "Beta Reduced Runs" << endl;
        MatrixXi FactorInfo = createFactorInfo(InfoMat, K);
        MatrixXd tempX(T, nXs + levels);
        MatrixXd betaStar = mean(BetaPosteriorDraws);
        RowVectorXd btemp(nXs + levels);
        for (int k = 0; k < K; ++k)
        {
            priorBetaStar(k) = logmvnpdf(betaStar.row(k), b0, B0);
        }
        for (int j = 0; j < rr; ++j)
        {
            cout << "RR = " << j + 1 << endl;
            Factors = FactorPosteriorDraws[j];
            deltas = DeltasPosteriorDraws[j];
            gammas = GammasPosteriorDraws[j];
            omVariance = OmVariancePosteriorDraws[j];
            factorVariance = FactorVariancePosteriorDraws[j];
            Xtk = groupByTime(Xtfull, K);
            for (int k = 0; k < K; ++k)
            {
                s2 = omVariance(k);
                H = ReturnH(deltas.row(k), T);
                ythat = H * yt.row(k).transpose();
                ythat.transposeInPlace();
                Xthat = H * Xtk[k];
                // Xthat = makeStationary(Xtk[k], deltas.row(k), s2, 1);

                piPosterior(k, j) = ub.betaReducedRun(betaStar.row(k), ythat, Xthat, s2, b0, B0);

                epsilons = yt.row(k) - betaStar.row(k) * Xtk[k].transpose();
                arupdater.updateArParameters(epsilons, deltas.row(k), s2, g0, G0);
                deltas.row(k) = arupdater.phinew;
                // D0 = Ilagom * (1 / s2);
                // D0 = setInitialCovar(deltas.row(k), 1);
                // D0 = D0.ldlt().solve(Ilagom);
                // D0 = D0.llt().matrixL();
                H = ReturnH(deltas.row(k), T);
                ythat = H * yt.row(k).transpose();
                ythat.transposeInPlace();
                Xthat = H * Xtk[k];
                residuals.rightCols(T - arOrderOm) = ythat.rightCols(T - arOrderOm) -
                                                     betaStar.row(k) * Xthat.transpose().rightCols(T - arOrderOm);
                residuals.leftCols(arOrderOm) = ythat.leftCols(arOrderOm);
                omVariance(k) = updateVariance(residuals, r0, R0).value();
            }

            updateFactor2(Factors, yt, Xtfull, InfoMat, betaStar, omVariance, factorVariance, deltas, gammas);

            for (int n = 0; n < nFactors; ++n)
            {
                arupdater.updateArParameters(Factors.row(n), gammas.row(n), factorVariance(n), g0, G0);
                gammas.row(n) = arupdater.phinew;
                if (id == 1)
                {
                    H = ReturnH(gammas.row(n), T);
                    nu = (H * Factors.row(n).transpose()).transpose();
                    factorVariance(n) = updateVariance(nu, d0, D0).value();
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
            Factors = FactorPosteriorDrawsj[j];
            factorVariance = FactorVariancePosteriorDrawsj[j];
            Xtk = groupByTime(Xtfull, K);

            for (int k = 0; k < K; ++k)
            {
                s2 = omVariance(k);
                H = ReturnH(deltastar.row(k), T);
                ythat = H * yt.row(k).transpose();
                ythat.transposeInPlace();
                Xthat = H * Xtk[k];
                epsilons = yt.row(k) - betaStar.row(k) * Xtk[k].transpose();
                Numerator(k, j) = arupdater.alphag(epsilons, deltas.row(k), deltastar.row(k), s2, g0, G0);
                Denominator(k, j) = arupdater.alphaj(deltastar.row(k), epsilons, s2, g0, G0);
                // D0 = Ilagom;
                // D0 = Ilagom * (1 / s2);
                // D0 = setInitialCovar(deltastar.row(k), 1);
                // D0 = D0.ldlt().solve(Ilagom);
                // D0 = D0.llt().matrixL();
                H = ReturnH(deltastar.row(k), T);
                ythat = H * yt.row(k).transpose();
                ythat.transposeInPlace();
                Xthat = H * Xtk[k];
                residuals.rightCols(T - arOrderOm) = ythat.rightCols(T - arOrderOm) -
                                                     betaStar.row(k) * Xthat.transpose().rightCols(T - arOrderOm);
                residuals.leftCols(arOrderOm) = ythat.leftCols(arOrderOm);
                omVariance(k) = updateVariance(residuals, r0, R0).value();
            }
            updateFactor2(Factors, yt, Xtfull, InfoMat, betaStar, omVariance, factorVariance, deltastar, gammas);

            for (int n = 0; n < nFactors; ++n)
            {
                arupdater.updateArParameters(Factors.row(n), gammas.row(n), factorVariance(n), g0, G0);
                gammas.row(n) = arupdater.phinew;
                if (id == 1)
                {
                    H = ReturnH(gammas.row(n), T);
                    nu = (H * Factors.row(n).transpose()).transpose();
                    factorVariance(n) = updateVariance(nu, d0, D0).value();
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
        for (int n = 0; n < nFactors; ++n)
        {
            priorGammaStar(n) = logmvnpdf(gammastar.row(n), g0, G0);
            StoreH[n] = ReturnH(gammastar.row(n), T);
        }
        for (int j = 0; j < rr; ++j)
        {
            cout << "RR = " << j + 1 << endl;
            Factors = FactorPosteriorDraws[j];
            omVariance = OmVariancePosteriorDrawsj[j];
            gammas = GammasPosteriorDrawsj[j];
            factorVariance = FactorVariancePosteriorDrawsj[j];
            Xtfull.rightCols(levels) = makeOtrokXt(InfoMat, Factors, K);
            Xtk = groupByTime(Xtfull, K);
            for (int k = 0; k < K; ++k)
            {
                s2 = omVariance(k);
                H = ReturnH(deltastar.row(k), T);
                ythat = H * yt.row(k).transpose();
                ythat.transposeInPlace();
                Xthat = H * Xtk[k];
                epsilons = yt.row(k) - betaStar.row(k) * Xtk[k].transpose();
                // D0 = Ilagom * (1 / s2);
                // D0 = setInitialCovar(deltastar.row(k), 1);
                // D0 = D0.ldlt().solve(Ilagom);
                // D0 = D0.llt().matrixL();
                H = ReturnH(deltastar.row(k), T);
                ythat = H * yt.row(k).transpose();
                ythat.transposeInPlace();
                Xthat = H * Xtk[k];
                residuals.rightCols(T - arOrderOm) = ythat.rightCols(T - arOrderOm) -
                                                     betaStar.row(k) * Xthat.transpose().rightCols(T - arOrderOm);
                residuals.leftCols(arOrderOm) = ythat.leftCols(arOrderOm);
                omVariance(k) = updateVariance(residuals, r0, R0).value();
            }

            updateFactor2(Factors, yt, Xtfull, InfoMat, betaStar, omVariance, factorVariance, deltastar, gammastar);

            for (int n = 0; n < nFactors; ++n)
            {
                f2 = factorVariance(n);
                Numerator(n, j) = arupdater.alphag(Factors.row(n), gammas.row(n), gammastar.row(n), f2, g0, G0);
                Denominator(n, j) = arupdater.alphaj(gammastar.row(n), Factors.row(n), f2, g0, G0);
                if (id == 1)
                {
                    H = ReturnH(gammas.row(n), T);
                    nu = (H * Factors.row(n).transpose()).transpose();
                    factorVariance(n) = updateVariance(nu, d0, D0).value();
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
        piPosterior.resize(K, rr);
        double parama = .5 * (T + r0);
        double paramb;
        Xtfull.rightCols(levels) = makeOtrokXt(InfoMat, Factorstar, K);
        VectorXd priorOmVarianceStar(K);

        for (int k = 0; k < K; ++k)
        {
            s2 = omVariancestar(k);
            priorOmVarianceStar(k) = loginvgammapdf(s2, .5 * r0, .5 * R0);
        }
        for (int j = 0; j < rr; ++j)
        {
            cout << "RR = " << j + 1 << endl;
            Xtk = groupByTime(Xtfull, K);
            factorVariance = FactorVariancePosteriorDrawsj[j];
            for (int k = 0; k < K; ++k)
            {
                s2 = omVariancestar(k);
                H = ReturnH(deltastar.row(k), T);
                ythat = H * yt.row(k).transpose();
                ythat.transposeInPlace();
                Xthat = H * Xtk[k];
                residuals = ythat - betaStar.row(k) * Xthat.transpose();
                paramb = .5 * (R0 + (residuals * residuals.transpose()).value());
                piPosterior(k, j) = loginvgammapdf(s2, parama, paramb);
            }
            updateFactor2(Factors, yt, Xtfull, InfoMat, betaStar, omVariancestar, factorVariance,
                          deltastar, gammastar);

            for (int n = 0; n < nFactors; ++n)
            {
                if (id == 1)
                {
                    H = StoreH[n];
                    nu = (H * Factors.row(n).transpose()).transpose();
                    factorVariance(n) = updateVariance(nu, d0, D0).value();
                }
            }
            FactorPosteriorDrawsj[j] = Factors;
            FactorVariancePosteriorDrawsj[j] = factorVariance;
        }
        posteriorStar += logavg(piPosterior, 0).sum();
        cout << "Factor Variance Reduced Run (if id == 1)" << endl;
        VectorXd factorVariancestar = mean(FactorVariancePosteriorDrawsj);
        VectorXd priorFactorVarianceStar(nFactors);
        cout << posteriorStar << endl;
        if (id == 1)
        {

            parama = .5 * (T + r0);
            piPosterior.resize(nFactors, rr);
            Factorstar = mean(FactorPosteriorDrawsj);
            Xtfull.rightCols(levels) = makeOtrokXt(InfoMat, Factorstar, K);
            Xtk = groupByTime(Xtfull, K);
            for (int n = 0; n < nFactors; ++n)
            {
                f2 = factorVariancestar(n);
                priorFactorVarianceStar(n) = loginvgammapdf(f2, .5 * d0, .5 * D0);
            }

            for (int j = 0; j < rr; ++j)
            {
                cout << "RR = " << j + 1 << endl;
                updateFactor2(Factors, yt, Xtfull, InfoMat, betaStar, omVariancestar,
                              factorVariancestar, deltastar, gammastar);
                for (int n = 0; n < nFactors; ++n)
                {
                    H = StoreH[n];
                    nu = (H * Factors.row(n).transpose()).transpose();
                    paramb = .5 * (R0 + (nu * nu.transpose()).value());
                    piPosterior(n, j) = loginvgammapdf(factorVariancestar(n), parama, paramb);
                }
                FactorPosteriorDrawsj[j] = Factors;
            }
            posteriorStar += logavg(piPosterior, 0).sum();
            cout << posteriorStar << endl;
        }

        // cout << mean(FactorVariancePosteriorDraws).transpose() << endl;
        // cout << mean(OmVariancePosteriorDrawsj).transpose() << endl;
        cout << factorVariancestar << endl;
        cout << "Final run for factors" << endl;
        Factorstar = mean(FactorPosteriorDrawsj);
        MatrixXd fp = g0.replicate(nFactors, 1);
        VectorXd priorFactorStar = evalFactorPriors(Factorstar, InfoMat, factorVariancestar, fp);
        VectorXd posteriorFactorStar(nFactors, 1);
        posteriorFactorStar = factorReducedRun(Factorstar, yt, Xtfull, InfoMat, betaStar, omVariancestar,
                                               factorVariancestar, deltastar, gammastar);
        RowVectorXd Z2 = RowVectorXd::Zero(1, T);
        Xtfull.rightCols(levels) = makeOtrokXt(InfoMat, Factorstar, K);
        Xtk = groupByTime(Xtfull, K);
        VectorXd likelihood(K);
        MatrixXd Covar = MatrixXd::Identity(T, T);
        for (int k = 0; k < K; ++k)
        {
            s2 = omVariancestar(k);
            H = ReturnH(deltastar.row(k), T);
            ythat = H * yt.row(k).transpose();
            ythat.transposeInPlace();
            Xthat = H * Xtk[k];
            residuals = ythat - betaStar.row(k) * Xthat.transpose();
            likelihood(k) = logmvnpdf(residuals, Z2, s2 * Covar);
        }
        cout << likelihood.sum() << endl;
        cout << priorFactorStar.sum() << endl;
        cout << posteriorFactorStar.sum() << endl;
        double conditionalOfFactors = likelihood.sum() + priorFactorStar.sum() - posteriorFactorStar.sum();
        double priorSum;
        if (id == 1)
        {
            priorSum = priorGammaStar.sum() + priorBetaStar.sum() + priorOmVarianceStar.sum() +
                       priorFactorVarianceStar.sum() + priorDeltaStar.sum();
        }
        else
        {
            priorSum = priorGammaStar.sum() + priorBetaStar.sum() + priorOmVarianceStar.sum() +
                       +priorDeltaStar.sum();
        }

        marginal_likelihood = conditionalOfFactors + priorSum - posteriorStar;
        cout << priorSum << endl;
        cout << posteriorStar << endl;
        cout << "Marginal Likelihood " << marginal_likelihood << endl;

        std::ofstream file(fname, ios_base::app | ios_base::out);
        if (file.is_open())
        {
            file << "Marginal Likelihood: " << marginal_likelihood << endl;
        }

        return marginal_likelihood;
    }

    double
    mlNoAr()
    {
        /* Marginal likelihood. 
        * Reduced runs for betas, OM Ar parameters, Factors, Factor Variance, 
        * Factors Ar parameters. 
        */
        int rr = Sims - burnin;
        int T = yt.cols();
        int K = yt.rows();
        int nFactors = Factors.rows();
        int levels = calcLevels(InfoMat, K);
        int arOrderFac = GammasPosteriorDraws[0].cols();
        double s2;
        double posteriorStar = 0;
        FactorPosteriorDrawsj.resize(rr);
        GammasPosteriorDrawsj.resize(rr);
        OmVariancePosteriorDrawsj.resize(rr);
        FactorVariancePosteriorDrawsj.resize(rr);
        MatrixXd ythat(K, T);
        MatrixXd Xtfull(K * T, nXs + levels);

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
        VectorXd factorMean;
        MatrixXd Ilagfac = MatrixXd::Identity(arOrderFac, arOrderFac);
        RowVectorXd Z1 = RowVectorXd::Zero(T);
        MatrixXd IT = MatrixXd::Identity(T, T);
        MatrixXd H(T, T);
        MatrixXd nu(1, T);
        if (nXs > 0)
        {
            Xtfull.leftCols(nXs) = Xt;
        }
        Xtfull.rightCols(levels) = makeOtrokXt(InfoMat, Factors, K);
        UnivariateBeta ub;
        MatrixXd piPosterior(K, rr);
        ArParameterTools arupdater;
        VectorXd priorBetaStar(K);
        MatrixXi FactorInfo = createFactorInfo(InfoMat, K);
        std::vector<MatrixXd> Xtk;
        Xtk.resize(K);

        ythat = yt;
        cout << "Beta Reduced Runs" << endl;
        MatrixXd tempX(T, nXs + levels);
        MatrixXd betaStar = mean(BetaPosteriorDraws);
        RowVectorXd btemp(nXs + levels);
        for (int k = 0; k < K; ++k)
        {
            priorBetaStar(k) = logmvnpdf(betaStar.row(k), b0, B0);
        }
        for (int j = 0; j < rr; ++j)
        {
            cout << "RR = " << j + 1 << endl;
            Factors = FactorPosteriorDraws[j];
            gammas = GammasPosteriorDraws[j];
            omVariance = OmVariancePosteriorDraws[j];
            Xtfull.rightCols(levels) = makeOtrokXt(InfoMat, Factors, K);
            Xtk = groupByTime(Xtfull, K);
            for (int k = 0; k < K; ++k)
            {
                s2 = omVariance(k);
                piPosterior(k, j) = ub.betaReducedRun(betaStar.row(k), yt.row(k), Xtk[k], s2, b0, B0);
                epsilons = yt.row(k) - betaStar.row(k) * Xtk[k].transpose();
                omVariance(k) = updateVariance(residuals, r0, R0).value();
            }

            updateFactor2(Factors, yt, Xtfull, InfoMat, betaStar, omVariance, factorVariance, gammas);

            for (int n = 0; n < nFactors; ++n)
            {
                arupdater.updateArParameters(Factors.row(n), gammas.row(n), factorVariance(n), g0, G0);
                gammas.row(n) = arupdater.phinew;
                H = ReturnH(gammas.row(n), T);
                nu = (H * Factors.row(n).transpose()).transpose();
                factorVariance(n) = updateVariance(nu, r0, R0).value();
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
        for (int n = 0; n < nFactors; ++n)
        {
            priorGammaStar(n) = logmvnpdf(gammastar.row(n), g0, G0);
            StoreH[n] = ReturnH(gammastar.row(n), T);
        }
        for (int j = 0; j < rr; ++j)
        {
            cout << "RR = " << j + 1 << endl;
            Factors = FactorPosteriorDraws[j];
            omVariance = OmVariancePosteriorDrawsj[j];
            gammas = GammasPosteriorDrawsj[j];
            Xtfull.rightCols(levels) = makeOtrokXt(InfoMat, Factors, K);
            Xtk = groupByTime(Xtfull, K);
            for (int k = 0; k < K; ++k)
            {
                s2 = omVariance(k);
                epsilons = yt.row(k) - betaStar.row(k) * Xtk[k].transpose();
                omVariance(k) = updateVariance(epsilons, r0, R0).value();
            }

            updateFactor2(Factors, yt, Xtfull, InfoMat, betaStar, omVariance, factorVariance, gammastar);

            for (int n = 0; n < nFactors; ++n)
            {
                f2 = factorVariance(n);
                Numerator(n, j) = arupdater.alphag(Factors.row(n), gammas.row(n), gammastar.row(n), f2, g0, G0);
                Denominator(n, j) = arupdater.alphaj(gammastar.row(n), Factors.row(n), f2, g0, G0);
                H = StoreH[n];
                nu = (H * Factors.row(n).transpose()).transpose();
                factorVariance(n) = updateVariance(nu, r0, R0).value();
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
        Xtfull.rightCols(levels) = makeOtrokXt(InfoMat, Factorstar, K);
        Xtk = groupByTime(Xtfull, K);
        VectorXd priorOmVarianceStar(K);
        for (int k = 0; k < K; ++k)
        {
            s2 = omVariancestar(k);
            priorOmVarianceStar(k) = loginvgammapdf(s2, .5 * r0, .5 * R0);
        }
        for (int j = 0; j < rr; ++j)
        {
            cout << "RR = " << j + 1 << endl;

            for (int k = 0; k < K; ++k)
            {
                s2 = omVariancestar(k);
                residuals = yt.row(k) - betaStar.row(k) * Xtk[k].transpose();
                paramb = .5 * (R0 + (residuals * residuals.transpose()).value());
                piPosterior(k, j) = loginvgammapdf(s2, parama, paramb);
            }
            updateFactor2(Factors, yt, Xtfull, InfoMat, betaStar, omVariancestar, factorVariance, gammastar);

            for (int n = 0; n < nFactors; ++n)
            {
                H = StoreH[n];
                nu = (H * Factors.row(n).transpose()).transpose();
                factorVariance(n) = updateVariance(nu, r0, R0).value();
            }
            FactorPosteriorDrawsj[j] = Factors;
            FactorVariancePosteriorDrawsj[j] = factorVariance;
        }
        posteriorStar += logavg(piPosterior, 0).sum();

        cout << "Factor Variance Reduced Run" << endl;
        VectorXd factorVariancestar = mean(FactorVariancePosteriorDrawsj);
        parama = .5 * (T + r0);
        piPosterior.resize(nFactors, rr);
        Factors = mean(FactorPosteriorDrawsj);
        VectorXd priorFactorVarianceStar(nFactors);
        for (int n = 0; n < nFactors; ++n)
        {
            f2 = factorVariancestar(n);
            priorFactorVarianceStar(n) = loginvgammapdf(f2, .5 * r0, (.5 * R0));
        }
        for (int j = 0; j < rr; ++j)
        {

            cout << "RR = " << j + 1 << endl;
            updateFactor2(Factors, yt, Xtfull, InfoMat, betaStar, omVariancestar, factorVariancestar, gammastar);

            for (int n = 0; n < nFactors; ++n)
            {
                H = StoreH[n];
                nu = (H * Factors.row(n).transpose()).transpose();
                paramb = .5 * (R0 + (nu * nu.transpose()).value());
                piPosterior(n, j) = loginvgammapdf(factorVariancestar(n), parama, paramb);
            }
            FactorPosteriorDrawsj[j] = Factors;
            FactorVariancePosteriorDrawsj[j] = factorVariance;
        }
        posteriorStar += logavg(piPosterior, 0).sum();

        cout << "Final run for factors" << endl;
        Factorstar = mean(FactorPosteriorDrawsj);
        VectorXd priorFactorStar = evalFactorPriors(Factorstar, InfoMat, factorVariance, gammastar);
        VectorXd posteriorFactorStar = factorReducedRun(Factorstar, yt, Xtfull, InfoMat, betaStar, omVariancestar,
                                                        factorVariance, gammastar);

        RowVectorXd Z2 = RowVectorXd::Zero(1, T);
        Xtfull.rightCols(levels) = makeOtrokXt(InfoMat, Factorstar, K);
        Xtk = groupByTime(Xtfull, K);
        VectorXd likelihood(K);
        MatrixXd Covar = MatrixXd::Identity(T, T);
        for (int k = 0; k < K; ++k)
        {
            s2 = omVariancestar(k);
            residuals = yt.row(k) - betaStar.row(k) * Xtk[k].transpose();
            likelihood(k) = logmvnpdf(residuals, Z2, s2 * Covar);
        }

        double conditionalOfFactors = likelihood.sum() + priorFactorStar.sum() - posteriorFactorStar.sum();
        double priorSum = priorGammaStar.sum() + priorBetaStar.sum() + priorOmVarianceStar.sum() +
                          priorFactorVarianceStar.sum();

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
        std::ofstream file(fname.c_str());
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