#include <Eigen/Dense>
#include <ctime>
#include <iostream>

#include "EigenTools.hpp"
#include "FullConditionals.hpp"
#include "GenerateMLFactorData.hpp"
#include "IntegratedLikelihood.hpp"
#include "MultilevelModelFunctions.hpp"
#include "Plotter.hpp"

using namespace std;
using namespace Eigen;

int main() { /* Run the standard otrok whiteman model, 1 factor*/
  int T = 50;
  int K = 10;
  int sims = 300;
  int burnin = 100;
  VectorXd betas = .5 * VectorXd::Ones(1, 1);
  int nXs = betas.size();
  Matrix<int, Dynamic, 2> InfoMat(1, 2);
  InfoMat << 0, K-1;

  int nFactors = InfoMat.rows();
  MatrixXd Identity = MakeObsModelIdentity(InfoMat, K);
  MatrixXd A = .5 * Identity;
  VectorXd factorVariances = VectorXd::Ones(nFactors, 1);
  RowVectorXd phi(1);
  phi << .25;
  GenerateMLFactorData mldata;
  mldata.genData(T, K, betas, InfoMat, phi, A, 1);
  FullConditionals mlotrok;
  double r0 = 6;
  double R0 = 10;
  double d0 = 6; 
  double D0 = 5*d0;

  int id = 1;
  RowVectorXd g0;
  MatrixXd G0;
  g0.setZero(phi.cols());
  G0 = MatrixXd::Identity(phi.cols(), phi.cols());
  MatrixXd Xt = mldata.Xt;
  int levels = calcLevels(InfoMat, K);
  RowVectorXd otrokb0 = RowVectorXd::Zero(nXs + levels);
  MatrixXd otrokB0 = MatrixXd::Identity(nXs + levels, nXs + levels);
  mlotrok.setModel(mldata.yt, Xt, mldata.Factors, mldata.gammas, InfoMat,
                   otrokb0, otrokB0, r0, R0, d0, D0, g0, G0, id);

  mlotrok.runModel(sims, burnin);
  mlotrok.ml();

  MatrixXd Factorbar = mean(mlotrok.FactorPosteriorDraws);
  plotter("plot.p", Factorbar.row(0).transpose(),
          mldata.Factors.row(0).transpose(), "fest", "ftrue");
  mlotrok.summary();
  // plotter("plot.p", Factorbar.row(1).transpose(),
  //         mldata.Factors.row(1).transpose(), "fest", "ftrue");
}
