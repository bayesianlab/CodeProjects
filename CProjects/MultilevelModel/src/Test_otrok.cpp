#include "EigenTools.hpp"
#include "FullConditionals.hpp"
#include "GenerateMLFactorData.hpp"
#include "IntegratedLikelihood.hpp"
#include "MultilevelModelFunctions.hpp"
#include "Plotter.hpp"
#include <Eigen/Dense>
#include <ctime>
#include <iostream>

using namespace std;
using namespace Eigen;
int main(int argc, char* argv[])
{
  char h[256];
  char *s;
  s = getcwd(h, 256);
  string x = h;
  // size_t t = x.find("build");
  // string path = x.substr(0, t);
  x = s; 
  string ytpath = x + "/kowz.csv";
  string xtpath = x + "/kowXtz.csv";
  string indexpath = x + "/factor_index_world_region_country.csv";
  MatrixXd yt = readCSV(ytpath);
  MatrixXd xvals = readCSV(xtpath);
  MatrixXd I = readCSV(indexpath);
  Matrix<int, Dynamic, 2> InfoMat = castToInfoMat(I);
  int K = yt.rows();
  int T = yt.cols();
  int sims = 1000;
  int burnin = 100;
  int nFactors = InfoMat.rows();

  MatrixXd Xt(K * T, 1);
  Xt << VectorXd::Ones(K * T);
  int nXs = Xt.cols();
  MatrixXd Factors = normrnd(0, 1, nFactors, T);
  int gammaRows = 3;
  RowVectorXd g(3);
  g << .01, .02, .03;
  MatrixXd gammas = g.replicate(nFactors, 1);
  MatrixXd deltas;
  deltas = g.replicate(K, 1);
  RowVectorXd g0 = RowVectorXd::Zero(gammaRows);
  VectorXd G0diag(gammaRows);
  G0diag << .25, .5, 1;
  MatrixXd G0 = G0diag.asDiagonal();
  int levels = calcLevels(InfoMat, K);
  RowVectorXd otrokb0 = RowVectorXd::Zero(Xt.cols() + levels);
  MatrixXd otrokB0 = MatrixXd::Identity(Xt.cols() + levels, Xt.cols() + levels);
  otrokB0.block(0, 0, nXs, nXs) = 10 * MatrixXd::Identity(nXs, nXs);

  double r0 = 6;
  double R0 = 4;
  FullConditionals mlotrok;
  int id = 2;
  mlotrok.setModel(yt, Xt, Factors, gammas, deltas, InfoMat, otrokb0, otrokB0,
                   r0, R0, r0, R0, g0, G0, g0, G0, id);
  mlotrok.runModel(sims, burnin);
  mlotrok.ml();
  std::ofstream file(mlotrok.fname, ios_base::app | ios_base::out);
  if (file.is_open())
  {
    file << ytpath << endl;
    file << xtpath << endl;
    file << argv[0] << endl; 
    file.close();
  }
}
