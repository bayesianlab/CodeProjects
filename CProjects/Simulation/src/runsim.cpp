#include "CreateSampleData.hpp"
#include "Dist.hpp"
#include "Importance.hpp"
#include "LinRegGibbs.hpp"
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
#define nSims 11000
#define burnin 1000
#define mlSims  500
#define batches 50
#define linRegSS 2500

void askTest2(VectorXd &betas, VectorXd &ll, VectorXd &ul) {
	int dim = betas.size();
  CreateSampleData csd(linRegSS, betas, seed);
  VectorXd b0 = MatrixXd::Zero(dim, 1);
  MatrixXd B0 = 1000*MatrixXd::Identity(dim, dim);
  double a0 = 3;
  double d0 = 5;
  Ask ask;
  ask.runSim(mlSims, batches, ll, ul, csd.maxLikeEsts, csd.inverseFisher, csd.y,
             csd.X, nSims, burnin, 500, b0, B0, a0, d0);
}

void askTestT(VectorXd &betas, VectorXd &ll, VectorXd &ul) {
  int dim = betas.size();
  CreateSampleData csd(linRegSS, betas, seed);
  Ask ask;
  double initPeta = .5;
  int sbr = 100;
  MatrixXd LinConst = MatrixXd::Identity(dim + 1, dim + 1);
  VectorXd b0 = MatrixXd::Zero(dim, 1);
  MatrixXd B0 = 1000*MatrixXd::Identity(dim, dim);
  double a0 = 3;
  double d0 = 5;
  double df = dim + 1;
  VectorXd weight(dim + 1);
  weight.fill(.5);
  ask.runTsim(mlSims, batches, ll, ul, LinConst, df, csd.maxLikeEsts,
              csd.inverseFisher, csd.y, csd.X, nSims, burnin, sbr, initPeta, b0,
              B0, a0, d0, weight);
}

void arkTest2(VectorXd &betas, VectorXd &ll, VectorXd &ul) {
  int dim = betas.size();
  CreateSampleData csd(linRegSS, betas, seed);
  VectorXd b0 = MatrixXd::Zero(dim, 1);
  MatrixXd B0 = 1000*MatrixXd::Identity(dim, dim);
  double a0 = 3;
  double d0 = 5;
  Ark ark;
  ark.runSim(mlSims, batches, csd.maxLikeEsts, csd.inverseFisher, csd.y, csd.X,
             ll, ul, nSims, 5000, b0, B0, a0, d0);
}

void arkTestT(VectorXd &betas, VectorXd &ll, VectorXd &ul) {
  CreateSampleData csd(linRegSS, betas, seed);
  int dim = betas.size();
  MatrixXd LC = MatrixXd::Identity(dim + 1, dim + 1);
  VectorXd b0 = MatrixXd::Zero(dim, 1);
  MatrixXd B0 = 1000*MatrixXd::Identity(dim, dim);
  double a0 = 3;
  double d0 = 5;
  double df = dim + 1;
  Ark ark;
  ark.runTsim(mlSims, batches, ll, ul, LC, df, csd.maxLikeEsts,
              csd.inverseFisher, csd.y, csd.X, nSims, 1000, b0, B0, a0, d0);
}

void crbTest2(VectorXd &betas, VectorXd &ll, VectorXd &ul) {
  int dim = betas.size();
  Crb crb;
  VectorXd zStar(dim + 1);
  VectorXd fzStar(dim + 1);
  VectorXd b0 = MatrixXd::Zero(dim, 1);
  MatrixXd B0 = 1000*MatrixXd::Identity(dim, dim);
  double a0 = 3;
  double d0 = 5;
  CreateSampleData csd(linRegSS, betas, seed);
  crb.runSim(csd.maxLikeEsts, csd.inverseFisher, csd.y, csd.X, ll, ul, nSims,
             burnin, mlSims, batches, b0, B0, a0, d0);
}

