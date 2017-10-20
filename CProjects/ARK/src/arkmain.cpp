#include "CreateSampleData.hpp"
#include "Dist.hpp"
#include "ark.hpp"
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

  VectorXd mu(3);
  MatrixXd sig(3, 3);
  mu << 0., .5, 1.;
  sig << 1, -.7, .49, -.7, 1, -.7, .49, -.7, 1;

  VectorXd m(3);
  MatrixXd s;
  s = MatrixXd::Identity(3, 3);
  VectorXd ll(3);
  VectorXd ul(3);
  ll.fill(a);
  ul.fill(inf);

  Ark ark(ll, ul, mu, sig, 10000);
  ark.displayMLike();
}
