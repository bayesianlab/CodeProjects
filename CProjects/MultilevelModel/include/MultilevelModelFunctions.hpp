#pragma once
#ifndef MLFUNC_H
#define MLFUNC_H
#include <iostream>
#include <stdexcept>
#include <math.h>

#include <eigen-3.3.9/Eigen/Dense>
#include <eigen-3.3.9/unsupported/Eigen/KroneckerProduct>

#include "Distributions.hpp"
#include "EigenTools.hpp"
#include "TimeSeries.hpp"

using namespace Eigen;
using namespace std;


MatrixXd makeOtrokXt(const Matrix<int, Dynamic, 2> &InfoMat, const Ref<MatrixXd> &Factors,
                     const int &nXs, const int &K);




MatrixXd updateFactor(const MatrixXd &residuals, const MatrixXd &Loadings,
                      const MatrixXd &FactorPrecision, const VectorXd &precision, int T);



MatrixXd MakeObsModelIdentity(const Matrix<int, Dynamic, 2> &m, int eqns);



template <typename D>
MatrixXd zeroOutFactorLevel(const MatrixBase<D> &Id, int level)
{
    MatrixXd I = Id;
    I.col(level) = MatrixXd::Zero(I.rows(), 1);
    return I;
}




template <typename D1>
VectorXd gamma_G(const int &rr, const MatrixBase<D1> &gammastar, const std::vector<MatrixXd> &gammagPosterior, const std::vector<MatrixXd> &ytPosterior,
                 const std::vector<VectorXd> &sigma2Posterior, const MatrixXd &priorMean, const MatrixXd &priorVar)
{
    /* current comes in as a row, priorMean comes in as a row */
    int nFactors = gammastar.rows();
    int lags = gammastar.cols();
    int T = ytPosterior[0].cols();
    MatrixXd yt;
    MatrixXd Xt;
    MatrixXd ytstar;
    MatrixXd Ip;
    MatrixXd XX;
    MatrixXd g1;
    MatrixXd Xy;
    MatrixXd G1;
    MatrixXd Pstar;
    MatrixXd G1L;
    MatrixXd Pg(lags, lags);
    MatrixXd Xp;
    MatrixXd empty;
    MatrixXd Sstar;
    MatrixXd Sg;
    MatrixXd Xss(lags, T);
    MatrixXd ZeroMean;
    double qg;
    double val;
    double lalphaqg;

    MatrixXd gammag;
    VectorXd sigma2;
    VectorXd numerator(nFactors * rr);
    int d = 0;
    for (int i = 0; i < rr; ++i)
    {
        yt = ytPosterior[i];
        gammag = gammagPosterior[i];
        sigma2 = sigma2Posterior[i];
        for (int k = 0; k < nFactors; ++k)
        {
            Xt = lag(yt.row(k), lags, 0);
            ytstar = yt.row(k).rightCols(T - lags);
            Ip = MatrixXd::Identity(lags, lags);
            XX = Xt * Xt.transpose();
            XX = XX.array() / sigma2[k];
            G1 = priorVar.householderQr().solve(Ip);
            g1 = G1 * priorMean.transpose();
            G1 = (G1 + XX).householderQr().solve(Ip);
            Xy = (Xt * ytstar.transpose()).array() / sigma2[k];
            g1 = (G1 * (g1 + Xy)).transpose();
            Matrix<double, 1, 1> s2;
            s2 << sigma2[k];
            Pstar = setInitialCovar(gammastar.row(k), s2);
            G1L = G1.llt().matrixL();

            Pg = setInitialCovar(gammag.row(k), s2);
            Xp = MatrixXd::Zero(lags, lags);
            empty;
            for (int i = 1; i < lags; ++i)
            {
                empty = yt.row(k).leftCols(i);
                empty.resize(i, 1);
                Xp.col(i).segment(lags - i, i) = empty;
                empty.resize(0, 0);
            }
            Sstar = s2.replicate(T, 1).asDiagonal();
            Sg = Sstar;
            Sstar.topLeftCorner(lags, lags) = Pstar;
            Sg.topLeftCorner(lags, lags) = Pg;
            Xss << Xp, Xt;
            ZeroMean = MatrixXd::Zero(1, T);
            qg = logmvnpdf(gammastar.row(k), g1, G1);
            val = (logmvnpdf(yt.row(k) - gammastar.row(k) * Xss, ZeroMean, Sstar) +
                   logmvnpdf(gammastar.row(k), priorMean, priorVar) +
                   logmvnpdf(gammag.row(k), g1, G1)) -
                  (logmvnpdf(yt.row(k) - gammag.row(k) * Xss, ZeroMean, Sg) +
                   logmvnpdf(gammag.row(k), priorMean, priorVar) +
                   qg);
            lalphaqg = min(0., val);
            lalphaqg = lalphaqg + qg;
            numerator(d);
            ++d;
        }
        return numerator;
    }
    return numerator;
}

