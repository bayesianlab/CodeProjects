

#ifndef TIMESERIES_H
#define TIMESERIES_H
#include "Dist.hpp"
#include <Eigen/Dense>

using namespace std;
using namespace Eigen;

class TimeSeries : public Dist {
public:
  void lagvars(MatrixXd &Xt, const Ref<const MatrixXd> &Yt, int N);

  MatrixXd VAR(const MatrixXd &Yt, int lag);

  VectorXd calcSigmaHatSqd(const MatrixXd &Yt, int lag);

  VectorXd CreateScaledVarDiag(const MatrixXd &Yt, int lag, int C, double Big);

  VectorXd CreateLagDiag(int C, int lag, double Big);

  MatrixXd MinnesotaPrior(const MatrixXd &Yt, int lag, int C);

  void BVAR(const MatrixXd &Yt, int lag);
};

#endif

