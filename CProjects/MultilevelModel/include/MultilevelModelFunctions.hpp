#pragma once
#ifndef MLFUNC_H
#define MLFUNC_H
#include <iostream>
#include <stdexcept>
#include <map>
#include <string>
#include <math.h>

#include <eigen-3.3.9/Eigen/Dense>
#include <eigen-3.3.9/unsupported/Eigen/KroneckerProduct>

#include "Distributions.hpp"
#include "Optimization.hpp"
using namespace Eigen;
using namespace std;



template <typename D>
VectorXi elemPos(const MatrixBase<D> &V)
{
    VectorXi pos = VectorXi::Zero(V.size());
    for (int i = 0; i < V.size(); ++i)
    {
        if (V(i) > 0)
        {
            pos = 1;
        }
    }
    return pos;
}

template <typename D>
void dim(const MatrixBase<D> &M)
{
    cout << M.rows() << " x " << M.cols() << endl;
}

VectorXd var(const Ref<const MatrixXd> &A, int row_col);

void vectorize(MatrixXd &mat);

VectorXi sequence(int b, int e);

MatrixXd makeOtrokXt(const Matrix<int, Dynamic, 2> &InfoMat, const Ref<MatrixXd> &Factors,
                     const int &nXs, const int &K);

VectorXi sequence(int b, int e, int skip);


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

MatrixXd updateFactor(const MatrixXd &residuals, const MatrixXd &Loadings,
                      const MatrixXd &FactorPrecision, const VectorXd &precision, int T);

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
MatrixXd setCovar(const MatrixBase<Derived1> &params, const MatrixBase<Derived2> &vars)
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
MatrixXd setCovar(const MatrixBase<Derived1> &params, const double &var)
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

MatrixXd MakeObsModelIdentity(const Matrix<int, Dynamic, 2> &m, int eqns);

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
MatrixXd zeroOutFactorLevel(const MatrixBase<D> &Id, int level)
{
    MatrixXd I = Id;
    I.col(level) = MatrixXd::Zero(I.rows(), 1);
    return I;
}

template <typename D>
MatrixXd lag(const MatrixBase<D> &xt, int lags)
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

// template <typename D1, typename D2>
// MatrixXd updateAR(const MatrixBase<D1> &current, const MatrixBase<D2> &yt, const double &sigma2,
//                   const MatrixXd &priorMean, const MatrixXd &priorVar)
// {
//     /* current comes in as a row, priorMean comes in as a row */
//     int rows = current.rows();
//     int lags = current.cols();
//     int T = yt.cols();
//     if (rows > lags)
//     {
//         throw invalid_argument("Invalid input in updateAR, rows greater than cols.");
//     }
//     MatrixXd Xt = lag(yt, lags);
//     MatrixXd ytstar = yt.rightCols(T - lags);
//     MatrixXd Ip = MatrixXd::Identity(lags, lags);
//     MatrixXd XX = Xt * Xt.transpose();
//     XX = XX.array() / sigma2;

//     MatrixXd G1 = priorVar.ldlt().solve(Ip);
//     MatrixXd g1 = G1 * priorMean.transpose();
//     G1 = (G1 + XX).ldlt().solve(Ip);

//     MatrixXd Xy = (Xt * ytstar.transpose()).array() / sigma2;
//     g1 = (G1 * (g1 + Xy)).transpose();

//     Matrix<double, 1, 1> s2;
//     s2 << sigma2;
//     MatrixXd P0 = setCovar(current, s2);
//     MatrixXd G1L = G1.llt().matrixL();
//     MatrixXd P1(lags, lags);
//     int MAX_TRIES = 10;
//     int count = 0;
//     int notvalid = 1;
//     MatrixXd proposal = g1;
//     while ((notvalid == 1))
//     {
//         proposal = (g1.transpose() + G1L * normrnd(0, 1, lags, 1)).transpose();
//         P1 = setCovar(proposal, s2);
//         if (isPD(P1))
//         {
//             notvalid = 0;
//         }
//         if (count == MAX_TRIES)
//         {
//             P1 = MatrixXd::Identity(lags, lags);
//             break;
//         }
//         ++count;
//     }

