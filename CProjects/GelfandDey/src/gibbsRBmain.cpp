#include "CreateSampleData.hpp"
#include "Dist.hpp"
#include "GelfandDey.cpp"
#include "LinRegGibbs.hpp"
#include <Eigen/Dense>
#include <iostream>

using namespace std;
using namespace Eigen;
int main() {
  double inf = numeric_limits<double>::max();
  int dim = 4;
  int gs = 120;
  int sSize = 5000;
  int burnin = 20;
  VectorXd betas(dim);
  VectorXd rll(dim + 1);
  VectorXd rul(dim + 1);
  betas << .99, .99, 5.6, 3.2;
  rll << 0., 0., 0., -inf, -inf;
  rul << inf, 1, 1, inf, inf;
  CreateSampleData csd(sSize, betas, 100);
  LinRegGibbs lrg;
  cout << "MLE's" << endl;
  cout << csd.maxLikeEsts.transpose() << endl;
  cout << "Show gibbs sampler converges to MLE's after burnin: " << endl;

  MatrixXd b0 = MatrixXd::Zero(dim,1);
  MatrixXd B0 = MatrixXd::Identity(dim,dim);
  double a0 = 6;
  double d0 = 12;
  /*lrg.runSim(50, 5, rll, rul, csd.maxLikeEsts, csd.inverseFisher, csd.y, csd.X,
             b0, B0, a0, d0, gs, burnin);
  cout << endl;
  lrg.runSimModified(50, 5, rll, rul, csd.maxLikeEsts, csd.inverseFisher, csd.y, csd.X,
             b0, B0, a0, d0, gs, burnin);
*/

  MatrixXd I = MatrixXd::Identity(3, 3);
  MatrixXd K(3,3);
  MatrixXd G =  MatrixXd::Identity(3, 3);

  K << 1, -.7, .49, -.7, 1, -.7, .49, -.7, 1;
  G << 1, 2, 3, 4, 5, 6, 7, 8, 9;
  cout << lrg.SigmayyInverse(G) << endl;
  VectorXd a(3);
  VectorXd b(3);
  a << 0, 0, 0;
  b << 1, 1, 1;
  VectorXd mu(3);
  mu << 0, .5, 1;
  cout << endl;
  cout << lrg.tmultnorm(a, b, mu, K, 25 ) << endl;
  cout << endl;
  cout << "MV t" << endl;
  cout << lrg.mvttgewke91(a, b, I, mu, K, 5.0, 100, 80) << endl;
  cout << "GHK t" << endl;
  I(0,2) = 1;
  cout << lrg.ghkT(a,b, I, mu, K, 5.0, 1000, 80) << endl;

  return 0;
}
