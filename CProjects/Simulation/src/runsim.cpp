#include "CreateSampleData.hpp"
#include "Dist.hpp"
#include "Importance.hpp"
#include "ark.hpp"
#include "ask.hpp"
#include "crb.hpp"
#include "crt.hpp"
#include <Eigen/Dense>
#include <ctime>
#include <fstream>
#include <iostream>
#include <limits>
#include <math.h>

using namespace std;
using namespace Eigen;

#define seed 100
#define mlSims 500
#define nSims 12000
#define burnin 2000
#define batches 50

void askTest() {
  VectorXd betas(3);
  betas << .98, 5.6, 3.2;

  CreateSampleData csd(1000, betas, seed);
  double a = 0.;
  double inf = numeric_limits<double>::max();

  VectorXd ll(4);
  VectorXd ul(4);
  ll << -inf, 0, -inf, -inf;
  ul << inf, 1, inf, inf;
  Ask ask;
  ask.runSim(mlSims, batches, ll, ul, csd.maxLikeEsts, csd.inverseFisher, csd.y,
             csd.X, nSims, burnin, 500);
}

void arkTest() {
  VectorXd betas(3);
  betas << .98, 5.6, 3.2;

  CreateSampleData csd(1000, betas, seed);
  double a = 0.;
  double inf = numeric_limits<double>::max();

  VectorXd ll(4);
  VectorXd ul(4);
  ll << -inf, 0, -inf, -inf;
  ul << inf, 1, inf, inf;

  Ark ark;
  ark.runSim(mlSims, batches, csd.maxLikeEsts, csd.inverseFisher, csd.y, csd.X,
             ll, ul, nSims, 5000);
}

void crbTest() {
  int dim = 3;
  double inf = numeric_limits<double>::max();

  Crb crb(dim);
  int testN = 1000;
  VectorXd betas(dim);
  betas << .98, 5.6, 3.2;
  VectorXd lowerLimit(dim + 1);
  VectorXd upperLimit(dim + 1);
  VectorXd zStar(dim + 1);
  VectorXd fzStar(dim + 1);
  lowerLimit << -inf, 0, -inf, -inf;
  upperLimit << inf, 1, inf, inf;
  CreateSampleData csd(testN, betas, seed);
  crb.runSim(csd.maxLikeEsts, csd.inverseFisher, csd.y, csd.X, lowerLimit,
             upperLimit, nSims, burnin, mlSims, batches);
}

void crtTest() {
  VectorXd betas(3);
  betas << .98, 5.6, 3.2;

  CreateSampleData csd(1000, betas, seed);
  double a = 0.;
  double inf = numeric_limits<double>::max();

  VectorXd ll(4);
  VectorXd ul(4);
  ll << -inf, 0, -inf, -inf;
  ul << inf, 1, inf, inf;
  CRT crt;

  crt.runSim(mlSims, batches, ll, ul, csd.maxLikeEsts, csd.inverseFisher, csd.y,
             csd.X, nSims, burnin);
}
void impTest() {
  double inf = numeric_limits<double>::max();

  VectorXd ll2(4);
  VectorXd ul2(4);
  VectorXd betas2(3);
  betas2 << .98, 5.6, 3.2;
  Importance imp;
  ll2 << -inf, 0, -inf, -inf;
  ul2 << inf, 1, inf, inf;
  VectorXd b02 = MatrixXd::Zero(3, 1);
  MatrixXd S02 = MatrixXd::Identity(3, 3);

  CreateSampleData csd2(1000, betas2, seed);
  imp.runSim(mlSims, batches, csd2.maxLikeEsts, csd2.inverseFisher, csd2.y,
             csd2.X, ll2, ul2, nSims, burnin, b02, S02, 3, 6);
}
int main() {

  cout << "\n\n\tBegan runsim\n" << endl;
 // askTest();
 // arkTest();
 // crbTest();
  crtTest();
  impTest();

  return 0;
}

