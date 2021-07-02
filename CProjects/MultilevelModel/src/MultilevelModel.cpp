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

MatrixXd updateFactor(MatrixXd vectorizedResiduals, const MatrixXd &Loadings, const MatrixXd &FactorPrecision,
                      const VectorXd &precision, int T)
{
    int K = precision.size();
    int nFactors = Loadings.cols();
    int nFactorsT = nFactors*T;
    MatrixXd IT = MatrixXd::Identity(T, T);
    MatrixXd FullPrecision = precision.asDiagonal();
    MatrixXd ApO = Loadings.transpose() * FullPrecision;
    MatrixXd P = FactorPrecision + kroneckerProduct(IT, ApO * Loadings);
    MatrixXd Plower = P.llt().matrixL();
    MatrixXd Plowerinv = Plower.householderQr().solve(MatrixXd::Identity(nFactorsT, nFactorsT));
    vectorizedResiduals.resize(K, T);
    MatrixXd musum = ApO * vectorizedResiduals;
    musum.resize(musum.rows() * musum.cols(), 1);
    VectorXd mu = (Plowerinv.transpose() * Plowerinv) * musum;
    MatrixXd f = mu + Plowerinv.transpose()*normrnd(0,1,nFactorsT,1);
    f.resize(nFactors, T);
    return f;
}

GenerateMLFactorData::GenerateMLFactorData(int _nObs, int _nEqns, const VectorXd &coeffValues,
                                           const map<string, Matrix<int, 1, 2>> &InfoMap,
                                           const VectorXd &factorCoeff, const VectorXd &_factorVariances,
                                           const MatrixXd &_Loadings)
{
    T = _nObs;
    K = _nEqns;
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
    factorVariances = _factorVariances;
    Loadings = _Loadings;
    Loadings = Identity.array() * Loadings.array();
    P0 = setCovar(gammas, factorVariances);
    FactorPrecision = MakePrecision(gammas, factorVariances, T);
    MatrixXd I = MatrixXd::Identity(FactorPrecision.rows(), FactorPrecision.rows());
    VectorXd epsilon = normrnd(0, 1, T * nFactors, 1);
    H = ReturnH(gammas, T);
    Factors = H.householderQr().solve(epsilon);
    Factors.resize(nFactors, T);
    AF = Loadings * Factors;
    mu = AF + Xbeta;
    MatrixXd nu = normrnd(0, 1, K, T);
    yt = mu + nu;
    om_variance = VectorXd::Ones(K);
    om_precision = om_variance;
    b0 = VectorXd::Ones(nEqnsP, 1);
    B0 = 10 * MatrixXd::Identity(nEqnsP, nEqnsP);
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