void crbTestT(VectorXd &betas, VectorXd &ll, VectorXd &ul) {
	Crb crb;
  int dim = betas.size();
  VectorXd b0 = MatrixXd::Zero(dim, 1);
  MatrixXd B0 = 1000*MatrixXd::Identity(dim, dim);
  double a0 = 3;
  double d0 = 5;
  CreateSampleData csd(linRegSS, betas, seed);
  crb.runTsim(csd.maxLikeEsts, csd.inverseFisher, dim, csd.y, csd.X, ll, ul,
              MatrixXd::Identity(dim + 1, dim + 1), b0, B0, a0, d0, nSims,
              burnin, mlSims, batches);
}

void crtTest2(VectorXd &betas, VectorXd &ll, VectorXd &ul) {
  CreateSampleData csd(linRegSS, betas, seed);
  int J = betas.size();
  VectorXd b0 = MatrixXd::Zero(J, 1);
  MatrixXd B0 = 1000*MatrixXd::Identity(J, J);
  double a0 = 3;
  double d0 = 5;
  Crt crt;
  crt.runSim(mlSims, batches, ll, ul, csd.maxLikeEsts, csd.inverseFisher, csd.y,
             csd.X, nSims, burnin, b0, B0, a0, d0);
}

void crtTestT(VectorXd &betas, VectorXd &ll, VectorXd &ul) {
  CreateSampleData csd(linRegSS, betas, seed);
  Crt crt;
  int J = betas.size();
  VectorXd b0 = MatrixXd::Zero(J, 1);
  MatrixXd B0 = 1000*MatrixXd::Identity(J, J);
  double a0 = 3;
  double d0 = 5;
  MatrixXd LinearConstraints = MatrixXd::Identity(J + 1, J + 1);
  crt.runTsim(mlSims, batches, ll, ul, LinearConstraints, J + 1,
              csd.maxLikeEsts, csd.inverseFisher, csd.y, csd.X, nSims, burnin,
              b0, B0, a0, d0);
}

void impTest2(VectorXd &betas, VectorXd &ll, VectorXd &ul) {
  Importance imp;
  int J = betas.size();
  VectorXd b02 = MatrixXd::Zero(J, 1);
  MatrixXd S02 = 1000*MatrixXd::Identity(J, J);
  CreateSampleData csd(linRegSS, betas, seed);
  imp.runSim(mlSims, batches, csd.maxLikeEsts, csd.inverseFisher, csd.y, csd.X,
             ll, ul, nSims, burnin, b02, S02, 3, 5);
}

void impTestT(VectorXd &betas, VectorXd &ll, VectorXd &ul) {
  Importance imp;
  int dim = betas.size();
  MatrixXd b0 = MatrixXd::Zero(dim, 1);
  MatrixXd B0 = 1000*MatrixXd::Identity(dim, dim);
  MatrixXd LinearConstraints = MatrixXd::Identity(dim + 1, dim + 1);
  CreateSampleData csd(linRegSS, betas, seed);
  imp.runTsim(mlSims, batches, csd.maxLikeEsts, csd.inverseFisher, csd.y, csd.X,
              ll, ul, LinearConstraints, dim + 1, nSims, b0, B0, 3, 5);
}

void modifiedGelfandDeyTest(VectorXd &betas, VectorXd &a, VectorXd &b) {
  int dim = betas.size();
  MatrixXd b0 = MatrixXd::Zero(dim, 1);
  MatrixXd B0 = 1000*MatrixXd::Identity(dim, dim);
  double a0 = 3;
  double d0 = 5;
  LinRegGibbs lrg;
  CreateSampleData csd(linRegSS, betas, seed);
  lrg.runSimModified(mlSims, batches, a, b, csd.maxLikeEsts, csd.inverseFisher,
                     csd.y, csd.X, b0, B0, a0, d0, nSims, burnin);
}

