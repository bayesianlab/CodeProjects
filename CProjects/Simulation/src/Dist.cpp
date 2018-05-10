#include "Dist.hpp"
#include <Eigen/Dense>
#include <assert.h>
#include <boost/math/distributions/chi_squared.hpp>
#include <boost/math/distributions/exponential.hpp>
#include <boost/math/distributions/logistic.hpp>
#include <boost/math/distributions/normal.hpp>
#include <boost/math/distributions/students_t.hpp>
#include <boost/random/gamma_distribution.hpp>
#include <boost/random/mersenne_twister.hpp>
#include <boost/random/normal_distribution.hpp>
#include <boost/random/uniform_01.hpp>
#include <boost/random/variate_generator.hpp>
#include <cstdint>
#include <ctime>
#include <limits>
#include <math.h>
#include <random>
#include <unsupported/Eigen/KroneckerProduct>

using namespace Eigen;
using namespace std;

#define LOG_E_2 0.693147180559945309417232121458
#define LOG_PI 1.14472988584940017414342735135305871165
#define LOG_E_2_PI                                                             \
  0.693147180559945309417232121458 + 1.14472988584940017414342735135305871165

Dist::Dist() {
  now = time(0);
  rseed.seed(static_cast<uint32_t>(now));
  inf = numeric_limits<double>::max();
  ROBERT_LIMIT = 5000000;
}

Dist::Dist(int x) {
  now = time(0);
  rseed.seed(x);
  inf = numeric_limits<double>::max();
  ROBERT_LIMIT = 5000000;
}

void Dist::igammarnd(double shape, double scale, VectorXd &igamma) {
  boost::random::gamma_distribution<> gammavars(shape, scale);
  int rows = igamma.rows();
  for (int i = 0; i < rows; i++) {
    igamma(i) = 1.0 / gammavars(rseed);
  }
}

VectorXd Dist::gammarnd(double shape, double scale, int N) {
  VectorXd ig(N);
  boost::random::gamma_distribution<> g(shape, scale);
  boost::variate_generator<boost::mt19937 &, boost::gamma_distribution<>>
      genvars(rseed, g);
  for (int i = 0; i < N; i++) {
    ig(i) = genvars();
  }
  return ig;
}

VectorXd Dist::igammarnd(double shape, double scale, int N) {
  VectorXd g = gammarnd(shape, scale, N);
  return 1. / g.array();
}

double Dist::linearRegLikelihood(const VectorXd &y, const MatrixXd &X,
                                 const Ref<const MatrixXd> &beta,
                                 double sigma2) {
  int N = y.size();
  return pow(2. * M_PI * sigma2, -N * .5) *
         exp(-pow(2. * sigma2, -1) * (y - (X * beta)).array().pow(2).sum());
}

double Dist::igammapdf(double shape, double scale, double y) {
  return pow(pow(scale, shape) * tgamma(shape), -1) * pow(y, -(shape + 1)) *
         exp(-pow(scale * y, -1));
}

double Dist::igammarnd(double shape, double scale) {
  /*
(1/theta^k gamma(k)) x^(k-1) e^(-x/theta) is the gamma
   parameterization
*/
  boost::random::gamma_distribution<> gammavars(shape, scale);
  return 1.0 / gammavars(rseed);
}

double Dist::normrnd(double mu, double sig) {
  boost::random::normal_distribution<> normalDist(mu, sig);
  return normalDist(rseed);
}

VectorXd Dist::normrnd(double mu, double sig, int N) {
  boost::random::normal_distribution<> normalDist(mu, sig);
  VectorXd Z(N);
  boost::variate_generator<boost::mt19937 &, boost::normal_distribution<>>
      gennorm(rseed, normalDist);
  for (int i = 0; i < N; i++) {
    Z(i) = gennorm();
  }
  return Z;
}

MatrixXd Dist::normrnd(double mu, double sig, int N, int J) {
  MatrixXd Z(N, J);
  for (int j = 0; j < J; j++) {
    Z.col(j) = normrnd(mu, sig, N);
  }
  return Z;
}

MatrixXd Dist::mvnrnd(const VectorXd &mu, const MatrixXd &sig, int N) {
  int J = sig.cols();
  MatrixXd Z = normrnd(0., 1., N, J);
  LLT<MatrixXd> lltOfA(sig);
  MatrixXd L = lltOfA.matrixL();
  Z = (L * Z.transpose()).transpose();
  Z.rowwise() += mu.transpose();
  return Z;
}

MatrixXd Dist::mvnrnd2(VectorXd &mu, const Ref<const MatrixXd> &sig, int N,
                       int J) {
  MatrixXd Z = normrnd(0., 1., N, J);
  LLT<MatrixXd> lltOfA(sig);
  MatrixXd L = lltOfA.matrixL();
  Z = (L * Z.transpose()).transpose();
  Z.rowwise() += mu.transpose();
  return Z;
}

void Dist::unifrnd(double a, double b, VectorXd &unifVector) {
  boost::random::uniform_01<> u;
  double diff = b - a;
  for (int i = 0; i < unifVector.size(); i++) {
    unifVector(i) = a + u(rseed) * diff;
  }
}

double Dist::tnormrnd(double a, double b, double mu, double sigma) {
  // Still used in truncNormalRnd, KEEP
  double alpha = (a - mu) / sigma;
  double beta = (b - mu) / sigma;
  double Fa = cdf(normalDistribution, alpha);
  double Fb = cdf(normalDistribution, beta);
  double q = Fa + u(rseed) * (Fb - Fa);
  return mu + (sigma * quantile(normalDistribution, q));
}

double Dist::shiftexprnd(double alpha, double shift) {
  boost::random::uniform_01<> u;
  return shift - log(1. - u(rseed)) / alpha;
}

double Dist::shiftexppdf(double alpha, double shift, double z) {
  return alpha * exp(-alpha * (z - shift));
}

double Dist::leftTruncation(double a) {
  int maxIterations = 0;
  boost::random::uniform_01<> u;
  double optimalScale, lrho_z, z, lu;
  optimalScale = (a + sqrt(pow(a, 2) + 4.)) * .5;
  while (maxIterations < ROBERT_LIMIT) {
    z = shiftexprnd(optimalScale, a);
    lu = log(u(rseed));
    lrho_z = -pow(z - optimalScale, 2) * .5;
    if (lu <= lrho_z) {
      return z;
    } else {
      maxIterations++;
    }
  }
  cout
      << "Error leftTruncation: maxIterations exceeded, no truncation possible."
      << endl;
  return inf;
}

double Dist::twoSided(double a, double b) {
  int maxIterations = 0;
  boost::random::uniform_01<> z;
  boost::random::uniform_01<> u;
  double zdouble, rho_z;
  while (maxIterations < ROBERT_LIMIT) {
    zdouble = a + (z(rseed) * (b - a));
    double U = log(u(rseed));
    if (a <= 0 && 0 <= b) {
      rho_z = -.5 * pow(zdouble, 2);
      if (U < rho_z) {
        return zdouble;
      } else {
        maxIterations++;
      }
    } else if (b < 0) {
      rho_z = (pow(b, 2) - pow(zdouble, 2)) * .5;
      if (U < rho_z) {
        return zdouble;
      } else {
        maxIterations++;
      }
    } else {
      rho_z = (pow(a, 2) - pow(zdouble, 2)) * .5;
      if (U < rho_z) {
        return zdouble;
      } else {
        maxIterations++;
      }
    }
  }
  cout << "Error in twoSided: maxIterations exceeded" << endl;
  return -inf;
}

