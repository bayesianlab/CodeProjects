#include "MultilevelModel.hpp"

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

MatrixXd updateFactor(const MatrixXd &residuals, const MatrixXd &Loadings, const MatrixXd &FactorPrecision,
                      const VectorXd &precision, int T)
{
    int K = precision.size();
    int nFactors = Loadings.cols();
    int nFactorsT = nFactors * T;
    MatrixXd factorNew = Loadings.transpose() * precision.asDiagonal();
    MatrixXd F = FactorPrecision + kroneckerProduct(MatrixXd::Identity(T, T), factorNew * Loadings);
    F = F.householderQr().solve(MatrixXd::Identity(F.rows(), F.rows()));
    MatrixXd lower = F.llt().matrixL();
    factorNew = factorNew * residuals;
    factorNew.resize(factorNew.rows() * factorNew.cols(), 1);
    factorNew = F * factorNew;
    factorNew = factorNew + lower * normrnd(factorNew.rows(), 1);
    factorNew.resize(nFactors, T);
    return factorNew;
}

GenerateMLFactorData::GenerateMLFactorData(int _nObs, int _nEqns, const VectorXd &coeffValues,
                                           const map<string, Matrix<int, 1, 2>> &InfoMap,
                                           const VectorXd &factorCoeff,
                                           const MatrixXd &_Loadings, const double &omVar)
{
    T = _nObs;
    K = _nEqns;
    double facVar = .25*omVar;
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
    factorVariances = facVar * VectorXd::Ones(nFactors, 1) * facVar;

    setLoadings(_Loadings, InfoMap, Identity, 1);

    Loadings = Identity.array() * Loadings.array();
    FactorPrecision = MakePrecision(gammas, factorVariances, T);
    VectorXd epsilon = normrnd(0, sqrt(facVar), T * nFactors, 1);
    H = ReturnH(gammas, T);
    Factors = H.householderQr().solve(epsilon);
    Factors.resize(nFactors, T);
    AF = Loadings * Factors;
    mu = AF + Xbeta;

    MatrixXd nu = normrnd(0, sqrt(omVar), K, T);
    yt = mu + nu;
    resids = yt - mu - nu;
    om_variance = omVar * VectorXd::Ones(K);
    om_precision = 1. / om_variance.array();
    b0 = RowVectorXd::Zero(1, nEqnsP);
    B0 = 100 * MatrixXd::Identity(nEqnsP, nEqnsP);
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