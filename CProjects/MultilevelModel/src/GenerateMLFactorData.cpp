#include "GenerateMLFactorData.hpp"

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


    AF = Loadings * Factors;
    mu = AF + Xbeta;
    MatrixXd nu = normrnd(0, sqrt(omVar), K, T);
    yt = mu + nu;

    resids = yt - mu - nu;
    om_variance = omVar * VectorXd::Ones(K);
    om_precision = 1. / om_variance.array();
    b0 = RowVectorXd::Zero(1, nEqnsP);
    B0 = 1000 * MatrixXd::Identity(nEqnsP, nEqnsP);
}