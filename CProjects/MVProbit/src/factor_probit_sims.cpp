
#include "GenerateFactorData.hpp"
#include "Plotter.hpp"
#include "mvp.hpp"
#include <iostream>

using namespace std;
using namespace Eigen;
int main() {
  cout << " Test mvp" << endl;
  int T = 100;
  for (int i = 3; i < 8; ++i) {
    int K = (int)pow(2, i);
    GenerateFactorData gfp;
    Matrix<int, Dynamic, 2> InfoMat(2, 2);
    InfoMat << 0, K - 1, 0, K - 1;
    VectorXd phi = unifrnd(0, .5, InfoMat.rows());
    gfp.genProbitData(K, T, 1, 1, InfoMat);
    MatrixXd yt(K, T);
    for (int i = 0; i < T; ++i) {
      for (int j = 0; j < K; ++j) {
        if (gfp.yt(j, i) > 0) {
          yt(j, i) = 1;
        } else {
          yt(j, i) = 0;
        }
      }
    }
    MVP mv;
    VectorXd b = unifrnd(0, 1, K);
    string name = "factor_" + to_string(K); 
    mv.setModel(yt, gfp.Xt, b, phi, gfp.b0, 10*gfp.B0, InfoMat, name);
    mv.runFactorModel(3000, 300);
    string fn = "true_"+to_string(K);
    vector<MatrixXd> tf;
    tf.push_back(gfp.Factors); 
    mv.storePosterior(fn, tf);
  }
}