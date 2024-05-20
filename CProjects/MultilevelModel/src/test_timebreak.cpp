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
int main(int argc, char* argv[]) {
  // int T = atoi(argv[1]);
  // int K = atoi(argv[2]);
  // int sims = atoi(argv[3]);
  // int burnin = (int)(.1*sims);
  // double mu = atof(argv[4]);
  // double sig = atof(argv[5]);
  int T = 100;
  int K = 50;
  int sims = 500;
  int burnin = (int)(.1 * sims);
  double mu = 0;
  double sig = 1;
  cout << "T " << T << " K " << K << " sims " << sims << " bn " << burnin
       << endl;
  Matrix<int, Dynamic, 2> InfoMat(1, 2);
  InfoMat << 0, K - 1;
  RowVectorXd phi(1);
  phi << .25;
  GenerateFactorData mldata;
  double betaVal = 1;
  int nXs = 2;
  int tb = (int)(.5 * T);
  cout << tb << endl; 
  mldata.breakPointGenData(T, K, InfoMat, tb, 1.);
  FullConditionalsNoAr fcfull;
  fcfull.easySetModel(mldata.yt, mldata.Xt, phi, InfoMat, mu, sig);
  fcfull.runModel(sims, burnin, "fullmodel");
  fcfull.ml();
  int begin_sim = 15; 
  int end_sim = 16;
  VectorXd marginal_likelihoods(end_sim-begin_sim);
  FullConditionalsNoAr fc1;
  fc1.easySetModel(mldata.yt, mldata.Xt, phi, InfoMat, mu, sig);
  fc1.runTimeBreakModel(sims, burnin, tb+25, "break");
  fc1.mlTimeBreak();

  FullConditionalsNoAr fc2;
  fc2.easySetModel(mldata.yt, mldata.Xt, phi, InfoMat, mu, sig);
  fc2.runTimeBreakModel(sims, burnin, tb, "perfect");
  fc2.mlTimeBreak();
  // MatrixXd yt1 = mldata.yt.block(0,0,K, tb);
  // MatrixXd yt2 = mldata.yt.block(0,tb-1, K, tb);
  // MatrixXd Xt1 = mldata.Xt.block(0,0, K*tb, nXs);
  // MatrixXd Xt2 = mldata.Xt.block(K*(tb-1), 0, K*tb, nXs); 
  // fc1.easySetModel(yt1, Xt1, phi, InfoMat, 0, 1);
  // fc1.runModel(sims, burnin, "break1");
  // fc1.ml();
  // FullConditionalsNoAr fc2;
  // fc2.easySetModel(yt2, Xt2, phi, InfoMat, 0, 1);
  // fc2.runModel(sims, burnin, "break2");
  // fc2.ml(); 
  // for (int t = begin_sim; t < end_sim; ++t) {
    
  //   fc.easySetModel(mldata.yt, mldata.Xt, phi, InfoMat, 0, 1);
  //   fc.runTimeBreakModel(sims, burnin, tb, "tbmodel");
  //   fc.mlTimeBreak(tb);
  //   marginal_likelihoods(t-begin_sim) = fc.marginal_likelihood; 
  // }
  // writeToCSVfile("mllogfiles/marginal_likelihoods.csv", marginal_likelihoods);

  return 0;
}
