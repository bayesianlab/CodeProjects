#include "GenerateFactorData.hpp"

void GenerateFactorData::genDataArErrors(const int &nObs, const int &nEqns,
                                         const int &nXs,
                                         const double &coeffValues,
                                         const Matrix<int, Dynamic, 2> &InfoMat,
                                         const RowVectorXd &factorArTerms,
                                         const RowVectorXd &omArTerms,
                                         const double &omVar) {
  int T = nObs;
  int K = nEqns;
  int levels = calcLevels(InfoMat, K);
  int nFactors = InfoMat.rows();
  double facVar = omVar;
  VectorXd omVariance = VectorXd::Ones(K);
  gammas = factorArTerms.replicate(nFactors, 1);
  VectorXd factorVariance = facVar * VectorXd::Ones(nFactors, 1);
  MatrixXd FactorPrecision = MakePrecision(gammas, factorVariance, T);
  MatrixXd FactorCovar = FactorPrecision.ldlt().solve(
      MatrixXd::Identity(FactorPrecision.rows(), FactorPrecision.rows()));
  Factors = FactorCovar.llt().matrixL() * normrnd(0, 1, FactorCovar.rows());
  Factors.resize(nFactors, T);
  MatrixXd OMI = MakeObsModelIdentity(InfoMat, K);
  OMI = OMI.array() * coeffValues;
  deltas = omArTerms.replicate(K, 1);
  int lagsOm = deltas.cols();
  MatrixXd D0(lagsOm, lagsOm);
  VectorXd epsilonp(lagsOm);
  Xt = normrnd(0, 1, K * T, nXs);
  MatrixXd betas = coeffValues * MatrixXd::Ones(K, Xt.cols());
  b0 = RowVectorXd::Zero(betas.cols());
  B0 = 100 * MatrixXd::Identity(betas.cols(), betas.cols());

  betas.resize(K * Xt.cols(), 1);
  MatrixXd AF = OMI * Factors;
  MatrixXd Xbeta = surForm(Xt, K) * betas;
  Xbeta.resize(K, T);
  Xbeta = Xbeta + AF;
  yt.setZero(K, T);
  for (int k = 0; k < K; ++k) {
    D0 = setInitialCovar(deltas.row(k), omVariance(k));
    yt.row(k).leftCols(lagsOm) = (Xbeta.row(k).leftCols(lagsOm).transpose() +
                                  D0.llt().matrixL() * normrnd(0, 1, lagsOm, 1))
                                     .transpose();
    for (int t = lagsOm; t < T; ++t) {
      yt(k, t) = Xbeta(k, t) +
                 deltas.row(k) *
                     (yt.row(k).segment(t - lagsOm, lagsOm).transpose() -
                      Xbeta.row(k).segment(t - lagsOm, lagsOm).transpose()) +
                 normrnd(0, 1);
    }
  }
}

