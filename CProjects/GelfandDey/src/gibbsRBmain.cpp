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
  MatrixXd G =  MatrixXd::Identity(3, 3);

  I << 1, -.7, .49, -.7, 1, -.7, .49, -.7, 1;
  G << 1, 2, 3, 4, 5, 6, 7, 8, 9;
  cout << lrg.SigmayyInverse(G) << endl;
  VectorXd a(3);
  VectorXd b(3);
  a << 0, 0, 0;
  b << 1, 2, 3;
  VectorXd mu(3);
  mu << .5, 1.9, 2.8;
//  lrg.MVTruncT(a, b, I, mu, I, 3.0, 100, 50);
 cout << lrg.mvttgewke91(a, b, I, mu, I, 3.0, 100, 50) << endl;

  return 0;
}
