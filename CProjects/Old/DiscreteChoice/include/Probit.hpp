#ifndef PROBIT_H
#define PROBIT_H
#include "Dist.hpp"
class Probit : public Dist {
public:
  void ProbitDataAug(const VectorXd &y, const MatrixXd &X, VectorXd &b0,
                     MatrixXd &B0, int Sims, int burnin);

  void yStarUpdate(const VectorXd &y, VectorXd &yStar, const MatrixXd &X,
                   const Ref<const VectorXd> &beta);

  void ProbitMaxLike();

  double ProbitLogLike(const VectorXd &y, const MatrixXd &X,
                       const VectorXd &beta);
};
#endif
