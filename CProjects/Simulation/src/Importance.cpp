#include "Importance.hpp"
#include "Dist.hpp"
#include <Eigen/Dense>
#include <assert.h>
#include <boost/math/distributions/normal.hpp>
#include <cstdint>
#include <ctime>
#include <limits>
#include <math.h>

using namespace Eigen;
using namespace std;

double Importance::importanceSampling(const VectorXd &ll, const VectorXd &ul,
                                      const VectorXd &mu, const MatrixXd &Sigma,
                                      const VectorXd &y, const MatrixXd &X,
                                      int sampleSize, const VectorXd &b0,
                                      const MatrixXd &B0, int a0, int d0) {
  int J = Sigma.cols();
  MatrixXd lowerC = Sigma.llt().matrixL();
  VectorXd lowerCdiag = lowerC.diagonal();
  VectorXd logpdf(sampleSize);
  sample = ghkLinearConstraints(ll, ul, mu, Sigma, sampleSize, logpdf);
  MatrixXd betas = sample.rightCols(J - 1);
  VectorXd sigmas = sample.col(0);
  return pdfavg(lrLikelihood(betas, sigmas, y, X)) +
         pdfavg(loginvgammapdf(sigmas, a0, d0)) +
         pdfavg(logmvnpdfV(b0, B0, betas)) - pdfavg(logpdf);
}

double Importance::trunctprop(const VectorXd &a, const VectorXd &b,
                              const MatrixXd &LinearConstraints,
                              const VectorXd &mu, const MatrixXd &Sigma,
                              const int nu, const VectorXd &y,
                              const MatrixXd &X, int sampleSize,
                              const VectorXd &b0, const MatrixXd &B0, int a0,
                              int d0) {
  int J = Sigma.cols();
  VectorXd logpdf(sampleSize);
  MatrixXd sample =
      ghkT(a, b, LinearConstraints, mu, Sigma, nu, sampleSize, logpdf);
  MatrixXd betas = sample.rightCols(J - 1);
  VectorXd sigmas = sample.col(0);
  return pdfavg(lrLikelihood(betas, sigmas, y, X)) +
         pdfavg(loginvgammapdf(sigmas, a0, d0)) +
         pdfavg(logmvnpdfV(b0, B0, betas)) - pdfavg(logpdf);
}

double Importance::mlT(const VectorXd &a, const VectorXd &b,
                       const MatrixXd &LinearConstraints, const VectorXd &mu,
                       const MatrixXd &Sigma, const MatrixXd &y,
                       const MatrixXd &X, double df, int sims, int burnin,
                       const VectorXd &b0, const MatrixXd &B0, double a0,
                       double d0) {
  int J = Sigma.cols();
  MatrixXd draws = ghkT(a, b, LinearConstraints, mu, Sigma, df, sims);
  VectorXd stdevs = Sigma.diagonal().array().sqrt();
  VectorXd hTheta =
      ttpdf(a, b, df, mu, stdevs, draws).rowwise().prod().array().log();
  VectorXd likelihood =
      lrLikelihood(draws.rightCols(J - 1), draws.col(0), y, X).array() +
      loginvgammapdf(draws.col(0), a0, d0).array() +
      logmvnpdfV(b0, B0, draws.rightCols(J - 1)).array() - hTheta.array();
  return likelihood.mean();
}

double Importance::mlGeweke91(const VectorXd &a, const VectorXd &b,
                       const MatrixXd &LinearConstraints, const VectorXd &mu,
                       const MatrixXd &Sigma, const MatrixXd &y,
                       const MatrixXd &X, int sims, int burnin,
                       const VectorXd &b0, const MatrixXd &B0, double a0,
                       double d0) {
  int J = Sigma.cols();
  MatrixXd draws = geweke91(a, b, LinearConstraints, mu, Sigma, sims, burnin);
  VectorXd stdevs = Sigma.diagonal().array().sqrt();
  VectorXd hTheta =
      tnormpdfMat(a, b, mu, stdevs, draws).rowwise().prod().array().log();
  VectorXd likelihood =
      lrLikelihood(draws.rightCols(J - 1), draws.col(0), y, X).array() +
      loginvgammapdf(draws.col(0), a0 , d0 ).array() +
      logmvnpdfV(b0, B0, draws.rightCols(J - 1)).array() - hTheta.array();
  return likelihood.mean();
}

