#ifndef ML_H
#define ML_H

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
        throw invalid_argument("Invalid input in updateAR, rows greater than cols.");
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

template <typename D1, typename D2, typename D3>
VectorXd gamma_G(const MatrixBase<D1> &gammastar, const std::vector<MatrixXd> &gammagPosterior, const std::vector<MatrixXd> &ytPosterior,
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

    MatrixXd gammag;
    VectorXd numerator(nFactors * rr);
    int d = 0;
    for (int i = 0; i < rr; ++i)
    {
        yt = ytPosterior[i]; 
        Xt = lag(yt, lags);
        ytstar = yt.rightCols(T - lags);
        Ip = MatrixXd::Identity(lags, lags);
        XX = Xt * Xt.transpose();
        sigma2 = sigma2Posterior[i];
        for (int k = 0; k < nFactors; ++k)
        {
            sigma2 = sigma2[k];
            XX = XX.array() / sigma2[k];
            MatrixXd G1 = priorVar.householderQr().solve(Ip);
            G1 = (G1 + XX).householderQr().solve(Ip);
            MatrixXd g1 = priorVar.householderQr().solve(priorMean.transpose());
            MatrixXd Xy = (Xt * ytstar.transpose()).array() / sigma2[k];
            g1 = (G1 * (g1 + Xy)).transpose();
            Matrix<double, 1, 1> s2;
            s2 << sigma2[k];
            MatrixXd Pstar = setCovar(gammastar, s2);
            MatrixXd G1L = G1.llt().matrixL();
            MatrixXd Pg(lags, lags);
            Pg = setCovar(gammag.row(k));
            MatrixXd Xp = MatrixXd::Zero(lags, lags);
            MatrixXd empty;
            for (int i = 1; i < lags; ++i)
            {
                empty = yt.leftCols(i);
                empty.resize(i, 1);
                Xp.col(i).segment(lags - i, i) = empty;
                empty.resize(0, 0);
            }
            MatrixXd Sstar = s2.replicate(T, 1).asDiagonal();
            MatrixXd Sg = Sstar;
            Sstar.topLeftCorner(lags, lags) = Pstar;
            Sg.topLeftCorner(lags, lags) = Pg;
            MatrixXd Xss(lags, T);
            Xss << Xp, Xt;
            MatrixXd ZeroMean = MatrixXd::Zero(1, T);
            double qg = logmvnpdf(gammastar, g1, G1);
            double val = (logmvnpdf(yt - gammastar * Xss, ZeroMean, Sstar) +
                          logmvnpdf(gammastar, priorMean, priorVar) +
                          logmvnpdf(gammag.row(k), g1, G1)) -
                         (logmvnpdf(yt - gammag.row(k) * Xss, ZeroMean, Sg) +
                          logmvnpdf(gammag.row(k), priorMean, priorVar) +
                          qg);
            double lalphaqg = min(0., val);
            lalphaqg = lalphaqg + qg;
            numerator(d);
            ++d;
        }
    }
    return numerator;
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
    VectorXd betamean; // Mean update
    MatrixXd B;        // Covariance Matrix update
    MatrixXd betanew;  // beta update
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
        MatrixXd B0inv = (B0.diagonal().array().pow(-1)).matrix().asDiagonal();
        MatrixXd xpx = MatrixXd::Zero(KP, KP);
        MatrixXd xpy = MatrixXd::Zero(KP, 1);
        MatrixXd xzz = MatrixXd::Zero(nFactorsT, KP);
        MatrixXd yzz = MatrixXd::Zero(nFactorsT, 1);
        MatrixXd tx;
        MatrixXd ty;
        MatrixXd AtO = A.transpose() * FullPrecision;

        MatrixXd XzzPinv = (FactorPrecision + kroneckerProduct(It, AtO * A)).ldlt().solve(InFactorsT);

        int c1 = 0;
        int c2 = 0;
        for (int t = 0; t < T; ++t)
        {
            tx = FullPrecision * surX.middleRows(c1, K);
            ty = FullPrecision * yt.col(t);
            xzz.middleRows(c2, nFactors) = A.transpose() * tx;
            yzz.middleRows(c2, nFactors) = A.transpose() * ty;
            xpx += surX.middleRows(c1, K).transpose() * tx;
            xpy += surX.middleRows(c1, K).transpose() * ty;

            c1 += K;
            c2 += nFactors;
        }

        XzzPinv = xzz.transpose() * XzzPinv;
        B = B0inv + xpx - (XzzPinv * xzz);

        B = B.ldlt().solve(MatrixXd::Identity(KP, KP));
        betamean = B * (B0inv * b0.transpose() + xpy - (XzzPinv * yzz));

        betanew = betamean + (B.llt().matrixL() * normrnd(0, 1, KP, 1));
        xbt = surX * betanew;
        xbt.resize(K, T);
    }

    template <typename D1, typename D2, typename D3, typename D4, typename D5,
              typename D6, typename D7>
    void computeParameters(const MatrixBase<D1> &yt, const MatrixBase<D2> &surX,
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
        MatrixXd B0inv = (B0.diagonal().array().pow(-1)).matrix().asDiagonal();
        MatrixXd xpx = MatrixXd::Zero(KP, KP);
        MatrixXd xpy = MatrixXd::Zero(KP, 1);
        MatrixXd xzz = MatrixXd::Zero(nFactorsT, KP);
        MatrixXd yzz = MatrixXd::Zero(nFactorsT, 1);
        MatrixXd tx;
        MatrixXd ty;
        MatrixXd AtO = A.transpose() * FullPrecision;

        MatrixXd XzzPinv = (FactorPrecision + kroneckerProduct(It, AtO * A)).ldlt().solve(InFactorsT);

        int c1 = 0;
        int c2 = 0;
        for (int t = 0; t < T; ++t)
        {
            tx = FullPrecision * surX.middleRows(c1, K);
            ty = FullPrecision * yt.col(t);
            xzz.middleRows(c2, nFactors) = A.transpose() * tx;
            yzz.middleRows(c2, nFactors) = A.transpose() * ty;
            xpx += surX.middleRows(c1, K).transpose() * tx;
            xpy += surX.middleRows(c1, K).transpose() * ty;

            c1 += K;
            c2 += nFactors;
        }

        XzzPinv = xzz.transpose() * XzzPinv;
        B = B0inv + xpx - (XzzPinv * xzz);

        B = B.ldlt().solve(MatrixXd::Identity(KP, KP));
        betamean = B * (B0inv * b0.transpose() + xpy - (XzzPinv * yzz));
    }

    template <typename D0, typename D1, typename D2, typename D3, typename D4, typename D5,
              typename D6, typename D7>
    double betapdf(const MatrixBase<D0> &betastar, const MatrixBase<D1> &yt, const MatrixBase<D2> &surX,
                   const MatrixBase<D3> &om_precision, const MatrixBase<D4> &A,
                   const MatrixBase<D5> &FactorPrecision, const MatrixBase<D6> &b0,
                   const MatrixBase<D7> &B0)
    {
        computeParameters(yt, surX, om_precision, A, FactorPrecision, b0, B0);
        return logmvnpdf(betastar, betamean.transpose(), B);
    }

    template <typename T1, typename T2>
    void setXbeta(const MatrixBase<T1> &betastar, const MatrixBase<T2> &surX, const int &K, const int &T)
    {
        xbt = surX * betastar;
        xbt.resize(K, T);
    }
};