void modifiedGelfandDeyTestT(VectorXd &betas, VectorXd &a, VectorXd &b) {
  int dim = betas.size();
  MatrixXd b0 = MatrixXd::Zero(dim, 1);
  MatrixXd B0 = 1000*MatrixXd::Identity(dim, dim);
  double a0 = 3;
  double d0 = 5;
  LinRegGibbs lrg;
  CreateSampleData csd(linRegSS, betas, seed);
  MatrixXd LinearConstraints = MatrixXd::Identity(dim + 1, dim + 1);
  lrg.runTsimModified(mlSims, batches, a, b, LinearConstraints, dim + 1,
                      csd.maxLikeEsts, csd.inverseFisher, csd.y, csd.X, b0, B0,
                      a0, d0, nSims, burnin);
}

void runTests(VectorXd &betas, VectorXd &a, VectorXd &b) {
 /* cout << "Ask method:" << endl;
  askTest2(betas, a, b);
  cout << "Ark method:" << endl;
  arkTest2(betas, a, b);
  cout << "Crb method:" << endl;
  crbTest2(betas, a, b);
  cout << "Crt method:" << endl;
  crtTest2(betas, a, b);
  cout << "Importance Sampling:" << endl;
  impTest2(betas, a, b);*/
  cout << "Modified Gelfand Dey:" << endl;
  modifiedGelfandDeyTest(betas, a, b);
  cout << endl;
/*  cout << "Ask method T:" << endl;
  askTestT(betas, a, b);
  cout << "Ark method T:" << endl;
  arkTestT(betas, a, b);
  cout << "Crb method T:" << endl;
  crbTestT(betas, a, b);
  cout << "Crt method T:" << endl;
  crtTestT(betas, a, b);
  cout << "Importance Sampling T:" << endl;
  impTestT(betas, a, b);*/
  cout << "Modified Gelfand Dey T:" << endl;
  modifiedGelfandDeyTestT(betas, a, b); 
}

int main() {
  cout << "\n\n\tBegan runsim\n" << endl;
  if (linRegSS < 100) {
    cout << "\n\tSmall dataset test" << endl;
  } else if (linRegSS >= 100 & linRegSS < 1000) {
    cout << "\n\tMedium dataset test" << endl;
  } else {
    cout << "\n\tLarge dataset test" << endl;
  }
  double a = 0.;
  double inf = numeric_limits<double>::max();
  int dim = 4;
  VectorXd betas(dim);
  VectorXd betas1(dim);
  VectorXd rll(dim + 1);
  VectorXd rul(dim + 1);
  betas << .99, .99, .75, .85;
  rll << 0., 0, 0, -inf, -inf;
  rul << inf, 1, 1, inf, inf;
  cout << "\nseed " << seed << " mlSims " << mlSims << " nSims  " << nSims
       << " burnin " << burnin << " batch size " << batches
       << " linear regression sample size " << linRegSS << " " << batches
       << endl;
/*  cout << "\tTEST 1" << endl;
  cout << "\n\tTwo restriction test, beta1 .99, beta2 .99" << endl;
  cout << "\nBetas\n" << betas.transpose() << endl;
  runTests(betas, rll, rul);
  
  betas.resize(betas.size() + 2);
  rll.resize(rll.size() + 2);
  rul.resize(rul.size() + 2);
  betas << .99, .99, .99, .75, .85, -.55;
  rll << 0, 0, 0, 0, -inf, -inf, -inf;
  rul << inf, 1, 1, 1, inf, inf, inf;
  cout << endl;*/
  cout << "\tTEST 2" << endl;
  cout << "\nBetas\n" << betas.transpose() << endl;
  runTests(betas, rll, rul);
  
  betas.resize(betas.size() + 2);
  rll.resize(rll.size() + 2);
  rul.resize(rul.size() + 2);
  betas << .99, .99, .99, .99, .75, .85, -.55, .95;
  rll << 0, 0, 0, 0, 0, -inf, -inf, -inf, -inf;
  rul << inf, 1, 1, 1, 1, inf, inf, inf, inf;
  cout << endl;
  cout << "\tTEST 3" << endl;
  cout << "\nBetas\n" << betas.transpose() << endl;
  runTests(betas, rll, rul);
  return 0;
}

