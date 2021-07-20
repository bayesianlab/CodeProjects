#ifndef ML_H
#define ML_H

#include <iostream>
#include <stdexcept>
#include <map>
#include <string>
#include <math.h>
#include <chrono>
#include <fstream>

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

void vectorize(MatrixXd &mat);

VectorXi sequence(int b, int e);

VectorXi sequence(int b, int e, int skip);

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

MatrixXd MakeObsModelIdentity(const map<string, Matrix<int, 1, 2>> &m, int eqns);

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
        invalid_argument("Invalid input in updateAR, rows greater than cols.");
    }
    MatrixXd Xt = lag(yt, lags);
    MatrixXd ytstar = yt.rightCols(T - lags);
    MatrixXd Ip = MatrixXd::Identity(lags, lags);
    MatrixXd XX = Xt * Xt.transpose();
    XX = XX.array() / sigma2;
    MatrixXd G1 = priorVar.householderQr().solve(Ip);
    G1 = (G1 + XX).householderQr().solve(Ip);
    MatrixXd g1 = priorVar.householderQr().solve(priorMean.transpose());

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

template <typename D1, typename D3, typename D4, typename D5,
          typename D6, typename D7>
double ConditionalLogLikelihood(const MatrixBase<D1> &guess, MatrixXd &resids,
                                const MatrixBase<D3> &priorMeanA0, const MatrixBase<D4> &priorPrecisionA0,
                                const MatrixBase<D5> &obsPrecision, const MatrixBase<D6> &factor,
                                const MatrixBase<D7> &FactorPrecision)
{
    /* Guess comes in as a column, resids is modified inside */
    /* likelihood for one factor alone */
    /* priorMeanA0 is a row */
    int T = factor.cols();
    int K = obsPrecision.size();
    MatrixXd OmegaInverse = obsPrecision.asDiagonal();
    MatrixXd FtOF = kroneckerProduct(OmegaInverse, factor * factor.transpose());
    MatrixXd Avariance = (priorPrecisionA0 +
                          FtOF)
                             .householderQr()
                             .solve(MatrixXd::Identity(K, K));
    MatrixXd Term = (factor * resids.transpose()).array() * obsPrecision.transpose().array();
    vectorize(Term);
    VectorXd Amean = Avariance * (priorPrecisionA0 * priorMeanA0.transpose() + Term);
    double pdfA = logmvnpdf(guess.transpose(), Amean.transpose(), Avariance);
    MatrixXd AOI = guess.transpose() * OmegaInverse;
    MatrixXd IT = MatrixXd::Identity(T, T);
    MatrixXd Fvariance = (FactorPrecision + kroneckerProduct(IT, AOI *
                                                                     guess))
                             .householderQr()
                             .solve(IT);
    vectorize(resids);
    VectorXd Fmean = Fvariance * (kroneckerProduct(IT, AOI) * resids);
    resids.resize(K, T);
    double pdfF = logmvnpdf(factor, Fmean.transpose(), Fvariance);
    return pdfA - pdfF;
}

template <typename D>
VectorXd updateVariance(const MatrixBase<D> &residuals, int v0, int D0)
{
    double parama = .5 * (residuals.cols() + v0);
    VectorXd paramb = .5 * (D0 + residuals.array().pow(2).rowwise().sum());
    paramb = 1. / paramb.array();
    return igammarnd(parama, paramb);
}

