#include "Dist.hpp"
#include <Eigen/Dense>
#include <ctime>
#include <fstream>
#include <iostream>
#include <limits>
#include <math.h>

using namespace std;
using namespace Eigen;

int main() {
  Dist d;
  d.mvtrnd();
  VectorXd a(3);
  VectorXd b(3);
  a << 0,0,0;
  b << 10, 10, 10;
  VectorXd mu(3);
  mu << 0., .5, 1.;
  MatrixXd sigma(3, 3);
  sigma << 1, -.7, .49, -.7, 1, -.7, .49, -.7, 1;
  MatrixXd D = MatrixXd::Identity(3,3);
  cout << d.geweke91(a, b, D, mu, sigma, 1000, 500).colwise().mean() << endl;
  cout << d.tmultnorm(a,b,mu,sigma,1000).bottomRows(500).colwise().mean() << endl;
  cout << endl;
}
