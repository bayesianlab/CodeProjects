#include "MultilevelModel.hpp"

VectorXd var(const Ref<const MatrixXd> &A, int row_col)
{
    MatrixXd centered = (A.colwise() - A.rowwise().mean()).array().pow(2);
    return (1. / A.cols()) * centered.rowwise().sum();
}

MatrixXd MakeObsModelIdentity(const map<string, Matrix<int, 1, 2>> &m, int eqns)
{
    int levels = m.size();
    MatrixXd X = MatrixXd::Zero(eqns, levels);
    int factor = 0;
    for (auto it = m.begin(); it != m.end(); ++it)
    {
        int begin = it->second(0);
        int end = it->second(1);
        if (end > eqns)
        {
            throw invalid_argument("In MakeObsModelIdentity, index passed number of equations.");
        }
        for (int u = begin; u <= end; ++u)
        {
            X(u, factor) = 1;
        }
        ++factor;
    }
    return X;
}

void vectorize(MatrixXd &mat)
{
    mat.resize(mat.rows() * mat.cols(), 1);
}

VectorXi sequence(int b, int e)
{
    if (e < b)
    {
        throw invalid_argument("Error in sequence, end point less than beginning.");
    }
    VectorXi c(e - b + 1);
    int h = 0;
    for (int i = b; i <= e; ++i)
    {
        c(h) = b + h;
        ++h;
    }
    return c;
}

VectorXi sequence(int b, int e, int skip)
{
    if (e < b)
    {
        throw invalid_argument("Error in sequence, end point less than beginning.");
    }
    int N = (e - b + skip) / skip;
    VectorXi c(N);
    int h = 0;
    for (int i = b; i <= e; i += skip)
    {
        c(h) = b + h * skip;
        ++h;
    }
    return c;
}


// VectorXd betaupdate(const MatrixBase<D1> &yt, const MatrixBase<D2> &surX,
//                         const MatrixBase<D3> &om_precision, const MatrixBase<D4> &A,
//                         const MatrixBase<D5> &FactorPrecision, const MatrixBase<D6> &b0,
//                         const MatrixBase<D7> &B0)
//     {
//         /* b0 is a column */
//         int T = yt.cols();
//         int K = yt.rows();
//         int nFactors = A.cols();
//         int nFactorsT = nFactors * T;
//         int KP = surX.cols();
//         MatrixXd It = MatrixXd::Identity(T, T);
//         MatrixXd InFactorsT = MatrixXd::Identity(nFactorsT, nFactorsT);
//         MatrixXd Ikp = MatrixXd::Identity(KP, KP);
//         MatrixXd FullPrecision = om_precision.asDiagonal();
//         MatrixXd temp = (B0.diagonal().array().pow(-1));
//         MatrixXd B0inv = temp.asDiagonal(); // Get rid of this temporary
//         MatrixXd xpx = MatrixXd::Zero(KP, KP);
//         MatrixXd xpy = MatrixXd::Zero(KP, 1);
//         MatrixXd xzz = MatrixXd::Zero(nFactorsT, KP);
//         MatrixXd yzz = MatrixXd::Zero(nFactorsT, 1);
//         MatrixXd tx;
//         MatrixXd ty;
//         int c1 = 0;
//         int c2 = 0;
//         for (int t = 0; t < T; ++t)
//         {
//             tx = FullPrecision * surX.middleRows(c1, K);
//             ty = FullPrecision * yt.col(t);
//             xzz.middleRows(c2, nFactors) = A.transpose() * tx;
//             yzz.middleRows(c2, nFactors) = A.transpose() * yt.col(t);
//             xpx += surX.middleRows(c1, K).transpose() * tx;
//             xpy += surX.middleRows(c1, K).transpose() * ty;

//             c1 += K;
//             c2 += nFactors;
//         }
//         MatrixXd XzzPinv = (FactorPrecision + kroneckerProduct(It, (A.transpose() * FullPrecision) * A)).householderQr().solve(InFactorsT);
//         XzzPinv = xzz.transpose() * XzzPinv;
//         MatrixXd Covar = B0inv + xpx - (XzzPinv * xzz);
//         MatrixXd Blowerinv = Covar.llt().matrixL(); 
//         Blowerinv = Blowerinv.householderQr().solve(MatrixXd::Identity(Blowerinv.rows(), Blowerinv.rows()));
//         Covar = Blowerinv.transpose()*Blowerinv; 
//         MatrixXd mu  = Covar * ((B0inv * b0.transpose()) + xpy - (XzzPinv * yzz));
//         VectorXd bs = mu + (Blowerinv.transpose()* normrnd(0, 1, KP, 1));
//         return bs;
//     } 

