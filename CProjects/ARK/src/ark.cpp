#include <Eigen/Dense>
#include <assert.h>
#include <boost/math/distributions/bernoulli.hpp>
#include <boost/math/distributions/normal.hpp>
#include <boost/random/mersenne_twister.hpp>
#include <boost/random/uniform_01.hpp>
#include <boost/random/variate_generator.hpp>
#include <cstdint>
#include <ctime>
#include <limits>
#include <math.h>
#include <random>

#include "Dist.hpp"
#include "ark.hpp"

using namespace Eigen;
using namespace std;

Ark::Ark(VectorXd &lowLim, VectorXd &upLim, VectorXd &theta, MatrixXd &variance,
         int sims) {

  cout << "\n\n\tARK begin\n\n" << endl;
  Rows = sims;
  sigma = variance;
  J = sigma.cols();
  Jminus1 = J - 1;
  mu = theta;
  ll = lowLim;
  ul = upLim;
  int maxIterations = 10000;
  precision = sigma.inverse();
  Hxx = precision.diagonal();
  sigmaVector = (1. / Hxx.array()).sqrt();
  arkSample = MatrixXd::Zero(sims, J);
  arkSample = arSample(lowLim, upLim, mu, sigma, sims, maxIterations);
  zStar = arkSample.colwise().mean();
  Kernel = MatrixXd::Zero(Rows, J);
  muNotj = MatrixXd::Zero(Jminus1, 1);
  Hxy = MatrixXd::Zero(Jminus1, 1);
  xNotj = MatrixXd::Zero(Rows, Jminus1);
  xNotj = arkSample.rightCols(Jminus1);
  gibbsKernel();
}

Ark::Ark(VectorXd &lowLim, VectorXd &upLim, VectorXd &theta, MatrixXd &variance,
         int sims, int maxIterations) {
  cout << "\n\n\tARK begin: Custom iterations\n\n" << endl;
  Rows = sims;
  sigma = variance;
  J = sigma.cols();
  Jminus1 = J - 1;
  mu = theta;
  ll = lowLim;
  ul = upLim;
  precision = sigma.inverse();
  Hxx = precision.diagonal();
  sigmaVector = (1. / Hxx.array()).sqrt();
  arkSample = MatrixXd::Zero(sims, J);
  arkSample = arSample(lowLim, upLim, mu, sigma, sims, maxIterations);
  zStar = arkSample.colwise().mean();
  Kernel = MatrixXd::Zero(Rows, J);
  muNotj = MatrixXd::Zero(Jminus1, 1);
  Hxy = MatrixXd::Zero(Jminus1, 1);
  xNotj = MatrixXd::Zero(Rows, Jminus1);
  xNotj = arkSample.rightCols(Jminus1);
}

MatrixXd Ark::arSample(VectorXd &ll, VectorXd &ul, VectorXd &mu,
                       MatrixXd &sigma, int sSize, int maxIterations) {
  int J, n, maxit;
  J = sigma.cols();
  MatrixXd arSample(sSize, J);
  n = 0;
  maxit = 0;
  while (n < sSize) {
    MatrixXd t = mvnrnd(mu, sigma, 1, J).array();
    if ((t.array() > ll.transpose().array()).all() +
            (t.array() < ul.transpose().array()).all() ==
        2) {
      arSample.row(n) = t;
      n++;
      maxit = 0;
    } else if (maxit == maxIterations) {
      cout << arkWarning << n << endl;
      arSample.row(n).fill(-inf);
      n++;
      maxit = 0;
    } else {
      maxit++;
    }
  }
  return arSample;
}

void Ark::gibbsKernel() {

  VectorXd tempk(Rows);
  VectorXd cmeanVect(Rows);
  Hxy = precision.row(0).tail(Jminus1);
  muNotj = mu.tail(Jminus1);
  conditionalMean(Hxx(0), Hxy, muNotj, xNotj, mu(0), cmeanVect);
  tnormpdf(ll(0), ul(0), cmeanVect, sigmaVector(0), zStar(0), tempk);
  Kernel.col(0) = tempk;
  xNotj.rightCols(Jminus1 - 1) = arkSample.rightCols(J - 2);

  for (int j = 1; j < Jminus1; j++) {
    muNotj << mu.head(j), mu.tail(Jminus1 - j);
    Hxy << precision.row(j).head(j).transpose().eval(),
        precision.row(j).tail(Jminus1 - j).transpose().eval();
    xNotj.col(j - 1).fill(zStar(j - 1));
    conditionalMean(Hxx(j), Hxy, muNotj, xNotj, mu(j), cmeanVect);
    tnormpdf(ll(j), ul(j), cmeanVect, sigmaVector(j), zStar(j), tempk);
    Kernel.col(j) = tempk;
  }

  Hxy << precision.row(Jminus1).head(Jminus1).transpose();
  muNotj = mu.head(Jminus1);
  VectorXd xnotJ = zStar.head(Jminus1);
  double muJ =
      Dist::conditionalMean(Hxx(Jminus1), Hxy, muNotj, xnotJ, mu(Jminus1));
  double y = Dist::tnormpdf(ll(Jminus1), ul(Jminus1), muJ, sigmaVector(Jminus1),
                            zStar(Jminus1));
  Kernel.col(Jminus1).fill(y);
}

void Ark::conditionalMean(double Hxx, VectorXd &Hxy, VectorXd &muNotj,
                          MatrixXd &xNotj, double muxx,
                          VectorXd &conditionalMeanVector) {
  xNotj.rowwise() -= muNotj.transpose();
  conditionalMeanVector = muxx - ((1 / Hxx) * xNotj * Hxy).array();
}

void Ark::tnormpdf(double a, double b, VectorXd &mu, double sigma, double x,
                   VectorXd &k) {
  boost::math::normal normalDist;
  double Fa, Fb;
  for (int i = 0; i < mu.size(); i++) {
    Fa = cdf(normalDist, (a - mu(i)) / sigma);
    Fb = cdf(normalDist, (b - mu(i)) / sigma);
    double sigmaZ = sigma * (Fb - Fa);
    k(i) = pdf(normalDist, (x - mu(i)) / sigma) / sigmaZ;
  }
}

int Ark::isVectVgreater(VectorXd &v, VectorXd &u) {
  if ((v.array() > u.array()).all() == 1) {
    return 1;
  } else {
    return 0;
  }
}

void Ark::displayMLike() {
  double num = mvnpdf(mu, sigma, zStar);
  double den = Kernel.rowwise().prod().mean();
  double ans = log(num / den);
  cout << "Marginal Likelihood  " << ans << endl;
}

