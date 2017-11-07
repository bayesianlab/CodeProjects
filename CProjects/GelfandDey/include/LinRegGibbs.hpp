#ifndef LINREGDIST_H
#define LINREGDIST_H
#include "Dist.hpp"


class LinRegGibbs : public Dist {

public:
  MatrixXd gibbsLR(const VectorXd &, const MatrixXd &x, const int, const int);
  MatrixXd gibbsLR(const VectorXd &, const MatrixXd &x, const int, const int,
                   const VectorXd &b0, const MatrixXd &B0, const double a0,
                   const double d0);
  MatrixXd gibbsRestrictBeta(const VectorXd &, const MatrixXd &x, const int,
                             const int, const int);
  void gibbsBetaUpdates(MatrixXd &, VectorXd &, const VectorXd &,
                        const MatrixXd &, const VectorXd &, const MatrixXd &,
                        const VectorXd &, int);
  MatrixXd calcOmega(const MatrixXd &);

  void analyticalLL(const VectorXd &y, const MatrixXd &x);

  int inTheta(const Ref<const MatrixXd> &, const Ref<const MatrixXd>&,  const MatrixXd &);
  void gelfandDeyML(const MatrixXd &, const VectorXd &, const MatrixXd &);
};
#endif
