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
  int Rows, J, Jminus1;
  string arkWarning =
      "  Exceed max iterations, use custom constructor to alter maximum.\n";
  VectorXd betaPrior;
  MatrixXd sigmaPrior;
  double igamA, igamB;

public:
  Ark();

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

  double ml(VectorXd &, double, VectorXd &, MatrixXd &);
  void arkKernel(VectorXd &, VectorXd &, VectorXd &, MatrixXd &, int, int);
  void runSim(int nSims, int batches, VectorXd &theta, MatrixXd &sigma,
              VectorXd &y, MatrixXd &X, VectorXd &ll, VectorXd &ul,
              int sampleSize, int );
};

#endif

