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
  MatrixXd B = lrg.gibbsLR(csd.y, csd.X, gs, burnin);
  cout << B.colwise().mean() << endl;
  cout << endl;
  lrg.gelfandDeyML(B, csd.y, csd.X);
  lrg.analyticalLL(csd.y, csd.X);
  cout << endl;
  return 0;
}
