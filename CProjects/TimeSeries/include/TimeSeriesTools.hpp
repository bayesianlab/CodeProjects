#pragma once
#ifndef TSTOOL_H
#define TSTOOL_H
#include <Eigen/Dense>
#include <Eigen/Sparse>
#include <unsupported/Eigen/KroneckerProduct>
#include <iostream>
#include <stdexcept>

#include "Distributions.hpp"

typedef SparseMatrix<double> SparseDouble;
template <typename D>
std::vector<MatrixXd> groupByTime(const MatrixBase<D> &Xtfull, const int &K) {
  if (Xtfull.rows() % K) {
    throw(std::invalid_argument(
        "Invalid number of rows in Xtfull for function groupByTime."));
  }
  const int T = Xtfull.rows() / K;
  ArrayXi indices = sequence(0, K * T, K);
  ArrayXi indexshift;
  std::vector<MatrixXd> Xtk;
  Xtk.resize(K);
  MatrixXd Xtemp;
  Xtemp.setZero(T, Xtfull.cols());
  for (int k = 0; k < K; ++k) {
    indexshift = indices + k;
    for (int t = 0; t < T; ++t) {
      Xtemp.row(t) = Xtfull.row(indexshift(t));
    }
    Xtk[k] = Xtemp;
  }
  return Xtk;
}

template <typename Derived>
MatrixXd makeStateSpace(const MatrixBase<Derived> &params) {
  /* phi_p should be 1st in parameter vector if lag p model
     e.g phi_p, phi_p-1, ... , phi_1
  */
  const int lags = params.cols();
  const int rows = params.rows();
  MatrixXd d = CreateDiag(params, sequence(0, (rows * lags) - 1, rows), rows,
                          rows * lags);
  MatrixXd B(rows * lags, rows * lags);
  B.bottomRows(rows * (lags - 1))
      << MatrixXd::Identity(rows * (lags - 1), rows * (lags - 1)),
      MatrixXd::Zero(rows * (lags - 1), rows);
  B.topRows(rows) << d;
  return B;
}

template <typename Derived>
MatrixXd makeStateSpace2(const MatrixBase<Derived> &params) {
  /* phi_p should be 1st in parameter vector if lag p model
     e.g phi_p, phi_p-1, ... , phi_1
  */
  const int lags = params.cols();
  const int rows = params.rows();
  MatrixXd d = CreateDiag(params, sequence(0, (rows * lags) - 1, rows), rows,
                          rows * lags);
  MatrixXd B(rows * lags, rows * lags);
  B.topRows(rows * (lags - 1)) << MatrixXd::Zero(rows * (lags - 1), rows),
      MatrixXd::Identity(rows * (lags - 1), rows * (lags - 1));
  B.bottomRows(rows) << d;
  return B;
}

