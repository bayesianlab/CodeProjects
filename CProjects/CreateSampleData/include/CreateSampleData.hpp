#ifndef CSD
#define CSD

#include "Dist.hpp"
#include <Eigen/Dense>
using namespace Eigen;

class CreateSampleData : public Dist {
public:
  CreateSampleData(int, VectorXd &);
  CreateSampleData(int, VectorXd &, int seed);
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
