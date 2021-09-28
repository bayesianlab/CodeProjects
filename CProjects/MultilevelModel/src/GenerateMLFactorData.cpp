#include "GenerateMLFactorData.hpp"

void DynamicFactorsArErrors::genData(const int &nObs, const int &nEqns, const int &nXs, const double &coeffValues,
                                     const Matrix<int, Dynamic, 2> &InfoMat, const RowVectorXd &factorArTerms,
                                     const RowVectorXd &omArTerms, const double &omVar)
{
    int T = nObs;
    int K = nEqns;
    int nFactors = InfoMat.rows();

    double facVar = omVar;
    VectorXd omVariance = VectorXd::Ones(K);

    gammas = factorArTerms.replicate(nFactors, 1);
    VectorXd factorVariance = facVar * VectorXd::Ones(nFactors, 1);
    MatrixXd FactorPrecision = MakePrecision(gammas, factorVariance, T);
    MatrixXd FactorCovar = FactorPrecision.ldlt().solve(MatrixXd::Identity(FactorPrecision.rows(),
                                                                           FactorPrecision.rows()));
    Factors = FactorCovar.llt().matrixL() * normrnd(0, 1, FactorCovar.rows());
    Factors.resize(nFactors, T);
    if (omArTerms.size() > 0)
    {
        deltas = omArTerms.replicate(K, 1);
        int lagsOm = deltas.cols();

        if (nXs == 0)
        {
            Xt.setZero(K * T, nFactors);
            Xt = makeOtrokXt(InfoMat, Factors, K);
        }
        else if (nXs == 1)
        {
            Xt.setZero(K * T, nFactors + 1);
            Xt.leftCols(nXs) << MatrixXd::Ones(K * T, 1);
            Xt.rightCols(nFactors) = makeOtrokXt(InfoMat, Factors, K);
        }
        else if (nXs > 1)
        {
            Xt.setZero(K * T, nXs + nFactors);
            Xt.leftCols(nXs) << MatrixXd::Ones(K * T, 1), normrnd(0, 1, K * T, nXs - 1);
            Xt.rightCols(nFactors) = makeOtrokXt(InfoMat, Factors, K);
        }
        else
        {
            throw invalid_argument("Invalid number of x's included in genOtrokData. nXs > 0.");
        }
        MatrixXd D0(lagsOm, lagsOm);
        VectorXd epsilonp(lagsOm);
        betas = coeffValues * MatrixXd::Ones(K, Xt.cols());
        b0 = RowVectorXd::Zero(betas.cols());
        B0 = 100*MatrixXd::Identity(betas.cols(), betas.cols());
        for (int k = 0; k < K; ++k)
        {
            for (int n = 0; n < nFactors; ++n)
            {
                if (k == InfoMat.row(n).head(1).value())
                {
                    betas(k, nXs + n) = 1;
                }
            }
        }
        betas.resize(1, K * Xt.cols());
        MatrixXd Xbeta = surForm(Xt, K) * betas.transpose();
        Xbeta.resize(K, T);
        yt.setZero(K, T);
        for (int k = 0; k < K; ++k)
        {
            D0 = setInitialCovar(deltas.row(k), omVariance(k));
            yt.row(k).leftCols(lagsOm) = (Xbeta.row(k).leftCols(lagsOm).transpose() + D0.llt().matrixL() * normrnd(0, 1, lagsOm, 1)).transpose();
            for (int t = lagsOm; t < T; ++t)
            {
                yt(k, t) = Xbeta(k, t) + deltas.row(k) * (yt.row(k).segment(t - lagsOm, lagsOm).transpose() - Xbeta.row(k).segment(t - lagsOm, lagsOm).transpose()) + normrnd(0, 1);
            }
        }
    }
    else
    {
        if (nXs == 0)
        {
            Xt.setZero(K * T, nFactors);
            Xt = makeOtrokXt(InfoMat, Factors, K);
        }
        else if (nXs == 1)
        {
            Xt.setZero(K * T, nFactors + 1);
            Xt.leftCols(nXs) << MatrixXd::Ones(K * T, 1);
            Xt.rightCols(nFactors) = makeOtrokXt(InfoMat, Factors, K);
        }
        else if (nXs > 1)
        {
            Xt.setZero(K * T, nFactors + nXs);
            Xt.leftCols(nXs) << MatrixXd::Ones(K * T, 1), normrnd(0, 1, K * T, nXs - 1);
            Xt.rightCols(nFactors) = makeOtrokXt(InfoMat, Factors, K);
        }
        else
        {
            throw invalid_argument("Invalid number of x's included in genOtrokData. nXs > 0.");
        }
        betas = coeffValues * MatrixXd::Ones(K, Xt.cols());
        for (int k = 0; k < K; ++k)
        {
            for (int n = 0; n < nFactors; ++n)
            {
                if (k == InfoMat.row(n).head(1).value())
                {
                    betas(k, nXs + n) = 1;
                }
            }
        }

        betas.resize(1, K * Xt.cols());
        MatrixXd Xbeta = surForm(Xt, K) * betas.transpose();
        Xbeta.resize(K, T);
        yt = Xbeta + normrnd(0, 1, K, T);
    }
}

void GenerateMLFactorData::genData(int _nObs, int _nEqns, const VectorXd &coeffValues,
                                   const Matrix<int, Dynamic, 2> &InfoMat,
                                   const RowVectorXd &factorCoeff,
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
    Identity = MakeObsModelIdentity(InfoMat, K);
    nFactors = InfoMat.rows();
    gammas = factorCoeff.replicate(nFactors, 1);
    int factorLags = gammas.cols(); 

    factorVariances = facVar * VectorXd::Ones(nFactors, 1);

    setLoadings(_Loadings, InfoMat, Identity, 1.);

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
    B0 = 100 * MatrixXd::Identity(nEqnsP, nEqnsP);
    g0 = RowVectorXd::Zero(factorLags);
    G0 = MatrixXd::Identity(factorLags, factorLags); 
}
