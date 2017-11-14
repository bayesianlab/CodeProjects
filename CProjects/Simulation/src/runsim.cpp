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
#define mlSims 500
#define nSims 12000
#define burnin 2000
#define batches 50
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
             csd.X, ll, ul, nSims, burnin, b02, S02, 3, 6);
}

void gelfandDey(VectorXd &betas, VectorXd &ll, VectorXd &ul){
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
  
  VectorXd rll(dim + 1);
  VectorXd rul(dim + 1);
  VectorXd urll(dim + 1);
  VectorXd urul(dim + 1);
  
  //two restrictions
  cout << "\n\tTwo restriction test, beta1 .99, beta2 .99" << endl;
  betas << .99, .99, 5.6, 3.2;
  rll << 0., 0., 0., -inf, -inf;
  rul << inf, 1., 1., inf, inf;
  urll << 0, -inf, -inf, -inf, -inf;
  urul << inf, inf, inf, inf, inf;


  // One restriction
  /*
   cout << \n\t One restriction test small dataset << endl; 
   betas <<  1.2, 5.6, 3.2;
   rll << 0., 0., -inf, -inf;
   rul << inf, 1., inf, inf;
   urll << 0.,  -inf, -inf, -inf;
   urul << inf, inf, inf, inf; 
   */

   
  askTest2(betas, rll, rul);
  askTest2(betas, urll, urul);

  arkTest2(betas, rll, rul);
  arkTest2(betas, urll, urul);

  crbTest2(betas, rll, rul);
  crbTest2(betas, urll, urul);

  crtTest2(betas, rll, rul);
  crtTest2(betas, urll, urul);

  impTest2(betas, rll, rul);
  impTest2(betas, urll, urul);
  

  return 0;
}