class UpdateBeta
{
public:
    MatrixXd betamean; // Mean update
    MatrixXd B;        // Covariance Matrix update
    MatrixXd betastar; // beta update
    MatrixXd xbt;      // X*beta update
    template <typename D1, typename D2, typename D3, typename D4, typename D5,
              typename D6, typename D7>
    void betaupdate(const MatrixBase<D1> &yt, const MatrixBase<D2> &surX,
                    const MatrixBase<D3> &om_precision, const MatrixBase<D4> &A,
                    const MatrixBase<D5> &FactorPrecision, const MatrixBase<D6> &b0,
                    const MatrixBase<D7> &B0)
    {
        /* b0 is a column */
        int T = yt.cols();
        int K = yt.rows();
        int nFactors = A.cols();
        int nFactorsT = nFactors * T;
        int KP = surX.cols();
        MatrixXd It = MatrixXd::Identity(T, T);
        MatrixXd InFactorsT = MatrixXd::Identity(nFactorsT, nFactorsT);
        MatrixXd Ikp = MatrixXd::Identity(KP, KP);
        MatrixXd FullPrecision = om_precision.asDiagonal();
        MatrixXd XzzPinv(nFactorsT, nFactorsT);
        XzzPinv = (FactorPrecision + kroneckerProduct(It, A.transpose() * FullPrecision * A)).ldlt().solve(InFactorsT);
        MatrixXd temp = (B0.diagonal().array().pow(-1));
        MatrixXd B0inv = temp.asDiagonal(); // Get rid of this temporary
        MatrixXd xpx = MatrixXd::Zero(KP, KP);
        MatrixXd xpy = MatrixXd::Zero(KP, 1);
        MatrixXd xzz = MatrixXd::Zero(nFactorsT, KP);
        MatrixXd yzz = MatrixXd::Zero(nFactorsT, 1);
        MatrixXd tx;
        MatrixXd ty;
        int c1 = 0;
        int c2 = 0;
        for (int t = 0; t < T; ++t)
        {
            tx = FullPrecision * surX.middleRows(c1, K);
            ty = FullPrecision * yt.col(t);
            xzz.middleRows(c2, nFactors) = A.transpose() * tx;
            yzz.middleRows(c2, nFactors) = A.transpose() * yt.col(t);
            xpx += surX.middleRows(c1, K).transpose() * tx;
            xpy += surX.middleRows(c1, K).transpose() * ty;
            c1 += K;
            c2 += nFactors;
        }
        XzzPinv = xzz.transpose() * XzzPinv;
        B = B0inv + xpx - (XzzPinv * xzz);
        B = B.ldlt().solve(Ikp);
        betamean = B * ((B0inv * b0.transpose()) + xpy - (XzzPinv * yzz));
        betastar = betamean + B.llt().matrixL() * normrnd(0, 1, KP, 1);
        xbt = surX * betastar;
        xbt.resize(K, T);
    }
};

class LoadingsPriorsSetup
{
public:
    map<string, VectorXd> loadingsPriorMeans;
    map<string, MatrixXd> loadingsPriorPrecision;
    double a0;
    double A0;
    LoadingsPriorsSetup(double _a0, double _A0, map<string, Matrix<int, 1, 2>> InfoMap)
    {
        setPriors(_a0, _A0, InfoMap);
    }

    void setPriors(double priorMean, double priorPrecision, map<string, Matrix<int, 1, 2>> InfoMap)
    {
        for (auto it = InfoMap.begin(); it != InfoMap.end(); ++it)
        {
            int d = it->second(1) - it->second(0) + 1;
            VectorXd pm;
            pm = priorMean * VectorXd::Ones(d);
            MatrixXd cov = priorPrecision * MatrixXd::Identity(d, d);
            loadingsPriorMeans.insert({it->first, pm});
            loadingsPriorPrecision.insert({it->first, cov});
        }
    }
};

class LoadingsFactorUpdate
{
public:
    MatrixXd Factors;
    MatrixXd Loadings;

    void setFactors(const Ref<const MatrixXd> &F)
    {
        Factors = F;
    }

    void setLoadings(const Ref<const MatrixXd> &A, const map<string, Matrix<int, 1, 2>> &InfoMap,
                     MatrixXd &Identity, double restriction)
    {

        Loadings = A;
        int c = 0;
        for (auto m = InfoMap.begin(); m != InfoMap.end(); ++m)
        {

            Loadings(m->second(0), c) = restriction;
            ++c;
        }
    }