class LoadingsPriorsSetup
{
public:
    map<string, VectorXd> loadingsPriorMeans;
    map<string, MatrixXd> loadingsPriorPrecision;

    void setPriors(const double &priorMean, const double &priorPrecision, const map<string, Matrix<int, 1, 2>> &InfoMap)
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
    double acceptance_rate;

    LoadingsFactorUpdate()
    {
        acceptance_rate = 0;
    }

    void getAcceptanceRate(double nRuns)
    {
        acceptance_rate = acceptance_rate / nRuns;
    }

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

    void updateLoadingsFactors(const Ref<const MatrixXd> &yt, const Ref<const MatrixXd> &Xbeta,
                               const Ref<const MatrixXd> &gammas, const Ref<const VectorXd> &obsPrecision,
                               const Ref<const VectorXd> &factorVariance, const map<string, Matrix<int, 1, 2>> &InfoMap,
                               map<string, VectorXd> &loadingsPriorMeanMap, map<string, MatrixXd> &loadingsPriorPrecisionMap,
                               Optimize &optim)
    {

        int T = yt.cols();
        int nFactors = InfoMap.size();
        int nrows;
        int c = 0;
        int df = 15;
        int disp_on = 0;
        double lalpha;
        double tau = 100;
        MatrixXd ytdemeaned;
        MatrixXd subytdemeaned;
        MatrixXd subgammas;
        MatrixXd subFp;
        MatrixXd subFt;
        MatrixXd COM;
        MatrixXd mut;
        MatrixXd subPriorMean;
        MatrixXd subPriorPrecision;
        MatrixXd proposalCovariance;
        MatrixXd lower;
        MatrixXd covDiag;
        MatrixXd Diag;

        VectorXd subA;
        VectorXd subfv;
        VectorXd subomPrecision;
        VectorXd proposalMean;
        VectorXd proposal;

        for (auto m = InfoMap.begin(); m != InfoMap.end(); ++m)
        {
            cout << "Factor level " << c + 1 << endl;
            COM = zeroOutFactorLevel(Loadings, c);
            mut = Xbeta + COM * Factors;
            ytdemeaned = yt - mut;
            nrows = m->second(1) - m->second(0) + 1;
            subytdemeaned = ytdemeaned.middleRows(m->second(0), nrows);
            subomPrecision = obsPrecision.segment(m->second(0), nrows);
            subA = Loadings.col(c).segment(m->second(0), nrows);
            subgammas = gammas.row(c);
            subfv = factorVariance.row(c);
            subFp = MakePrecision(subgammas, subfv, T);
            subFt = Factors.row(c);
            subPriorMean = loadingsPriorMeanMap[m->first].transpose();
            subPriorPrecision = loadingsPriorPrecisionMap[m->first];

            auto CLL = [&subytdemeaned, &subPriorMean, &subPriorPrecision,
                        &subomPrecision, &subFt, &subFp](const VectorXd &x0)
            {
                return -ConditionalLogLikelihood(x0, subytdemeaned, subPriorMean, subPriorPrecision,
                                                 subomPrecision, subFt, subFp);
            };

            optim.BFGS(subA, CLL, disp_on);
            proposalMean = optim.x1;
            covDiag = optim.AprroximateDiagHessian(optim.x1, CLL, optim.fval1);
            Diag = covDiag.diagonal();
            Diag = Diag.array().pow(-1);
            proposalCovariance = Diag.asDiagonal();

            lower = proposalCovariance.llt().matrixL();

            proposal = proposalMean + lower * normrnd(0, 1, lower.rows(), 1);
            lalpha = -CLL(proposal) + logmvtpdf(subA.transpose(), tau * proposalMean.transpose(), proposalCovariance, df) +
                     CLL(subA) - logmvtpdf(proposal.transpose(), tau * proposalMean.transpose(), proposalCovariance, df);
            lalpha = min(0., lalpha);
            // cout << proposal << endl;
            // cout <<    CLL(proposal) << endl;
            // cout <<    logmvtpdf(subA.transpose(), proposalMean.transpose(), proposalCovariance, df) << endl;
            // cout << CLL(subA) << endl;
            // cout << logmvtpdf(proposal.transpose(), proposalMean.transpose(), proposalCovariance, df) << endl;
            if (isnan(lalpha))
            {
                throw std::domain_error("Error in update factor MH step.");
            }
            if (log(unifrnd(0, 1)) < lalpha)
            {
                acceptance_rate += 1;
                subA = proposal;
                subA(0) = 1;
                Loadings.col(c).segment(m->second(0), nrows) = subA;
            }
            Factors.row(c) = updateFactor(subytdemeaned, subA, subFp, subomPrecision, T);
            ++c;
        }
    }
};

