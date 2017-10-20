#ifndef ARK_H
#define ARK_H

#include "Dist.hpp"
#include <Eigen/Dense>

using namespace Eigen;

class Ark : public Dist {
private:
  MatrixXd xNotj;
  VectorXd muNotj;
  VectorXd Hxy;
  VectorXd Hxx;
  VectorXd sigmaVector;
  VectorXd ll;
  VectorXd ul;
  MatrixXd precision;
  MatrixXd sigma;
  int Rows;
  int J;
  int Jminus1;
  string arkWarning =
      "  Exceed max iterations, use custom constructor to alter maximum.\n";

public:
  Ark(VectorXd &, VectorXd &, VectorXd &, MatrixXd &, int);
  Ark(VectorXd &, VectorXd &, VectorXd &, MatrixXd &, int, int);

  MatrixXd arSample(VectorXd &, VectorXd &, VectorXd &, MatrixXd &, int, int);

  int isVectVgreater(VectorXd &v, VectorXd &u);

  void gibbsKernel();

  void conditionalMean(double, VectorXd &, VectorXd &, MatrixXd &, double,
                       VectorXd &);

  void tnormpdf(double, double, VectorXd &, double, double, VectorXd &);

  void displayMLike();

  MatrixXd arkSample;

  MatrixXd Kernel;

  VectorXd zStar;

  VectorXd mu;

};

#endif

