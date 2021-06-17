#ifndef ML_H
#define ML_H
#include <eigen3/Eigen/Dense>
#include <eigen3/unsupported/Eigen/KroneckerProduct>
#include <iostream>
#include <stdexcept>
using namespace Eigen;
using namespace std;

VectorXd sequence(int b, int e);

VectorXd sequence(int b, int e, int skip);

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

template <typename Derived1, typename Derived2>
MatrixXd CreateDiag(const MatrixBase<Derived1> &di, const MatrixBase<Derived2> &d,
                    int k, int c)
{

    MatrixXd D = MatrixXd::Zero(k, c);

    int td;
    VectorXd tdi(di.rows());
    int elem;
    if ((k - d.cwiseAbs().minCoeff() - 1) > di.rows())
    {
        throw invalid_argument("di rows must be greater than number of elements in longest diagonal.");
    }
    if (di.cols() < d.rows())
    {
        throw invalid_argument("Not enough diagonals supplied.");
    }

    int diagonal;
    for (int u = 0; u < d.size(); ++u)
    {
        elem = 0;
        td = d(u);
        tdi = di.col(u);
        if (td >= 0)
        {
            diagonal = td;
            for (int i = 0; i < k; i++)
            {
                for (int j = i; j < c; j++)
                {
                    if (j == diagonal)
                    {

                        D(i, j) = tdi(elem);
                        ++elem;
                        break;
                    }
                }
                ++diagonal;
            }
        }
        else
        {
            elem = 0;
            td = -1 * td;
            tdi = di.col(u);
            for (int j = 0; j < c; ++j)
            {
                for (int i = j; i < k; ++i)
                {
                    if (i == (td + j))
                    {
                        D(i, j) = tdi(elem);
                        ++elem;
                        break;
                    }
                }
            }
        }
    }
    return D;
}

template <typename Derived>
MatrixXd makeStateSpace(const MatrixBase<Derived> &params)
{
    const int lags = params.cols();
    const int rows = params.rows();

    MatrixXd d = CreateDiag(params, sequence(0, (rows * lags) - 1, rows),
                            rows, rows * lags);
    MatrixXd B(rows * lags, rows * lags);
    B.bottomRows(rows * (lags - 1)) << MatrixXd::Identity(rows * (lags - 1), rows * (lags - 1)), MatrixXd::Zero(rows * (lags - 1), rows);
    B.topRows(rows) << d;
    return B;
}

template <typename Derived1, typename Derived2>
MatrixXd setCovar(const MatrixBase<Derived1> &params, const MatrixBase<Derived2> &vars)
{
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

template <typename D1, typename D2>
MatrixXd MakePrecision(const MatrixBase<D1> &params, const MatrixBase<D2> &var,
                       const Ref<const MatrixXd> &P0, int T)
{
    int eqns = params.rows();
    int lags = params.cols();
    MatrixXd negparams = -params.replicate(T, 1).rowwise().reverse();
    MatrixXd X(T * eqns, lags + 1);
    X << negparams, MatrixXd::Ones(T * eqns, 1);
    MatrixXd H = CreateDiag(X, sequence(-eqns * (lags), 0, eqns), T * eqns, T * eqns);
    VectorXd v = (var.array().pow(-1)).replicate(T, 1);
    MatrixXd Sinv = v.asDiagonal();
    MatrixXd P0inv = P0.fullPivLu().solve(MatrixXd::Identity(eqns * lags, eqns * lags));
    Sinv.topLeftCorner(eqns * lags, eqns * lags) = P0inv;
    return H.transpose() * Sinv * H;
}

#endif