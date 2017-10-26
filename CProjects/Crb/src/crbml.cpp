#include "Crb.hpp"
#include "CreateSampleData.hpp"
#include "Dist.hpp"
#include <Eigen/Dense>
#include <ctime>
#include <fstream>
#include <iostream>
#include <limits>
#include <math.h>

using namespace std;
using namespace Eigen;

#define inf  numeric_limits<double>::max()
#define a 0

void probTest(){
  Crb crb(3);
  VectorXd crbmu(3);
  crbmu << 0, .5, 1.;
  MatrixXd crbsigma(3, 3);

  crbmu << 0, .5, 1.;
  crbsigma << 1, -.7, .49, -.7, 1, -.7, .49, -.7, 1;
  VectorXd ll(3);
  VectorXd ul(3);
  ll.fill(a);
  ul.fill(inf);
  clock_t begin = clock();

  crb.chibRao(ll, ul, crbmu, crbsigma, 11000, 1000, 11000, 1000);
  clock_t end = clock();
  cout << "Time to execute ->" << double(end - begin) / CLOCKS_PER_SEC << endl;
  cout << " Simulated Prob. " << endl;
  double prob = log(crb.mvnpdf(crbmu, crbsigma, crb.zStar) / crb.fzStar.prod());
  cout << prob << endl;
  if (abs(prob + 1.55) > .02) {
    cout << "PROB TEST FAILED" << endl;
  } else {
    cout << "PROB TEST PASSED" << endl;
  }
  cout << "\n\t\tTESTS COMPLETE" << endl;
}

void oneRestrictionTest() {
  int dim = 3;
  VectorXd betas(dim);
  betas << .98, 5.6, 3.2;
  VectorXd lowerLimit(dim + 1);
  VectorXd upperLimit(dim + 1);
  VectorXd zStar(dim + 1);
  VectorXd fzStar(dim + 1);
  lowerLimit << -inf, 0, -inf, -inf;
  upperLimit << inf, 1, inf, inf;
  CreateSampleData csd(testN, betas, 1);
  cout << csd.maxLikeEsts << endl;
  crb.chibRao(lowerLimit, upperLimit, csd.maxLikeEsts, csd.inverseFisher, 1000,
              500, 1000, 500);
  cout << crb.ml(crb.betas, crb.zStar(0), csd.y, csd.X) << endl;
}

int main() {
  int testN = 1000;
  probTest();
  oneRestrictionTest();

  return 0;
}


