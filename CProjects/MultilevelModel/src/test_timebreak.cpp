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
  int T = 20;
  int K = 10;
  int sims = 10;
  int burnin = (int)(.1*sims);
  double mu = 0;
  double sig = 1;
  cout << "T " << T << " K " << K << " sims " << sims << " bn " << burnin << endl; 
  Matrix<int, Dynamic, 2> InfoMat(1, 2);
  InfoMat << 0, K - 1;
  RowVectorXd phi(1);
  phi << .25;
  GenerateFactorData mldata;
  double betaVal = 1;
  int nXs = 2;
  int tb = .5*T; 
  mldata.breakPointGenData(T, K, InfoMat, tb, 1.);
  FullConditionalsNoAr fc; 
  fc.easySetModel(mldata.yt, mldata.Xt, phi, InfoMat, 0, 1);
  fc.runTimeBreakModel(sims, burnin, tb, "tbmodel");
  fc.mlTimeBreak(tb);
  // string name; 
  // map<int, pair<double,double>> mls; 
  // vector<FullConditionalsNoAr> hold;
  // for (int j = 50; j < 51; ++j) {
  //   FullConditionalsNoAr fcar;

  //   MatrixXd Xtbeg = mldata.Xt.topRows(K * j);
  //   MatrixXd ytbeg = mldata.yt.leftCols(j);
  //   MatrixXd Xtend = mldata.Xt.bottomRows(K * j);
  //   MatrixXd ytend = mldata.yt.rightCols(j);
  //   name = "beg" + to_string(j);
  //   fcar.easySetModel(ytbeg, Xtbeg, phi, InfoMat, mu, sig);
  //   fcar.runModel(sims, burnin, name);
  //   double mlbeg = fcar.ml();
  //   name = "end" + to_string(j);
  //   hold.push_back(fcar); 
  //   FullConditionalsNoAr fcar2;
  //   fcar2.easySetModel(ytend, Xtend, phi, InfoMat, mu, sig);
  //   fcar2.runModel(sims, burnin, name);
  //   double mlend = fcar2.ml();
  //   mls[j] = make_pair(mlbeg, mlend); 
  //   hold.push_back(fcar2);
  // }
  // FullConditionalsNoAr fcar3;
  // fcar3.easySetModel(mldata.yt, mldata.Xt, phi, InfoMat, mu, sig);
  // name = "all";
  // fcar3.runModel(sims, burnin, name);
  // double mlall = fcar3.ml();
  // hold.push_back(fcar3); 
  // for(auto it = mls.begin(); it != mls.end(); ++it){
  //   cout << it->first << " " << it->second.first + it->second.second << endl; 
  // }
  // cout << mlall << endl; 

  // for(auto it = hold.begin(); it != hold.end(); ++it)
  // {
  //   cout << "beta " << it->ml_breakdown["beta"] << endl; 
  //   cout << "gamma " << it->ml_breakdown["gamma"] << endl;
  //   cout << "sigma " << it->ml_breakdown["sigma"] << endl; 
  //   cout << "factor " << it->ml_breakdown["factor"] << endl; 
  //   cout << "likelihood " << it->ml_breakdown["likelihood"] << endl; 
  //   cout << "posterior factor " <<it->ml_breakdown["posteriorFactorStar"] << endl; 
  //   cout << "posterior " <<it->ml_breakdown["posterior"] << endl; 
  //   cout << endl; 
  // }
  return 0;
}
