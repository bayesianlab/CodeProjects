#include "Dist.hpp"
#include "Probit.hpp"
#include <Eigen/Dense>

int main() {
  Dist dist(1);
  int N = 500;
  VectorXd beta(4);
  beta << 1, .8, -.5, .77;
  VectorXd constant(N);
  constant.fill(1);
  MatrixXd X(N, beta.size());
  X << constant, dist.normrnd(0, 1, N, beta.size() - 1);
  VectorXd epsilon = dist.normrnd(0, 1, N, 1);
  VectorXd z = X * beta + epsilon;
  VectorXd y(N);
  for (int i = 0; i < N; i++) {
    if (z(i) > 0) {
      y(i) = 1;
    } else {
      y(i) = 0;
    }
  }
  cout << "Probit Main" << endl;
  Probit p;
  VectorXd b0(X.cols());
  b0 << 1.081,  0.796917, -0.379066,  0.857086;
  MatrixXd B0 = 10*MatrixXd::Identity(X.cols(), X.cols());
  p.ProbitDataAug(y, X, b0, B0, 10000, 1000);
  return 1;
}
