#ifndef ASK_H
#define ASK_H

#include "Dist.hpp"
#include <Eigen/Dense>

using namespace Eigen;

class Ask : public Dist {
private:
  MatrixXd xNotj;
  VectorXd Hxy;
  VectorXd muNotj;
  VectorXd betaPrior;
  MatrixXd sigmaPrior;
  double igamA, igamB;
  void setPriors(VectorXd& b0, MatrixXd& S0, double, double);
  void setPriors(int);
  void setTemporaries(VectorXd &, VectorXd &, VectorXd &, MatrixXd &, int, int);

public:
  Ask();
  MatrixXd sample;
  int J;
  int Jminus1;
  VectorXd sigmaVector;
  VectorXd mu;
  MatrixXd Kernel;
  void gibbsKernel();
  VectorXd lowerTruncPoints;
  VectorXd upperTruncPoints;
  VectorXd theta;
  MatrixXd sigma;
  MatrixXd precision;
  VectorXd zStar;
  VectorXd Hxx;
  int Rows;
  VectorXd weight;

  void conditionalMean(double, VectorXd &, VectorXd &, MatrixXd &, double,
                       VectorXd &);

  void tnormpdf(double, double, VectorXd &, double, double, VectorXd &);

  void adaptiveSampler(double, int, int, int);
  int isVectVgreater(VectorXd &, VectorXd &);
  MatrixXd burninAdaptive(int, int, double);
  double calcPeta(VectorXd &, VectorXd &);
  void askKernel(VectorXd&, VectorXd&, VectorXd&, MatrixXd&, int, int, int);
  double ml(VectorXd &, double, VectorXd &, MatrixXd &);
  void runSim(int, int, VectorXd&, VectorXd&, VectorXd&, MatrixXd&, VectorXd &, MatrixXd&, int, int, int);
};

#endif

