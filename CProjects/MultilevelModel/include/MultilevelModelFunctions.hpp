#pragma once
#ifndef MLFUNC_H
#define MLFUNC_H
#include <iostream>
#include <stdexcept>
#include <math.h>

#include <Eigen/Dense>
#include <unsupported/Eigen/KroneckerProduct>

#include "Distributions.hpp"
#include "EigenTools.hpp"
#include "TimeSeriesTools.hpp"

using namespace Eigen;
using namespace std;

MatrixXd makeOtrokXt(const Matrix<int, Dynamic, 2> &InfoMat, const Ref<MatrixXd> &Factors,
                     const int &K);

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

template <typename T0, typename T1, typename T2, typename T3, typename T4>
MatrixXd otrokFactorUpdate(const MatrixBase<T0> &Factors, const MatrixXd &yt, std::vector<MatrixXd> &Xtk, const MatrixBase<T1> &betaParams,
                           const double &loading, const MatrixBase<T2> &gammas, const MatrixBase<T3> &deltas,
                           const VectorXd &omVariance, const VectorXd &factorVariance, const MatrixBase<T4> &Identity,
                           const Matrix<int, 1, 2> &InfoMatRow)
{
    int nFactors = Factors.rows();
    int T = Factors.cols();
    int K = deltas.rows();
    int nXs = Xtk[0].cols();
    double s2;
    MatrixXd CovarSum;
    MatrixXd MeanSum;
    MatrixXd Xtemp;
    MatrixXd btemp;
    MatrixXd D0;
    MatrixXd H1;
    MatrixXd Ilagfac = MatrixXd::Identity(gammas.cols(), gammas.cols());
    MatrixXd Ilagom = MatrixXd::Identity(deltas.cols(), deltas.cols());
    MatrixXd factorMean;
    MatrixXd epsilons(1, T);
    CovarSum.setZero(T, T);
    MeanSum.setZero(T, 1);
    for (int k = InfoMatRow.head(1).value(); k <= InfoMatRow.tail(1).value(); ++k)
    {
        Xtemp = Xtk[k];
        btemp = betaParams.row(k);
        btemp.rightCols(nFactors) = btemp.rightCols(nFactors).array() * Identity.row(k).array();
        epsilons = yt.row(k) - btemp * Xtemp.transpose();
        if (k == InfoMatRow.head(1).value())
        {
            H1 = MakePrecision(gammas, factorVariance, T);
            D0 = setInitialCovar(gammas, factorVariance).ldlt().solve(Ilagfac);
            H1.topLeftCorner(gammas.cols(), gammas.cols()) = D0;
            CovarSum += H1;
        }
        else
        {
            s2 = omVariance(k);
            H1 = MakePrecision(deltas.row(k), s2, T);
            D0 = setInitialCovar(deltas.row(k), s2).ldlt().solve(Ilagom);
            H1.topLeftCorner(deltas.cols(), deltas.cols()) = D0;
            CovarSum += (loading * loading) * H1;
            MeanSum += loading * (H1 * epsilons.transpose());
        }
    }
    CovarSum = CovarSum.ldlt().solve(MatrixXd::Identity(T, T));
    factorMean = CovarSum * MeanSum;
    return (factorMean + CovarSum.llt().matrixL() * normrnd(0, 1, CovarSum.rows(), 1)).transpose();
}

template <typename T1, typename T2>
MatrixXd removeZeros(const MatrixBase<T1> &ObsModelIdentity, const MatrixBase<T2> &betaParams, int nXs)
{
    int c;
    int levels = (int)ObsModelIdentity.row(0).sum();
    MatrixXd tb(ObsModelIdentity.rows(), levels + nXs);
    MatrixXi Icopy = ObsModelIdentity.template cast<int>();
    for (int i = 0; i < ObsModelIdentity.rows(); ++i)
    {
        c = nXs;
        for (int j = nXs; j < ObsModelIdentity.cols() + nXs; ++j)
        {
            if (Icopy(i, j - nXs) > 0)
            {
                tb(i, c) = betaParams(i, j);
                ++c;
            }
        }
    }
    tb.leftCols(nXs) = betaParams.leftCols(nXs);
    return tb;
}

template <typename T1>
MatrixXi createFactorInfo(const MatrixBase<T1> &I, const Matrix<int, Dynamic, 2> &InfoMat)
{
    int levels = (int)I.row(0).sum();
    int K = I.rows();
    MatrixXi FactorInfo(K, levels);
    FactorInfo.setZero();
    RowVectorXi r(2);
    int start;
    int end;
    int c = 0;
    int columnShift = 0;
    int shift = K - 1;
    for (int j = 0; j < InfoMat.rows(); ++j)
    {
        r = InfoMat.row(j);
        start = r(0);
        end = r(1);
        for (int i = start; i < end + 1; ++i)
        {
            FactorInfo(i, columnShift) = c;
        }
        if (end == shift)
        {
            ++columnShift;
        }
        ++c;
    }
    return FactorInfo;
}

MatrixXi returnIdentificationRestictions(const MatrixXi &FactorInfo);

template <typename T0, typename T1, typename T2>
MatrixXd removeXtZeros(const MatrixBase<T0> &Xthat, const MatrixBase<T1> &I, const Matrix<int, Dynamic, -1> &InfoMat, const MatrixBase<T2> &FactorInfo)
{
    int xcols = Xthat.cols();
    int T = Xthat.rows();
    int nXs = xcols - I.cols();
    int levels = (int)I.row(0).sum();
    MatrixXd tempX(T, nXs + levels);
    for (int i = 0; i < levels; ++i)
    {
        tempX.col(i + nXs) = Xthat.col(nXs + FactorInfo(i));
    }
    tempX.leftCols(nXs) = Xthat.leftCols(nXs);
    return tempX;
}

int calcLevels(const Matrix<int, Dynamic, 2> &InfoMat, const int &K);
#endif