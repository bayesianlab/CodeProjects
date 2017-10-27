#include <Eigen/Dense>
#include <assert.h>
#include <boost/math/distributions/normal.hpp>
#include <cstdint>
#include <ctime>
#include <limits>
#include <math.h>
#include "Dist.hpp"
#include "Importance.hpp"

using namespace Eigen;
using namespace std;

Importance::Importance() {
  cout << beginString << endl;
}

double Importance::importanceSampling(VectorXd &ll, VectorXd &ul,
                                      VectorXd &betas, MatrixXd &sigma,
                                      VectorXd &y, MatrixXd &X, int sampleSize,
                                      int burnin, VectorXd &b0, MatrixXd &S0,
                                      int a0, int d0) {
  J = ll.size();
 Jminus1 = J-1; 
  lowerLim = ll;
  upperLim = ul;
  betaInit = b0; 
  sigmaInit = S0; 
  igamParamA = a0;
  igamParamB = d0;
  sample = ghkLinearConstraints(lowerLim, upperLim, betas,
                                sigma, sampleSize, burnin);
  lsEsts = sample.rightCols(J - 1);
  sigSqd = sample.col(0);
  diagInverseFish = sigma.diagonal().array().sqrt();
  importanceDensity =
      tnormpdf(ll, ul, betas, diagInverseFish, sample);
  
  return ml( y, X);
}

double Importance::ml( VectorXd &y, MatrixXd &X) {
  VectorXd loghTheta;
  loghTheta = importanceDensity.rowwise().prod().array().log();
  VectorXd likelihood;
  likelihood = lrLikelihood(lsEsts, sigSqd, y, X).array() +
               loginvgammapdf(sigSqd, igamParamA, igamParamB).array() +
               logmvnpdf(betaInit, sigmaInit, lsEsts).array() -
               loghTheta.array();
  return likelihood.mean();
}

VectorXd Importance::tnormpdf(double a, double b, double mu, double sigma,
                              VectorXd &x) {
  boost::math::normal normalDist;
  VectorXd fx(x.size());
  double sigmaZ = sigma * (cdf(normalDist, (b - mu) / sigma) -
                           cdf(normalDist, (a - mu) / sigma));
  for (int i = 0; i < x.size(); i++) {
    fx(i) = Dist::tnormpdf(a, b, mu, sigma, x(i));
  }
  return fx;
}

MatrixXd Importance::tnormpdf(VectorXd &ll, VectorXd &ul, VectorXd &mu,
                              VectorXd &stDevs, MatrixXd &x) {
  MatrixXd fx(x.rows(), x.cols());
  VectorXd temp;
  for (int j = 0; j < stDevs.size(); j++) {
    temp = x.col(j);
    fx.col(j) = Importance::tnormpdf(ll(j), ul(j), mu(j), stDevs(j), temp);
  }
  return fx;
}

void Importance::runSim(int nSims, int batches, VectorXd &theta, MatrixXd& sigma,
                 VectorXd &y, MatrixXd &X, VectorXd &ll, VectorXd &ul,
                 int sampleSize, int burnin, VectorXd& b0, MatrixXd& S0, int a0, int d0) {
	int J = sigma.cols() ;
	int Jminus1 = J -1;
  VectorXd mLike(nSims);
  VectorXd b(Jminus1);

  for (int i = 0; i < nSims; i++) {
    mLike(i) = importanceSampling(ll, ul, theta, sigma, y, X, sampleSize, burnin, b0, S0, a0, d0);
  }
  cout << setprecision(9) << mLike.mean() << endl;
  if (batches != 0) {
    int obsInMean = floor(nSims / batches);
    int remainder = nSims - (batches * obsInMean);
    if (remainder == 0) {
      VectorXd yBar(batches);
      int startIndex = 0;
      for (int j = 0; j < batches; j++) {
        yBar(j) = mLike.segment(startIndex, obsInMean).mean();
        startIndex = startIndex + obsInMean;
      }
      cout << setprecision(10) << standardDev(yBar) << endl;
    } else {
      VectorXd yBar(batches + 1);
      int startIndex = 0;
      for (int j = 0; j < batches; j++) {
        yBar(j) = mLike.segment(startIndex, obsInMean).mean();
        startIndex = startIndex + obsInMean;
      }
      yBar(batches) = mLike.segment(startIndex, remainder).mean();
      cout << setprecision(10) << standardDev(yBar) << endl;
    }
  }
}

