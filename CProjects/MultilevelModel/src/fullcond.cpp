#include "EigenTools.hpp"
#include "FullConditionals.hpp"
#include "GenerateFactorData.hpp"
#include "IntegratedLikelihood.hpp"
#include "MultilevelModelFunctions.hpp"
#include "Plotter.hpp"
#include <Eigen/Dense>
#include <ctime>
#include <iostream>

using namespace Eigen;
using namespace std;
int main(int argc, char *argv[]) {
//   string ytpath = argv[1];
//   string xtpath = argv[2];
//   string indexpath = argv[3];
//   string gammapath = argv[4];
//   string deltapath = argv[5];

  string ytpath = "kowz.csv";
  string xtpath = "kowXtz.csv";
  string indexpath = "factor_index_world_region_country.csv";
  string gammapath = "gammas.csv";
  string deltapath = "deltas.csv";

  cout << ytpath << endl;
  cout << xtpath << endl;
  char h[256];
  getcwd(h, 256);
  string x = h;
  size_t t = x.find("build");
  string path = x.substr(0, t);
  MatrixXd yt = readCSV(ytpath);
  MatrixXd Xt = readCSV(xtpath);
  MatrixXd I = readCSV(indexpath);
  MatrixXd gammas = readCSV(gammapath);
  MatrixXd deltas = readCSV(gammapath);

  Matrix<int, Dynamic, 2> InfoMat = castToInfoMat(I);
  int K = yt.rows();
  int T = yt.cols();
  int nFactors = InfoMat.rows();
  FullConditionals fcond;
  fcond.easySetModel(yt, Xt, gammas, deltas, InfoMat);
  fcond.runModel(10,2);
  fcond.ml(); 
  fcond.summary(); 
}