    void updateLoadingsFactors(const Ref<const MatrixXd> &yt, const Ref<const MatrixXd> &Xbeta, MatrixXd &Ft,
                               const Ref<const MatrixXd> &A, const Ref<const MatrixXd> &gammas,
                               const Ref<const VectorXd> &obsPrecision, const Ref<const VectorXd> &factorVariance,
                               const Ref<const MatrixXd> &Identity, const map<string, Matrix<int, 1, 2>> &InfoMap,
                               map<string, VectorXd> &loadingsPriorMeanMap, map<string, MatrixXd> &loadingsPriorPrecisionMap,
                               Optimize &optim)
    {

        int T = yt.cols();
        int nFactors = InfoMap.size();
        int nrows;
        int c = 0;
        int df = 15;
        double lalpha;
        MatrixXd ytdemeaned;
        MatrixXd subytdemeaned;
        MatrixXd subgammas;
        MatrixXd subFp;
        MatrixXd subFt;
        MatrixXd COM;
        MatrixXd mut;
        MatrixXd subPriorMean;
        MatrixXd subPriorPrecision;
        MatrixXd Itemp;
        MatrixXd proposalCovariance;
        MatrixXd lower;

        VectorXd subA;
        VectorXd subfv;
        VectorXd subomPrecision;
        VectorXd proposalMean;
        VectorXd covDiag;
        VectorXd proposal;

        for (auto m = InfoMap.begin(); m != InfoMap.end(); ++m)
        {
            cout << "Factor level " << c + 1 << endl;
            COM = zeroOutFactorLevel(Identity, c);
            mut = Xbeta + COM * Ft;
            ytdemeaned = yt - mut;
            nrows = m->second(1) - m->second(0) + 1;
            Itemp = MatrixXd::Identity(nrows, nrows);
            subytdemeaned = ytdemeaned.middleRows(m->second(0), nrows);
            subomPrecision = obsPrecision.segment(m->second(0), nrows);
            subA = A.col(c).segment(m->second(0), nrows);
            subgammas = gammas.row(c);
            subfv = factorVariance.row(c);
            subFp = MakePrecision(subgammas, subfv, T);
            subFt = Ft.row(c);
            subPriorMean = loadingsPriorMeanMap[m->first].transpose();
            subPriorPrecision = loadingsPriorPrecisionMap[m->first];

            auto CLL = [&subytdemeaned, &subPriorMean, &subPriorPrecision,
                        &subomPrecision, &subFt, &subFp](const VectorXd &x0)
            {
                return -ConditionalLogLikelihood(x0, subytdemeaned, subPriorMean, subPriorPrecision,
                                                 subomPrecision, subFt, subFp);
            };

            optim.BFGS(subA, CLL, 1);
            optim.AprroximateDiagHessian(optim.x1, CLL, optim.fval1);

            proposalMean = optim.x1;
            proposalCovariance = optim.Hess;
            covDiag = proposalCovariance.diagonal();
            covDiag = covDiag.array().pow(-1);
            for (int j = 0; j < covDiag.size(); ++j)
            {
                if (covDiag(j) < 0)
                {
                    covDiag(j) = covDiag(j) * (-1);
                }
            }
            covDiag.array().sqrt();
            lower = covDiag.asDiagonal();
            proposal = proposalMean + lower * normrnd(0, 1, covDiag.size(), 1);
            lalpha = -CLL(proposal) + logmvtpdf(subA.transpose(), proposalMean.transpose(), proposalCovariance, df) +
                     CLL(subA) - logmvtpdf(proposal.transpose(), proposalMean.transpose(), proposalCovariance, df);
            if (log(unifrnd(0, 1)) < lalpha)
            {
                subA = proposal;
                subA(0) = 1;
                Loadings.col(c).segment(m->second(0), nrows) = subA;
            }

            Ft.row(c) = updateFactor(subytdemeaned, subA, subFp, subomPrecision, T);
            ++c;
        }
    }
};

