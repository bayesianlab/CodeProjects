#include "CreateSampleData.hpp"
#include "Dist.hpp"
#include "GelfandDey.cpp"
#include "LinRegGibbs.hpp"
#include <Eigen/Dense>
#include <iostream>

using namespace std;
using namespace Eigen;
int main() {
  int dim = 2;
  int gs = 20000;
  int sSize = 100;
  int burnin = 200;
  VectorXd betas(dim);
  betas << 1, .5;
  CreateSampleData csd(sSize, betas, 1, .2);
  LinRegGibbs lrg;
  cout << "\n\t Gelfand Dey Tests" << endl;
  cout << "MLE's" << endl;
  cout << csd.maxLikeEsts.transpose() << endl;

  cout << "Show gibbs sampler converges to MLE's after burnin: " << endl;
  MatrixXd b0 = MatrixXd::Zero(dim,1);
  MatrixXd B0 = MatrixXd::Identity(dim,dim)*4;
  double a0 = 6;
  double d0 = 2.5;
  lrg.lrCondPriorsGibbs(csd.y, csd.X, gs, burnin, b0, B0, a0, d0);
  cout << endl;
  return 0;
}