MatrixXd updateFactor(const MatrixXd &residuals, const MatrixXd &Loadings, const MatrixXd &FactorPrecision,
                      const VectorXd &precision, int T)
{
    int K = precision.size();
    int nFactors = Loadings.cols();
    int nFactorsT = nFactors * T;
    MatrixXd AtO = Loadings.transpose() * precision.asDiagonal();
    MatrixXd F = FactorPrecision + kroneckerProduct(MatrixXd::Identity(T, T), AtO * Loadings);
    MatrixXd Q = F.householderQr().solve(MatrixXd::Identity(F.rows(), F.rows()));
    MatrixXd lower = Q.llt().matrixL();
    MatrixXd musum = AtO * residuals;
    MatrixXd mu = Q * musum;
    return mu + lower * normrnd(0, 1, nFactorsT);
    // factorNew = factorNew * residuals;
    // factorNew.resize(factorNew.rows() * factorNew.cols(), 1);
    // factorNew = F * factorNew;
    // factorNew = factorNew + lower * normrnd(factorNew.rows(), 1);
    // factorNew.resize(nFactors, T);
    // return factorNew;
}

GenerateMLFactorData::GenerateMLFactorData(int _nObs, int _nEqns, const VectorXd &coeffValues,
                                           const map<string, Matrix<int, 1, 2>> &InfoMap,
                                           const VectorXd &factorCoeff,
                                           const MatrixXd &_Loadings, const double &omVar)
{
    T = _nObs;
    K = _nEqns;
    double facVar = omVar;
    betas = coeffValues;
    if (betas.size() == 1)
    {
        Xt = MatrixXd::Ones(T * K, betas.size());
    }
    else
    {

        Xt = MatrixXd::Ones(T * K, betas.size());
        Xt.rightCols(betas.size() - 1) = normrnd(0, 1, T * K, betas.size() - 1);
    }
    surX = surForm(Xt, K);

    nEqnsP = surX.cols();
    VectorXd allBetas = betas.replicate(K, 1);
    Xbeta = surX * allBetas;
    Xbeta.resize(K, T);
    Identity = MakeObsModelIdentity(InfoMap, K);
    nFactors = InfoMap.size();
    gammas = factorCoeff.transpose().replicate(nFactors, 1);
    factorVariances = facVar * VectorXd::Ones(nFactors, 1);

    setLoadings(_Loadings, InfoMap, Identity, 1.);

    FactorPrecision = MakePrecision(gammas, factorVariances, T);



    MatrixXd FactorCovar = FactorPrecision.householderQr().solve(MatrixXd::Identity(FactorPrecision.rows(), FactorPrecision.rows()));

    

    Factors = FactorCovar.llt().matrixL() * normrnd(0, 1, FactorCovar.rows());
    Factors.resize(nFactors, T);
    // VectorXd epsilon = normrnd(0, sqrt(facVar), T * nFactors, 1);
    // H = ReturnH(gammas, T);
    // Factors = H.householderQr().solve(epsilon);
    // Factors.resize(nFactors, T);

    AF = Loadings * Factors;
    mu = AF + Xbeta;
    MatrixXd nu = normrnd(0, sqrt(omVar), K, T);
    yt = mu + nu;

    // VectorXd V = var(yt, 0);

    // V = V.array().sqrt(); 
    // cout << V << endl ;
    // yt = yt.array().colwise()/V.array();

    resids = yt - mu - nu;
    om_variance = omVar * VectorXd::Ones(K);
    om_precision = 1. / om_variance.array();
    b0 = RowVectorXd::Zero(1, nEqnsP);
    B0 = 1000*MatrixXd::Identity(nEqnsP, nEqnsP);
}

GenerateAutoRegressiveData::GenerateAutoRegressiveData(int time, const MatrixXd &params)
{
    lags = params.cols();
    H = ReturnH(params, time);
    epsilon = normrnd(0, 1, time, 1);
    yt = H.householderQr().solve(epsilon).transpose();
    G0 = 10 * MatrixXd::Identity(lags, lags);
    g0 = MatrixXd::Zero(1, lags);
    ythat = yt.rightCols(time - lags);
    Xthat = lag(yt, lags);
    sigma2 = 1.;
}