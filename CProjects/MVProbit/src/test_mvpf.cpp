
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
  VectorXd beta = VectorXd::Ones(p + 1);
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
  Matrix<int, Dynamic, 2> InfoMat(1, 2);
  InfoMat << 0, K - 1;
  VectorXd phi(1);
  phi << .25; 

  mv.setModel(yt, Xt, beta.replicate(K, 1), phi, b0, B0, InfoMat, "factor");
  mv.runFactorModel(5, 1);
}