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
  // int burnin = (int)(.1 * sims);
  // double mu = atof(argv[4]);
  // double sig = atof(argv[5]);
  int T = 100;
  // int K = 10;
  int sims = 1000;
  int burnin = (int)(.1 * sims);
  double mu = 0;
  double sig = 1;
  vector<int> Ks = {10, 50, 100};
  for (int i  =0; i < Ks.size(); ++i) {
    int K = Ks[i]; 
    cout << "T " << T << " K " << K << " sims " << sims << " bn " << burnin
         << endl;
    Matrix<int, Dynamic, 2> InfoMat(1, 2);
    InfoMat << 0, K - 1;
    RowVectorXd phi(1);
    phi << .25;
    GenerateFactorData mldata;
    double betaVal = 1;
    int true_time_break = (int)(.5 * T);
    mldata.breakPointGenData(T, K, 1, InfoMat, true_time_break, 1.);
    FullConditionalsNoAr fcfull;
    fcfull.easySetModel(mldata.yt, mldata.Xt, phi, InfoMat, mu, sig);
    fcfull.runModel(sims, burnin, "fullmodel");
    fcfull.ml();
    int downshift = true_time_break - (int)(.1*T); 
    int upshift = true_time_break + (int)(.1*T);
    for (int tb = downshift; tb <= upshift; ++tb) {
      MatrixXd yt1 = mldata.yt.block(0, 0, K, tb);
      MatrixXd yt2 = mldata.yt.block(0, tb, K, T - tb);
      MatrixXd Xt1 = mldata.Xt.block(0,0, K*tb, mldata.Xt.cols());
      MatrixXd Xt2 = mldata.Xt.block(K*tb, 0, K*(T-tb), mldata.Xt.cols());
      FullConditionalsNoAr fc1;
      fc1.easySetModel(yt1, Xt1, phi, InfoMat, 0, 1);
      string name1 = "end_"+ to_string(K) + "_" + to_string(tb) ;
      string name2 = "beg_"+  to_string(K) + "_" + to_string(tb+1);
      fc1.runModel(sims, burnin, name1);
      fc1.ml();
      FullConditionalsNoAr fc2;
      fc2.easySetModel(yt2, Xt2, phi, InfoMat, 0, 1);
      fc2.runModel(sims, burnin, name2);
      fc2.ml();
      // cout << fcfull.marginal_likelihood << endl;
      cout << fc1.marginal_likelihood + fc2.marginal_likelihood << endl;
    }
  }

  // writeToCSVfile("mllogfiles/marginal_likelihoods.csv",
  // marginal_likelihoods);

  return 0;
}