template <typename D1, typename D2>
double gamma_J(const MatrixBase<D1> &gammastar, const MatrixBase<D2> &yt, const double &sigma2,
               const MatrixXd &priorMean, const MatrixXd &priorVar)
{

    /* current comes in as a row, priorMean comes in as a row */
    int rows = gammastar.rows();
    int lags = gammastar.cols();
    int T = yt.cols();
    if (rows > lags)
    {
        throw invalid_argument("Invalid input in updateAR, rows greater than cols.");
    }
    MatrixXd Xt = lag(yt, lags, 0);
    MatrixXd ytstar = yt.rightCols(T - lags);
    MatrixXd Ip = MatrixXd::Identity(lags, lags);
    MatrixXd XX = Xt * Xt.transpose();
    XX = XX.array() / sigma2;
    MatrixXd G1 = priorVar.householderQr().solve(Ip);
    MatrixXd g1 = G1 * priorMean.transpose();
    G1 = (G1 + XX).householderQr().solve(Ip);

    MatrixXd Xy = (Xt * ytstar.transpose()).array() / sigma2;
    g1 = (G1 * (g1 + Xy)).transpose();

    Matrix<double, 1, 1> s2;
    s2 << sigma2;
    MatrixXd P0 = setInitialCovar(gammastar, s2);
    MatrixXd G1L = G1.llt().matrixL();
    MatrixXd P1(lags, lags);
    int MAX_TRIES = 10;
    int count = 0;
    int notvalid = 1;
    MatrixXd proposal = g1;
    while ((notvalid == 1))
    {
        proposal = (g1.transpose() + G1L * normrnd(0, 1, lags, 1)).transpose();
        P1 = setInitialCovar(proposal, s2);
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
                  logmvnpdf(gammastar, g1, G1)) -
                 (logmvnpdf(yt - gammastar * Xss, ZeroMean, Scur) +
                  logmvnpdf(gammastar, priorMean, priorVar) +
                  logmvnpdf(proposal, g1, G1));
    double lalpha = min(0., val);
    return lalpha;
}

template <typename T>
MatrixXd mean(const std::vector<T> &X)
{
    MatrixXd avg;
    avg.setZero(X[0].rows(), X[0].cols());
    for (T i : X)
    {
        avg += i;
    }
    return avg.array() / X.size();
}

template <typename D1, typename D2, typename D3, typename D4, typename D5,
          typename D6, typename D7>
double ConditionalLogLikelihood(const MatrixBase<D1> &guess, const MatrixBase<D2> &resids,
                                const MatrixBase<D3> &priorMeanA0, const MatrixBase<D4> &priorPrecisionA0,
                                const MatrixBase<D5> &obsPrecision, const MatrixBase<D6> &factor,
                                const MatrixBase<D7> &FactorPrecision)
{
    /* Guess comes in as a column, resids is modified inside */
    /* likelihood for one factor alone */
    /* priorMeanA0 is a row */
    int T = factor.cols();
    int K = obsPrecision.size();
    MatrixXd Avariance = (obsPrecision * (factor * factor.transpose())).asDiagonal();
    Avariance = priorPrecisionA0 + Avariance;
    Avariance = Avariance.ldlt().solve(MatrixXd::Identity(K, K));
    MatrixXd Amean = (factor * resids.transpose()).array() * obsPrecision.transpose().array();
    Amean.resize(Amean.rows() * Amean.cols(), 1);
    Amean = Avariance * (priorPrecisionA0 * priorMeanA0.transpose() + Amean);
    double pdfA = logmvnpdf(guess.transpose(), Amean.transpose(), Avariance);
    MatrixXd AOI = guess.transpose() * obsPrecision.asDiagonal();
    MatrixXd Fvariance = (VectorXd::Ones(T) * (AOI * guess)).asDiagonal();
    Fvariance = FactorPrecision + Fvariance;
    Fvariance = (Fvariance).ldlt().solve(MatrixXd::Identity(T, T));
    MatrixXd Fmean = AOI * resids;
    Fmean.resize(T, 1);
    Fmean = Fvariance * Fmean;
    return pdfA - logmvnpdf(factor, Fmean.transpose(), Fvariance);
}


#endif