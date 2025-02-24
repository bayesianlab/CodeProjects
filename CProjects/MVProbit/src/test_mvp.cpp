
#include <iostream>

#include "mvp.hpp"

int main() {
  cout << " Test mvp" << endl;
  int T = 100;
  int p = 2;
  int K = 4;
  MatrixXd B0 = MatrixXd::Identity((p + 1) * K, (p + 1) * K);
  RowVectorXd b0((p + 1) * K);
  b0.setZero();
  MatrixXd xt = normrnd(0, 1, T * K, p);
  MatrixXd Xt(K * T, p + 1);
  Xt << VectorXd::Ones(K * T), xt;
  VectorXd beta = VectorXd::Ones(p+1);
  MatrixXd S = CreateSigma(.5, K);
  cout << vech(S) << endl;
  MatrixXd Lower = S.llt().matrixL();
  MatrixXd eps = Lower * normrnd(0, 1, K, T);
  eps.resize(K * T, 1);
  MatrixXd zt = Xt * beta + eps;
  zt.resize(K, T);
  MatrixXd yt(K, T);
  for (int i = 0; i < T; ++i) {
    for (int j = 0; j < K; ++j) {
      if (zt(j, i) > 0) {
        yt(j, i) = 1;
      } else {
        yt(j, i) = 0;
      }
    }
  }

  MVP mv;
  auto priors = mv.setPriorBlocks(K); 
  auto s0 = priors.first;
  auto S0 = priors.second; 
  double optim_options[5] = {1e-6, 1e-6, 1e-6, 1e-6, 20};
  Optimize optim(optim_options);
  double tune1 = 1.05;
  mv.setModel(yt, zt, Xt, beta.replicate(K, 1), b0, B0, s0, S0, optim, tune1);
  mv.runModel(40, 10);

}