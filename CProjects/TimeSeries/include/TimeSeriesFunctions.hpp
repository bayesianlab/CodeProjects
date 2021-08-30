#pragma once
#ifndef TSFUNC_H
#define TSFUNC_H
#include <iostream>
#include <stdexcept>
#include <math.h>

#include <eigen-3.3.9/Eigen/Dense>
#include <eigen-3.3.9/unsupported/Eigen/KroneckerProduct>

template <typename D>
std::vector<MatrixXd> groupByTime(const MatrixBase<D> &Xtfull, const int &T, const int &K)
{
    ArrayXi indices = sequence(0, K * T, K);
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
    return Xtk;
}


template <typename Derived>
MatrixXd makeStateSpace(const MatrixBase<Derived> &params)
{
    /* phi_p should be 1st in parameter vector if lag p model
       e.g phi_p, phi_p-1, ... , phi_1
    */
    const int lags = params.cols();
    const int rows = params.rows();
    MatrixXd d = CreateDiag(params, sequence(0, (rows * lags) - 1, rows),
                            rows, rows * lags);
    MatrixXd B(rows * lags, rows * lags);
    B.bottomRows(rows * (lags - 1)) << MatrixXd::Identity(rows * (lags - 1), rows * (lags - 1)),
        MatrixXd::Zero(rows * (lags - 1), rows);
    B.topRows(rows) << d;
    return B;
}

template <typename Derived1, typename Derived2>
MatrixXd setInitialCovar(const MatrixBase<Derived1> &params, const MatrixBase<Derived2> &vars)
{
    /* phi_p should be 1st in parameter vector if lag p model
       e.g phi_p, phi_p-1, ... , phi_1
    */
    int lags = params.cols();
    int rows = params.rows();
    if (rows != vars.size())
    {
        throw invalid_argument("In setCovar, variances must be equal to number of equations.");
    }
    MatrixXd stateSpaceParams = makeStateSpace(params);
    int eqns = stateSpaceParams.rows();
    MatrixXd SkronS = kroneckerProduct(stateSpaceParams, stateSpaceParams);
    int rows2 = SkronS.rows();
    MatrixXd Irows2 = MatrixXd::Identity(rows2, rows2);
    MatrixXd Var = vars.asDiagonal();
    MatrixXd Varmat(rows * lags, rows);
    Varmat << Var, MatrixXd::Zero(rows * (lags - 1), rows);
    MatrixXd outerp = Varmat * Varmat.transpose();
    outerp.resize(rows * rows * lags * lags, 1);
    MatrixXd P0 = (Irows2 - SkronS).fullPivLu().solve(outerp);
    P0.resize(rows * lags, rows * lags);
    if (isPD(P0) != true)
    {
        return MatrixXd::Identity(rows * lags, rows * lags);
    }
    else
    {
        return P0;
    }
}

template <typename Derived1>
MatrixXd setInitialCovar(const MatrixBase<Derived1> &params, const double &var)
{
    /* phi_p should be 1st in parameter vector if lag p model
       e.g phi_p, phi_p-1, ... , phi_1
    */
    int lags = params.cols();
    int rows = params.rows();
    MatrixXd stateSpaceParams = makeStateSpace(params);
    int eqns = stateSpaceParams.rows();
    MatrixXd SkronS = kroneckerProduct(stateSpaceParams, stateSpaceParams);
    int rows2 = SkronS.rows();
    MatrixXd Irows2 = MatrixXd::Identity(rows2, rows2);
    MatrixXd Varmat(rows * lags, rows);
    Varmat << var, MatrixXd::Zero(rows * (lags - 1), rows);
    MatrixXd outerp = Varmat * Varmat.transpose();
    outerp.resize(rows * rows * lags * lags, 1);
    MatrixXd P0 = (Irows2 - SkronS).fullPivLu().solve(outerp);
    P0.resize(rows * lags, rows * lags);
    if (isPD(P0) != true)
    {
        return MatrixXd::Identity(rows * lags, rows * lags);
    }
    else
    {
        return P0;
    }
}

template <typename D>
MatrixXd ReturnH(const MatrixBase<D> &params, int T)
{
    /* param vector should include the greatest lag in the 0th column */
    int eqns = params.rows();
    int lags = params.cols();
    MatrixXd negparams = -params.replicate(T, 1);
    MatrixXd X(T * eqns, lags + 1);
    X << negparams, MatrixXd::Ones(T * eqns, 1);
    return CreateDiag(X, sequence(-eqns * (lags), 0, eqns), T * eqns, T * eqns);
}

