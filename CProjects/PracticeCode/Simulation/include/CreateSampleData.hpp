#ifndef CSD
#define CSD

#include "Dist.hpp"
#include <Eigen/Dense>
using namespace Eigen;

class CreateSampleData : public Dist {
public:
  CreateSampleData(int, VectorXd &);
  CreateSampleData(int, VectorXd &, int seed);
  CreateSampleData(int, VectorXd&, int, double, int);
  CreateSampleData(int, VectorXd&, int, double);
  void CorrData(const VectorXd &b, const MatrixXd &V, const int N);

  VectorXd MleLinearReg(const VectorXd &z, const MatrixXd &Covariates);
  MatrixXd X;
  MatrixXd epsilon;
  VectorXd y;
  VectorXd mles;
  VectorXd resids;
  MatrixXd inverseFisher;
  double residsTresids;
  double sigmaSqdHat;
  VectorXd maxLikeEsts;
  int dimension;
};
#endif
