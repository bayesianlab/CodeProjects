

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

  VectorXd CreateScaledVarDiag(const MatrixXd &Yt, int lag, int C,
                               double lambda0, double lambda1, double theta);

  VectorXd CreateLagDiag(int C, int lag);

  MatrixXd MinnesotaPrior(const MatrixXd &Yt, int lag, int C);

  void BvarMinnesota(const MatrixXd &Yt, int lag);
  
  void BvarConjugate(const MatrixXd &Yt, int lag);
};


#endif

