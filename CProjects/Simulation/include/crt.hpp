#ifndef CRT_H
#define CRT_H

#include "Dist.hpp"
#include <Eigen/Dense>

using namespace Eigen;
class CRT : public Dist {
private:
  MatrixXd precision;
  VectorXd Hxx;
  MatrixXd xNotj;
  VectorXd muNotj;
  VectorXd Hxy;
  int J;
  int Rows;
  int Jminus1;
  VectorXd ll;
  VectorXd ul;
  VectorXd mu;
  MatrixXd Sigma;
  VectorXd xnotJ;
  VectorXd betaPrior;
  MatrixXd sigmaPrior;
  double igamB, igamA;

public:
  CRT();

  void crtKernel(VectorXd &, VectorXd &, VectorXd &, MatrixXd &, int, int);
  void gibbsKernel();
  MatrixXd Kernel;
  VectorXd zStar;
  MatrixXd truncatedSample;
  VectorXd sigmaVector;
  double getKernelColumn(double a, double b, MatrixXd &sample, int col,
                         double sigma, double zStar);
  void conditionalMean(double, VectorXd &, VectorXd &, MatrixXd &, double,
                       VectorXd &);
  void tnormpdf(double, double, VectorXd &, double, double, VectorXd &);
  double ml(VectorXd &, double, VectorXd &, MatrixXd &);
  void runSim(int nSims, int batches, VectorXd &lowerConstraint,
            VectorXd &upperConstraint, VectorXd &theta, MatrixXd &sig,
            VectorXd &y, MatrixXd &X, int sims, int burnin);
};

#endif
