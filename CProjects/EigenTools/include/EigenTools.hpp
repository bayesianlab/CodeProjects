#pragma once
#ifndef EIGENTOOLS_H
#define EIGENTOOLS_H
#include <iostream>
#include <stdexcept>
#include <math.h>
#include <fstream>

#include <eigen-3.3.9/Eigen/Dense>
#include <eigen-3.3.9/unsupported/Eigen/KroneckerProduct>

using namespace std;
using namespace Eigen; 

template <typename D>
void dim(const MatrixBase<D> &M)
{
    cout << M.rows() << " x " << M.cols() << endl;
}

VectorXd var(const Ref<const MatrixXd> &A, int row_col);


VectorXi sequence(int b, int e);


VectorXi sequence(int b, int e, int skip);

template <typename Derived1>
MatrixXd CreateDiag(const MatrixBase<Derived1> &diagonalMat, const ArrayXi &diagonalVector,
                    int k, int c)
{

    MatrixXd D = MatrixXd::Zero(k, c);
    int td;
    int elem;
    if (k > c)
    {
        if (min(k - diagonalVector.cwiseAbs().minCoeff(), c) > diagonalMat.rows())
        {
            throw invalid_argument("di rows must be greater than number of elements in longest diagonal.");
        }
    }
    else
    {
        if (min(c - diagonalVector.cwiseAbs().minCoeff(), k) > diagonalMat.rows())
        {
            throw invalid_argument("di rows must be greater than number of elements in longest diagonal.");
        }
    }

    if (diagonalMat.cols() < diagonalVector.rows())
    {
        throw invalid_argument("Not enough diagonals supplied.");
    }
    int w = 0;
    int lastcol = 0;
    int curdiagonal;
    int abscurdiag;
    for (int t = 0; t < diagonalVector.size(); ++t)
    {
        curdiagonal = diagonalVector(t);
        if (curdiagonal < 0)
        {
            abscurdiag = abs(diagonalVector(t));
            lastcol = min(k - abscurdiag, c);
            for (int h = 0; h < lastcol; ++h)
            {
                w = h + abscurdiag;
                D(w, h) = diagonalMat(h, t);
            }
        }
        else
        {
            lastcol = min(c - abs(diagonalVector(t)), k);
            for (int h = 0; h < lastcol; ++h)
            {

                w = h + diagonalVector(t);
                D(h, w) = diagonalMat(h, t);
            }
        }
    }
    return D;
}

template <typename D>
MatrixXd surForm(const MatrixBase<D> &stackedx, int K)
{
    int KT = stackedx.rows();
    int cols = stackedx.cols();
    int T = KT / K;
    MatrixXd KronIone = kroneckerProduct(MatrixXd::Identity(K, K), MatrixXd::Ones(1, cols)).replicate(T, 1);
    return KronIone.array() * stackedx.replicate(1, K).array();
}

template <typename D>
bool isPD(const MatrixBase<D> &x)
{

    if (x.llt().info() == NumericalIssue)
    {
        return false;
    }
    else
    {
        return true;
    }
}

MatrixXd readCSV(std::string file, int rows, int cols);


#endif