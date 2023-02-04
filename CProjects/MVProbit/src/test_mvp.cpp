
#include <iostream>

#include "mvp.hpp"

int main() {
  cout << " Test mvp" << endl;
  int N = 100;
  int p = 2;
  int K = 4;
  MatrixXd B0 = MatrixXd::Identity((p + 1) * K, (p + 1) * K);
  RowVectorXd b0((p + 1) * K);
  b0.setZero();
  MatrixXd xt = normrnd(0, 1, N * K, p);
  MatrixXd Xt(K * N, p + 1);
  Xt << VectorXd::Ones(K * N), xt;
  VectorXd beta(p + 1);
  beta << 1, 1, 1;
  MatrixXd S = CreateSigma(.5, K);
  cout << vech(S) << endl;
  MatrixXd Lower = S.llt().matrixL();
  MatrixXd eps = Lower * normrnd(0, 1, K, N);
  eps.resize(K * N, 1);
  MatrixXd zt = Xt * beta + eps;
  zt.resize(K, N);
  MatrixXd yt(K, N);
  for (int i = 0; i < N; ++i) {
    for (int j = 0; j < K; ++j) {
      if (zt(j, i) > 0) {
        yt(j, i) = 1;
      } else {
        yt(j, i) = 0;
      }
    }
  }
  int blocks = K - 1;
  std::vector<VectorXd> s0;
  std::vector<MatrixXd> S0;
  s0.resize(blocks);
  S0.resize(blocks);
  int dim;
  for (int i = 0; i < K - 1; ++i) {
    dim = (K - 1) - i;
    s0[i] = VectorXd::Zero(dim);
    S0[i] = .5 * MatrixXd::Identity(dim, dim);
  }

  MVP mv;
  double optim_options[5] = {1e-6, 1e-6, 1e-6, 1e-6, 20};
  Optimize optim(optim_options);
  double tune1 = 1;
  mv.setModel(yt, zt, Xt, beta.replicate(K, 1), b0, B0, s0, S0, optim, tune1);

  mv.runModel(40, 10);
  mv.ml();

  MatrixXd Loadings = MatrixXd::Ones(K, 1);
  MatrixXd Ft = normrnd(0, 1, N, 1);
  Matrix<int, Dynamic, 2> InfoMat(1, 2);
  InfoMat << 0, K - 1;
  int nFactors = InfoMat.rows();
  RowVectorXd b02(K * (p + nFactors));
  MatrixXd B02 = MatrixXd::Identity(K * (p + nFactors), K * (p + nFactors));
  int lags = 2;

  MatrixXd gammas(nFactors, lags);
  gammas << .2, .1;
  mv.setModel(yt, Xt, beta, Loadings, Ft, gammas, b02, B02, InfoMat);
  return 1;
}