class MultilevelModel : public UpdateBeta, public LoadingsFactorUpdate, public LoadingsPriorsSetup
{
public:
    std::vector<MatrixXd> LoadingsPosteriorDraws;
    std::vector<VectorXd> BetaPosteriorDraws;
    std::vector<MatrixXd> FactorPosteriorDraws;
    std::vector<MatrixXd> GammasPosteriorDraws;
    std::vector<VectorXd> ObsPrecisionPosteriorDraws;
    std::vector<VectorXd> FactorVariancePosteriorDraws;
    std::vector<VectorXd> PosteriorMeans;
    std::vector<MatrixXd> PosteriorCovariances;

    MatrixXd yt;
    MatrixXd Xt;
    MatrixXd gammas;
    RowVectorXd b0;
    MatrixXd B0;
    double r0;
    double R0;
    RowVectorXd g0;
    MatrixXd G0;
    map<string, Matrix<int, 1, 2>> InfoMap;
    MatrixXd Identity;
    int Sims;
    int burnin;

    void setModel(const Ref<const MatrixXd> &yt, const Ref<const MatrixXd> &Xt, const Ref<const MatrixXd> &A,
                  const Ref<const MatrixXd> &Ft, const Ref<const MatrixXd> &gammas, const map<string, Matrix<int, 1, 2>> &InfoMap,
                  const RowVectorXd &b0, const MatrixXd &B0, const double &a0, const double &A0, const double &r0,
                  const double &R0, const Ref<const RowVectorXd> &g0, const Ref<const MatrixXd> &G0)
    {
        this->yt = yt;
        this->Xt = Xt;
        this->gammas = gammas;
        this->InfoMap = InfoMap;
        this->b0 = b0;
        this->B0 = B0;
        this->r0 = r0;
        this->R0 = R0;
        this->g0 = g0;
        this->G0 = G0;
        this->Identity = MakeObsModelIdentity(InfoMap, yt.rows());
        setFactors(Ft);
        setLoadings(A, InfoMap, Identity, 1.);
        setPriors(a0, A0, InfoMap);
    }

