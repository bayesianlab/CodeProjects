#pragma once
#ifndef AR_H

// #include "MultilevelModel.hpp"
#include "BayesianUpdates.hpp"
#include "MultilevelModelFunctions.hpp"
#include "TimeSeriesTools.hpp"

using namespace Eigen;
using namespace std;

class AutoregressiveModel
{
public:
    MatrixXd yt;
    MatrixXd Xt;
    RowVectorXd b0;
    MatrixXd B0;
    RowVectorXd g0;
    MatrixXd G0;
    MatrixXd arparams;
    VectorXd sigma2;
    double r0;
    double R0;
    std::vector<MatrixXd> storeBeta;
    std::vector<MatrixXd> storeArParams;
    std::vector<VectorXd> storeSigma2;

    void setModel(const MatrixXd &yt, const MatrixXd &Xt, const MatrixXd &g0, const MatrixXd &G0,
                  const double &r0, const double &R0, const RowVectorXd &b0,
                  const MatrixXd &B0)
    {
        this->yt = yt;
        this->Xt = Xt;
        this->b0 = b0;
        this->B0 = B0;
        this->r0 = r0;
        this->R0 = R0;
        this->g0 = g0;
        this->G0 = G0;
        this->sigma2 = VectorXd::Ones(this->yt.rows());
    }
    void runAr(const int &Sims, const int burnin)
    {
        int T = yt.cols();
        int K = yt.rows();
        int lags = g0.cols();
        double s2;

        MatrixXd Xthat;
        MatrixXd ythat;
        MatrixXd Xtemp;
        MatrixXd epsilons;
        MatrixXd epsilonstar;
        MatrixXd mut;
        MatrixXd arparams(K, lags);
        MatrixXd betaParams(K, Xt.cols());
        MatrixXd residuals(1, T);
        MatrixXd D0(lags, lags);
        MatrixXd Ilags = MatrixXd::Identity(lags, lags);
        VectorXd sig;

        std::vector<MatrixXd> XtbyT = groupByTime(Xt, T, K);
        UnivariateBeta ub;
        ArParameterTools ar;
        ub.initializeBeta(b0);

        storeBeta.resize(Sims - burnin);
        storeArParams.resize(Sims - burnin);
        storeSigma2.resize(Sims - burnin);
        arparams = g0.replicate(K,1);

        for (int i = 0; i < Sims; ++i)
        {
            cout << "Sim " << i << endl; 
            ythat = makeStationary(yt, arparams, sigma2, 0);
            for (int k = 0; k < K; ++k)
            {
                Xtemp = XtbyT[k];
                Xthat = makeStationary(Xtemp, arparams.row(k), s2, 1);
                s2 = sigma2(k);
                ub.updateBetaUnivariate(ythat.row(k), Xthat, s2, b0, B0);
                mut = ub.bnew * Xtemp.transpose();
                epsilons = yt.row(k) - ub.bnew * Xtemp.transpose();
                ar.updateArParameters(epsilons, arparams.row(k), s2, g0, G0);
                D0 = setInitialCovar(ar.phinew, 1);
                D0 = D0.ldlt().solve(Ilags);
                D0 = D0.llt().matrixL();
                residuals.rightCols(T - lags) = ythat.row(k).rightCols(T - lags) - ub.bnew * Xthat.transpose().rightCols(T - lags);
                residuals.leftCols(lags) = epsilons.leftCols(lags)*D0;
                sigma2(k) = updateVariance(residuals, r0, R0).value();
                arparams.row(k) = ar.phinew;
                betaParams.row(k) = ub.bnew;
            }

            if (i >= burnin)
            {
                storeBeta[i - burnin] = betaParams;
                storeArParams[i - burnin] = arparams;
                storeSigma2[i - burnin] = sigma2;
            }
        }
    }
};

#endif