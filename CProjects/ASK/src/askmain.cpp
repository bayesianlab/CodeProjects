#include "CreateSampleData.hpp"
#include "Dist.hpp"
#include "ask.hpp"
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

  VectorXd ll(3);
  VectorXd ul(3);
  ll.fill(a);
  ul.fill(inf);

  MatrixXd sample(11000, 6);
  MatrixXd gsamp(11000, 3);
  VectorXd sv(3);

  Ask ask(ll, ul, mu, sig, 11000, 1000, 1000);
  ask.tmvnrand(ll, ul, mu, sig, sample, sv);
  ask.ghkLinearConstraints(ll, ul, mu, sig, gsamp);
  MatrixXd g1991(2, 3);
  // Shows that output of adaptive is similar to average of two methods.
  cout << "Geweke 1991" << endl;
  g1991 << sample.colwise().mean().head(3), gsamp.colwise().mean();
  cout << sample.colwise().mean() << endl;
  cout << "GHK" << endl;
  cout << gsamp.colwise().mean() << endl;
  cout << "Average of two" << endl;
  cout << g1991.colwise().mean() << endl;

  cout << ask.autoCorr(mu) << endl;

  double num = ask.mvnpdf(mu, sig, ask.zStar);
  cout << num << endl;
  double den = ask.Kernel.rowwise().prod().mean();
  cout << num / den << endl;
  cout << den << endl;
  double ans = log(num / den);
  double testval = abs(ans - (-1.55));
  if (testval < .01) {
    cout << "ASK Test PASSED" << endl;
    cout << ans << " " << testval << " " << endl;
  } else {
    cout << "ASK Test FAILED" << endl;
    cout << ans << " " << testval << " " << endl;
  }
}
