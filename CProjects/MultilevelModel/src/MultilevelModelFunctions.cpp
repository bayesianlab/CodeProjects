#include "MultilevelModelFunctions.hpp"

MatrixXi createFactorInfo(const Matrix<int, Dynamic, 2> &InfoMat,
                          const int &K) {
  RowVectorXi r(2);
  int start;
  int end;
  int endlast = InfoMat(0, 0) - 1;
  int c = 0;
  int shift = K - 1;
  vector<VectorXi> temp;
  VectorXi FactorInfo(K);
  FactorInfo.setConstant(-1);
  for (int j = 0; j < InfoMat.rows(); ++j) {
    r = InfoMat.row(j);
    start = r(0);
    end = r(1);
    if (endlast >= start) {
      temp.push_back(FactorInfo);
      FactorInfo.setConstant(-1);
      FactorInfo.segment(start, end - start + 1).setConstant(c);
    } else {
      FactorInfo.segment(start, end - start + 1).setConstant(c);
    }
    ++c;
    endlast = end;
  }
  temp.push_back(FactorInfo);
  MatrixXi FI(K, temp.size());
  c = 0;
  for (auto it = temp.begin(); it != temp.end(); ++it) {
    FI.col(c) = (*it);
    ++c;
  }
  return FI;
}

MatrixXd packageFactorsInXt(const Matrix<int, Dynamic, 2> &InfoMat,
                            const Ref<MatrixXd> &Factors, const int &K) {
  int start;
  int start2 = 0;
  int nrows;
  int nFactors = Factors.rows();
  int T = Factors.cols();
  int colShift;
  int levels = calcLevels(InfoMat, K);
  MatrixXd Xt;
  Xt.setZero(K * T, levels);
  for (int t = 0; t < T; ++t) {
    colShift = 0;
    for (int i = 0; i < nFactors; ++i) {
      start = InfoMat.row(i).head(1).value();
      nrows = InfoMat.row(i).tail(1).value() - start + 1;
      Xt.col(colShift).middleRows(start + start2, nrows) =
          Factors.row(i).col(t).replicate(nrows, 1);
      if ((InfoMat.row(i).tail(1).value()) == K - 1) {
        ++colShift;
      }
    }
    start2 += K;
  }
  return Xt;
}

MatrixXd MakeObsModelIdentity(const Matrix<int, Dynamic, 2> &InfoMat,
                              const int eqns) {
  int nFactors = InfoMat.rows();
  MatrixXd X = MatrixXd::Zero(eqns, nFactors);
  int factor = 0;

  for (int i = 0; i < nFactors; ++i) {
    int begin = InfoMat.row(i).head(1).value();
    int end = InfoMat.row(i).tail(1).value();

    if (end > eqns) {
      throw invalid_argument(
          "In MakeObsModelIdentity, index passed number of equations.");
    }
    for (int u = begin; u <= end; ++u) {
      X(u, factor) = 1;
    }
    ++factor;
  }
  return X;
}

// template <typename D1, typename D2, typename D3, typename D4>
// MatrixXd updateFactor(const MatrixBase<D1> &residuals, const MatrixBase<D2> &Loadings,
//                       const MatrixBase<D3> &FactorPrecision,
//                       const MatrixBase<D4> &Precision){
//   int nFactors = Loadings.cols();
//   if(not (residuals.rows() % Loadings.rows()))
//   {
//     throw std::invalid_argument("Rows of resids not divisilble by K. Input error.");
//   }
//   int T = residuals.rows()/Loadings.rows(); 
//   int nFactorsT = nFactors * T;
//   MatrixXd AtO = Loadings.transpose() * Precision;
//   MatrixXd FplusAtOinv =
//       FactorPrecision +
//       kroneckerProduct(MatrixXd::Identity(T, T), AtO * Loadings);
//   FplusAtOinv = FplusAtOinv.llt().solve(
//       MatrixXd::Identity(FplusAtOinv.rows(), FplusAtOinv.rows()));
//   MatrixXd lower = FplusAtOinv.llt().matrixL();
//   MatrixXd musum = AtO * residuals;
//   Map<VectorXd> vecmu(musum.data(), musum.size());
//   VectorXd mu = FplusAtOinv * vecmu;
//   FplusAtOinv = mu + lower * normrnd(0, 1, nFactorsT, 1);
//   FplusAtOinv.resize(nFactors, T);
//   return FplusAtOinv;
// }

double factorReducecdRun(const RowVectorXd &factorStar,
                         const MatrixXd &residuals, const MatrixXd &Loadings,
                         const MatrixXd &FactorPrecision,
                         const VectorXd &precision, int T) {
  MatrixXd AtO = Loadings.transpose() * precision.asDiagonal();
  MatrixXd FplusAtOinv =
      FactorPrecision +
      kroneckerProduct(MatrixXd::Identity(T, T), AtO * Loadings);
  FplusAtOinv = FplusAtOinv.ldlt().solve(
      MatrixXd::Identity(FplusAtOinv.rows(), FplusAtOinv.rows()));
  MatrixXd musum = AtO * residuals;
  Map<VectorXd> vecmu(musum.data(), musum.size());
  RowVectorXd mu = (FplusAtOinv * vecmu);
  return logmvnpdf(factorStar, mu.transpose(), FplusAtOinv);
}

MatrixXi returnIdentificationRestictions(const MatrixXi &FactorInfo) {
  int x = -1;
  MatrixXi F(FactorInfo.rows(), FactorInfo.cols());
  F.setZero();
  for (int j = 0; j < FactorInfo.cols(); ++j) {
    for (int r = 0; r < FactorInfo.rows(); ++r) {
      if (x != FactorInfo(r, j)) {
        F(r, j) = 1;
      }
      x = FactorInfo(r, j);
    }
  }
  return F;
}

int calcLevels(const Matrix<int, Dynamic, 2> &InfoMat, const int &K) {
  int levelCount = 0;
  for (int n = 0; n < InfoMat.rows(); ++n) {
    if (K - 1 == InfoMat.row(n).tail(1).value()) {
      ++levelCount;
    }
  }
  return levelCount;
}

string dateString() {
  time_t now = time(0);
  tm *ltm = localtime(&now);
  string l = "yhms";
  string s = l + "_" + to_string(1900 + ltm->tm_year) + "_" +
             to_string(ltm->tm_mon) + "_" + to_string(ltm->tm_mday) +
             "_" + to_string(ltm->tm_hour) + "_" + to_string(ltm->tm_min) + "_" +
             to_string(ltm->tm_sec);
  return s;
}

