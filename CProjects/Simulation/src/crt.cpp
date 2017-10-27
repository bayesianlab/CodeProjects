#include "CRT.hpp"
#include "Dist.hpp"
#include <Eigen/Dense>
#include <iostream>
#include <math.h>

using namespace Eigen;
using namespace std;

CRT::CRT() { cout << "\n\tCRT Begin\n" << endl; }

void CRT::crtKernel(VectorXd &lowerlim, VectorXd &upperlim, VectorXd &theta,
                    MatrixXd &sigma, int sims, int burnin) {
  ll = lowerlim;
  ul = upperlim;
  mu = theta;
  Sigma = sigma;
  J = sigma.cols();
  Rows = sims - burnin;
  Jminus1 = J - 1;
  precision = sigma.inverse();
  Hxx = precision.diagonal();
  sigmaVector = MatrixXd::Zero(sigma.cols(), 1);
  sigmaVector = (1. / Hxx.array()).sqrt();
  truncatedSample = MatrixXd::Zero(sims, 2 * J);
  truncatedSample = tmultnorm(lowerlim, upperlim, mu, sigma, sims);
  truncatedSample = truncatedSample.bottomRows(sims - burnin).eval();
  zStar = truncatedSample.leftCols(J).colwise().mean();
  Kernel = MatrixXd::Zero(Rows, J);
  xNotj = MatrixXd::Zero(Rows, Jminus1);
  xNotj.rightCols(Jminus1 - 1) = truncatedSample.middleCols(2, J - 2);
  muNotj = MatrixXd::Zero(Jminus1, 1);
  Hxy = MatrixXd::Zero(Jminus1, 1);
  xnotJ = zStar.head(Jminus1);
  betaPrior = MatrixXd::Zero(Jminus1, 1);
  sigmaPrior = MatrixXd::Identity(Jminus1, Jminus1);
  igamA = 3;
  igamB = 6;
  gibbsKernel();
}

void CRT::gibbsKernel() {
  Kernel.col(0) = Dist::tnormpdfMeanVect(
      ll(0), ul(0), truncatedSample.col(J).matrix(), sigmaVector(0), zStar(0));
  MatrixXd tempj;
  for (int j = 1; j < Jminus1; j++) {
    muNotj << mu.head(j), mu.tail(Jminus1 - j);
    Hxy << precision.row(j).head(j).transpose().eval(),
        precision.row(j).tail(Jminus1 - j).transpose().eval();
    xNotj.col(j - 1).fill(zStar(j - 1));
    Kernel.col(j) = Dist::tnormpdfMeanVect(
        ll(j), ul(j), Dist::conditionalMean(Hxx(j), Hxy, muNotj, xNotj, mu(j)),
        sigmaVector(j), zStar(j));
  }
  Hxy << precision.row(Jminus1).head(Jminus1).transpose();
  muNotj = mu.head(Jminus1);
  double y = Dist::tnormpdf(
      ll(Jminus1), ul(Jminus1),
      Dist::conditionalMean(Hxx(Jminus1), Hxy, muNotj, xnotJ, mu(Jminus1)),
      sigmaVector(Jminus1), zStar(Jminus1));
  Kernel.col(Jminus1).fill(y);
}

double CRT::ml(VectorXd &zStarTail, double zStarHead, VectorXd &y,
               MatrixXd &X) {
  double mLike = lrLikelihood(zStarTail, zStarHead, y, X) +
                 logmvnpdf(betaPrior, sigmaPrior, zStarTail) +
                 loginvgammapdf(zStarHead, igamA, igamB) -
                 log(Kernel.rowwise().prod().mean());
  return mLike;
}

void CRT::runSim(int nSims, int batches, VectorXd &lowerConstraint,
                 VectorXd &upperConstraint, VectorXd &theta, MatrixXd &sig,
                 VectorXd &y, MatrixXd &X, int sims, int burnin) {

  int J = sig.cols();
  int Jminus1 = J - 1;
  VectorXd mLike(nSims);
  VectorXd b(Jminus1);

  for (int i = 0; i < nSims; i++) {
    crtKernel(lowerConstraint, upperConstraint, theta, sig, sims, burnin);
    b = zStar.tail(Jminus1);
    mLike(i) = ml(b, zStar(0), y, X);
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