//     MatrixXd Xp = MatrixXd::Zero(lags, lags);
//     MatrixXd empty;
//     for (int i = 1; i < lags; ++i)
//     {
//         empty = yt.leftCols(i);
//         empty.resize(i, 1);
//         Xp.col(i).segment(lags - i, i) = empty;
//         empty.resize(0, 0);
//     }
//     MatrixXd Scur = s2.replicate(T, 1).asDiagonal();
//     MatrixXd Snew = Scur;
//     Scur.topLeftCorner(lags, lags) = P0;
//     Snew.topLeftCorner(lags, lags) = P1;
//     MatrixXd Xss(lags, T);
//     Xss << Xp, Xt;
//     MatrixXd ZeroMean = MatrixXd::Zero(1, T);
//     double val = (logmvnpdf(yt - proposal * Xss, ZeroMean, Snew) +
//                   logmvnpdf(proposal, priorMean, priorVar) +
//                   logmvnpdf(current, g1, G1)) -
//                  (logmvnpdf(yt - current * Xss, ZeroMean, Scur) +
//                   logmvnpdf(current, priorMean, priorVar) +
//                   logmvnpdf(proposal, g1, G1));
//     double lalpha = min(0., val);
//     if (log(unifrnd(0, 1)) < lalpha)
//     {
//         return proposal;
//     }
//     else
//     {
//         return current;
//     }
// }

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
            Xt = lag(yt.row(k), lags);
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
            Pstar = setCovar(gammastar.row(k), s2);
            G1L = G1.llt().matrixL();

            Pg = setCovar(gammag.row(k), s2);
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
    MatrixXd Xt = lag(yt, lags);
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
    MatrixXd P0 = setCovar(gammastar, s2);
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

// template <typename D1, typename D3, typename D4, typename D5,
//           typename D6, typename D7>
// double ConditionalLogLikelihoodB(const MatrixBase<D1> &guess, MatrixXd &resids,
//                                  const MatrixBase<D3> &priorMeanA0, const MatrixBase<D4> &priorPrecisionA0,
//                                  const MatrixBase<D5> &obsPrecision, const MatrixBase<D6> &factor,
//                                  const MatrixBase<D7> &FactorPrecision)
// {
//     int T = factor.cols();
//     int K = obsPrecision.size();
//     MatrixXd OmegaInverse = obsPrecision.asDiagonal();
//     MatrixXd FtOF = kroneckerProduct(OmegaInverse, factor * factor.transpose());
//     MatrixXd Avariance = (priorPrecisionA0 +
//                           FtOF)
//                              .householderQr()
//                              .solve(MatrixXd::Identity(K, K));
//     MatrixXd Term = (factor * resids.transpose()).array() * obsPrecision.transpose().array();
//     vectorize(Term);
//     VectorXd Amean = Avariance * (priorPrecisionA0 * priorMeanA0.transpose() + Term);
//     double pdfA = logmvnpdf(guess.transpose(), Amean.transpose(), Avariance);
//     MatrixXd AOI = guess.transpose() * OmegaInverse;
//     MatrixXd IT = MatrixXd::Identity(T, T);
//     MatrixXd Fvariance = (FactorPrecision + kroneckerProduct(IT, AOI *
//                                                                      guess))
//                              .householderQr()
//                              .solve(IT);
//     vectorize(resids);
//     VectorXd Fmean = Fvariance * (kroneckerProduct(IT, AOI) * resids);
//     resids.resize(K, T);
//     double pdfF = logmvnpdf(factor, Fmean.transpose(), Fvariance);
//     return pdfA - pdfF;
// }

#endif