    void setPostMeansAndCovars(const Ref<const MatrixXd> &A, const Ref<const MatrixXd> &Xbeta, MatrixXd &Ft,
                               const Ref<const MatrixXd> &gammas, const Ref<const VectorXd> &obsPrecision,
                               const Ref<const VectorXd> &factorVariance, Optimize &optim)
    {
        int T = yt.cols();
        int nFactors = InfoMap.size();
        PosteriorMeans.resize(nFactors);
        PosteriorCovariances.resize(nFactors);
        MatrixXd ytdemeaned;
        MatrixXd subytdemeaned;
        MatrixXd subgammas;
        MatrixXd subFp;
        MatrixXd subFt;
        MatrixXd COM;
        MatrixXd mut;
        MatrixXd subPriorMean;
        MatrixXd subPriorPrecision;
        MatrixXd lower;
        MatrixXd postCovar;

        VectorXd subA;
        VectorXd subfv;
        VectorXd subomPrecision;

        int disp_on = 0;
        int N = LoadingsPosteriorDraws.size();

        int nrows;
        int c = 0;
        for (auto m = InfoMap.begin(); m != InfoMap.end(); ++m)
        {
            nrows = m->second(1) - m->second(0) + 1;
            COM = zeroOutFactorLevel(A, c);
            mut = Xbeta + COM * Ft;
            ytdemeaned = yt - mut;
            subytdemeaned = ytdemeaned.middleRows(m->second(0), nrows);
            subomPrecision = obsPrecision.segment(m->second(0), nrows);
            subA = A.col(c).segment(m->second(0), nrows);
            subgammas = gammas.row(c);
            subfv = factorVariance.row(c);
            subFp = MakePrecision(subgammas, subfv, T);
            subFt = Ft.row(c);
            subPriorMean = loadingsPriorMeans[m->first].transpose();
            subPriorPrecision = loadingsPriorPrecision[m->first];

            auto CLL = [&subytdemeaned, &subPriorMean, &subPriorPrecision,
                        &subomPrecision, &subFt, &subFp](const VectorXd &x0)
            {
                return -ConditionalLogLikelihood(x0, subytdemeaned, subPriorMean, subPriorPrecision,
                                                 subomPrecision, subFt, subFp);
            };
            optim.BFGS(subA, CLL, disp_on);
            postCovar = optim.AprroximateDiagHessian(optim.x1, CLL, optim.fval1);
            postCovar = postCovar.ldlt().solve(MatrixXd::Identity(nrows, nrows));
            PosteriorMeans[c] = subA.transpose();
            PosteriorCovariances[c] = postCovar;
            ++c;
        }
    }

