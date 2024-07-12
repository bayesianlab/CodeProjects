#include <Eigen/Dense>
#include <ctime>
#include <iostream>

#include "Distributions.hpp"
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
  int sims = 10000;
  int burnin = (int)(.1 * sims);
  double mu = 0;
  double sig = 1;
  vector<int> Ks = {50};
  // StandardScaler ss;

  for (int i = 0; i < Ks.size(); ++i) {
    int K = Ks[i];
    cout << "T " << T << " K " << K << " sims " << sims << " bn " << burnin
         << endl;
    Matrix<int, Dynamic, 2> InfoMat(1, 2);
    InfoMat << 0, K - 1;
    RowVectorXd phi(1);
    phi << .25;
    GenerateFactorData mldata;
    double loadingVal = 1;
    int true_time_break = (int)(.5 * T);
    mldata.breakPointGenData(T, K, 0, InfoMat, true_time_break, loadingVal);
    // StandardScaler ssy;
    // ssy.fit(mldata.yt);
    // MatrixXd yt = ssy.transform(mldata.yt);
    MatrixXd blankX;
    FullConditionalsNoAr fcfull;
    fcfull.easySetModel(mldata.yt, blankX, phi, InfoMat, mu, sig);
    fcfull.runModel(sims, burnin, "fullmodel_" + to_string(K));
    fcfull.ml();
    int downshift = true_time_break - (int)(.1 * T);
    int upshift = true_time_break + (int)(.1 * T);
    for (int tb = downshift; tb <= upshift; tb += 10) {
      // string name = "break_" + to_string(K) + "_" + to_string(tb);
      // FullConditionalsNoAr fcbreak;
      // fcbreak.easySetModel(mldata.yt, mldata.Xt, phi, InfoMat, mu, sig);
      // fcbreak.runTimeBreakModel(sims, burnin, tb, name);
      // fcbreak.mlTimeBreak();
      
      MatrixXd yt1 = mldata.yt.block(0, 0, K, tb);
      // StandardScaler ssy1; 
      // ssy1.fit(yt1);
      // yt1 = ssy1.transform(yt1); 
      MatrixXd yt2 = mldata.yt.block(0, tb, K, T - tb);
      // StandardScaler ssy2; 
      // ssy2.fit(yt2);
      // yt2 = ssy2.transform(yt2);
      MatrixXd Xt1;
      MatrixXd Xt2;
      FullConditionalsNoAr fc1;
      fc1.easySetModel(yt1, Xt1, phi, InfoMat, mu, sig);
      string name1 = "end_" + to_string(K) + "_" + to_string(tb);
      string name2 = "beg_" + to_string(K) + "_" + to_string(tb + 1);
      fc1.runModel(sims, burnin, name1);
      fc1.ml();
      FullConditionalsNoAr fc2;
      fc2.easySetModel(yt2, Xt2, phi, InfoMat, mu, sig);
      fc2.runModel(sims, burnin, name2);
      fc2.ml();
      cout << fcfull.marginal_likelihood << endl;
      cout << fc1.marginal_likelihood + fc2.marginal_likelihood << endl;
      // cout << fcbreak.marginal_likelihood << endl;
    }
  }

  // writeCsv("mllogfiles/marginal_likelihoods.csv",
  // marginal_likelihoods);

  return 0;
}