template <typename D1, typename D2>
MatrixXd MakePrecision(const MatrixBase<D1> &params, const MatrixBase<D2> &var,
                       int T)
{
    int eqns = params.rows();
    int lags = params.cols();
    MatrixXd H = ReturnH(params, T);
    VectorXd v = (var.array().pow(-1)).replicate(T, 1);
    MatrixXd Sinv = v.asDiagonal();
    return H.transpose() * Sinv * H;
}

template <typename D>
MatrixXd lag(const MatrixBase<D> &xt, const int &lags, const int &dimension)
{
    if (dimension == 0)
    {
        int K = xt.rows();
        int T = xt.cols();
        MatrixXd X = MatrixXd::Zero(K * lags, T - lags);
        VectorXi d = sequence(0, K - 1);
        int r = 0;
        for (int u = 0; u < lags; ++u)
        {
            X.middleRows(r, K) = xt.middleCols(u, T - lags);
            r += K;
        }
        return X;
    }
    else if (dimension == 1)
    {
        int K = xt.cols();
        int T = xt.rows();
        MatrixXd X = MatrixXd::Zero(T - lags, K * lags);
        VectorXi d = sequence(0, K - 1);
        int r = 0;
        for (int u = 0; u < lags; ++u)
        {
            X.middleCols(r, K) = xt.middleRows(u, T - lags);
            r += K;
        }
        return X;
    }
    else
    {
        throw invalid_argument("Invalid argument in lag.");
    }
}

template <typename T1, typename T2>
MatrixXd lagOperator(const MatrixBase<T1> &X, const MatrixBase<T2> &params,
                     const int operatingDimension)
{
    int lags = params.cols();

    if (operatingDimension == 0)
    {
        if (params.rows() != X.rows())
        {
            throw invalid_argument("Params and X must have equal rows in lag.");
        }
        // T extends over rows, t1,t2,...T
        int T = X.cols();
        MatrixXd LagX(X.rows(), X.cols() - lags);
        for (int i = 0; i < X.rows(); ++i)
        {
            LagX.row(i) = X.row(i).tail(T - lags) - params.row(i) * lag(X.row(i), lags, 0);
        }
        return LagX;
    }
    else
    {
        if (params.rows() != X.cols())
        {
            throw invalid_argument("Params rows and X cols must be equal.");
        }
        // T extends over cols, (t1,t2,...T)^T
        int T = X.rows();
        MatrixXd LagX(X.rows() - lags, X.cols());
        for (int i = 0; i < X.cols(); ++i)
        {
            LagX.col(i) = X.col(i).tail(T - lags) - lag(X.col(i), lags, 1) * params.row(i).transpose();
        }
        return LagX;
    }
}

template <typename T1, typename T2>
MatrixXd makeStationary(const MatrixBase<T1> &M, const MatrixBase<T2> &params, const VectorXd &sigma2,
                    const int &operatingDimension)
{
    MatrixXd D0;
    int lags = params.cols();

    if (operatingDimension == 0)
    {
        int T = M.cols();
        MatrixXd Mend(M.rows(), T);
        MatrixXd D0upper;
        MatrixXd Xstationary(M.rows(), M.cols());
        for (int i = 0; i < M.rows(); ++i)
        {
            Mend.row(i).rightCols(T - lags) = lagOperator(M.row(i), params.row(i), operatingDimension);
            D0 = setInitialCovar(params.row(i), 1);
            D0upper = D0.llt().matrixU();
            Xstationary.row(i).leftCols(lags) = M.row(i).leftCols(lags) * D0upper;
            Xstationary.row(i).rightCols(T - lags) = Mend.row(i).rightCols(T - lags);
        }
        return Xstationary;
    }
    else if (operatingDimension == 1)
    {
        int T = M.rows();
        MatrixXd Mend(T, M.cols());
        MatrixXd D0lower;
        MatrixXd Xstationary(T, M.cols());
        for (int i = 0; i < M.cols(); ++i)
        {
            Mend.col(i).bottomRows(T - lags) = lagOperator(M.col(i), params.row(i), operatingDimension);
            D0 = setInitialCovar(params.row(i), 1);
            D0lower = D0.llt().matrixL();
            Xstationary.col(i).topRows(lags) = D0lower * M.col(i).topRows(lags);
            Xstationary.col(i).bottomRows(T - lags) = Mend.col(i).bottomRows(T - lags);
        }
        return Xstationary;
    }
    else
    {
        throw invalid_argument("Invalid input in makeStationary for operating dimension.");
    }
}

#endif