#include <Eigen/Dense>
#include <ctime>
#include <iostream>

#include "EigenTools.hpp"
#include "FullConditionals.hpp"
#include "GenerateFactorData.hpp"
#include "IntegratedLikelihood.hpp"
#include "MultilevelModelFunctions.hpp"
#include "Plotter.hpp"

using namespace std;
using namespace Eigen;
int main() {
  int T = 100;
  int K = 20;
  int sims = 10;
  int burnin = 2;
  Matrix<int, Dynamic, 2> InfoMat(2, 2);
  InfoMat << 0, K - 1, 0,10;
  RowVectorXd phi(2);
  phi << .25, .05;
  RowVectorXd del(2);
  del << .25, .05;
  GenerateFactorData mldata;
  double betaVal = 1;
  int nXs = 2; 
  mldata.genDataArErrors(T, K, nXs, betaVal, InfoMat, phi, del, 1);
  MatrixXd Xt = mldata.Xt;

  FullConditionals mlotrok(mldata.yt, mldata.Xt, 2, 2, InfoMat);
  mlotrok.runModel(sims, burnin);

  MatrixXd Factorbar = mean(mlotrok.FactorPosteriorDraws);
  plotter("plot.p", Factorbar.row(0).transpose(),
          mldata.Factors.row(0).transpose(), "fest", "ftrue");
  mlotrok.ml();
  mlotrok.summary();
}
