#include <Eigen/Dense>
#include <boost/math/distributions/bernoulli.hpp>
#include <boost/math/distributions/normal.hpp>
#include <boost/random/uniform_01.hpp>
#include <cstdint>
#include <ctime>
#include <limits>
#include <math.h>

#include "Dist.hpp"
#include "ark.hpp"

using namespace Eigen;
using namespace std;

double Ark::arkKernelT(const VectorXd &a, const VectorXd &b,
                       const MatrixXd &LinearConstraints, const VectorXd &theta,
                       const MatrixXd &Sigma, double df, const VectorXd &y,
                       const MatrixXd &X, const VectorXd b0, const MatrixXd B0,
                       double a0, double d0, int sims, int maxIterations) {
  int K = Sigma.cols();
  int Km1 = K - 1;
  MatrixXd arsamp = acceptRejectT(a, b, LinearConstraints, theta, Sigma, df,
                                  sims, maxIterations);
  VectorXd zstar = arsamp.colwise().mean();
  MatrixXd xnot = arsamp.rightCols(Km1);
  MatrixXd kernel = gibbsKernelT(a, b, df, theta, Sigma, arsamp, xnot, zstar);
  VectorXd betas = zstar.tail(Km1);
  return mlT(betas, zstar(0), y, X, kernel, b0, B0, a0, d0);
}

MatrixXd Ark::gibbsKernelT(const VectorXd &a, const VectorXd &b, double df,
                           const VectorXd &theta, const MatrixXd &Sigma,
                           const MatrixXd &draws, MatrixXd &xnot,
                           VectorXd &zstar) {
  int K = Sigma.cols();
  int Km1 = K - 1;
  MatrixXd kernel(xnot.rows(), K);
  MatrixXd H = Sigma.inverse();
  VectorXd Hinoti = H.row(0).tail(Km1);
  VectorXd Hii = H.diagonal();
  VectorXd sigVect = Hii.array().pow(-1).sqrt();
  MatrixXd notj = selectorMat(K);
  VectorXd thetanot = theta.tail(Km1);
  kernel.col(0) = Dist::ttpdf(
      a(0), b(0), df + Km1,
      Dist::conditionalMean(Hii(0), Hinoti, thetanot, xnot, theta(0)),
      sigVect(0), zstar(0));
  xnot.rightCols(Km1 - 1) = draws.rightCols(K - 2);
  for (int j = 1; j < Km1; j++) {
    thetanot = notj.block(j * (Km1), 0, Km1, K) * theta;
    Hinoti = notj.block(j * (Km1), 0, Km1, K) * H.row(j).transpose();
    xnot.col(j - 1).fill(zstar(j - 1));
    kernel.col(j) = Dist::ttpdf(
        a(j), b(j), df + Km1,
        Dist::conditionalMean(Hii(j), Hinoti, thetanot, xnot, theta(j)),
        sigVect(j), zstar(j));
  }
  Hinoti = H.row(Km1).head(Km1).transpose();
  thetanot = theta.head(Km1);
  VectorXd xnotK = zstar.head(Km1);
  double thetaK =
      Dist::conditionalMean(Hii(Km1), Hinoti, thetanot, xnotK, theta(Km1));
  double y =
      Dist::ttpdf(a(Km1), b(Km1), df + Km1, thetaK, sigVect(Km1), zstar(Km1));
  kernel.col(Km1).fill(y);
  return kernel;
}

MatrixXd Ark::arSample(const VectorXd &ll, const VectorXd &ul, const VectorXd &mu,
                       const MatrixXd &sigma, int sSize, int maxIterations) {
  int J, n, maxit;
  J = sigma.cols();
  MatrixXd arSample(sSize, J);
  n = 0;
  maxit = 0;
  MatrixXd t(1, J);
  while (n < sSize) {
    t = mvnrnd(mu, sigma, 1, J).array();
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

MatrixXd Ark::acceptRejectT(const VectorXd &a, const VectorXd &b,
                            const MatrixXd &LinearConstraints,
                            const VectorXd &theta, const MatrixXd &Sigma,
                            double df, int sSize, int maxIterations) {
  int K = Sigma.cols();
  MatrixXd sample(sSize, K);
  int n = 0;
  int maxit = 0;
  MatrixXd t(1, K);
  while (n < sSize) {
    t = mvtruncT(a, b, LinearConstraints, theta, Sigma, df, 1).array();
    if ((t.array() > a.transpose().array()).all() +
            (t.array() < b.transpose().array()).all() ==
        2) {
      sample.row(n) = t;
      n++;
      maxit = 0;
    } else if (maxit == maxIterations) {
      cout << arkWarning << n << endl;
      sample.row(n).fill(-inf);
      n++;
      maxit = 0;
    } else {
      maxit++;
    }
  }
  return sample;
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

double Ark::ml(const VectorXd &betas, double sigmas, const VectorXd &y,
               const MatrixXd &X, const MatrixXd &Kernel, const VectorXd &b0,
               const MatrixXd &B0, double a0, double d0) {
  double mLike = lrLikelihood(betas, sigmas, y, X) +
                 logmvnpdf(b0, B0, betas) +
                 loginvgammapdf(sigmas, a0, d0) -
                 log(Kernel.rowwise().prod().mean());
  return mLike;
}

double Ark::mlT(VectorXd &betas, double sigma, const VectorXd &y,
                const MatrixXd &X, const MatrixXd &kernel, const VectorXd &b0,
                const MatrixXd &B0, double a0, double d0) {
  double mLike = lrLikelihood(betas, sigma, y, X) +
                 logmvnpdfVect(b0, B0, betas) +
                 loginvgammapdf(sigma, a0, d0) -
                 log(kernel.rowwise().prod().mean());
  return mLike;
}

void Ark::runSim(int nSims, int batches, const VectorXd &theta,
                 const MatrixXd &sigma, const VectorXd &y, const MatrixXd &X,
                 const VectorXd &ll, const VectorXd &ul, int sampleSize,
                 int maxIterations, const VectorXd &b0, const MatrixXd &B0,
                 double a0, double d0) {
  int J = sigma.cols();
  int Jm1 = J - 1;
  VectorXd mLike(nSims);
  VectorXd b(Jm1);
  MatrixXd arkSample(sampleSize, J);
  MatrixXd Kernel(sampleSize, J);
  VectorXd zStar(J);
  for (int i = 0; i < nSims; i++) {
    arkSample = arSample(ll, ul, theta, sigma, sampleSize, maxIterations);
    zStar = arkSample.colwise().mean();
    Kernel = gibbsKernel(ll, ul, theta, sigma, arkSample, zStar);
    b = zStar.tail(Jm1);
        mLike(i) = ml(b, zStar(0), y, X, Kernel, b0, B0, a0, d0);
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
      ;
    }
  }
}

void Ark::runTsim(int nSims, int batches, const VectorXd &a, const VectorXd &b,
                  const MatrixXd &LinearConstraints, double df,
                  const VectorXd &theta, const MatrixXd &Sigma,
                  const VectorXd &y, const MatrixXd &X, int sims, int maxIter,
                  const VectorXd &b0, const MatrixXd &B0, double a0,
                  double d0) {
  int K = Sigma.cols();
  VectorXd mLike(nSims);
  for (int i = 0; i < nSims; i++) {
    mLike(i) = arkKernelT(a, b, LinearConstraints, theta, Sigma, df, y, X, b0,
                          B0, a0, d0, sims, maxIter);
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
      ;
    }
  }
}
