#include "crt.hpp"
#include "Dist.hpp"
#include <Eigen/Dense>
#include <iostream>
#include <math.h>

using namespace Eigen;
using namespace std;

double Crt::crtTML(const VectorXd &a, const VectorXd &b,
                   const MatrixXd &LinearConstraints, const VectorXd &mu,
                   const MatrixXd &Sigma, const VectorXd &y, const MatrixXd &X,
                   double df, int sims, int burnin, const VectorXd &b0,
                   const MatrixXd &B0, double a0, double d0) {
  int J = Sigma.cols();
  int Jm1 = J - 1;
  int Rows = sims - burnin;
  MatrixXd truncTSample =
      mvttgeweke91(a, b, LinearConstraints, mu, Sigma, df, sims, burnin)
          .bottomRows(Rows);
  VectorXd zstar = truncTSample.leftCols(J).colwise().mean();
  MatrixXd kernel = gibbsTKernel(a, b, LinearConstraints, truncTSample, zstar,
                                 df, mu, Sigma, y, X, sims, burnin);
  VectorXd ztail = zstar.tail(Jm1);
  return mlT(ztail, zstar(0), y, X, kernel, b0, B0, a0, d0);
}


double Crt::ml(const VectorXd &zStarTail, double zStarHead,
               const MatrixXd &Kernel, const VectorXd &y, const MatrixXd &X,
               const VectorXd &b0, const MatrixXd &B0, double a0, double d0) {
	double Like =  lrLikelihood(zStarTail, zStarHead, y, X);
	double lmvn = logmvnpdf(b0, B0, zStarTail);
	double lig = loginvgammapdf(zStarHead, a0, d0);
	double lkp = log(Kernel.rowwise().prod().mean());
  return Like + lmvn + lig - lkp;
}

double Crt::mlT(const VectorXd &zStarTail, double zStarHead, const VectorXd &y,
                const MatrixXd &X, MatrixXd &kernel, const VectorXd &b0,
                const MatrixXd &B0, double a0, double d0) {
  double mLike = lrLikelihood(zStarTail, zStarHead, y, X) +
                 logmvnpdfVect(b0, B0, zStarTail) +
                 loginvgammapdf(zStarHead, a0, d0) -
                 log(kernel.rowwise().prod().mean());
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
    mLike(i) = crtTML(a, b, LinearConstraints, theta, Sigma, y, X, df, sims,
                      burnin, b0, B0, a0, d0);
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

void Crt::runSim(int nSims, int batches, const VectorXd &a, const VectorXd &b,
                 VectorXd &mu, MatrixXd &Sigma, VectorXd &y, MatrixXd &X,
                 int sims, int burnin, const VectorXd &b0, const MatrixXd &B0,
                 double a0, double d0) {
  int J = Sigma.cols();
  int Jminus1 = J - 1;
  VectorXd mLike(nSims);
  VectorXd betas(Jminus1);
  MatrixXd Sample(sims, J);
  MatrixXd Kernel(sims, J);
  VectorXd zStar(J);
  for (int i = 0; i < nSims; i++) {
    Sample =
        tmultnorm(a, b, mu, Sigma, sims).leftCols(J).bottomRows(sims - burnin);
    zStar = Sample.colwise().mean();
    Kernel = Dist::gibbsKernel(a, b, mu, Sigma, Sample, zStar);
    betas = zStar.tail(Jminus1);
    mLike(i) = ml(betas, zStar(0), Kernel, y, X, b0, B0, a0, d0);
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
