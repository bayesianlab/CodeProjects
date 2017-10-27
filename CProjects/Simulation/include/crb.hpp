#ifndef LIKELIHOOD
#define LIKELIHOOD

#include "Dist.hpp"
#include <Eigen/Dense>

using namespace Eigen;
class Crb:public Dist {
private:
  VectorXd betaPrior;
  MatrixXd sigmaPrior;
  double igamA, igamB;

public:
  Crb(int J);
  void setPriors(int j);

  VectorXd zStar;
  VectorXd fzStar;
  VectorXd betas;
  void setBetas(int ); 
  void chibRaoBlackwell(VectorXd &a, VectorXd &b, VectorXd &mu, MatrixXd &sigma,
                        VectorXd &zStar, VectorXd &fzStar, int, int, int, int);
 void chibRao(VectorXd &a, VectorXd &b, VectorXd &mu, MatrixXd &sigma,
                        int, int, int, int);

  int getReducedRunSampleColumnDimension(int);
  void fillSigmaVect(VectorXd &, VectorXd &);
  double getfzStarMeanAtCol(double, double, MatrixXd &, int, double, double);
  void fillfzStar(VectorXd &, int, VectorXd &, VectorXd &, MatrixXd &,
                  VectorXd &, VectorXd &);
  double ml(VectorXd &, double, VectorXd &, MatrixXd &);
  void runSim(VectorXd &, MatrixXd &, VectorXd &, MatrixXd &, VectorXd &,
              VectorXd &, int, int, int, int);
  void calcfzStar(VectorXd &, VectorXd &, VectorXd &, VectorXd&, MatrixXd &,
                  VectorXd &);
};

#endif
