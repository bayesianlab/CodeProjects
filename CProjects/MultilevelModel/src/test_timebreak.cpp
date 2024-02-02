#include <Eigen/Dense>
#include <ctime>
#include <iostream>

#include "EigenTools.hpp"
#include "FullConditionalsNoAr.hpp"
#include "GenerateFactorData.hpp"
#include "IntegratedLikelihood.hpp"
#include "MultilevelModelFunctions.hpp"
#include "Plotter.hpp"

using namespace std;
using namespace Eigen;
int main() {
  int i = 10;
  int T = 100;
  int K = 20;
  int sims = 10;
  int burnin = 2;
  Matrix<int, Dynamic, 2> InfoMat(2, 2);
  InfoMat << 0, K - 1, 0, 10;
  RowVectorXd phi(1);
  phi << .25;

  GenerateFactorData mldata;
  double betaVal = 1;
  int nXs = 2;
  mldata.breakPointGenData(T, K, InfoMat, 50, 1.);
  MatrixXd Xt = mldata.Xt;
  MatrixXd yt = mldata.yt;
  FullConditionalsNoAr fcar;
  fcar.easySetModel(yt, Xt, phi, InfoMat);
  fcar.runModel(sims,burnin);
  fcar.ml();

  MatrixXd ytbeg = yt.leftCols(50);
  MatrixXd ytend = yt.rightCols(50);
  cout << ytbeg << endl; 
  cout << endl; 
  cout << ytend << endl; 

  return 0;
}