double Importance::mlGeweke91T(const VectorXd &a, const VectorXd &b,
                              const MatrixXd &LinearConstraints,
                              const VectorXd &mu, const MatrixXd &Sigma,
                              double df, const MatrixXd &y, const MatrixXd &X,
                              int sims, int burnin, const VectorXd &b0,
                              const MatrixXd &B0, double a0, double d0) {
  int J = Sigma.cols();
  MatrixXd draws =
      mvttgeweke91(a, b, LinearConstraints, mu, Sigma, df, sims, burnin)
          .leftCols(J);
  VectorXd stdevs = Sigma.diagonal().array().sqrt();
  VectorXd hTheta = ttpdf(a, b, df + (J - 1), mu, stdevs, draws)
                        .rowwise()
                        .prod()
                        .array()
                        .log();
  VectorXd likelihood =
      lrLikelihood(draws.rightCols(J - 1), draws.col(0), y, X).array() +
      loginvgammapdf(draws.col(0), a0 , d0 ).array() +
      logmvnpdfV(b0, B0, draws.rightCols(J - 1)).array() - hTheta.array();
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

VectorXd Importance::logtLike(double df, const Ref<const VectorXd> &mu,
                              const VectorXd &sigmaSqd, MatrixXd X) {
  int N = X.rows();
  double halfDfP1 = (df + 1) * .5;
  double NhalfDfP1 = N * halfDfP1;
  VectorXd logGammaAndConstantTerms =
      lgamma(halfDfP1) - lgamma(df * .5) -
      ((.5 * N) * (M_PI * df) * sigmaSqd.array().log());
  X.rowwise() -= mu.transpose();
  return logGammaAndConstantTerms.array() -
         NhalfDfP1 * (1 + pow(df,-1)*X.array().pow(2).rowwise().sum());
}

VectorXd Importance::logmvtpdf(double df, const Ref<const VectorXd> &mu,
                               const MatrixXd &Sigma, MatrixXd X) {
  /* Checked against matlab with 0 mean, verified goes to N with df-> inf */
  int N = X.rows();
  int J = Sigma.cols();
  double detSigma = Sigma.determinant();
  double halfDfPp = (df + J) * .5;
  double logGammaAndConstantTerms = lgamma(halfDfPp) - lgamma(df * .5) -
                                    ((.5 * J) * log(M_PI * df)) -
                                    (.5 * log(detSigma));
  X.rowwise() -= mu.transpose();
  VectorXd Q =
      pow(df, -1) * ((X * Sigma.inverse()).array() * X.array()).rowwise().sum();
  return logGammaAndConstantTerms - halfDfPp * (1 + Q.array()).log();
}

void Importance::runSim(int nSims, int batches, VectorXd &theta,
                        MatrixXd &sigma, VectorXd &y, MatrixXd &X, VectorXd &ll,
                        VectorXd &ul, int sampleSize, int burnin, VectorXd &b0,
                        MatrixXd &S0, double a0, double d0) {
  int J = sigma.cols();
  int Jminus1 = J - 1;
  VectorXd mLike(nSims);
  for (int i = 0; i < nSims; i++) {
    mLike(i) = importanceSampling(ll, ul, theta, sigma, y, X, sampleSize,
                                  b0, S0, a0, d0);
    if (isnan(mLike(i)) == 1) {
      break;
    }
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

void Importance::runSimNew(int nSims, int batches, const VectorXd &theta,
                           const MatrixXd &sigma, const VectorXd &y,
                           const MatrixXd &X, const VectorXd &ll,
                           const VectorXd &ul,
                           const MatrixXd &LinearConstraints, int sampleSize,
                           int burnin, const VectorXd &b0, const MatrixXd &S0,
                           double a0, double d0) {
  int J = sigma.cols();
  int Jminus1 = J - 1;
  VectorXd mLike(nSims);
  VectorXd b(Jminus1);
  for (int i = 0; i < nSims; i++) {
    mLike(i) = mlGeweke91(ll, ul, LinearConstraints, theta, sigma, y, X,
                          sampleSize, burnin, b0, S0, a0, d0);
    if (isnan(mLike(i)) == 1) {
      break;
    }
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

void Importance::runTsim(int nSims, int batches, const VectorXd &theta,
                         const MatrixXd &sigma, const VectorXd &y,
                         const MatrixXd &X, const VectorXd &ll,
                         const VectorXd &ul, const MatrixXd &LinearConstraints,
                         double df, int sampleSize, const VectorXd &b0,
                         const MatrixXd &S0, double a0, double d0) {
  int J = sigma.cols();
  int Jminus1 = J - 1;
  VectorXd mLike(nSims);
  for (int i = 0; i < nSims; i++) {
    mLike(i) = trunctprop(ll, ul, LinearConstraints, theta, sigma, df, y, X,
                   sampleSize, b0, S0, a0, d0);
    if (isnan(mLike(i)) == 1) {
      break;
    }
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

void Importance::runTsimNew(int nSims, int batches, const VectorXd &theta,
                            const MatrixXd &sigma, const VectorXd &y,
                            const MatrixXd &X, const VectorXd &ll,
                            const VectorXd &ul,
                            const MatrixXd &LinearConstraints, double df,
                            int sampleSize, int burnin, const VectorXd &b0,
                            const MatrixXd &S0, double a0, double d0) {
  int J = sigma.cols();
  int Jminus1 = J - 1;
  VectorXd mLike(nSims);
  for (int i = 0; i < nSims; i++) {
    mLike(i) = mlGeweke91T(ll, ul, LinearConstraints, theta, sigma, df, y, X,
                           sampleSize, burnin, b0, S0, a0, d0);
    if (isnan(mLike(i)) == 1) {
      break;
    }
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

