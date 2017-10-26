#ifndef IMP_H
#define IMP_H

#include "Dist.hpp"
#include <Eigen/Dense>
#include <string.h>

using namespace Eigen;

class Importance : public Dist {
private:
  string beginString = "\n\n\tBegin Importance\n";
  string mlEst = "Marginal Likelihood Estimate:    ";
  string newLines = "\n\n";
  VectorXd lowerLim;
  VectorXd upperLim;
  VectorXd y;
  MatrixXd X;
  int J;
  VectorXd diagInverseFish;
  MatrixXd lsEsts;
  VectorXd sigSqd;
  VectorXd betaInit;
  MatrixXd sigmaInit;
  int igamParamA, igamParamB, Jminus1;

public:
  Importance();
  double importanceSampling(VectorXd &, VectorXd &, VectorXd &, MatrixXd &, VectorXd&, MatrixXd&,  int,
                            int,  VectorXd &, MatrixXd &, int, int);
  double  ml( VectorXd&, MatrixXd&);
  MatrixXd sample;
  VectorXd tnormpdf(double, double, double, double, VectorXd&);
  MatrixXd tnormpdf(VectorXd &, VectorXd &, VectorXd &, VectorXd &, MatrixXd &);
  MatrixXd importanceDensity;
  void runSim(int ,int , VectorXd&, MatrixXd&, VectorXd&, MatrixXd&, VectorXd&, VectorXd&, int, int, VectorXd&, MatrixXd&, int, int );
};

#endif

