#include "CreateSampleData.hpp"
#include "Dist.hpp"
#include "Importance.hpp"
#include "ark.hpp"
#include "ask.hpp"
#include "crb.hpp"
#include "crt.hpp"
#include "LinRegGibbs.hpp"
#include <Eigen/Dense>
#include <ctime>
#include <fstream>
#include <iostream>
#include <limits>
#include <math.h>

using namespace std;
using namespace Eigen;

#define seed 100
#define mlSims 5
#define nSims 120
#define burnin 20
#define batches 5
#define linRegSS 5000


void askTest2(VectorXd &betas, VectorXd &ll, VectorXd &ul) {
  CreateSampleData csd(linRegSS, betas, seed);
  Ask ask;
  ask.runSim(mlSims, batches, ll, ul, csd.maxLikeEsts, csd.inverseFisher, csd.y,
             csd.X, nSims, burnin, 500);
}

void arkTest2(VectorXd &betas, VectorXd &ll, VectorXd &ul) {
  CreateSampleData csd(linRegSS, betas, seed);
  Ark ark;
  ark.runSim(mlSims, batches, csd.maxLikeEsts, csd.inverseFisher, csd.y, csd.X,
             ll, ul, nSims, 5000);
}

void crbTest2(VectorXd &betas, VectorXd &ll, VectorXd &ul) {
  int dim = betas.size();
  Crb crb(dim);
  VectorXd zStar(dim + 1);
  VectorXd fzStar(dim + 1);
  CreateSampleData csd(linRegSS, betas, seed);
  crb.runSim(csd.maxLikeEsts, csd.inverseFisher, csd.y, csd.X, ll, ul, nSims,
             burnin, mlSims, batches);
}

void crbTestT(VectorXd &betas, VectorXd &ll, VectorXd &ul){
  int dim = betas.size();
  Crb crb(dim);
  VectorXd b0 = MatrixXd::Zero(dim, 1);
  MatrixXd B0 = MatrixXd::Identity(dim,dim);
  double a0 = 6;
  double d0 = 12;
  CreateSampleData csd(linRegSS, betas, seed);
  crb.runTsim(csd.maxLikeEsts, csd.inverseFisher, dim, csd.y, csd.X, ll, ul,
              MatrixXd::Identity(dim + 1, dim + 1), b0, B0, a0, d0, nSims,
              burnin, mlSims, batches);
}

void crtTest2(VectorXd &betas, VectorXd &ll, VectorXd &ul) {
  CreateSampleData csd(linRegSS, betas, seed);
  CRT crt;
  crt.runSim(mlSims, batches, ll, ul, csd.maxLikeEsts, csd.inverseFisher, csd.y,
             csd.X, nSims, burnin);
}

void impTest2(VectorXd &betas, VectorXd &ll, VectorXd &ul) {
  Importance imp;
  int J = betas.size();
  VectorXd b02 = MatrixXd::Zero(J, 1);
  MatrixXd S02 = MatrixXd::Identity(J, J);
  CreateSampleData csd(linRegSS, betas, seed);
  imp.runSim(mlSims, batches, csd.maxLikeEsts, csd.inverseFisher, csd.y,
             csd.X, ll, ul, nSims, burnin, b02, S02, 6, 12);
}

void impTestT(VectorXd &betas, VectorXd &ll, VectorXd &ul){
  Importance imp; 
  int dim = betas.size();
  MatrixXd b0 = MatrixXd::Zero(dim, 1);
  MatrixXd B0 = MatrixXd::Identity(dim,dim);
  MatrixXd LinearConstraints = MatrixXd::Identity(dim+1, dim+1);
  CreateSampleData csd(linRegSS, betas, seed);
  imp.runTsim(mlSims, batches, csd.maxLikeEsts, csd.inverseFisher, csd.y, csd.X,
              ll, ul, LinearConstraints, dim+1, nSims, burnin, b0, B0, 6, 12);
}

void gelfandDey(VectorXd &betas, VectorXd &ll, VectorXd &ul){
  int dim = betas.size();
  MatrixXd b0 = MatrixXd::Zero(dim, 1);
  MatrixXd B0 = MatrixXd::Identity(dim,dim);
  double a0 = 6;
  double d0 = 12;
  LinRegGibbs lrg;
  CreateSampleData csd(linRegSS, betas, seed);
  lrg.runSim(mlSims, batches, ll, ul, csd.maxLikeEsts, csd.inverseFisher, csd.y,
             csd.X, b0, B0, a0, d0, nSims, burnin);
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
  
  //two restrictions
  cout << "\n\tTwo restriction test, beta1 .99, beta2 .99" << endl;
  betas << .99, .99, .75, .85;
  rll << 0., 0., 0., -inf, -inf;
  rul << inf, 1., 1., inf, inf;


   
/*  askTest2(betas, rll, rul);

  arkTest2(betas, rll, rul);*/

  crbTest2(betas, rll, rul);

  /*crtTest2(betas, rll, rul);

  impTest2(betas, rll, rul); */
  impTestT(betas, rll, rul);
  crbTestT(betas, rll, rul);
  
  

  return 0;
}

