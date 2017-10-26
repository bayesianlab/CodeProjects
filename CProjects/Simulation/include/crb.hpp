#ifndef LIKELIHOOD
#define LIKELIHOOD

#include "Dist.hpp"
#include <Eigen/Dense>

using namespace Eigen;
class Crb:public Dist {
private:
  Dist distributionObject;
  VectorXd betaPrior;
  MatrixXd sigmaPrior;
  double igamA, igamB;

public:
  Crb(int);
  void chibRaoBlackwell(VectorXd &a, VectorXd &b, VectorXd &mu, MatrixXd &sigma,
                        VectorXd &zStar, VectorXd &fzStar, int, int, int, int);

  int getReducedRunSampleColumnDimension(int);
  void fillSigmaVect(VectorXd &, VectorXd &);
  double getfzStarMeanAtCol(double, double, MatrixXd &, int, double, double);
  void fillfzStar(VectorXd &, int, VectorXd &, VectorXd &, MatrixXd &,
                  VectorXd &, VectorXd &);
  void ml(VectorXd &, double, VectorXd &, VectorXd &, MatrixXd &);
  void runSim(VectorXd &, MatrixXd &, VectorXd &, MatrixXd &, VectorXd &,
              VectorXd &, int, int, int, int);
};

#endif