double Dist::truncNormalRnd(double a, double b, double mu, double sigma) {
  double Z, standardizedA, standardizedB, stdLimit;
  standardizedA = (a - mu) / sigma;
  standardizedB = (b - mu) / sigma;
  stdLimit = 5;
  if (mu > a && mu < b) {
    return tnormrnd(a, b, mu, sigma);
  } else {
    if (b >= 1e6) {
      if (standardizedA > stdLimit) {
        Z = leftTruncation(standardizedA);
        return mu + sigma * Z;
      } else {
        return tnormrnd(a, b, mu, sigma);
      }
    } else if (a <= -1e6) {
      if (standardizedB < -stdLimit) {
        Z = -leftTruncation(-standardizedB);
        return mu + sigma * Z;
      } else {
        return tnormrnd(a, b, mu, sigma);
      }
    } else {
      if (standardizedA > stdLimit) {
        Z = twoSided(standardizedA, standardizedB);
        return mu + sigma * Z;
      } else if (standardizedB < -stdLimit) {
        Z = twoSided(standardizedA, standardizedB);
        return mu + sigma * Z;
      } else {
        return tnormrnd(a, b, mu, sigma);
      }
    }
  }
}

void Dist::tmvnrand(VectorXd &a, VectorXd &b, VectorXd &mu, MatrixXd &sigma,
                    MatrixXd &sample, VectorXd &sigmaVect) {
  if (sample.cols() != 2 * mu.size()) {
    cout << "Error: Sample size needs to be 2x size of mu" << endl;
  } else {
    int J = sigma.cols();
    int Jminus1 = J - 1;
    int nSims = sample.rows();
    MatrixXd precision = sigma.inverse();
    VectorXd Hxx = precision.diagonal();
    VectorXd Hxy(Jminus1);
    VectorXd xNotJ(Jminus1);
    VectorXd muNotJ(Jminus1);
    sigmaVect = (1. / Hxx.array()).sqrt();
    for (int sim = 1; sim < nSims; sim++) {
      for (int j = 0; j < J; j++) {
        Hxy << precision.row(j).head(j).transpose().eval(),
            precision.row(j).tail(Jminus1 - j).transpose().eval();
        muNotJ << mu.head(j), mu.tail(Jminus1 - j);
        xNotJ << sample.row(sim - 1).head(j).transpose().eval(),
            sample.row(sim - 1).segment(j + 1, Jminus1 - j).transpose().eval();
        sample(sim, j + J) = conditionalMean(Hxx(j), Hxy, muNotJ, xNotJ, mu(j));
        sample(sim, j) =
            truncNormalRnd(a(j), b(j), sample(sim, j + J), sigmaVect(j));
      }
    }
  }
}

MatrixXd Dist::tmultnorm(const VectorXd &a, const VectorXd &b,
                         const VectorXd &mu, const MatrixXd &sigma, int nSims) {
  int J = sigma.cols();
  int Jminus1 = J - 1;
  MatrixXd sample = MatrixXd::Zero(nSims, 2 * J);
  MatrixXd precision = sigma.inverse();
  VectorXd Hxx = precision.diagonal();
  VectorXd Hxy(Jminus1);
  VectorXd xNotJ(Jminus1);
  VectorXd muNotJ(Jminus1);
  VectorXd sigmaVect(J);
  sigmaVect = (1. / Hxx.array()).sqrt();
  MatrixXd notjMat = selectorMat(J);
  VectorXd updateVec(J);
  updateVec.setZero();
  for (int sim = 0; sim < nSims; sim++) {
    for (int j = 0; j < J; j++) {
      Hxy = notjMat.block(j * (Jminus1), 0, Jminus1, J) *
            precision.row(j).transpose();
      muNotJ = notjMat.block(j * (Jminus1), 0, Jminus1, J) * mu;
      xNotJ = notjMat.block(j * (Jminus1), 0, Jminus1, J) * updateVec;
      sample(sim, j + J) = conditionalMean(Hxx(j), Hxy, muNotJ, xNotJ, mu(j));
      updateVec(j) =
          truncNormalRnd(a(j), b(j), sample(sim, j + J), sigmaVect(j));
    }
    sample.row(sim).head(J) = updateVec.transpose();
  }
  return sample;
}

MatrixXd Dist::tmultnorm(const VectorXd &a, const VectorXd &b,
                         const Ref<const MatrixXd> &lastBeta,
                         const VectorXd &mu, const MatrixXd &sigma,
                         const int nSims) {
  /*
   * Uses both inversion and ar sampling
   */
  int J = sigma.cols();
  int Jminus1 = J - 1;
  MatrixXd sample = MatrixXd::Zero(nSims, 2 * J);
  sample.row(0).head(J) = lastBeta;
  MatrixXd precision = sigma.inverse();
  VectorXd Hxx = precision.diagonal();
  VectorXd Hxy(Jminus1);
  VectorXd xNotJ(Jminus1);
  VectorXd muNotJ(Jminus1);
  VectorXd sigmaVect(J);
  sigmaVect = (1. / Hxx.array()).sqrt();
  MatrixXd notjMat = selectorMat(J);
  for (int sim = 1; sim < nSims; sim++) {
    for (int j = 0; j < J; j++) {
      Hxy = notjMat.block(j * (Jminus1), 0, Jminus1, J) *
            precision.row(j).transpose();
      muNotJ = notjMat.block(j * (Jminus1), 0, Jminus1, J) * mu;
      xNotJ = notjMat.block(j * (Jminus1), 0, Jminus1, J) *
              sample.row(j).head(J).transpose();
      sample(sim, j + J) = conditionalMean(Hxx(j), Hxy, muNotJ, xNotJ, mu(j));
      sample(sim, j) =
          truncNormalRnd(a(j), b(j), sample(sim, j + J), sigmaVect(j));
    }
  }
  return sample;
}

double Dist::tnormpdf(double a, double b, double mu, double sigma, double x) {
  double sigmaZ = sigma * (cdf(normalDistribution, (b - mu) / sigma) -
                           cdf(normalDistribution, (a - mu) / sigma));
  return pdf(normalDistribution, (x - mu) / sigma) / sigmaZ;
}

double Dist::ttpdf(double a, double b, double df, double mu, double sigma,
                   double x) {
  boost::math::students_t tdist(df);
  double Ta, Tb, alpha, beta;
  alpha = (a - mu) / sigma;
  beta = (b - mu) / sigma;
  if ((a <= -inf * .5) & (abs(b) <= inf * .5)) {
    Ta = 0;
    Tb = cdf(tdist, beta);

  } else {
    Ta = cdf(tdist, alpha);
  }
  if ((b >= inf * .5) & (abs(a) <= inf * .5)) {
    Tb = 1;
    Ta = cdf(tdist, alpha);
  } else {
    Ta = cdf(tdist, alpha);
    Tb = cdf(tdist, beta);
  }
  return pow(sigma * (Tb - Ta), -1) * pdf(tdist, (x - mu) / sigma);
}

double Dist::mvtpdf(const VectorXd &x, const VectorXd &mu,
                    const MatrixXd &Variance, int df) {
  int J = Variance.cols();
  double numconst = tgamma((df + J) * .5);
  double denconst = pow(M_PI * df, J * .5) * tgamma(df * .5) *
                    pow(Variance.determinant(), .5);
  VectorXd xMmu = x - mu;
  double Mahalnobis = ((xMmu.transpose() * Variance.inverse()) * xMmu).value();
  double kernel = pow(1 + (pow(df, -1) * Mahalnobis), -.5 * (df + J));
  return numconst * pow(denconst, -1) * kernel;
}

