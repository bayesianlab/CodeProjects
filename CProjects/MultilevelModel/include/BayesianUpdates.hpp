#pragma once
#ifndef BUP_H
#define BUP_H

#include <iostream>
#include <stdexcept>
#include <Eigen/Dense>
#include "Distributions.hpp"
using namespace Eigen;
using namespace std;

class UnivariateBeta
{
public:
    MatrixXd B;
    RowVectorXd bmean;
    RowVectorXd bnew;
    template <typename T1, typename T2, typename T3, typename T4>
    void updateBetaUnivariate(const MatrixBase<T1> &yt, const MatrixBase<T2> &Xt,
                         const double &s2, const MatrixBase<T3> &b0, const MatrixBase<T4> &B0)
    {
        MatrixXd Ix = MatrixXd::Identity(B0.rows(), B0.cols());
        VectorXd B0inv = B0.ldlt().solve(Ix);
        B = B0inv + ((Xt.transpose * Xt).array() / s2);
        B = B.ldlt().solve(Ix);
        MatrixXd Blower = B.llt().matrixL();
        bmean = (B * (B0inv * b0.transpose() + (Xt.transpose() * yt.transpose()).array() / s2)).transpose();
        bnew = (bmean.transpose() + Blower * normrnd(0, 1, B.rows(), 1)).transpose();
    }
};

template <typename D>
VectorXd updateVariance(const MatrixBase<D> &residuals, const int &v0, const int &D0)
{
    double parama = .5 * (residuals.cols() + v0);
    VectorXd paramb = .5 * (D0 + (residuals.array()*residuals.array()).rowwise().sum());
    paramb = 1. / paramb.array();
    return igammarnd(parama, paramb);
}

#endif
