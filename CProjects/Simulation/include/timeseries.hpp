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

  MatrixXd CreateMinnesotaPrior(const MatrixXd &Yt, int lag, double lambda0,
                                double lambda1, double theta);

  void BvarMinnesota(const MatrixXd &Yt, int lag, double constantShrinkage,
                     double totalShrink, double otherShrinkage, int Sims,
                     int burn);

  void BvarConjugate(const MatrixXd &Yt, int lag);
};

#endif