    void runMultilevelModel(int Sims, int burnin)
    {
        this->Sims = Sims;
        this->burnin = burnin;
        int T = yt.cols();
        int K = yt.rows();
        int nFactors = InfoMap.size();

        VectorXd omVariance = VectorXd::Ones(K);
        VectorXd omPrecision = 0.5 * omVariance.array().pow(-1);
        VectorXd factorVariance = VectorXd::Ones(nFactors);

        MatrixXd surX = surForm(Xt, K);
        MatrixXd FactorPrecision = MakePrecision(gammas, factorVariance, T);
        MatrixXd resids;
        MatrixXd H;
        VectorXd Hf;

        double optim_options[5] = {1e-4, 1e-5, 1e-5, 1e-4, 25};
        double parama = .5 * (r0 + T);
        double paramb;
        Optimize optim(optim_options);
        int stationarySims = Sims - (burnin);

        // obsPrecisionContainer = MatrixXd::Zero(K, stationarySims);
        // factorVarianceContainer = MatrixXd::Zero(nFactors, stationarySims);

        LoadingsPosteriorDraws.resize(stationarySims);
        BetaPosteriorDraws.resize(stationarySims);
        FactorPosteriorDraws.resize(stationarySims);
        GammasPosteriorDraws.resize(stationarySims);
        ObsPrecisionPosteriorDraws.resize(stationarySims);
        FactorVariancePosteriorDraws.resize(stationarySims);

        for (int i = 0; i < Sims; ++i)
        {

            cout << "Sim " << i + 1 << endl;

            betaupdate(yt, surX, omPrecision, Loadings, FactorPrecision, b0, B0);

            updateLoadingsFactors(yt, xbt, gammas, omPrecision,
                                  factorVariance, InfoMap, loadingsPriorMeans,
                                  loadingsPriorPrecision, optim);

            for (int j = 0; j < nFactors; ++j)
            {
                gammas.row(j) = updateAR(gammas.row(j), Factors.row(j), factorVariance(j), g0, G0);
                H = ReturnH(gammas.row(j), T);
                Hf = H * Factors.row(j).transpose();
                paramb = (.5 * (R0 + Hf.transpose() * Hf));
                factorVariance(j) = igammarnd(parama, 1.0 / paramb);
            }

            resids = yt - (Loadings * Factors) - xbt;
            for (int j = 0; j < K; ++j)
            {
                paramb = 0.5 * ((R0 + (resids.row(j) * resids.row(j).transpose())));
                omVariance(j) = igammarnd(parama, 1.0 / paramb);
            }
            omPrecision = omVariance.array().pow(-1.0);

            FactorPrecision = MakePrecision(gammas, factorVariance, T);

            if (i >= burnin)
            {
                BetaPosteriorDraws[i - (burnin)] = betanew;
                FactorPosteriorDraws[i - (burnin)] = Factors;
                LoadingsPosteriorDraws[i - (burnin)] = Loadings;
                GammasPosteriorDraws[i - (burnin)] = gammas;
                ObsPrecisionPosteriorDraws[i - (burnin)] = omPrecision;
                FactorVariancePosteriorDraws[i - (burnin)] = factorVariance;
            }
        }
        getAcceptanceRate(nFactors * Sims);
        cout << "Acceptance Rate " << acceptance_rate << endl;
    }

    VectorXd AStarReducedRun_G(int rr, Optimize optim)
    {

        if (rr > (Sims - burnin))
        {
            throw std::invalid_argument("Error in AStarReducedRun_G. N reduced runs cannot be greater than Sims - burnin - 1.");
        }
        int T = yt.cols();
        int K = yt.rows();
        int nFactors = InfoMap.size();
        int nrows;
        int c;
        int d = 0;
        int df = 15;
        int disp_on = 0;
        double lalpha;
        double qg;
        MatrixXd ytdemeaned;
        MatrixXd subytdemeanedstar;
        MatrixXd subytdemeanedg;
        MatrixXd subgammas;
        MatrixXd subFp;
        MatrixXd subFt;
        MatrixXd COM;
        MatrixXd mut;
        MatrixXd subPriorMean;
        MatrixXd subPriorPrecision;
        MatrixXd CovarianceStar;
        MatrixXd Diag;
        MatrixXd Ag;
        MatrixXd Factorg;
        MatrixXd gammag;
        MatrixXd surX = surForm(Xt, K);
        MatrixXd Xbetag;
        MatrixXd Astar = mean(LoadingsPosteriorDraws);
        MatrixXd postCovar;

        VectorXd betag;
        VectorXd obsPrecisiong;
        VectorXd factorVarianceg;
        VectorXd subA;
        VectorXd subfv;
        VectorXd subomPrecision;
        VectorXd MeanStar;
        VectorXd covDiag;
        VectorXd subAstar;
        VectorXd numerator(rr * nFactors);
        VectorXd postMean;
        for (int i = 0; i < rr; ++i)
        {
            betag = BetaPosteriorDraws[i];
            Ag = LoadingsPosteriorDraws[i];
            gammag = GammasPosteriorDraws[i];
            obsPrecisiong = ObsPrecisionPosteriorDraws[i];
            factorVarianceg = FactorVariancePosteriorDraws[i];
            Factorg = FactorPosteriorDraws[i];
            Xbetag = surX * betag;
            Xbetag.resize(K, T);
            c = 0;

            for (auto m = InfoMap.begin(); m != InfoMap.end(); ++m)
            {
                cout << "Factor level " << c + 1 << endl;
                nrows = m->second(1) - m->second(0) + 1;
                COM = zeroOutFactorLevel(Astar, c);
                mut = Xbetag + COM * Factorg;
                ytdemeaned = yt - mut;
                subytdemeanedstar = ytdemeaned.middleRows(m->second(0), nrows);

                COM = zeroOutFactorLevel(Ag, c);
                mut = Xbetag + COM * Factorg;
                ytdemeaned = yt - mut;
                subytdemeanedg = ytdemeaned.middleRows(m->second(0), nrows);

                subomPrecision = obsPrecisiong.segment(m->second(0), nrows);
                subA = Ag.col(c).segment(m->second(0), nrows);
                subAstar = Astar.col(c).segment(m->second(0), nrows);
                subgammas = gammag.row(c);
                subfv = factorVarianceg.row(c);
                subFp = MakePrecision(subgammas, subfv, T);
                subFt = Factorg.row(c);
                subPriorMean = loadingsPriorMeans[m->first].transpose();
                subPriorPrecision = loadingsPriorPrecision[m->first];

                MeanStar = PosteriorMeans[c];
                CovarianceStar = PosteriorCovariances[c];

                auto CLLstar = [&subytdemeanedstar, &subPriorMean, &subPriorPrecision,
                                &subomPrecision, &subFt, &subFp](const VectorXd &x0)
                {
                    return -ConditionalLogLikelihood(x0, subytdemeanedstar, subPriorMean, subPriorPrecision,
                                                     subomPrecision, subFt, subFp);
                };
                auto CLLg = [&subytdemeanedg, &subPriorMean, &subPriorPrecision,
                             &subomPrecision, &subFt, &subFp](const VectorXd &x0)
                {
                    return -ConditionalLogLikelihood(x0, subytdemeanedg, subPriorMean, subPriorPrecision,
                                                     subomPrecision, subFt, subFp);
                };
                optim.BFGS(subA, CLLg, disp_on);
                postMean = optim.x1;
                postCovar = optim.AprroximateDiagHessian(optim.x1, CLLg, optim.fval1);
                postCovar = postCovar.ldlt().solve(MatrixXd::Identity(nrows, nrows));
                qg = logmvtpdf(subAstar.transpose(), postMean.transpose(), postCovar, df);
                lalpha = -CLLstar(subAstar) + logmvtpdf(subA.transpose(), MeanStar.transpose(), CovarianceStar, df) +
                         CLLg(subA) - qg;
                lalpha = min(0., lalpha);
                numerator(d) = lalpha + qg;
                ++c;
                ++d;
            }
        }
        return numerator;
    }

