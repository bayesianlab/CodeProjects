
#include <Eigen/Dense>
#include <iostream>

#include "BayesianUpdates.hpp"
#include "EigenTools.hpp"
using namespace std;
using namespace Eigen;

int main() {
  cout << "Test Bayesian Updates" << endl;
  VectorXd beta(3);
  beta << 1, 1, 1;
  GenerateRegressionData grd(100, beta);
  LinearModel lm;
  RowVectorXd b0 = RowVectorXd::Zero(grd.Xt.cols());
  MatrixXd B0 = 10 * MatrixXd::Identity(grd.Xt.cols(), grd.Xt.cols());
  double s0 = 8;
  double S0 = 8;
  lm.setModel(grd.yt, grd.Xt, b0, B0, s0, S0);
  lm.runModel(10, 1);
  cout << "True values for beta " << endl;
  cout << beta.transpose() << endl;
  cout << mean(lm.betaPosterior).transpose() << endl;
  return 0;
}