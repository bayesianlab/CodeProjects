#include "CreateSampleData.hpp"
#include "Dist.hpp"
#include "Importance.hpp"
#include <Eigen/Dense>
#include <ctime>
#include <fstream>
#include <iostream>
#include <limits>
#include <math.h>

using namespace std;
using namespace Eigen;

int main() {
  double a = 0.;
  double inf = numeric_limits<double>::max();

  VectorXd ll(5);
  VectorXd ul(5);
  ll.fill(a);
  ul.fill(inf);
  VectorXd betas(4);
  betas << .55, .75, .85, .95;
  VectorXd b0 = MatrixXd::Zero(4, 1);
  MatrixXd S0 = MatrixXd::Identity(4, 4);

  CreateSampleData csd(1000, betas, 0);

  Importance imp;
  imp.runSim(20, 3, csd.maxLikeEsts, csd.inverseFisher, csd.y, csd.X, ll, ul,
             1000, 100, b0, S0, 3, 6);


  VectorXd ll2(4);
  VectorXd ul2(4);
  VectorXd betas2(3);
  betas2 << .98, 5.6, 3.2;

  ll2 << -inf, 0, -inf, -inf;
  ul2 << inf, 1, inf, inf;
  VectorXd b02 = MatrixXd::Zero(3, 1);
  MatrixXd S02= MatrixXd::Identity(3, 3);


  CreateSampleData csd2(1000, betas2, 0);
  cout << csd2.y.head(5) << endl; 
	imp.runSim(20, 3, csd2.maxLikeEsts, csd2.inverseFisher, csd2.y, csd2.X, ll2,ul2, 1000,100, b02, S02, 3,6);
}

