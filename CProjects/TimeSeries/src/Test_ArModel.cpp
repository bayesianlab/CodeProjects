#include <stdio.h>

#include <Eigen/Dense>

#include "ARMA.hpp"
#include "MA.hpp"
#include "GenerateAutoRegressiveData.hpp"
#include "MultilevelModelFunctions.hpp"

using namespace std;
using namespace Eigen;

int main() {
  int ar = 1;
  if (ar == 1) {
    int T = 200;
    MatrixXd params(1, 3);
    params << .1, .3, .4;
    GenerateAutoRegressiveData gar(T, params, -1);
    AutoregressiveModel ar;
    double r0 = 6;
    double R0 = 8;
    RowVectorXd b0 = RowVectorXd::Zero(gar.Xt.cols());
    MatrixXd B0 = 10 * MatrixXd::Identity(gar.Xt.cols(), gar.Xt.cols());
    RowVectorXd g0 = RowVectorXd::Zero(gar.lags);
    // RowVectorXd g0 = params;
    MatrixXd G0 = MatrixXd::Identity(gar.lags, gar.lags);
    ar.setModel(gar.yt, gar.Xt, g0, G0, r0, R0, b0, B0);
    ar.runAr(300, 50);
    cout << "AR Parameters" << endl;
    cout << "True values "
         << "AR " << params << endl;
    cout << ar.storeArParams.colwise().mean() << endl;
    cout << "True values beta " << -1 << endl;
    cout << ar.storeBeta.colwise().mean() << endl;
    cout << "True Values sigma2 " << 1 << endl;
    cout << ar.storeSigma2.mean() << endl;
    ar.bayesFit(); 
  }
  int ma = 0;
  if (ma == 1) {
    MovingAverageModel ma;
    int p = 3;
    RowVectorXd thetas(p);
    thetas << .5, .5, .5;
    int T = 50;
    ma.genData(p, thetas, T);
    ma.runModel(10, 1);
  }

  return 0;
}