class GenerateMLFactorData
{
    /* betas will be same for every equation, 
    X should be stacked over T
    gammas should include greatest lag in 0th column, stacked over equations
    loadings should be a matrix equaling the number of equaitons in the row dimension
    factors will be nFactors = rows time = cols */
public:
    int T;
    int K;
    int nFactors;
    int nEqnsP;
    VectorXd betas;
    MatrixXd Xt;
    MatrixXd surX;
    VectorXd allBetas;
    MatrixXd Xbeta;
    MatrixXd Identity;
    MatrixXd gammas;
    VectorXd factorVariances;
    MatrixXd Loadings;
    MatrixXd P0;
    MatrixXd FactorPrecision;
    MatrixXd Factors;
    MatrixXd AF;
    MatrixXd mu;
    MatrixXd epsilon;
    MatrixXd yt;
    VectorXd om_variance;
    VectorXd om_precision;
    MatrixXd b0;
    MatrixXd B0;
    MatrixXd H;
    MatrixXd resids;
    GenerateMLFactorData(int nObs, int nEqns, const VectorXd &coeffValues,
                         const map<string, Matrix<int, 1, 2>> &InfoMap,
                         const VectorXd &factorCoeff,
                         const MatrixXd &_Loadings, const double &omVar);

    void setLoadings(const Ref<const MatrixXd> &A, const map<string, Matrix<int, 1, 2>> &InfoMap,
                     MatrixXd &Identity, double restriction)
    {

        Loadings = A;
        int c = 0;
        for (auto m = InfoMap.begin(); m != InfoMap.end(); ++m)
        {

            Loadings(m->second(0), c) = restriction;
            ++c;
        }
        Loadings = Identity.array() * Loadings.array();
    }
};

class GenerateAutoRegressiveData
{
public:
    int lags;
    MatrixXd H;
    MatrixXd epsilon;
    MatrixXd yt;
    MatrixXd G0;
    MatrixXd g0;
    MatrixXd ythat;
    MatrixXd Xthat;
    double sigma2;
    GenerateAutoRegressiveData(int time, const MatrixXd &params);
};

class MultilevelModel
{
public:
    VectorXd beta1stMomentContainer;
    VectorXd beta2ndMomentContainer;
    MatrixXd Factor1stMomentContainer;
    MatrixXd Factor2ndMomentContainer;
    MatrixXd gammas1stMomentContainer;
    MatrixXd gammas2ndMomentContainer;
    MatrixXd obsPrecisionContainer;
    MatrixXd factorVarianceContainer;
    MatrixXd Loadings1stMomentContainer;
    MatrixXd Loadings2ndMomentContainer;