VectorXd Dist::logmvtpdf(double df, const Ref<const VectorXd> &mu,
                         const MatrixXd &Sigma, MatrixXd X) {
  /* Checked against matlab with 0 mean, verified goes to N with df-> inf */
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

double Dist::mvtpdfHelp(const Ref<const VectorXd> &x, const VectorXd &mu,
                        const MatrixXd &Variance, int df) {
  int J = Variance.cols();
  double numconst = tgamma((df + J) * .5);
  double denconst = pow(M_PI * df, J * .5) * tgamma(df * .5) *
                    pow(Variance.determinant(), .5);
  VectorXd xMmu = x - mu;
  double Mahalnobis = ((xMmu.transpose() * Variance.inverse()) * xMmu).value();
  double kernel = pow(1 + (pow(df, -1) * Mahalnobis), -.5 * (df + J));
  return numconst * pow(denconst, -1) * kernel;
}

VectorXd Dist::mvtpdf(const MatrixXd &X, const VectorXd &mu,
                      const MatrixXd &Variance, int df) {
  VectorXd pdf(X.rows());
  for (int i = 0; i < X.rows(); i++) {
    pdf(i) = mvtpdfHelp(X.row(i), mu, Variance, df);
  }
  return pdf;
}

VectorXd Dist::ttpdf(double a, double b, double df, double mu, double sigma,
                     const Ref<const VectorXd> &x) {
  VectorXd pdfVals(x.size());
  for (int i = 0; i < x.size(); i++) {
    pdfVals(i) = ttpdf(a, b, df, mu, sigma, x(i));
  }
  return pdfVals;
}

VectorXd Dist::ttpdf(double a, double b, double df,
                     const Ref<const VectorXd> &mu, double sigma, double x) {
  VectorXd pdfVals(mu.size());
  for (int i = 0; i < mu.size(); i++) {
    pdfVals(i) = ttpdf(a, b, df, mu(i), sigma, x);
  }
  return pdfVals;
}

MatrixXd Dist::ttpdf(const VectorXd &a, const VectorXd &b, double df,
                     const VectorXd &mu, const VectorXd &sigmaSqd,
                     const MatrixXd &X) {
  /* Verified in matlab */
  MatrixXd fx(X.rows(), X.cols());
  for (int j = 0; j < sigmaSqd.size(); j++) {
    fx.col(j) = Dist::ttpdf(a(j), b(j), df, mu(j), sigmaSqd(j), X.col(j));
  }
  return fx;
}

VectorXd Dist::tnormpdfVect(double a, double b, double mu, double sigma,
                            VectorXd &x) {
  boost::math::normal normalDist;
  VectorXd fx(x.size());
  for (int i = 0; i < x.size(); i++) {
    fx(i) = Dist::tnormpdf(a, b, mu, sigma, x(i));
  }
  return fx;
}

MatrixXd Dist::tnormpdfMat(VectorXd &ll, VectorXd &ul, VectorXd &mu,
                           VectorXd &stDevs, MatrixXd &x) {
  MatrixXd fx(x.rows(), x.cols());
  VectorXd temp;
  for (int j = 0; j < stDevs.size(); j++) {
    temp = x.col(j);
    fx.col(j) = Dist::tnormpdfVect(ll(j), ul(j), mu(j), stDevs(j), temp);
  }
  return fx;
}

MatrixXd Dist::tnormpdfMat(const VectorXd &ll, const VectorXd &ul,
                           const VectorXd &mu, const VectorXd &stDevs,
                           const MatrixXd &x) {
  /* Const version */
  MatrixXd fx(x.rows(), x.cols());
  VectorXd temp;
  for (int j = 0; j < stDevs.size(); j++) {
    temp = x.col(j);
    fx.col(j) = Dist::tnormpdfVect(ll(j), ul(j), mu(j), stDevs(j), temp);
  }
  return fx;
}

MatrixXd Dist::ghkLinearConstraints(const VectorXd &a, const VectorXd &b,
                                    const VectorXd &mu, const MatrixXd &Sigma,
                                    int sims) {
  /*
   * Take into account multiple constraints
   * Should replace ghkLinearConstraints
   * THIS CODE DOES NOT IMPLEMENT LINEAR CONSTRAINTS!!!
   */

  int J = Sigma.cols();
  MatrixXd sample(sims, J);
  MatrixXd lowerC = Sigma.llt().matrixL();
  MatrixXd offDiagMat = lowerC;
  offDiagMat.diagonal() = VectorXd::Zero(J);
  double update, aj, bj;
  for (int sim = 0; sim < sims; sim++) {
    for (int j = 0; j < J; j++) {
      update = mu(j) + (offDiagMat.row(j) * sample.row(sim).transpose());
      aj = (a(j) - update) / lowerC(j, j);
      bj = (b(j) - update) / lowerC(j, j);
      sample(sim, j) = truncNormalRnd(aj, bj, 0, 1);
    }
  }
  sample = (lowerC * sample.transpose()).transpose();
  sample.rowwise() += mu.transpose();
  return sample;
}

MatrixXd Dist::ghkLinearConstraints(const VectorXd &a, const VectorXd &b,
                                    const VectorXd &mu, const MatrixXd &Sigma,
                                    int sims, VectorXd &logpdf) {
  /*
   * Take into account multiple constraints
   * Should replace ghkLinearConstraints
   * THIS CODE DOES NOT IMPLEMENT LINEAR CONSTRAINTS!!!
   */
  int J = Sigma.cols();
  MatrixXd sample(sims, J);
  MatrixXd lowerC = Sigma.llt().matrixL();
  MatrixXd offDiagMat = lowerC;
  VectorXd LjjInv = lowerC.diagonal().array().pow(-1);
  offDiagMat.diagonal() = VectorXd::Zero(J);
  double update, aj, bj;
  for (int sim = 0; sim < sims; sim++) {
    double p = 0;
    for (int j = 0; j < J; j++) {
      update = mu(j) + (offDiagMat.row(j) * sample.row(sim).transpose());
      aj = (a(j) - update) / lowerC(j, j);
      bj = (b(j) - update) / lowerC(j, j);
      sample(sim, j) = truncNormalRnd(aj, bj, 0, 1);
      p = p + log(LjjInv(j)) + log(tnormpdf(aj, bj, 0, 1, sample(sim, j)));
    }
    logpdf(sim) = p;
  }
  sample = (lowerC * sample.transpose()).transpose();
  sample.rowwise() += mu.transpose();
  return sample;
}

MatrixXd Dist::returnNormalizingConstants(const VectorXd &a, const VectorXd &b,
                                          const VectorXd &mu,
                                          const MatrixXd &Sigma, int sims,
                                          MatrixXd &normC) {
  /*
   * Take into account multiple constraints
   * Should replace ghkLinearConstraints
   * THIS CODE DOES NOT IMPLEMENT LINEAR CONSTRAINTS!!!
   */

  int J = Sigma.cols();
  MatrixXd sample(sims, J);
  MatrixXd lowerC = Sigma.llt().matrixL();
  MatrixXd offDiagMat = lowerC;
  offDiagMat.diagonal() = VectorXd::Zero(J);
  double update, aj, bj;
  for (int sim = 0; sim < sims; sim++) {
    for (int j = 0; j < J; j++) {
      update = mu(j) + (offDiagMat.row(j) * sample.row(sim).transpose());
      aj = (a(j) - update) / lowerC(j, j);
      bj = (b(j) - update) / lowerC(j, j);
      sample(sim, j) = truncNormalRnd(aj, bj, 0, 1);
      normC(sim, j) = cdf(normalDistribution, bj) - cdf(normalDistribution, aj);
    }
  }
  sample = (lowerC * sample.transpose()).transpose();
  sample.rowwise() += mu.transpose();
  return sample;
}

void Dist::runSim(int nSims, int batches, const VectorXd &a, const VectorXd &b,
                  const VectorXd &mu, const MatrixXd &Sigma, int sims) {
  int J = Sigma.cols();
  int Jminus1 = J - 1;
  VectorXd mLike(nSims);
  MatrixXd Sample(sims, J);
  MatrixXd normC(sims, J);
  for (int i = 0; i < nSims; i++) {
    Sample.setZero();
    returnNormalizingConstants(a, b, mu, Sigma, sims, normC);
    mLike(i) = pdfmean(normC.array().log().rowwise().sum());
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

MatrixXd Dist::ghkT(const VectorXd &a, const VectorXd &b,
                    const MatrixXd &LinearConstraints, const VectorXd &mu,
                    const MatrixXd &Sigma, double df, int sims) {
  /*
   * Take into account multiple constraints
   * Should replace ghkLinearConstraints
   */
  int J = Sigma.cols();
  MatrixXd sample(sims, J);
  MatrixXd T = LinearConstraints * Sigma * LinearConstraints.transpose();
  MatrixXd lowerC = T.llt().matrixL();
  MatrixXd offDiagMat = lowerC;
  offDiagMat.diagonal() = VectorXd::Zero(J);
  VectorXd alpha = a - (LinearConstraints * mu);
  VectorXd beta = b - (LinearConstraints * mu);
  double update, aj, bj;
  for (int sim = 0; sim < sims; sim++) {
    for (int j = 0; j < J; j++) {
      update = offDiagMat.row(j) * sample.row(sim).transpose();
      aj = (alpha(j) - update) / lowerC(j, j);
      bj = (beta(j) - update) / lowerC(j, j);
      sample(sim, j) = truncTrnd(aj, bj, 0, 1, df + j);
    }
  }
  sample =
      (LinearConstraints.inverse() * (lowerC * sample.transpose())).transpose();
  sample.rowwise() += mu.transpose();
  return sample;
}

MatrixXd Dist::ghkT(const VectorXd &a, const VectorXd &b,
                    const MatrixXd &LinearConstraints, const VectorXd &mu,
                    const MatrixXd &Sigma, double df, int sims,
                    VectorXd &logpdf) {
  /*
   * Take into account multiple constraints
   * Should replace ghkLinearConstraints
   */
  int J = Sigma.cols();
  MatrixXd sample(sims, J);
  MatrixXd T = LinearConstraints * Sigma * LinearConstraints.transpose();
  MatrixXd lowerC = T.llt().matrixL();
  MatrixXd offDiagMat = lowerC;
  VectorXd LjjInv = lowerC.diagonal().array().pow(-1);
  offDiagMat.diagonal() = VectorXd::Zero(J);
  VectorXd alpha = a - (LinearConstraints * mu);
  VectorXd beta = b - (LinearConstraints * mu);
  double update, aj, bj;
  for (int sim = 0; sim < sims; sim++) {
    double p = 0;
    for (int j = 0; j < J; j++) {
      update = offDiagMat.row(j) * sample.row(sim).transpose();
      aj = (alpha(j) - update) / lowerC(j, j);
      bj = (beta(j) - update) / lowerC(j, j);
      sample(sim, j) = truncTrnd(aj, bj, 0, 1, df + j);
      p = p + log(LjjInv(j)) + log(ttpdf(aj, bj, df + j, 0, 1, sample(sim, j)));
    }
    logpdf(sim) = p;
  }
  sample =
      (LinearConstraints.inverse() * (lowerC * sample.transpose())).transpose();
  sample.rowwise() += mu.transpose();
  return sample;
}

MatrixXd Dist::askGhkLinearConstraints(const VectorXd &a, const VectorXd &b,
                                       const VectorXd &mu,
                                       const MatrixXd &Sigma, int rows) {
  /*
   * Take into account multiple constraints
   */
  int J = Sigma.cols();
  MatrixXd sample(rows, J);
  if (a.size() != b.size()) {
    cout << "\nError: The number of constraints are not the same." << endl;
    sample = MatrixXd::Zero(1, 1);
    return sample;
  } else if (a.size() != J) {
    cout << "Error: At least as many constraints as dimension in Sigma are "
            "needed."
         << endl;
    sample = MatrixXd::Zero(1, 1);
    return sample;
  } else {
    int sims = sample.rows();
    MatrixXd lowerC = Sigma.llt().matrixL();
    MatrixXd offDiagMat = lowerC;
    offDiagMat.diagonal() = VectorXd::Zero(J);
    double update, aj, bj;
    VectorXd alpha = a - mu;
    VectorXd beta = b - mu;
    for (int sim = 0; sim < sims; sim++) {
      for (int j = 0; j < J; j++) {
        update = (offDiagMat.row(j) * sample.row(sim).transpose());
        aj = (alpha(j) - update) / lowerC(j, j);
        bj = (beta(j) - update) / lowerC(j, j);
        sample(sim, j) = truncNormalRnd(aj, bj, 0, 1);
      }
    }
    sample = (lowerC * sample.transpose()).transpose();
    sample.rowwise() += mu.transpose();
    return sample;
  }
}

MatrixXd Dist::asktmvnrand(const VectorXd &a, const VectorXd &b,
                           const VectorXd &mu, const MatrixXd &sigma,
                           const VectorXd &sigmaVect,
                           const VectorXd &initVector, int sims) {
  /*
   * Uses both inversion and ar sampling, Geweke 1991
   * Deleted calculation of sigma vector, unneeded and better implementation
   * elsewhere
   */
  int J = sigma.cols();
  int Jminus1 = J - 1;
  MatrixXd sample(sims, J);
  int nSims = sample.rows();
  MatrixXd precision = sigma.inverse();
  VectorXd Hxx = precision.diagonal();
  VectorXd Hxy(Jminus1);
  VectorXd xNotJ(Jminus1);
  VectorXd muNotJ(Jminus1);
  MatrixXd notjMat = selectorMat(J);
  double muj;
  VectorXd updateVec = initVector;
  for (int sim = 0; sim < nSims; sim++) {
    for (int j = 0; j < J; j++) {
      Hxy = notjMat.block(j * (Jminus1), 0, Jminus1, J) *
            precision.row(j).transpose();
      muNotJ = notjMat.block(j * (Jminus1), 0, Jminus1, J) * mu;
      xNotJ = notjMat.block(j * (Jminus1), 0, Jminus1, J) * updateVec;
      muj = conditionalMean(Hxx(j), Hxy, muNotJ, xNotJ, mu(j));
      updateVec(j) = truncNormalRnd(a(j), b(j), muj, sigmaVect(j));
    }
    sample.row(sim) = updateVec.transpose();
  }
  return sample;
}

double Dist::conditionalMean(double Hxx, VectorXd &Hxy, VectorXd &muNotJ,
                             VectorXd &xNotJ, double muxx) {
  return muxx - ((1. / Hxx) * Hxy.dot(xNotJ - muNotJ));
}

double Dist::conditionalMean(double Hxx, const Ref<const VectorXd> &Hxy,
                             const Ref<const VectorXd> &muNotJ,
                             const Ref<const VectorXd> &xNotJ, double muxx) {
  return muxx - (1. / Hxx) * Hxy.dot(xNotJ - muNotJ);
}

VectorXd Dist::conditionalMean(double Hxx, VectorXd &Hxy, VectorXd &muNotj,
                               MatrixXd xNotj, double muxx) {
  VectorXd cm;
  xNotj.rowwise() -= muNotj.transpose();
  cm = muxx - ((1. / Hxx) * xNotj * Hxy).array();
  return cm;
}

double Dist::mvnpdfPrecision(const Ref<const MatrixXd> &mu,
                             const MatrixXd &precision,
                             const Ref<const MatrixXd> &x) {
  int muRows = mu.rows();
  int xRows = x.rows();
  int xCols = x.cols();
  if (xRows != muRows) {
    cout << "Dimension of mu and x must be same: see mvnpdf in Dist" << endl;
    return -inf;
  } else if (xCols != 1) {
    cout << "Must be column vector: see mvnpdf in Dist" << endl;
    return -inf;
  } else {
    return pow(2 * M_PI, -muRows * 0.5) * pow(precision.determinant(), 0.5) *
           exp((-.5 * (((x - mu).transpose() * precision) * (x - mu))).value());
  }
}

double Dist::mvnpdf(const Ref<const MatrixXd> &mu, const MatrixXd &sigma,
                    const Ref<const MatrixXd> &x) {
  int muRows = mu.rows();
  int xRows = x.rows();
  int xCols = x.cols();
  if (xRows != muRows) {
    cout << "Dimension of mu and x must be same: see mvnpdf in Dist" << endl;
    return -inf;
  } else if (xCols != 1) {
    cout << "Must be column vector: see mvnpdf in Dist" << endl;
    return -inf;
  } else {
    return pow(2 * M_PI, -muRows * 0.5) * pow(sigma.determinant(), -0.5) *
           exp((-.5 * (((x - mu).transpose() * sigma.inverse()) * (x - mu)))
                   .value());
  }
}

double Dist::standardDev(VectorXd &v) {
  ArrayXd t(v.size());
  t = v.array() - v.mean();
  return sqrt(t.square().sum() / (v.size() - 1));
}

VectorXd Dist::lrLikelihood(MatrixXd &betas, VectorXd &sigmasqds, VectorXd &y,
                            MatrixXd &X) {
  int N = X.rows();
  if ((sigmasqds.array() < 0).any() == 1) {
    cout << "Error! lrLikelihood, sigma < 0" << endl;
    VectorXd x;
    return x;
  } else {
    VectorXd e(X.rows());
    ArrayXd normConst = -(N / 2) * (sigmasqds.array().log() + log(2 * M_PI));
    ArrayXd expNormalizingConst = (-2 * sigmasqds.array()).pow(-1);
    linreglike = VectorXd::Zero(betas.rows());
    for (int i = 0; i < betas.rows(); i++) {
      e = y - X * betas.row(i).transpose();
      double eTe = e.transpose() * e;
      linreglike(i) = normConst(i) + eTe * expNormalizingConst(i);
    }
    return linreglike;
  }
}

VectorXd Dist::lrLikelihood(const Ref<const MatrixXd> &betas,
                            const Ref<const VectorXd> &sigmasqds,
                            const VectorXd &y, const MatrixXd &X) {
  int N = X.rows();
  if ((sigmasqds.array() < 0).any() == 1) {
    cout << "Error! lrLikelihood, sigma < 0" << endl;
    VectorXd x;
    return x;
  } else {
    VectorXd e(X.rows());
    ArrayXd normConst = -(N / 2) * (sigmasqds.array().log() + log(2 * M_PI));
    ArrayXd expNormalizingConst = (-2 * sigmasqds.array()).pow(-1);
    linreglike = VectorXd::Zero(betas.rows());
    for (int i = 0; i < betas.rows(); i++) {
      e = y - X * betas.row(i).transpose();
      double eTe = e.transpose() * e;
      linreglike(i) = normConst(i) + eTe * expNormalizingConst(i);
    }
    return linreglike;
  }
}

double Dist::lrLikelihood(VectorXd &betas, double sigmasqd, VectorXd &y,
                          MatrixXd &X) {
  int N = X.rows();
  VectorXd e(N);
  double normConst = -(N / 2) * (log(sigmasqd) + log(2 * M_PI));
  double expNormalizingConst = pow(-2 * sigmasqd, -1);
  e = y - X * betas;
  double eTe = e.transpose() * e;
  return normConst + eTe * expNormalizingConst;
}

double Dist::lrLikelihood(const VectorXd &betas, double sigmasqd,
                          const VectorXd &y, const MatrixXd &X) {
  int N = X.rows();
  VectorXd e = y - (X * betas);
  double eTe = e.transpose() * e;
  double normConst = N * (log(2 * M_PI * sigmasqd));
  return -.5 * (normConst + (eTe * pow(sigmasqd, -1)));
}

VectorXd Dist::loginvgammapdf(const Ref<const VectorXd> &y, double alpha,
                              double beta) {
  double C1 = -(alpha * log(beta) + lgamma(alpha));
  VectorXd ligampdf = y.array().log();
  ligampdf *= -(alpha + 1);
  return ligampdf.array() - (y.array() * beta).pow(-1) + C1;
}

double Dist::loginvgammapdf(double y, double alpha, double beta) {
  double C1 = -(alpha * log(beta) + lgamma(alpha));
  double ligampdf = log(y);
  ligampdf = ligampdf * (-(alpha + 1));
  return ligampdf - pow(y * beta, -1) + C1;
}

int Dist::bernoulli(double p) {
  boost::random::uniform_01<> u;
  if (u(rseed) < p) {
    return 1;
  } else {
    return 0;
  }
}

double Dist::autoCorr(VectorXd &X) {
  int nRows = X.size();
  VectorXd Xt(nRows - 1);
  Xt = X.head(nRows - 1);
  VectorXd Xtm1(nRows - 1);
  Xtm1 = X.tail(nRows - 1);
  double muxt = Xt.mean();
  double muxtm1 = Xtm1.mean();
  double sigXt = standardDev(Xt);
  double sigXtm1 = standardDev(Xtm1);
  return ((Xt.array() - muxt) * (Xtm1.array() - muxtm1)).sum() /
         (nRows * sigXt * sigXtm1);
}

VectorXd Dist::logmvnpdfV(const VectorXd &mu, const MatrixXd &sigma,
                          MatrixXd x) {
  int J = sigma.cols();
  double C1 = (J * log(2 * M_PI)) + log(sigma.determinant());
  x.rowwise() -= mu.transpose();
  return -.5 *
         (C1 + ((x * sigma.inverse()).array() * x.array()).rowwise().sum());
}

double Dist::logmvnpdf(const VectorXd &mu, const MatrixXd &sigma,
                       const VectorXd &x) {
  int J = sigma.cols();
  double C1 = (J * log(2 * M_PI)) + log(sigma.determinant());
  return -.5 * (C1 + ((x - mu).transpose() * sigma.inverse()) * (x - mu));
}

double Dist::logmvnpdfVect(const VectorXd &mu, const MatrixXd &sigma,
                           const VectorXd &x) {
  int J = sigma.cols();
  double C1 = (J * log(2 * M_PI)) + log(sigma.determinant());
  return -.5 * (C1 + ((x - mu).transpose() * sigma.inverse()) * (x - mu));
}

double Dist::logmvnpdfPrecision(const VectorXd &mu, const MatrixXd &precision,
                                const Ref<const MatrixXd> &x) {
  int J = precision.cols();
  double C1 = log(precision.determinant()) - (J * log(2 * M_PI));
  return -.5 * ((((x - mu).transpose() * precision) * (x - mu)).value() - C1);
}

VectorXd Dist::generateChiSquaredVec(double df, int rows) {
  std::mt19937 gen(rd());
  std::chi_squared_distribution<double> csd(df);
  VectorXd chiSqs(rows);
  for (int i = 0; i < rows; i++) {
    chiSqs(i) = csd(gen);
  }
  return chiSqs;
}

MatrixXd Dist::generateChiSquaredMat(double df, int rows, int cols) {
  std::mt19937 gen(rd());
  std::chi_squared_distribution<double> csd(df);
  MatrixXd chiSqs(rows, cols);
  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols; j++) {
      chiSqs(i, j) = csd(gen);
    }
  }
  return chiSqs;
}

MatrixXd Dist::mvtrunctrnd(const VectorXd &mu, const MatrixXd &Sigma,
                           const double nu, const int N) {
  int J = Sigma.cols();
  double c;
  VectorXd chis = generateChiSquaredVec(nu, N);
  VectorXd z = MatrixXd::Zero(J, 1);
  MatrixXd Normals = mvnrnd(z, Sigma, N);
  MatrixXd samp(N, J);
  for (int i = 0; i < N; i++) {
    c = sqrt(chis(i) / nu);
    samp.row(i) = Normals.row(i).array() / c;
  }
  samp.rowwise() += mu.transpose();
  return samp;
}

VectorXd Dist::studenttrnd(const double mu, const double sigma, const double nu,
                           const int N, const int J) {
  VectorXd chis = (generateChiSquaredVec(nu, N).array() / nu).sqrt();
  MatrixXd Normals = normrnd(mu, sigma, N, J);
  MatrixXd samp(N, J);
  for (int i = 0; i < N; i++) {
    samp.row(i) = Normals.row(i).array() / chis(i);
  }
  return samp;
}

double Dist::truncTrnd(double a, double b, double mu, double sigma, double nu) {
  std::mt19937 gen(rd());
  std::chi_squared_distribution<double> csd(nu);
  double w = sqrt(csd(gen) / nu);
  double alpha, beta;
  alpha = (a - mu) / sigma;
  beta = (b - mu) / sigma;
  return mu + (sigma * truncNormalRnd(alpha * w, beta * w, 0, 1) / w);
}

MatrixXd Dist::MVTruncT(const VectorXd &a, const VectorXd &b,
                        const MatrixXd &LinearConstraints, const VectorXd &mu,
                        const MatrixXd &Sigma, const int df, const int sims,
                        const int burnin) {
  int J = Sigma.cols();
  double newChi;
  MatrixXd lowerC = (LinearConstraints * Sigma * LinearConstraints.transpose())
                        .llt()
                        .matrixL();
  VectorXd chiSqs = generateChiSquaredVec(df, sims);
  VectorXd alpha = a - (LinearConstraints * mu);
  VectorXd beta = b - (LinearConstraints * mu);
  MatrixXd sample(sims, J);
  sample.setZero();
  for (int i = 1; i < sims; i++) {
    newChi = sqrt(chiSqs(i - 1) / df);
    for (int j = 0; j < J; j++) {
      sample(i, j) =
          truncNormalRnd((alpha(j) * newChi), (beta(j) * newChi), 0, 1) /
          newChi;
    }
  }
  sample = (lowerC * sample.transpose()).transpose();
  sample.rowwise() += mu.transpose();
  return sample;
}

MatrixXd Dist::mvtruncT(const VectorXd &a, const VectorXd &b,
                        const MatrixXd &LinearConstraints, const VectorXd &mu,
                        const MatrixXd &Sigma, const int df, const int sims) {
  int J = Sigma.cols();
  double newChi;
  MatrixXd lowerC = (LinearConstraints * Sigma * LinearConstraints.transpose())
                        .llt()
                        .matrixL();
  VectorXd chiSqs = generateChiSquaredVec(df, sims);
  VectorXd alpha = a - (LinearConstraints * mu);
  VectorXd beta = b - (LinearConstraints * mu);
  MatrixXd sample(sims, J);
  sample.setZero();
  for (int i = 0; i < sims; i++) {
    for (int j = 0; j < J; j++) {
      newChi = sqrt(chiSqs(i) / df);
      sample(i, j) =
          truncNormalRnd((alpha(j) * newChi), (beta(j) * newChi), 0, 1) /
          newChi;
    }
  }
  sample = (lowerC * sample.transpose()).transpose();
  sample.rowwise() += mu.transpose();
  return sample;
}

MatrixXd Dist::SigmayyInverse(const MatrixXd &Sigma) {
  int J = Sigma.cols();
  int Jm1 = J - 1;
  MatrixXd selector = selectorMat(J);
  MatrixXd syy((Jm1)*J, Jm1);
  int c = 0;
  for (int j = 0; j < J; j++) {
    syy.middleRows(c, Jm1) =
        (selector.block(j * (Jm1), 0, Jm1, J) *
         (selector.block(j * (Jm1), 0, Jm1, J) * Sigma).transpose())
            .transpose()
            .inverse();
    c = c + Jm1;
  }
  return syy;
}

MatrixXd Dist::askMvttgeweke91(const VectorXd &a, const VectorXd &b,
                               const MatrixXd &LinearConstraints,
                               const VectorXd &mu, const MatrixXd &Sigma,
                               const double df, const int sims,
                               const int burnin, VectorXd &initVector) {

  int J = Sigma.cols();
  int Jm1 = J - 1;
  MatrixXd chiSqs = (generateChiSquaredVec(df, sims).array() / df).sqrt();
  MatrixXd T = LinearConstraints * Sigma * LinearConstraints.transpose();
  MatrixXd precisionT = T.inverse();
  VectorXd Hii = precisionT.diagonal();
  VectorXd hii = Hii.array().pow(-1).sqrt();
  MatrixXd notj = selectorMat(J);
  MatrixXd precisionNotj = precisionNotjMatrix(J, precisionT, Hii);
  MatrixXd sample(sims, J);
  sample.setZero();
  VectorXd alpha = a - LinearConstraints * mu;
  VectorXd beta = b - LinearConstraints * mu;
  double innerProduct;
  sample.row(0) = initVector.transpose();
  VectorXd updateVec(J);
  updateVec.setZero();
  for (int i = 1; i < sims; i++) {
    for (int j = 0; j < J; j++) {
      innerProduct = (precisionNotj.row(j) *
                      (notj.block(j * (Jm1), 0, Jm1, J) * updateVec))
                         .value();
      updateVec(j) =
          innerProduct +
          hii(j) *
              truncNormalRnd(((alpha(j) - innerProduct) * chiSqs(i)) / hii(j),
                             ((beta(j) - innerProduct) * chiSqs(i)) / hii(j), 0,
                             1) /
              chiSqs(i);
    }
    sample.row(i) = updateVec.transpose();
  }
  sample = (LinearConstraints.inverse() * sample.transpose()).transpose();
  sample.rowwise() += mu.transpose();
  return sample.bottomRows(sims - burnin);
}

MatrixXd Dist::mvttgeweke91(const VectorXd &a, const VectorXd &b,
                            const MatrixXd &LinearConstraints,
                            const VectorXd &mu, const MatrixXd &Sigma,
                            const double df, const int sims, const int burnin) {

  int J = Sigma.cols();
  int Jm1 = J - 1;
  double conditionalDf = df + Jm1;
  double as, bs;
  MatrixXd chiSqs =
      (generateChiSquaredVec(conditionalDf, sims).array() / conditionalDf)
          .sqrt();
  MatrixXd T = LinearConstraints * Sigma * LinearConstraints.transpose();
  MatrixXd precisionT = T.inverse();
  VectorXd Hii = precisionT.diagonal();
  VectorXd hii = Hii.array().pow(-1).sqrt();
  MatrixXd notjMat = selectorMat(J);
  MatrixXd sample(sims, J);
  MatrixXd cmeans(sims, J);
  VectorXd xNotJ(Jm1);
  VectorXd muNotJ(Jm1);
  VectorXd m = LinearConstraints * mu;
  sample.setZero();
  VectorXd updateVec(J);
  updateVec.setZero();
  MatrixXd Hxy = Hnotj(precisionT);
  for (int i = 0; i < sims; i++) {
    for (int j = 0; j < J; j++) {
      muNotJ = notjMat.block(j * (Jm1), 0, Jm1, J) * m;
      xNotJ = notjMat.block(j * (Jm1), 0, Jm1, J) * updateVec;
      cmeans(i, j) =
          conditionalMean(Hii(j), Hxy.row(j).transpose(), muNotJ, xNotJ, m(j));
      as = (a(j) - cmeans(i, j)) * chiSqs(i) / hii(j);
      bs = (b(j) - cmeans(i, j)) * chiSqs(i) / hii(j);
      updateVec(j) =
          cmeans(i, j) + (hii(j) * truncNormalRnd(as, bs, 0, 1) / chiSqs(i));
    }
    sample.row(i) = updateVec.transpose();
  }
  sample = (LinearConstraints.inverse() * sample.transpose()).transpose();
  MatrixXd SampleAndMeans(sims - burnin, 2 * J);
  SampleAndMeans << sample.bottomRows(sims - burnin),
      cmeans.bottomRows(sims - burnin);
  return SampleAndMeans;
}

MatrixXd Dist::mvtstudtrnd(const VectorXd &a, const VectorXd &b,
                           const MatrixXd &LinearConstraints,
                           const VectorXd &mu, const MatrixXd &Sigma,
                           const double df, const int sims, const int burnin) {

  int J = Sigma.cols();
  int Jm1 = J - 1;
  double conditionalDf = df + Jm1;
  double as, bs, cmean;
  MatrixXd chiSqs =
      (generateChiSquaredVec(conditionalDf, sims).array() / conditionalDf)
          .sqrt();
  MatrixXd T = LinearConstraints * Sigma * LinearConstraints.transpose();
  MatrixXd precisionT = T.inverse();
  VectorXd Hii = precisionT.diagonal();
  VectorXd hii = Hii.array().pow(-1).sqrt();
  MatrixXd notjMat = selectorMat(J);
  MatrixXd sample(sims, J);
  VectorXd xNotJ(Jm1);
  VectorXd muNotJ(Jm1);
  VectorXd m = LinearConstraints * mu;
  sample.setZero();
  VectorXd updateVec(J);
  updateVec.setZero();
  MatrixXd Hxy = Hnotj(precisionT);
  for (int i = 0; i < sims; i++) {
    for (int j = 0; j < J; j++) {
      muNotJ = notjMat.block(j * (Jm1), 0, Jm1, J) * m;
      xNotJ = notjMat.block(j * (Jm1), 0, Jm1, J) * updateVec;
      cmean =
          conditionalMean(Hii(j), Hxy.row(j).transpose(), muNotJ, xNotJ, m(j));
      as = (a(j) - cmean) * chiSqs(i) / hii(j);
      bs = (b(j) - cmean) * chiSqs(i) / hii(j);
      updateVec(j) =
          cmean + (hii(j) * truncNormalRnd(as, bs, 0, 1) / chiSqs(i));
    }
    sample.row(i) = updateVec.transpose();
  }
  sample = (LinearConstraints.inverse() * sample.transpose()).transpose();
  return sample.bottomRows(sims - burnin);
}

MatrixXd Dist::mvtstudtrnd(const VectorXd &a, const VectorXd &b,
                           const MatrixXd &LinearConstraints,
                           const VectorXd &mu, const MatrixXd &Sigma,
                           const double df, const int sims, const int burnin,
                           VectorXd &init) {

  int J = Sigma.cols();
  int Jm1 = J - 1;
  double conditionalDf = df + Jm1;
  double as, bs, cmean;
  MatrixXd chiSqs =
      (generateChiSquaredVec(conditionalDf, sims).array() / conditionalDf)
          .sqrt();
  MatrixXd T = LinearConstraints * Sigma * LinearConstraints.transpose();
  MatrixXd precisionT = T.inverse();
  VectorXd Hii = precisionT.diagonal();
  VectorXd hii = Hii.array().pow(-1).sqrt();
  MatrixXd notjMat = selectorMat(J);
  MatrixXd sample(sims, J);
  VectorXd xNotJ(Jm1);
  VectorXd muNotJ(Jm1);
  VectorXd m = LinearConstraints * mu;
  sample.setZero();
  VectorXd updateVec = init;
  updateVec.setZero();
  MatrixXd Hxy = Hnotj(precisionT);
  for (int i = 0; i < sims; i++) {
    for (int j = 0; j < J; j++) {
      muNotJ = notjMat.block(j * (Jm1), 0, Jm1, J) * m;
      xNotJ = notjMat.block(j * (Jm1), 0, Jm1, J) * updateVec;
      cmean =
          conditionalMean(Hii(j), Hxy.row(j).transpose(), muNotJ, xNotJ, m(j));
      as = (a(j) - cmean) * chiSqs(i) / hii(j);
      bs = (b(j) - cmean) * chiSqs(i) / hii(j);
      updateVec(j) =
          cmean + (hii(j) * truncNormalRnd(as, bs, 0, 1) / chiSqs(i));
    }
    sample.row(i) = updateVec.transpose();
  }
  sample = (LinearConstraints.inverse() * sample.transpose()).transpose();
  return sample.bottomRows(sims - burnin);
}

MatrixXd Dist::Hnotj(const MatrixXd &precision) {
  int J = precision.cols();
  int Jm1 = J - 1;
  MatrixXd sm = selectorMat(J);
  MatrixXd smReturn(J, Jm1);
  smReturn.setZero();
  for (int j = 0; j < J; j++) {
    smReturn.row(j) =
        ((sm.block(j * (Jm1), 0, Jm1, J) * precision.row(j).transpose()))
            .transpose();
  }
  return smReturn;
}

MatrixXd Dist::selectorMat(int J) {
  int Jm1 = J - 1;
  MatrixXd I = MatrixXd::Identity(J, J);
  MatrixXd selectors = MatrixXd::Zero(J * (Jm1), J);
  for (int j = 0; j < J; j++) {
    if (j == 0) {
      selectors.topRows(J - 1) = I.bottomRows(Jm1);
    } else if (j > 0 & j < Jm1) {
      selectors.middleRows(j * (Jm1), Jm1) << I.topRows(j),
          I.bottomRows((Jm1)-j);
    } else {
      selectors.bottomRows(Jm1) = I.topRows(Jm1);
    }
  }
  return selectors;
}

MatrixXd Dist::precisionNotjMatrix(int J, const MatrixXd &precision,
                                   const VectorXd &Hii) {
  MatrixXd sm = selectorMat(J);
  int Jm1 = J - 1;
  MatrixXd smReturn(J, Jm1);
  smReturn.setZero();
  for (int j = 0; j < J; j++) {
    smReturn.row(j) = (-pow(Hii(j), -1) * (sm.block(j * (Jm1), 0, Jm1, J) *
                                           precision.row(j).transpose()))
                          .transpose();
  }
  return smReturn;
}

void Dist::cleanP(MatrixXd &P) {
  int R = P.cols();
  for (int i = 0; i < R; i++) {
    for (int j = 0; j < R; j++) {
      if (i != j) {
        if (P(i, j) < 1e-8) {
          P(i, j) = 0.;
        }
      }
    }
  }
}

MatrixXd Dist::geweke91(const VectorXd &a, const VectorXd &b,
                        const MatrixXd &LinearConstraints,
                        const Ref<const VectorXd> &mu,
                        const Ref<const MatrixXd> &sigma, int sims,
                        int burnin) {
  /* Trunc. MVNormal according to Geweke 1991 */
  int J = sigma.cols();
  int Jm1 = J - 1;
  MatrixXd T = LinearConstraints * sigma * LinearConstraints.transpose();
  MatrixXd precisionT = T.inverse();
  VectorXd Hii = precisionT.diagonal();
  VectorXd hii = Hii.array().pow(-1).sqrt();
  MatrixXd notj = selectorMat(J);
  MatrixXd precisionNotj = precisionNotjMatrix(J, precisionT, Hii);
  MatrixXd sample(sims, J);
  sample.setZero();
  VectorXd alpha = a - (LinearConstraints * mu);
  VectorXd beta = b - (LinearConstraints * mu);
  VectorXd updateVec(J);
  updateVec.setZero();
  double innerProduct;
  for (int i = 1; i < sims; i++) {
    for (int j = 0; j < J; j++) {
      innerProduct = (precisionNotj.row(j) *
                      (notj.block(j * (Jm1), 0, Jm1, J) * updateVec))
                         .value();
      updateVec(j) =
          innerProduct +
          (hii(j) * truncNormalRnd((alpha(j) - innerProduct) / hii(j),
                                   (beta(j) - innerProduct) / hii(j), 0, 1));
    }
    sample.row(i) = updateVec.transpose();
  }
  sample = (LinearConstraints.inverse() * sample.transpose()).transpose();
  sample.rowwise() += mu.transpose();
  return sample.bottomRows(sims - burnin);
}

MatrixXd Dist::gibbsKernel(const VectorXd &a, const VectorXd &b,
                           const VectorXd &mu, const MatrixXd &Sigma,
                           const MatrixXd &Sample, const VectorXd &zStar) {
  VectorXd cmeanVect(Sample.rows());
  int J = Sigma.cols();
  int Jm1 = J - 1;
  MatrixXd precision = Sigma.inverse();
  VectorXd Hxx = precision.diagonal();
  VectorXd sigmaVector = Hxx.array().pow(-1).sqrt();
  VectorXd Hxy = precision.row(0).tail(Jm1);
  VectorXd muNotj = mu.tail(Jm1);
  MatrixXd Kernel = MatrixXd::Zero(Sample.rows(), J);
  MatrixXd xNotj = Sample.rightCols(Jm1);
  Kernel.col(0) = Dist::tnormpdfMeanVect(
      a(0), b(0), Dist::conditionalMean(Hxx(0), Hxy, muNotj, xNotj, mu(0)),
      sigmaVector(0), zStar(0));
  xNotj.rightCols(Jm1 - 1) = Sample.rightCols(Jm1 - 1);
  MatrixXd notjMat = selectorMat(J);
  for (int j = 1; j < Jm1; j++) {
    muNotj = notjMat.block(j * (Jm1), 0, Jm1, J) * mu;
    Hxy = notjMat.block(j * (Jm1), 0, Jm1, J) * precision.row(j).transpose();
    xNotj.col(j - 1).fill(zStar(j - 1));
    Kernel.col(j) = Dist::tnormpdfMeanVect(
        a(j), b(j), Dist::conditionalMean(Hxx(j), Hxy, muNotj, xNotj, mu(j)),
        sigmaVector(j), zStar(j));
  }
  Hxy = precision.row(Jm1).head(Jm1).transpose();
  muNotj = mu.head(Jm1);
  VectorXd xnotJ = zStar.head(Jm1);
  double muJ = Dist::conditionalMean(Hxx(Jm1), Hxy, muNotj, xnotJ, mu(Jm1));
  double y = Dist::tnormpdf(a(Jm1), b(Jm1), muJ, sigmaVector(Jm1), zStar(Jm1));
  Kernel.col(Jm1).fill(y);
  return Kernel;
}

double Dist::pdfavg(const Ref<const VectorXd> &logpdf) {
  double maxval = logpdf.maxCoeff();
  return log(exp(logpdf.array() - maxval).mean()) + maxval;
}

double Dist::pdfmean(const Ref<const VectorXd> &logpdf) {
  double maxval = logpdf.maxCoeff();
  int N = logpdf.size();
  return -log(N) + maxval + log(exp(logpdf.array() - maxval).sum());
}

MatrixXd Dist::gibbsTKernel(const VectorXd &a, const VectorXd &b,
                            const MatrixXd &LinearConstraints,
                            const MatrixXd &sample, VectorXd &zstar,
                            const double df, const VectorXd &mu,
                            const MatrixXd &Sigma, const VectorXd &y,
                            const MatrixXd &X, const int sims,
                            const int burnin) {
  int J = Sigma.cols();
  int Jm1 = J - 1;
  int Rows = sims - burnin;
  MatrixXd xnoti = MatrixXd::Zero(Rows, Jm1);
  xnoti.rightCols(Jm1 - 1) = sample.middleCols(2, J - 2);
  MatrixXd precision =
      (LinearConstraints * Sigma * LinearConstraints.transpose()).inverse();
  VectorXd Hii = precision.diagonal();
  VectorXd sigVect = (1. / Hii.array()).sqrt();
  MatrixXd kernel = MatrixXd::Zero(Rows, J);
  kernel.col(0) =
      Dist::ttpdf(a(0), b(0), df, sample.col(J), sigVect(0), zstar(0));
  VectorXd Hinoti = MatrixXd::Zero(Jm1, 1);
  VectorXd munoti = MatrixXd::Zero(Jm1, 1);
  MatrixXd notj = selectorMat(J);
  for (int j = 1; j < Jm1; j++) {
    munoti = notj.block(j * (Jm1), 0, Jm1, J) * mu;
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

MatrixXd Dist::wishartrnd(const MatrixXd &Sigma, const int df) {
  std::mt19937 rng(rd());
  MatrixXd lowerC = Sigma.llt().matrixL();
  int cols = Sigma.cols();
  int rows = Sigma.rows();
  MatrixXd wishartvariates(cols, rows);
  wishartvariates.setZero();
  for (int i = 0; i < rows; i++) {
    std::chi_squared_distribution<double> csd(df - i);
    for (int j = 0; j <= i; j++) {
      if (i == j) {
        wishartvariates(i, j) = sqrt(csd(rng));
      } else {
        wishartvariates(i, j) = normrnd(0, 1);
      }
    }
  }
  return lowerC * wishartvariates * wishartvariates.transpose() *
         lowerC.transpose();
}

MatrixXd Dist::MatricVariateRnd(const MatrixXd &Mu, const MatrixXd &Sigma,
                                const MatrixXd &V) {
  Map<const VectorXd> VecMu(Mu.data(), Mu.size());
  int J = Sigma.cols();
  MatrixXd SigmaV = kroneckerProduct(V, Sigma);
  cout << SigmaV << endl;
  VectorXd VecSample = mvnrnd(VecMu, SigmaV, 1).transpose();
  Map<MatrixXd> Sample(VecSample.data(), J, J);
  return Sample;
}

MatrixXd Dist::CovToCorr(const MatrixXd &Cov) {
  MatrixXd CovDiag = Cov.diagonal().array().pow(-.5).matrix().asDiagonal();
  return CovDiag * Cov * CovDiag;
}

VectorXd Dist::logisticrnd(int N) {
  boost::random::uniform_01<> u;
  VectorXd logis(N);
  for (int i = 0; i < N; i++) {
    double udraw = u(rseed);
    logis(i) = log(udraw / (1 - udraw));
  }
  return logis;
}

VectorXd Dist::logisticcdf(const VectorXd &x) {
  boost::math::logistic L;
  VectorXd vals(x.size());
  for (int i = 0; i < x.size(); i++) {
    vals(i) = cdf(L, x(i));
  }
  return vals;
}

MatrixXd Dist::mvtrnd(const VectorXd &mu, const MatrixXd &Sigma, int nu,
                      int N) {
  MatrixXd lowerC = Sigma.llt().matrixL();
  VectorXd w = (generateChiSquaredVec(nu, N).array() / nu).pow(-.5);
  MatrixXd Z = normrnd(0, 1, N, mu.size());
  Z = Z.array().colwise() * w.array();
  MatrixXd T = lowerC * Z.transpose();
  T.colwise() += mu;
  return T.transpose();
}

MatrixXd Dist::CredibleIntervals(MatrixXd &X) {
  int C = X.cols();
  MatrixXd credInts(2, C);
  int low = .025 * X.rows();
  int high = X.rows() - low;
  for (int c = 0; c < C; c++) {
    vector<double> post(X.col(c).data(), X.col(c).data() + X.col(c).size());
    sort(post.begin(), post.end());
	credInts.col(c) << post[low], post[high];
  }
  return credInts;
}

MatrixXd Dist::CreateSigma(double rho, int Size){
	MatrixXd CorrMat = MatrixXd::Identity(Size,Size);
	for(int i = 0; i < Size; i++){
		for(int j = 0;j <Size;j++){
			if(i > j){
				CorrMat(i,j) = pow(rho, i);
			}
			else if(j > i){
			   CorrMat(i,j) = pow(rho,j);	
			}
		}
	}
	return CorrMat;
}

MatrixXd Dist::Cov(const MatrixXd &X, int dim) {
  if (dim == 0) {
    VectorXd mu = X.rowwise().mean();
    MatrixXd temp = X;
    temp.colwise() -= mu;
    MatrixXd covmat = temp.transpose() * temp;
    return covmat;
  } else {
    VectorXd mu = X.colwise().mean();
    MatrixXd temp = X;
    temp.rowwise() -= mu.transpose();
    MatrixXd covmat = temp.transpose() * temp;
    return covmat;
  }
}
