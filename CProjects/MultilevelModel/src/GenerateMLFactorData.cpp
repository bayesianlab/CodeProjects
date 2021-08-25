#include "GenerateMLFactorData.hpp"

void GenerateMLFactorData::genData(int _nObs, int _nEqns, const VectorXd &coeffValues,
                                   const Matrix<int, Dynamic, 2> &InfoMat,
                                   const VectorXd &factorCoeff,
                                   const MatrixXd &_Loadings, const double &omVar)
{
    if (factorCoeff.rows() != InfoMat.rows())
    {
        throw invalid_argument("Factor lags not set correctly in genData().");
    }
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
    gammas = factorCoeff.transpose().replicate(nFactors, 1);

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
    B0 = 1000 * MatrixXd::Identity(nEqnsP, nEqnsP);
}

void GenerateMLFactorData::genOtrokData(const int &nObs, const int &nEqns, const int &nXs,
                                        const double &coeffValues, const Matrix<int, Dynamic, 2> &InfoMat,
                                        const RowVectorXd &gammas, const double &omVar, const RowVectorXd &omArTerms)
{
    if (omArTerms.size() == 0)
    {
        this->T = nObs;
        this->K = nEqns;
        this->nFactors = InfoMat.rows();
        double facVar = omVar;
        this->gammas = gammas.replicate(this->nFactors, 1);
        this->factorVariances = facVar * VectorXd::Ones(this->nFactors, 1);

        this->FactorPrecision = MakePrecision(this->gammas, this->factorVariances, this->T);
        MatrixXd FactorCovar = this->FactorPrecision.ldlt().solve(MatrixXd::Identity(this->FactorPrecision.rows(),
                                                                                     this->FactorPrecision.rows()));
        this->Factors = FactorCovar.llt().matrixL() * normrnd(0, 1, FactorCovar.rows());
        this->Factors.resize(this->nFactors, this->T);

        this->Xt.setZero(this->K * this->T, this->nFactors + nXs + 1);
        this->Xt.leftCols(nXs + 1) << MatrixXd::Ones(this->K * this->T, 1), normrnd(0, 1, this->K * this->T, nXs);
        this->Xt.rightCols(this->nFactors) = makeOtrokXt(InfoMat, this->Factors, nXs, this->K);
        this->betas = VectorXd::Ones(this->Xt.cols());
        this->betas = this->betas.array() * coeffValues;
        this->Xbeta = this->Xt * this->betas;
        this->Xbeta.resize(this->K, this->T);
        this->yt = this->Xbeta + normrnd(0, 1, this->K, this->T);
        this->om_variance = omVar * VectorXd::Ones(this->K);
        this->om_precision = 1. / this->om_variance.array();
        this->b0 = RowVectorXd::Zero(1, this->Xt.cols());
        this->B0 = 100 * MatrixXd::Identity(this->Xt.cols(), this->Xt.cols());
    }
    else
    {
        this->T = nObs;
        this->K = nEqns;
        this->nFactors = InfoMat.rows();
        double facVar = omVar;
        this->deltas = omArTerms.replicate(this->K, 1);
        this->gammas = gammas.replicate(this->nFactors, 1);
        this->factorVariances = facVar * VectorXd::Ones(this->nFactors, 1);
        this->FactorPrecision = MakePrecision(this->gammas, this->factorVariances, this->T);
        MatrixXd FactorCovar = this->FactorPrecision.ldlt().solve(MatrixXd::Identity(this->FactorPrecision.rows(),
                                                                                     this->FactorPrecision.rows()));
        this->Factors = FactorCovar.llt().matrixL() * normrnd(0, 1, FactorCovar.rows());
        this->Factors.resize(this->nFactors, this->T);
        this->Xt.setZero(this->K * this->T, this->nFactors + nXs + 1);
        this->Xt.leftCols(nXs + 1) << MatrixXd::Ones(this->K * this->T, 1), normrnd(0, 1, this->K * this->T, nXs);
        this->Xt.rightCols(this->nFactors) = makeOtrokXt(InfoMat, this->Factors, nXs, this->K);
        this->betas = VectorXd::Ones(this->Xt.cols());
        this->betas = this->betas.array() * coeffValues;
        this->Xbeta = this->Xt * this->betas;
        this->H = ReturnH(this->deltas, this->T);
        MatrixXd Hinv = this->H.householderQr().solve(MatrixXd::Identity(this->H.rows(), this->H.rows()));
        this->Xbeta.resize(this->K*this->T,1); 
        MatrixXd mu = Hinv*this->Xbeta;
        mu.resize(this->K,this->T);  
        VectorXd epsilon = normrnd(0, 1, this->K * this->T, 1);
        MatrixXd HinvEpsilon = Hinv * epsilon;
        HinvEpsilon.resize(this->K, this->T);
        HinvEpsilon.resize(this->K, this->T); 
        this->yt = mu + HinvEpsilon;
        this->yt.resize(this->K,this->T); 
        this->om_variance = omVar * VectorXd::Ones(this->K);
        this->om_precision = 1. / this->om_variance.array();
        this->b0 = RowVectorXd::Zero(1, this->Xt.cols());
        this->B0 = 100 * MatrixXd::Identity(this->Xt.cols(), this->Xt.cols());
    }
}