    VectorXd AStarReducedRun_J(const Ref<const MatrixXd> &Xbetaj,
                               const Ref<const MatrixXd> &gammasj, const Ref<const VectorXd> &obsPrecisionj,
                               const Ref<const VectorXd> &factorVariancej, Optimize &optim)
    {

        int T = yt.cols();
        int K = yt.rows();
        int nFactors = InfoMap.size();
        int nrows;
        int c = 0;
        int d = 0;
        int df = 15;
        int disp_on = 0;
        double lalpha;
        double qg;
        MatrixXd ytdemeaned;
        MatrixXd subytdemeanedstar;
        MatrixXd subytdemeanedj;
        MatrixXd subgammas;
        MatrixXd subFp;
        MatrixXd subFt;
        MatrixXd COM;
        MatrixXd mut;
        MatrixXd subPriorMean;
        MatrixXd subPriorPrecision;
        MatrixXd CovarianceStar;
        MatrixXd Diag;
        MatrixXd Astar = mean(LoadingsPosteriorDraws);
        MatrixXd postCovar;
        MatrixXd lower;
        MatrixXd jCovar;

        VectorXd subA;
        VectorXd subfv;
        VectorXd subomPrecision;
        VectorXd MeanStar;
        VectorXd covDiag;
        VectorXd subAstar;
        VectorXd denominator;
        VectorXd jmean;
        VectorXd proposalj;

        denominator.setZero(nFactors);

        for (auto m = InfoMap.begin(); m != InfoMap.end(); ++m)
        {
            cout << "Factor level " << c + 1 << endl;
            nrows = m->second(1) - m->second(0) + 1;
            MeanStar = PosteriorMeans[c].transpose();
            CovarianceStar = PosteriorCovariances[c];
            lower = CovarianceStar.llt().matrixL();
            proposalj = MeanStar + lower * normrnd(0, 1, lower.rows(), 1);
            proposalj(1) = 1;
            Loadings.col(c).segment(m->second(0), nrows) = proposalj;

            COM = zeroOutFactorLevel(Astar, c);
            mut = Xbetaj + COM * Factors;
            ytdemeaned = yt - mut;
            subytdemeanedstar = ytdemeaned.middleRows(m->second(0), nrows);

            COM = zeroOutFactorLevel(Loadings, c);

            mut = Xbetaj + COM * Factors;
            ytdemeaned = yt - mut;
            subytdemeanedj = ytdemeaned.middleRows(m->second(0), nrows);
            subomPrecision = obsPrecisionj.segment(m->second(0), nrows);
            subA = Loadings.col(c).segment(m->second(0), nrows);
            subAstar = Astar.col(c).segment(m->second(0), nrows);
            subgammas = gammasj.row(c);
            subfv = factorVariancej.row(c);
            subFp = MakePrecision(subgammas, subfv, T);
            subFt = Factors.row(c);
            subPriorMean = loadingsPriorMeans[m->first].transpose();
            subPriorPrecision = loadingsPriorPrecision[m->first];

            auto CLLstar = [&subytdemeanedstar, &subPriorMean, &subPriorPrecision,
                            &subomPrecision, &subFt, &subFp](const VectorXd &x0)
            {
                return -ConditionalLogLikelihood(x0, subytdemeanedstar, subPriorMean, subPriorPrecision,
                                                 subomPrecision, subFt, subFp);
            };
            auto CLLj = [&subytdemeanedj, &subPriorMean, &subPriorPrecision,
                         &subomPrecision, &subFt, &subFp](const VectorXd &x0)
            {
                return -ConditionalLogLikelihood(x0, subytdemeanedj, subPriorMean, subPriorPrecision,
                                                 subomPrecision, subFt, subFp);
            };
            optim.BFGS(subA, CLLj, disp_on);
            jmean = optim.x1;
            jCovar = optim.AprroximateDiagHessian(optim.x1, CLLj, optim.fval1);
            jCovar = jCovar.ldlt().solve(MatrixXd::Identity(nrows, nrows));
            lalpha = -CLLj(subA) + logmvtpdf(subAstar.transpose(), MeanStar.transpose(), CovarianceStar, df) +
                     CLLstar(subAstar) - logmvtpdf(subA.transpose(), jmean.transpose(), jCovar, df);
            lalpha = min(0., lalpha);
            denominator(c) = lalpha;

            Factors.row(c) = updateFactor(subytdemeanedstar, subAstar, subFp, subomPrecision, T);
            ++c;
        }
        return denominator;
    }

