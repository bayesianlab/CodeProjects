#include "Dist.hpp"
#include "Logit.hpp"
#include "CreateSampleData.hpp"
#include <boost/math/distributions/logistic.hpp>
#include <Eigen/Dense>

using namespace std;
using namespace boost::math;

int main() {
  logistic L;
  Dist dist(1);
  int N = 250;
  VectorXd beta(4);
  beta << 1, .8, -.5, .77;
  VectorXd constant(N);
  constant.fill(1);
  MatrixXd X(N, beta.size());
  X << constant, dist.normrnd(0, 1, N, beta.size() - 1);
  VectorXd epsilon = dist.logisticrnd(N);
  VectorXd z = X * beta + epsilon;
  VectorXd y(N);
  for (int i = 0; i < N; i++) {
    if (z(i) > 0) {
      y(i) = 1;
    } else {
      y(i) = 0;
    }
  }
  Logit logit;
  VectorXd beta0(beta.size());
  MatrixXd H0(beta.size(), beta.size());
  beta0.setZero();
  VectorXd mu(3);
  mu << 1, .5, 1.3;
  MatrixXd Sigma(3, 3);
  Sigma << 1, .5, .25, .5, 1, .25, .25, .5, 1;
  //cout << dist.mvtrnd(mu, Sigma, 6, 10) << endl;
  //cout<< dist.mvnrnd(mu,Sigma, 10) << endl;

 // cout << logit.logitPrimePrime(X, beta0) << endl;
 VectorXd betaP = MatrixXd::Zero(beta.size(), 1);
 MatrixXd sigmaP = MatrixXd::Identity(beta.size(), beta.size());
 logit.LogitMetropolisHastings(y,X, betaP, sigmaP, 10, 10000, 1000);
}