    void
    runMultilevelModel(MatrixXd yt, MatrixXd Xt, MatrixXd A, MatrixXd Ft, MatrixXd gammas, const map<string, Matrix<int, 1, 2>> &InfoMap,
                       const RowVectorXd &b0, const MatrixXd &B0, int Sims, int burnin)
    {
        int T = yt.cols();
        int K = yt.rows();
        int nFactors = InfoMap.size();
        int r0 = 6;
        int R0 = 4;

        UpdateBeta ub;
        LoadingsPriorsSetup lps(0, 1, InfoMap);
        LoadingsFactorUpdate lfu;
        MatrixXd surX = surForm(Xt, K);

        ub.betastar = VectorXd::Ones(surX.cols()) * .5;
        ub.xbt = surX * ub.betastar;
        ub.xbt.resize(K, T);

        VectorXd omVariance = MatrixXd::Ones(K, 1);
        VectorXd omPrecision = omVariance.array().pow(-1);
        VectorXd factorVariance = omVariance.head(nFactors);
        MatrixXd FactorPrecision = MakePrecision(gammas, factorVariance, T);
        MatrixXd Identity = MakeObsModelIdentity(InfoMap, K);
        MatrixXd resids;
        MatrixXd H;
        VectorXd Hf;
        RowVectorXd g0 = RowVectorXd::Zero(gammas.cols());
        MatrixXd G0 = MatrixXd::Identity(gammas.cols(), gammas.cols());
        yt.resize(K * T, 1);
        lfu.setFactors(Ft);
        lfu.setLoadings(A, InfoMap, Identity, .1);
        yt.resize(K, T);
        double optim_options[5] = {SEPS, SEPS, EPS, 1e-6, 1};
        double parama = .5 * (r0 + T);
        double paramb;
        Optimize optim(optim_options);
        beta1stMomentContainer = VectorXd::Zero(surX.cols(), 1);
        beta2ndMomentContainer = beta1stMomentContainer;
        Factor1stMomentContainer = MatrixXd::Zero(nFactors, T);
        Factor2ndMomentContainer = MatrixXd::Zero(nFactors, T);
        gammas1stMomentContainer = MatrixXd::Zero(nFactors, gammas.cols());
        gammas2ndMomentContainer = MatrixXd::Zero(nFactors, gammas.cols());
        obsPrecisionContainer = MatrixXd::Zero(K, Sims - (burnin + 1));
        factorVarianceContainer = MatrixXd::Zero(nFactors, Sims - (burnin + 1));
        Loadings1stMomentContainer = MatrixXd::Zero(A.rows(), A.cols());

        for (int i = 0; i < Sims; ++i)
        {

            cout << "Sim " << i + 1 << endl;

            ub.betaupdate(yt, surX, omPrecision, lfu.Loadings, FactorPrecision, b0, B0);

            // cout << ub.betastar.transpose() << endl;
            // cout << omPrecision.transpose() << endl;
            // cout << factorVariance.transpose() << endl;
            // cout << gammas << endl;

            lfu.updateLoadingsFactors(yt, ub.xbt, lfu.Factors, lfu.Loadings, gammas, omPrecision,
                                      factorVariance, Identity, InfoMap, lps.loadingsPriorMeans,
                                      lps.loadingsPriorPrecision, optim);

            for (int j = 0; j < nFactors; ++j)
            {
                gammas.row(j) = updateAR(gammas.row(j), lfu.Factors.row(j), factorVariance(j), g0, G0);
                H = ReturnH(gammas.row(j), T);
                Hf = H * lfu.Factors.row(j).transpose();
                paramb = 1. / (.5 * (R0 + Hf.transpose() * Hf));
                factorVariance(j) = igammarnd(parama, paramb);
            }

            resids = yt - (lfu.Loadings * lfu.Factors) - ub.xbt;
            omPrecision = updateVariance(resids, r0, R0);
            omPrecision = omPrecision.array().pow(-1);

            FactorPrecision = MakePrecision(gammas, factorVariance, T);

            if (i > burnin)
            {
                beta1stMomentContainer += ub.betastar;
                // beta2ndMomentContainer += (ub.betastar.array() * ub.betastar.array()).matrix();
                Factor1stMomentContainer += lfu.Factors;
                // Factor2ndMomentContainer += (lfu.Factors.array() * lfu.Factors.array()).matrix();
                gammas1stMomentContainer += gammas;
                // gammas2ndMomentContainer += (gammas.array() * gammas.array()).matrix();
                obsPrecisionContainer.col(i - (burnin + 1)) = omPrecision;
                factorVarianceContainer.col(i - (burnin + 1)) = factorVariance;
                Loadings1stMomentContainer += lfu.Loadings;
            }
        }
        int stationarySims = Sims - (burnin + 1);
        if (stationarySims > 0)
        {
            beta1stMomentContainer = beta1stMomentContainer.array() / stationarySims;
            beta2ndMomentContainer = beta2ndMomentContainer.array() / stationarySims;
            Factor1stMomentContainer = Factor1stMomentContainer.array() / stationarySims;
            Factor2ndMomentContainer = Factor2ndMomentContainer.array() / stationarySims;
            gammas1stMomentContainer = gammas1stMomentContainer.array() / stationarySims;
            gammas2ndMomentContainer = gammas2ndMomentContainer.array() / stationarySims;
            Loadings1stMomentContainer = Loadings1stMomentContainer.array() / stationarySims;
        }
        else
        {
            throw invalid_argument("Sims less than burnin. Invalid argument in runMultilevelModel");
        }
    }
};

#endif