#include <stdio.h>

#include <Eigen/Dense>

#include "ARMA.hpp"
#include "AutoregressiveModel.hpp"
#include "GenerateAutoRegressiveData.hpp"

using namespace std;
using namespace Eigen;

int main() {
  int T = 250;
  MatrixXd params(1, 1);
  params << .9;
  GenerateAutoRegressiveData gar(T, params);
  AutoregressiveModel ar;
  double r0 = 6;
  double R0 = 8;
  RowVectorXd b0 = RowVectorXd::Zero(gar.Xt.cols());
  MatrixXd B0 = 10* MatrixXd::Identity(gar.Xt.cols(), gar.Xt.cols());
  RowVectorXd g0 = RowVectorXd::Zero(gar.lags);
  MatrixXd G0 = 10*MatrixXd::Identity(gar.lags, gar.lags);
  ar.setModel(gar.yt, gar.Xt, g0, G0, r0, R0, b0, B0);

  // plotter("epst", );
  ar.runAr(1500, 500);
  cout << "AR Parameters" << endl;
  cout << "True values "
       << "AR " << params << endl;
  cout << ar.storeArParams.colwise().mean() << endl;
  cout << "True values beta " << -1 << endl;
  cout << ar.storeBeta.colwise().mean() << endl;
  cout << "True Values sigma2 " << 1 << endl;
  cout << ar.storeSigma2.mean() << endl;
  ar.bayesFit();

  return 0;
}