template <typename Derived1, typename Derived2>
MatrixXd setInitialCovar(const MatrixBase<Derived1> &params,
                         const MatrixBase<Derived2> &vars) {
  /* phi_p should be 1st in parameter vector if lag p model
     e.g phi_p, phi_p-1, ... , phi_1
  */
  int lags = params.cols();
  int rows = params.rows();
  if (rows != vars.size()) {
    throw invalid_argument(
        "In setCovar, variances must be equal to number of equations.");
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
  if (isPD(P0) != true) {
    return MatrixXd::Identity(rows * lags, rows * lags);
  } else {
    return P0;
  }
}

template <typename Derived1>
MatrixXd setInitialCovar(const MatrixBase<Derived1> &params,
                         const double &var) {
  /* phi_p should be 1st in parameter vector if lag p model
     e.g phi_p, phi_p-1, ... , phi_1
  */
  int lags = params.cols();
  int rows = params.rows();
  MatrixXd stateSpaceParams = makeStateSpace(params);
  MatrixXd SkronS = kroneckerProduct(stateSpaceParams, stateSpaceParams);
  int rows2 = SkronS.rows();
  MatrixXd Irows2 = MatrixXd::Identity(rows2, rows2);
  MatrixXd Varmat(rows * lags, rows);
  Varmat << 1, MatrixXd::Zero(rows * (lags - 1), rows);
  MatrixXd outerp = Varmat * Varmat.transpose();
  outerp.resize(rows * rows * lags * lags, 1);
  MatrixXd P0 = (Irows2 - SkronS).householderQr().solve(outerp);
  P0.resize(rows * lags, rows * lags);
  if (isPD(P0)) {
    return var*P0;
  } else {
    return MatrixXd::Identity(rows * lags, rows * lags);
  }
}

template <typename D>
MatrixXd ReturnH(const MatrixBase<D> &params, int T) {
  /* param vector should include the greatest lag in the 0th column */
  int eqns = params.rows();
  int lags = params.cols();
  MatrixXd negparams = -params.replicate(T, 1);
  MatrixXd X(T * eqns, lags + 1);
  X << negparams, MatrixXd::Ones(T * eqns, 1);
  return CreateDiag(X, sequence(-eqns * (lags), 0, eqns), T * eqns, T * eqns);
}

template <typename D>
SparseDouble ReturnBigH(const MatrixBase<D> &params, int T) {
  /* param vector should include the greatest lag in the 0th column */
  int eqns = params.rows();
  int lags = params.cols();
  MatrixXd negparams = -params.replicate(T, 1);
  MatrixXd X(T * eqns, lags + 1);
  X << negparams, MatrixXd::Ones(T * eqns, 1);
  return CreateBigDiag(X, sequence(-eqns * (lags), 0, eqns), T * eqns,
                       T * eqns);
}

template <typename D1, typename D2>
MatrixXd MakePrecision(const MatrixBase<D1> &params, const MatrixBase<D2> &var,
                       int T) {
  MatrixXd H = ReturnH(params, T);
  VectorXd v = (var.array().pow(-1)).replicate(T, 1);
  MatrixXd Sinv = v.asDiagonal();
  return H.transpose() * Sinv * H;
}

template <typename D1, typename D2>
MatrixXd MakePrecisionBig(const MatrixBase<D1> &params,
                          const MatrixBase<D2> &var, int T) {
  // double mil = 1e6;
  // auto start = std::chrono::high_resolution_clock::now();
  SparseMatrix<double> H(var.size() * T, var.size() * T);
  H = ReturnBigH(params, T);
  // auto stop = std::chrono::high_resolution_clock::now();
  // auto duration = std::chrono::duration_cast<std::chrono::microseconds>(stop
  // - start); cout << duration.count() / mil << endl;
  VectorXd v = (var.array().pow(-1)).replicate(T, 1);
  SparseMatrix<double> Sinv(H.rows(), H.cols());
  for (int i = 0; i < H.rows(); ++i) {
    Sinv.insert(i, i) = v(i);
  }
  return H.transpose() * Sinv * H;
}

template <typename D1>
MatrixXd MakePrecision(const MatrixBase<D1> &params, const double &var, int T) {
  MatrixXd H = ReturnH(params, T);
  VectorXd v = VectorXd::Ones(T).array() / var;
  MatrixXd Sinv = v.asDiagonal();
  return H.transpose() * Sinv * H;
}

template <typename D>
MatrixXd lag(const MatrixBase<D> &xt, const int &lags, const int &dimension) {
  if (dimension == 0) {
    int K = xt.rows();
    int T = xt.cols();
    MatrixXd X = MatrixXd::Zero(K * lags, T - lags);
    VectorXi d = sequence(0, K - 1);
    int r = 0;
    for (int u = 0; u < lags; ++u) {
      X.middleRows(r, K) = xt.middleCols(u, T - lags);
      r += K;
    }
    return X;
  } else if (dimension == 1) {
    int K = xt.cols();
    int T = xt.rows();
    MatrixXd X = MatrixXd::Zero(T - lags, K * lags);
    VectorXi d = sequence(0, K - 1);
    int r = 0;
    for (int u = 0; u < lags; ++u) {
      X.middleCols(r, K) = xt.middleRows(u, T - lags);
      r += K;
    }
    return X;
  } else {
    throw invalid_argument("Invalid argument in lag.");
  }
}

  template <typename T>
  MatrixXd lagPolynomial(const MatrixBase<T> &X, const RowVectorXd &arparams,
                         const int lags, int dim) {
                          // prefer this to lagOperator
    if (dim == 1) {
      MatrixXd Xn(X.rows() - lags, X.cols());
      for (int i = 0; i < X.cols(); ++i) {
        MatrixXd Xl = lag(X.col(i), lags, dim);
        Xn.col(i) =
            X.col(i).bottomRows(X.rows() - lags) - Xl * arparams.transpose();
      }
      return Xn;
    } else if (dim == 0) {
      MatrixXd Xn(X.rows(), X.cols() - lags);
      for (int i = 0; i < X.rows(); ++i) {
        MatrixXd Xl = lag(X.row(i), lags, 0);
        Xn.row(i) = X.row(i).rightCols(X.cols() - lags) - arparams * Xl;
      }
      return Xn;
    } else {
      invalid_argument("Error in lag polynomial");
      return X;
    }
  }



class ArParameterTools {
 public:
  MatrixXd phinew;
  template <typename T1>
  RowVectorXd updateArParameters(const MatrixBase<T1> &epsilons,
                                 const RowVectorXd &current,
                                 const double sigma2, const RowVectorXd &g0,
                                 const MatrixXd &G0) {
    // yt comes in as 1 row
    // mut is 1 row of the mean function Xbeta
    if (epsilons.rows() != 1) {
      throw invalid_argument(
          "Error in updateArParams. epsilons must be == to 1 row.");
    }
    int T = epsilons.cols();
    int lags = current.cols();
    int MAX_TRIES = 25;
    int notvalid = 1;
    int count = 0;
    MatrixXd Etminus1 = lag(epsilons, current.cols(), 0);
    MatrixXd IG = MatrixXd::Identity(G0.rows(), G0.cols());
    MatrixXd G0inv = G0.llt().solve(IG);
    MatrixXd Vinv = G0inv + (Etminus1 * Etminus1.transpose()) / sigma2;
    Vinv = Vinv.llt().solve(IG);
    VectorXd v =
        Vinv * (G0inv * g0.transpose() +
                (Etminus1 * epsilons.rightCols(T - lags).transpose()) / sigma2);
    MatrixXd proposal;
    MatrixXd Test;
    VectorXd eigr(lags);
    VectorXd eigi(lags);
    VectorXd e(lags);
    int c;
    while (notvalid == 1) {
      proposal =
          (v + (Vinv.llt().matrixL() * normrnd(0, 1, lags, 1))).transpose();
      Test = makeStateSpace(proposal.rowwise().reverse());
      eigr = Test.eigenvalues().real();
      eigi = Test.eigenvalues().imag();
      e = eigr.array() * eigr.array() + eigi.array() * eigi.array();
      e = e.array().sqrt();
      c = 0;
      for (int i = 0; i < lags; ++i) {
        if (e(i) < 1) {
          ++c;
        }
      }
      if (c == lags) {
        notvalid = 0;
      }
      if (count == MAX_TRIES) {
        return current;
      }
      ++count;
    }
    MatrixXd P1(lags, lags);
    P1 = setInitialCovar(proposal, sigma2);
    MatrixXd P0(lags, lags);
    P0 = setInitialCovar(current, sigma2);

    RowVectorXd zeros = RowVectorXd::Zero(lags);
    double lalpha = min(0.0, logmvnpdf(epsilons.leftCols(lags), zeros, P1) -
                                 logmvnpdf(epsilons.leftCols(lags), zeros, P0));

    if (log(unifrnd()) < lalpha) {
      return proposal;
    } else {
      return current;
    }
  }

  template <typename T1>
  double alphag(const MatrixBase<T1> &posteriorEpsilonG,
                const RowVectorXd &phig, const RowVectorXd &phistar,
                const double sigma2g, const RowVectorXd &g0,
                const MatrixXd &G0) {
    int T = posteriorEpsilonG.cols();
    int lags = phig.cols();
    MatrixXd Etminus1 = lag(posteriorEpsilonG, phig.cols(), 0);
    MatrixXd IG = MatrixXd::Identity(G0.rows(), G0.cols());
    MatrixXd G0inv = G0.ldlt().solve(IG);
    MatrixXd Vinv = G0inv + (Etminus1 * Etminus1.transpose()) / sigma2g;
    Vinv = Vinv.ldlt().solve(IG);
    VectorXd v =
        Vinv * (G0inv * g0.transpose() +
                (Etminus1 * posteriorEpsilonG.rightCols(T - lags).transpose()) /
                    sigma2g);
    MatrixXd S2new = MatrixXd::Identity(T, T);
    S2new = S2new.array() * sigma2g;
    MatrixXd S2old = S2new;
    S2new.block(0, 0, lags, lags) = setInitialCovar(phistar, sigma2g);
    S2old.block(0, 0, lags, lags) = setInitialCovar(phig, sigma2g);
    MatrixXd IT = MatrixXd::Identity(S2new.rows(), S2new.cols());
    MatrixXd S2newinv = S2new.ldlt().solve(IT);
    MatrixXd S2newinvlower = S2newinv.llt().matrixL();
    MatrixXd S2oldinv = S2old.ldlt().solve(IT);
    MatrixXd S2oldinvlower = S2oldinv.llt().matrixL();
    MatrixXd epsilonstarnew = posteriorEpsilonG;
    MatrixXd epsilonstarold = posteriorEpsilonG;
    epsilonstarnew.rightCols(T - lags) =
        posteriorEpsilonG.rightCols(T - lags) - phistar * Etminus1;
    epsilonstarold.rightCols(T - lags) =
        posteriorEpsilonG.rightCols(T - lags) - phig * Etminus1;
    epsilonstarnew = epsilonstarnew * S2newinvlower;
    epsilonstarold = epsilonstarold * S2oldinvlower;
    RowVectorXd zero = RowVectorXd::Zero(epsilonstarnew.cols());
    VectorXd dnum = S2newinvlower.diagonal();
    VectorXd dden = S2oldinvlower.diagonal();
    return min(0.0, (logmvnpdfCentered(epsilonstarnew, dnum) +
                     logmvnpdf(phistar, g0, G0) -
                     logmvnpdf(phig, v.transpose(), Vinv)) -
                        (logmvnpdfCentered(epsilonstarold, dden) +
                         logmvnpdf(phig, g0, G0) -
                         logmvnpdf(phistar, v.transpose(), Vinv))) +
           logmvnpdf(phistar, v.transpose(), Vinv);
  }

  template <typename D1, typename D2>
  double alphaj(const MatrixBase<D1> &gammastar, const MatrixBase<D2> &epsilons,
                const double &sigma2, const MatrixXd &g0, const MatrixXd &G0) {
    if (epsilons.rows() != 1) {
      throw invalid_argument(
          "Error in updateArParams. epsilons must be == to 1 row.");
    }
    int T = epsilons.cols();
    int lags = gammastar.cols();
    int MAX_TRIES = 10;
    int notvalid = 1;
    int count = 0;
    MatrixXd Etminus1 = lag(epsilons, gammastar.cols(), 0);
    MatrixXd IG = MatrixXd::Identity(G0.rows(), G0.cols());
    MatrixXd G0inv = G0.ldlt().solve(IG);
    MatrixXd Vinv = G0inv + (Etminus1 * Etminus1.transpose()) / sigma2;
    Vinv = Vinv.ldlt().solve(IG);
    VectorXd v =
        Vinv * (G0inv * g0.transpose() +
                (Etminus1 * epsilons.rightCols(T - lags).transpose()) / sigma2);
    MatrixXd proposal;
    MatrixXd P1;
    while (notvalid == 1) {
      proposal =
          (v + (Vinv.llt().matrixL() * normrnd(0, 1, lags, 1))).transpose();
      P1 = setInitialCovar(proposal, sigma2);
      if (isPD(P1)) {
        notvalid = 0;
      }
      if (count == MAX_TRIES) {
        P1 = MatrixXd::Identity(lags, lags);
        break;
      }
      ++count;
    }
    MatrixXd S2new = MatrixXd::Identity(T, T);
    S2new = S2new.array() * sigma2;
    MatrixXd S2old = S2new;
    S2new.block(0, 0, lags, lags) = P1;
    S2old.block(0, 0, lags, lags) = setInitialCovar(gammastar, sigma2);
    MatrixXd IT = MatrixXd::Identity(S2new.rows(), S2new.cols());
    MatrixXd S2newinv = S2new.ldlt().solve(IT);
    MatrixXd S2newinvlower = S2newinv.llt().matrixL();
    MatrixXd S2oldinv = S2old.ldlt().solve(IT);
    MatrixXd S2oldinvlower = S2oldinv.llt().matrixL();
    MatrixXd epsilonstarnew = epsilons;
    MatrixXd epsilonstarold = epsilons;
    epsilonstarnew.rightCols(T - lags) =
        epsilons.rightCols(T - lags) - proposal * Etminus1;
    epsilonstarold.rightCols(T - lags) =
        epsilons.rightCols(T - lags) - gammastar * Etminus1;
    epsilonstarnew = epsilonstarnew * S2newinvlower;
    epsilonstarold = epsilonstarold * S2oldinvlower;
    RowVectorXd zero = RowVectorXd::Zero(epsilonstarnew.cols());
    VectorXd dnum = S2newinvlower.diagonal();
    VectorXd dden = S2oldinvlower.diagonal();
    return min(0.0, (logmvnpdfCentered(epsilonstarnew, dnum) +
                     logmvnpdf(proposal, g0, G0) -
                     logmvnpdf(gammastar, v.transpose(), Vinv)) -
                        (logmvnpdfCentered(epsilonstarold, dden) +
                         logmvnpdf(gammastar, g0, G0) -
                         logmvnpdf(proposal, v.transpose(), Vinv)));
  }
};

template <typename D1, typename D2>
MatrixXd updateAR(const MatrixBase<D1> &current, const MatrixBase<D2> &yt,
                  const double &sigma2, const MatrixXd &priorMean,
                  const MatrixXd &priorVar) {
  // Deprecated
  /* current comes in as a row, priorMean comes in as a row */
  int lags = current.cols();
  int T = yt.cols();

  MatrixXd Xt = lag(yt, lags, 0);
  MatrixXd ytstar = yt.rightCols(T - lags);
  MatrixXd Ip = MatrixXd::Identity(lags, lags);
  MatrixXd XX = Xt * Xt.transpose();
  XX = XX.array() / sigma2;

  MatrixXd G1 = priorVar.ldlt().solve(Ip);
  MatrixXd g1 = G1 * priorMean.transpose();
  G1 = (G1 + XX).ldlt().solve(Ip);

  MatrixXd Xy = (Xt * ytstar.transpose()).array() / sigma2;
  g1 = (G1 * (g1 + Xy)).transpose();

  Matrix<double, 1, 1> s2;
  s2 << sigma2;
  MatrixXd P0 = setInitialCovar(current, s2);
  MatrixXd G1L = G1.llt().matrixL();
  MatrixXd P1(lags, lags);
  int MAX_TRIES = 10;
  int count = 0;
  int notvalid = 1;
  MatrixXd proposal = g1;
  while ((notvalid == 1)) {
    proposal = (g1.transpose() + G1L * normrnd(0, 1, lags, 1)).transpose();
    P1 = setInitialCovar(proposal, s2);
    if (isPD(P1)) {
      notvalid = 0;
    }
    if (count == MAX_TRIES) {
      P1 = MatrixXd::Identity(lags, lags);
      break;
    }
    ++count;
  }

  MatrixXd Xp = MatrixXd::Zero(lags, lags);
  MatrixXd empty;
  for (int i = 1; i < lags; ++i) {
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
  double val =
      (logmvnpdf(yt - proposal * Xss, ZeroMean, Snew) +
       logmvnpdf(proposal, priorMean, priorVar) + logmvnpdf(current, g1, G1)) -
      (logmvnpdf(yt - current * Xss, ZeroMean, Scur) +
       logmvnpdf(current, priorMean, priorVar) + logmvnpdf(proposal, g1, G1));
  double lalpha = min(0., val);
  if (log(unifrnd(0, 1)) < lalpha) {
    return proposal;
  } else {
    return current;
  }
}

#endif