#include <Eigen/Dense>
#include <iostream>

#include "EigenTools.hpp"
#include "FullConditionals.hpp"
#include "GenerateFactorData.hpp"
#include "IntegratedLikelihood.hpp"
#include "MultilevelModelFunctions.hpp"
#include "Plotter.hpp"

using namespace Eigen;
using namespace std;

int main(int argc, char *argv[]) {
  string ytpath = argv[1];
  string xtpath = argv[2];
  string indexpath = argv[3];
  string gammapath = argv[4];
  int sims = atoi(argv[5]);
  int bn = atoi(argv[6]);

  // string ytpath = "yt.csv";
  // string xtpath = "Xt.csv";
  // string indexpath = "wrc_index.csv";
  // string gammapath = "gammas_onedim.csv";
  // int sims = 5;
  // int bn = 1; 

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

  Matrix<int, Dynamic, 2> InfoMat = castToInfoMat(I);
  int K = yt.rows();
  int T = yt.cols();
  int nFactors = InfoMat.rows();
  FullConditionalsNoAr fcond;
  fcond.easySetModel(yt, Xt, gammas, InfoMat);
  fcond.runModel(sims, bn);
  // plotter("plot2.p", yt.row(0).transpose(),
  //         fcond.fittedModel.row(0).transpose(), "real", "fitted");
  // MatrixXd factorbar = mean(fcond.FactorPosteriorDraws);
  // plotter("plot2.p", factorbar.row(0).transpose());

  std::ofstream file(fcond.fname, ios_base::app);
  if (file.is_open()) {
    file << "Paths" << endl;
    file << ytpath << endl;
    file << xtpath << endl;
    file.close();
  } else {
    cout << "DID NOT WRITE" << endl;
  }
  fcond.ml();
  fcond.summary();
}