    void ml(int rr)
    {
        std::vector<VectorXd> BetaRRj;
        std::vector<MatrixXd> FactorRRj;
        std::vector<MatrixXd> gammasRRj;
        std::vector<VectorXd> omPrecisionRRj;
        std::vector<VectorXd> factorVarianceRRj;
        BetaRRj.resize(rr);
        FactorRRj.resize(rr);
        gammasRRj.resize(rr);
        omPrecisionRRj.resize(rr);
        factorVarianceRRj.resize(rr);
        int K = yt.rows();
        int T = yt.cols();
        int nFactors = InfoMap.size();
        double optim_options[5] = {1e-4, 1e-5, 1e-5, 1e-4, 25};
        double parama = .5 * (T + r0);
        double paramb;
        Optimize optim(optim_options);
        MatrixXd Ftstar = mean(FactorPosteriorDraws);
        MatrixXd Astar = mean(LoadingsPosteriorDraws);
        MatrixXd betabar = mean(BetaPosteriorDraws);
        MatrixXd gammastar = mean(GammasPosteriorDraws);
        MatrixXd gammas = gammastar;
        MatrixXd surX = surForm(Xt, K);
        MatrixXd Xbeta = surX * betabar;
        MatrixXd H;
        MatrixXd resids;

        VectorXd Hf;
        VectorXd factorVariancestar = mean(FactorVariancePosteriorDraws);
        MatrixXd FactorPrecision = MakePrecision(gammastar, factorVariancestar, T);

        VectorXd omPrecisionbar = mean(ObsPrecisionPosteriorDraws);
        VectorXd omPrecision = omPrecisionbar;
        VectorXd omVariance = 1. / omPrecision.array();
        VectorXd factorVariance = factorVariancestar;
        VectorXd Numerator;
        MatrixXd Denominator;
        Denominator.setZero(nFactors, rr);
        Xbeta.resize(K, T);
        setPostMeansAndCovars(Astar, Xbeta, Ftstar, gammastar, omPrecisionbar,
                              factorVariancestar, optim);
        /* Loadings Reduced Run */
        Numerator = AStarReducedRun_G(rr, optim);
        for (int j = 0; j < rr; ++j)
        {
            cout << "Sim " << j + 1 << endl;
            betaupdate(yt, surX, omPrecision, Loadings, FactorPrecision, b0, B0);
            Denominator.col(j) = AStarReducedRun_J(xbt, gammas, omPrecision, factorVariance, optim);

            for (int i = 0; i < nFactors; ++i)
            {
                gammas.row(i) = updateAR(gammas.row(i), Factors.row(i), factorVariance(i), g0, G0);
                H = ReturnH(gammas.row(i), T);
                Hf = H * Factors.row(i).transpose();

                paramb = (.5 * (R0 + Hf.transpose() * Hf));

                factorVariance(i) = igammarnd(parama, 1.0 / paramb);
            }

            resids = yt - (Astar * Factors) - xbt;
            for (int i = 0; i < K; ++i)
            {
                paramb = 0.5 * (R0 + (resids.row(i) * resids.row(i).transpose()));
                omVariance(i) = igammarnd(parama, 1.0 / paramb);
            }
            omPrecision = omVariance.array().pow(-1.0);

            FactorPrecision = MakePrecision(gammas, factorVariance, T);

            BetaRRj[j] = betanew;
            FactorRRj[j] = Factors;
            gammasRRj[j] = gammas;
            omPrecisionRRj[j] = omPrecision;
            factorVarianceRRj[j] = factorVariance;
        }
        Denominator.resize(nFactors * rr, 1);
        cout << logavg(Numerator) - logavg(Denominator) << endl;

        /* Beta Reduced Run */
        VectorXd betaStar = mean(BetaRRj);
        setXbeta(betaStar, surX, K, T);
        VectorXd pibeta;
        pibeta.setZero(rr);
        gammastar = mean(gammasRRj);
        factorVariancestar = mean(factorVarianceRRj);
        FactorPrecision = MakePrecision(gammastar, factorVariancestar, T);
        MatrixXd ytdemeaned;
        MatrixXd subytdemeaned;
        MatrixXd subgammas;
        MatrixXd subFp;
        MatrixXd COM;
        MatrixXd mut;
        VectorXd subA;
        VectorXd subfv;
        VectorXd subomPrecision;

        int nrows;
        int i;
        for (int j = 0; j < rr; ++j)
        {
            cout << "Sim " << j + 1 << endl;
            omPrecision = omPrecisionRRj[j];
            pibeta(j) = betapdf(betaStar.transpose(), yt, surX, omPrecision, Astar, FactorPrecision, b0, B0);
            factorVariance = factorVarianceRRj[j];
            gammas = gammasRRj[j];
            i = 0;
            for (auto m = InfoMap.begin(); m != InfoMap.end(); ++m)
            {
                nrows = m->second(1) - m->second(0) + 1;
                COM = zeroOutFactorLevel(Astar, i);
                mut = xbt + COM * Factors;
                ytdemeaned = yt - mut;
                subA = Astar.col(i).segment(m->second(0), nrows);
                subgammas = gammas.row(i);
                subfv = factorVariance.row(i);
                subFp = MakePrecision(subgammas, subfv, T);
                subytdemeaned = ytdemeaned.middleRows(m->second(0), nrows);
                subomPrecision = omPrecision.segment(m->second(0), nrows);
                Factors.row(i) = updateFactor(subytdemeaned, subA, subFp, subomPrecision, T);
                gammas.row(i) = updateAR(gammas.row(i), Factors.row(i), factorVariance(i), g0, G0);
                H = ReturnH(gammas.row(i), T);
                Hf = H * Factors.row(i).transpose();
                paramb = (.5 * (R0 + Hf.transpose() * Hf));
                factorVariance(i) = igammarnd(parama, 1.0 / paramb);
                ++i;
            }

            resids = yt - (Astar * Factors) - xbt;
            for (int i = 0; i < K; ++i)
            {
                paramb = 0.5 * (R0 + (resids.row(i) * resids.row(i).transpose()));
                omVariance(i) = igammarnd(parama, 1.0 / paramb);
            }
            omPrecision = omVariance.array().pow(-1.0);

            FactorPrecision = MakePrecision(gammasRRj[j], factorVarianceRRj[j], T);

            FactorRRj[j] = Factors;
            gammasRRj[j] = gammas;
            omPrecisionRRj[j] = omPrecision;
            factorVarianceRRj[j] = factorVariance;
        }
        cout << logavg(pibeta) << endl;
        /* Gamma Reduced Run */
        gammastar = mean(gammasRRj);
        gamma_G(gammastar, gammasRRj, )
    }
};

#endif