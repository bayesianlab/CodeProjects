#pragma once
#ifndef AR_H

#include "MultilevelModel.hpp"
#include "BayesianUpdates.hpp"
#include "MultilevelModelFunctions.hpp"

using namespace Eigen;
using namespace std;

template <typename D1, typename D2>
MatrixXd updateAR(const MatrixBase<D1> &current, const MatrixBase<D2> &yt, const double &sigma2,
                  const MatrixXd &priorMean, const MatrixXd &priorVar)
{
    /* current comes in as a row, priorMean comes in as a row */
    int rows = current.rows();
    int lags = current.cols();
    int T = yt.cols();
    if (rows > lags)
    {
        throw invalid_argument("Invalid input in updateAR, rows greater than cols.");
    }
    MatrixXd Xt = lag(yt, lags);
    MatrixXd ytstar = yt.rightCols(T - lags);
    MatrixXd Ip = MatrixXd::Identity(lags, lags);
    MatrixXd XX = Xt * Xt.transpose();
    XX = XX.array() / sigma2;

    MatrixXd G1 = priorVar.ldlt().solve(Ip);
    MatrixXd g1 = G1 * priorMean.transpose();
    G1 = (G1 + XX).ldlt().solve(Ip);

    MatrixXd Xy = (Xt * ytstar.transpose()).array() / sigma2;
    g1 = (G1 * (g1 + Xy)).transpose();

    Matrix<double, 1, 1> s2;
    s2 << sigma2;
    MatrixXd P0 = setCovar(current, s2);
    MatrixXd G1L = G1.llt().matrixL();
    MatrixXd P1(lags, lags);
    int MAX_TRIES = 10;
    int count = 0;
    int notvalid = 1;
    MatrixXd proposal = g1;
    while ((notvalid == 1))
    {
        proposal = (g1.transpose() + G1L * normrnd(0, 1, lags, 1)).transpose();
        P1 = setCovar(proposal, s2);
        if (isPD(P1))
        {
            notvalid = 0;
        }
        if (count == MAX_TRIES)
        {
            P1 = MatrixXd::Identity(lags, lags);
            break;
        }
        ++count;
    }

    MatrixXd Xp = MatrixXd::Zero(lags, lags);
    MatrixXd empty;
    for (int i = 1; i < lags; ++i)
    {
        empty = yt.leftCols(i);
        empty.resize(i, 1);
        Xp.col(i).segment(lags - i, i) = empty;
        empty.resize(0, 0);
    }
    MatrixXd Scur = s2.replicate(T, 1).asDiagonal();
    MatrixXd Snew = Scur;
    Scur.topLeftCorner(lags, lags) = P0;
    Snew.topLeftCorner(lags, lags) = P1;
    MatrixXd Xss(lags, T);
    Xss << Xp, Xt;
    MatrixXd ZeroMean = MatrixXd::Zero(1, T);
    double val = (logmvnpdf(yt - proposal * Xss, ZeroMean, Snew) +
                  logmvnpdf(proposal, priorMean, priorVar) +
                  logmvnpdf(current, g1, G1)) -
                 (logmvnpdf(yt - current * Xss, ZeroMean, Scur) +
                  logmvnpdf(current, priorMean, priorVar) +
                  logmvnpdf(proposal, g1, G1));
    double lalpha = min(0., val);
    if (log(unifrnd(0, 1)) < lalpha)
    {
        return proposal;
    }
    else
    {
        return current;
    }
}

class AutoregressiveModel
{
public:
    MatrixXd yt;
    MatrixXd Xt;
    RowVectorXd b0;
    MatrixXd B0;
    MatrixXd arparams;
    VectorXd sigma2;
    double r0;
    double R0;
    void setModel(const MatrixXd &yt, const MatrixXd &Xt, const MatrixXd &arparams,
                  const double &r0, const double &R0, const RowVectorXd &b0, const MatirxXd &B0)
    {
        this->yt = yt;
        this->Xt = Xt;
        this->b0 = b0;
        this->B0 = B0;
        this->r0 = r0;
        this->R0 = R0;
        this->arparams = arparams;
        this->sigma2 = VectorXd::Identity(yt.rows());
    }
    void runAr(int Sims)
    {
        int T = yt.cols();
        int K = yt.rows();
        MatrixXd Xtemp;
        std::vector<MatrixXd> XtbyT = groupByTime(Xt, T, K);
        UnivariateBeta ub;
        for (int i = 0; i < Sims; ++i)
        {
            for (int k = 0; k < K; ++k)
            {
                Xtemp = XtbyT[k];
                ub.updateBetaUnivariate(yt.row(k), Xtemp, )
            }
        }
    }
};

#endif