void GenerateFactorData::genData(int _K,int _T,  int nbetas, int ngammas,
                                 const Matrix<int, Dynamic, 2> &InfoMat) {
  T = _T;
  K = _K;
  double omVar = 1; 
  double facVar = omVar;
  betas = VectorXd::Ones(nbetas);
  if (betas.size() == 1) {
    Xt = MatrixXd::Ones(T * K, betas.size());
  } else {
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
  MatrixXd gammas(nFactors, ngammas);
  for (int i = 0; i < nFactors; ++i) {
    for (int j = 0; j < ngammas; ++j) {
      if (j = 0) {
        gammas(i, j) = .25;
      } else {
        gammas(i, j) = gammas(i, j) * gammas(i, j);
      }
    }
  }
  int factorLags = gammas.cols();
  factorVariances = facVar * VectorXd::Ones(nFactors, 1);
  MatrixXd A = MatrixXd::Ones(K, nFactors);
  for (int i = 0; i < A.cols(); ++i) {
    for (int j = i; j < A.cols(); ++j) {
      if (i == j) {
        A(i, j) = 1.0;
      } else {
        A(i, j) = 0;
      }
    }
  }

  FactorPrecision = MakePrecision(gammas, factorVariances, T);
  MatrixXd FactorCovar = FactorPrecision.llt().solve(
      MatrixXd::Identity(FactorPrecision.rows(), FactorPrecision.rows()));
  Factors = FactorCovar.llt().matrixL() * normrnd(0, 1, FactorCovar.rows());
  Factors.resize(nFactors, T);
  AF = A * Factors;
  mu = AF + Xbeta;
  MatrixXd nu = normrnd(0, sqrt(omVar), K, T);
  yt = mu + nu;
  resids = yt - mu;
  om_variance = omVar * VectorXd::Ones(K);
  om_precision = 1. / om_variance.array();
  b0 = RowVectorXd::Zero(1, nEqnsP);
  B0 = MatrixXd::Identity(nEqnsP, nEqnsP);
  g0 = RowVectorXd::Zero(factorLags);
  G0 = MatrixXd::Identity(factorLags, factorLags);
}

pair<MatrixXd, MatrixXd> GenerateFactorData::AstarLstar(const MatrixXd &A, const MatrixXd &Sigma){
		MatrixXd AAT = A * A.transpose();		 
		MatrixXd P = AAT + Sigma; 
		VectorXd d = P.diagonal().array().pow(-.5); 
		MatrixXd D = d.asDiagonal(); 
		MatrixXd L = Sigma.llt().matrixL();
		pair<MatrixXd, MatrixXd> M;  
		M.first = D*A; 
		M.second = D*L; 
		return M; 
}

void GenerateFactorData::genProbitData(int _K,int _T,  int nbetas, int ngammas,
                                 const Matrix<int, Dynamic, 2> &InfoMat) {
  T = _T;
  K = _K;
  double omVar = 1; 
  double facVar = omVar;
  betas = VectorXd::Ones(nbetas);
  if (betas.size() == 1) {
    Xt = MatrixXd::Ones(T * K, betas.size());
  } else {
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
  MatrixXd gammas(nFactors, ngammas);
  for (int i = 0; i < nFactors; ++i) {
    for (int j = 0; j < ngammas; ++j) {
      if (j = 0) {
        gammas(i, j) = .25;
      } else {
        gammas(i, j) = gammas(i, j) * gammas(i, j);
      }
    }
  }
  int factorLags = gammas.cols();
  factorVariances = facVar * VectorXd::Ones(nFactors, 1);
  MatrixXd A = MatrixXd::Ones(K, nFactors);
  MatrixXd Sigma = MatrixXd::Identity(K,K);
  for (int i = 0; i < A.cols(); ++i) {
    for (int j = i; j < A.cols(); ++j) {
      if (i == j) {
        A(i, j) = 1.0;
      } else {
        A(i, j) = 0;
      }
    }
  }

  auto AL = AstarLstar(A, Sigma);
  cout << "True Astar" << endl; 
  cout << AL.first << endl; 
  cout << "True Corr" << endl; 
  cout << AL.first*AL.first.transpose() + AL.second*AL.second.transpose() << endl; 
  FactorPrecision = MakePrecision(gammas, factorVariances, T);
  MatrixXd FactorCovar = FactorPrecision.llt().solve(
      MatrixXd::Identity(FactorPrecision.rows(), FactorPrecision.rows()));
  Factors = FactorCovar.llt().matrixL() * normrnd(0, 1, FactorCovar.rows());
  Factors.resize(nFactors, T);
  AF = AL.first * Factors;
  mu = AF + Xbeta;
  MatrixXd nu = normrnd(0, sqrt(omVar), K, T);
  yt = mu + nu;
  resids = yt - mu;
  om_variance = omVar * VectorXd::Ones(K);
  om_precision = 1. / om_variance.array();
  b0 = RowVectorXd::Zero(1, nEqnsP);
  B0 = MatrixXd::Identity(nEqnsP, nEqnsP);
  g0 = RowVectorXd::Zero(factorLags);
  G0 = MatrixXd::Identity(factorLags, factorLags);
}


void GenerateFactorData::breakPointGenData(
    int Time, int nEqns, int nbetas, const Matrix<int, Dynamic, 2> &InfoMat,
    int breakpoint, double loadingMag) {
  double facVar = 1;
  if (breakpoint > Time) {
    throw invalid_argument("breakpoint > Time in breakPointGenData");
  }
  if (nbetas == 0) {
    nFactors = InfoMat.rows();
    MatrixXd A = loadingMag * MatrixXd::Ones(nEqns, nFactors);
    for (int i = 0; i < A.rows(); ++i) {
      for (int j = 0; j < nFactors; ++j) {
        if (j > i) {
          A(i, j) = 0;
        }
      }
    }
    gammas = .55 * VectorXd::Ones(nFactors);
    int factorLags = gammas.cols();
    factorVariances = facVar * VectorXd::Ones(nFactors, 1);
    FactorPrecision = MakePrecision(gammas, factorVariances, Time);
    MatrixXd FactorCovar = FactorPrecision.householderQr().solve(
        MatrixXd::Identity(FactorPrecision.rows(), FactorPrecision.rows()));
    Factors = FactorCovar.llt().matrixL() * normrnd(0, 1, FactorCovar.rows());
    Factors.resize(nFactors, Time);
    MatrixXd AFactors = MatrixXd::Zero(nEqns, Time);
    MatrixXd Factorbreak1 = Factors.block(0, 0, nFactors, breakpoint);
    AFactors.block(0, breakpoint, nEqns, Time - breakpoint) =
        A * Factors.block(0, breakpoint, nFactors, Time - breakpoint);
    mu = AFactors;
    MatrixXd nu = normrnd(0, 1, nEqns, Time);
    yt = mu + nu;
    return;
  } else if (nbetas == 1) {
    betas = VectorXd::Ones(nbetas);
    Xt = MatrixXd::Ones(Time * nEqns, betas.size());
  } else {
    betas = VectorXd::Ones(nbetas);
    Xt = MatrixXd::Ones(Time * nEqns, betas.size());
    Xt.rightCols(betas.size() - 1) =
        normrnd(0, 1, Time * nEqns, betas.size() - 1);
  }

  surX = surForm(Xt, nEqns);
  nEqnsP = surX.cols();
  VectorXd allBetas = betas.replicate(nEqns, 1);
  Xbeta = surX * allBetas;
  Xbeta.resize(nEqns, Time);
  nFactors = InfoMat.rows();
  MatrixXd A = loadingMag * MatrixXd::Ones(nEqns, nFactors);
  for (int i = 0; i < A.rows(); ++i) {
    for (int j = 0; j < nFactors; ++j) {
      if (j > i) {
        A(i, j) = 0;
      }
    }
  }
  gammas = .55 * VectorXd::Ones(nFactors);
  int factorLags = gammas.cols();
  factorVariances = facVar * VectorXd::Ones(nFactors, 1);
  FactorPrecision = MakePrecision(gammas, factorVariances, Time);
  MatrixXd FactorCovar = FactorPrecision.householderQr().solve(
      MatrixXd::Identity(FactorPrecision.rows(), FactorPrecision.rows()));
  Factors = FactorCovar.llt().matrixL() * normrnd(0, 1, FactorCovar.rows());
  Factors.resize(nFactors, Time);
  MatrixXd AFactors = MatrixXd::Zero(nEqns, Time);
  MatrixXd Factorbreak1 = Factors.block(0, 0, nFactors, breakpoint);
  AFactors.block(0, breakpoint, nEqns, Time - breakpoint) =
      A * Factors.block(0, breakpoint, nFactors, Time - breakpoint);
  mu = AFactors + Xbeta;
  MatrixXd nu = normrnd(0, 1, nEqns, Time);
  yt = mu + nu;
}