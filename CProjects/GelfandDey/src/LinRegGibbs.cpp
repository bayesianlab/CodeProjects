#include "LinRegGibbs.hpp"
#include <Eigen/Dense>
#include <math.h>

using namespace Eigen;
void LinRegGibbs::gibbsLR(const VectorXd &y, const MatrixXd &x,
                          const int gibbsSteps) {
  int J = x.cols();
  int N = x.rows();
  double a0, d0, aG, dG;
 aG= a0 + N;
  VectorXd sigma2 = MatrixXd::Ones(gibbsSteps, 1);
  MatrixXd beta = MatrixXd::Zero(gibbsSteps, J);
  MatrixXd B0 = MatrixXd::Identity(J, J);
  MatrixXd B0inv = B0.inverse();
  MatrixXd XpX = x.transpose() * x;
  VectorXd Xpy = x.transpose()*y;
  VectorXd b0 = MatrixXd::Zero(J,1);

  MatrixXd B1 = MatrixXd::Zero(J,J);
  VectorXd betaBar = MatrixXd::Zero(J,1);

  for (int i = 1; i < gibbsSteps; i++) {
	  
    gibbsBetaUpdates(B1, betaBar, sigma2, XpX, Xpy, B0inv, b0, 1);

    beta.row(i) = mvnrnd(betaBar, B1, 1, J);
	cout << beta << endl;
	dG = d0 +  (y - X*beta.row(i).transpose()).pow(2).sum();
	
	
  }
}

void LinRegGibbs::gibbsBetaUpdates(MatrixXd &B1, VectorXd &betaBar,
                               const VectorXd &sigma2, const MatrixXd &XpX,
                               const VectorXd &Xpy, const MatrixXd &B0inv,
                               const VectorXd &b0, int currIteration) {
  B1 = (pow(sigma2(currIteration), -1) * XpX + B0inv).inverse();
  betaBar = B1* (pow(sigma2(currIteration), -1)*Xpy + B0inv*b0);
}
