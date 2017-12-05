#include "crt.hpp"
#include "Dist.hpp"
#include <Eigen/Dense>
#include <iostream>
#include <math.h>

using namespace Eigen;
using namespace std;

Crt::Crt() { cout << "\n\tCRT Begin\n" << endl; }

void Crt::crtKernel(VectorXd &lowerlim, VectorXd &upperlim, VectorXd &theta,
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

double Crt::crtTML(const VectorXd &a, const VectorXd &b,
                   const MatrixXd &LinearConstraints, const VectorXd &mu,
                   const MatrixXd &Sigma, const VectorXd &y, const MatrixXd &X,
                   double df, int sims, int burnin, const VectorXd b0,
                   const MatrixXd &B0, double a0, double d0) {
  int J = Sigma.cols();
  int Jm1 = J - 1;
  Rows = sims - burnin;
  MatrixXd truncTSample =
      mvttgeweke91(a, b, LinearConstraints, mu, Sigma, df, sims, burnin)
          .bottomRows(Rows);
  VectorXd zstar = truncTSample.leftCols(J).colwise().mean();
  MatrixXd kernel = gibbsTKernel(a, b, LinearConstraints, truncTSample, zstar,
                                 df, mu, Sigma, y, X, sims, burnin);
  VectorXd ztail = zstar.tail(Jm1);
  cout << "zta" << endl;
  cout << ztail <<endl;
  return mlT(ztail, zstar(0), y, X, kernel);
}

MatrixXd Crt::gibbsTKernel(const VectorXd &a, const VectorXd &b,
                           const MatrixXd &LinearConstraints,
                           const MatrixXd &sample, VectorXd &zstar, double df,
                           const VectorXd &mu, const MatrixXd &Sigma,
                           const VectorXd &y, const MatrixXd &X, int sims,
                           int burnin) {
  int J = Sigma.cols();
  int Jm1 = J - 1;
  Rows = sims - burnin;/*
  MatrixXd truncTSample =
      mvttgeweke91(a, b, LinearConstraints, mu, Sigma, df, sims, burnin)
          .bottomRows(Rows);
  VectorXd zstar = truncTSample.leftCols(J).colwise().mean();*/
  MatrixXd xnoti = MatrixXd::Zero(Rows, Jm1);
  xnoti.rightCols(Jm1 - 1) = sample.middleCols(2, J - 2);
  MatrixXd precision = Sigma.inverse();
  VectorXd Hii = precision.diagonal();
  VectorXd sigVect = (1. / Hii.array()).sqrt();
  MatrixXd kernel = MatrixXd::Zero(Rows, J);
  kernel.col(0) =
      Dist::ttpdf(a(0), b(0), df, sample.col(J), sigVect(0), zstar(0));
  VectorXd Hinoti = MatrixXd::Zero(Jminus1, 1);
  VectorXd munoti = MatrixXd::Zero(Jminus1, 1);
  MatrixXd notj = selectorMat(J);
  for (int j = 1; j < Jm1; j++) {
    munoti=  notj.block(j * (Jm1), 0, Jm1, J) *mu;
    Hinoti = notj.block(j * (Jm1), 0, Jm1, J) * precision.row(j).transpose();
    xnoti.col(j - 1).fill(zstar(j - 1));
    kernel.col(j) =
        Dist::ttpdf(a(j), b(j), df + Jm1,
                    Dist::conditionalMean(Hii(j), Hinoti, munoti, xnoti, mu(j)),
                    sigVect(j), zstar(j));
  }
  Hinoti = precision.row(Jm1).head(Jm1).transpose();
  munoti = mu.head(Jm1);
  VectorXd xnotI = zstar.head(Jm1);
  double lastColumn = Dist::ttpdf(
      a(Jm1), b(Jm1), df + Jm1,
      Dist::conditionalMean(Hii(Jm1), Hinoti, munoti, xnotI, mu(Jm1)),
      sigVect(Jm1), zstar(Jm1));
  kernel.col(Jm1).fill(lastColumn);
  return kernel;
}

void Crt::gibbsKernel() {
  Kernel.col(0) = Dist::tnormpdfMeanVect(
      ll(0), ul(0), truncatedSample.col(J).matrix(), sigmaVector(0), zStar(0));
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

double Crt::ml(VectorXd &zStarTail, double zStarHead, VectorXd &y,
               MatrixXd &X) {
  double mLike = lrLikelihood(zStarTail, zStarHead, y, X) +
                 logmvnpdf(betaPrior, sigmaPrior, zStarTail) +
                 loginvgammapdf(zStarHead, igamA, igamB) -
                 log(Kernel.rowwise().prod().mean());
  return mLike;
}

double Crt::mlT(VectorXd &zStarTail, double zStarHead, const VectorXd &y,
                const MatrixXd &X, MatrixXd &Kernel, const VectorXd &b0,
                const MatrixXd &B0, double a0, double d0) {
  double mLike = lrLikelihood(zStarTail, zStarHead, y, X) +
                 logmvnpdf(b0, B0, zStarTail) +
                 loginvgammapdf(zStarHead, a0, d0) -
                 log(Kernel.rowwise().prod().mean());
  return mLike;
}

void Crt::runTsim(int nSims, int batches, const VectorXd &a, const VectorXd &b,
                  const MatrixXd &LinearConstraints, double df,
                  const VectorXd &theta, const MatrixXd &Sigma,
                  const VectorXd &y, const MatrixXd &X, int sims, int burnin,
                  const VectorXd &b0, const MatrixXd &B0, double a0,
                  double d0) {

  int J = Sigma.cols();
  int Jminus1 = J - 1;
  VectorXd mLike(nSims);
  for (int i = 0; i < nSims; i++) {
    mLike(i) =
        crtTML(a, b, LinearConstraints, theta, Sigma, y, X, df, sims, burnin);
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

void Crt::runSim(int nSims, int batches, VectorXd &lowerConstraint,
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
