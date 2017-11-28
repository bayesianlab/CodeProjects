#include "Dist.hpp"
#include <random>
#include <assert.h>
#include <boost/math/distributions/exponential.hpp>
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
}

void Dist::igammarnd(double shape, double scale, VectorXd &igamma) {
  boost::random::gamma_distribution<> gammavars(shape, scale);
  int rows = igamma.rows();
  for (int i = 0; i < rows; i++) {
    igamma(i) = 1.0 / gammavars(rseed);
  }
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
  for (int i = 0; i < N; i++) {
    Z(i) = normrnd(mu, sig);
  }
  return Z;
}

MatrixXd Dist::normrnd(double mu, double sig, int N, int J) {
  boost::random::normal_distribution<> normalDist(mu, sig);
  MatrixXd Z(N, J);
  for (int i = 0; i < N; i++) {
    for (int j = 0; j < J; j++) {
      Z(i, j) = normrnd(mu, sig);
    }
  }
  return Z;
}

MatrixXd Dist::mvnrnd(VectorXd mu, MatrixXd &sig, int N, int J) {
  MatrixXd Z = normrnd(0., 1., N, J);
  LLT<MatrixXd> lltOfA(sig);
  MatrixXd L = lltOfA.matrixL();
  Z = (L * Z.transpose()).transpose();
  Z.rowwise() += mu.transpose();
  return Z;
}

MatrixXd Dist::mvnrnd2(VectorXd mu, const Ref<const MatrixXd> &sig, int N,
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

double Dist::leftTruncation(double a, double b) {
  int maxIterations = 0;
  boost::random::uniform_01<> u;
  double optimalScale, rho_z, z;
  optimalScale = (a + sqrt(pow(a, 2) + 4)) / 2.;
  while (maxIterations < 10000) {
    z = shiftexprnd(optimalScale, a);
    rho_z = exp(-pow(z - optimalScale, 2));
    if (u(rseed) <= rho_z) {
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

double Dist::rightTruncation(double a, double b) {
  double optimalScale, rho_z, z, temp;
  temp = b;
  b = -a;
  a = -temp;
  int maxIterations = 0;
  boost::random::uniform_01<> u;
  optimalScale = (a + sqrt(pow(a, 2) + 4)) / 2.;
  while (maxIterations < 10000) {
    z = shiftexprnd(optimalScale, a);
    rho_z = exp(-pow(z - optimalScale, 2));
    if (u(rseed) <= rho_z) {
      return -z;
    }
    maxIterations++;
  }
  cout << "Error rightTruncation: maxIterations exceeded, no truncation "
          "possible."
       << endl;
  return inf;
}

double Dist::twoSided(double a, double b) {
  int maxIterations = 0;
  boost::random::uniform_01<> z;
  boost::random::uniform_01<> u;
  double zdouble, rho_z;
  while (maxIterations < 10000) {
    zdouble = a + z(rseed) * (b - a);
    if (a < 0 && 0 < b) {
      rho_z = (-pow(zdouble, 2));
      if (log(u(rseed)) < rho_z) {
        return zdouble;
      } else {
        maxIterations++;
      }
    } else if (b < 0) {
      rho_z = ((pow(b, 2) - pow(zdouble, 2))*.5 );
      if (log(u(rseed)) < rho_z) {
        return zdouble;
      } else {
        maxIterations++;
      }
    } else {
      rho_z = log((pow(a, 2) - pow(zdouble, 2)) / 2.);
      if (log(u(rseed)) < rho_z) {
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
  double Z;
  if (b >= inf) {
    double standardizedA;
    standardizedA = (a - mu) / sigma;
    if (standardizedA > 5) {
      Z = leftTruncation(standardizedA, b);
      return mu + sigma * Z;
    } else {
      return tnormrnd(a, b, mu, sigma);
    }
  } else if (a <= -inf) {
    double standardizedB;
    standardizedB = (b - mu) / sigma;
    if (standardizedB < -5) {
      Z = rightTruncation(a, standardizedB);
      return mu + sigma * Z;
    } else {
      return tnormrnd(a, b, mu, sigma);
    }
  } else {
    double standardizedA, standardizedB;
    standardizedA = (a - mu) / sigma;
    standardizedB = (b - mu) / sigma;
    if (standardizedA > 5) {
      Z = twoSided(standardizedA, standardizedB);
      return mu + sigma * Z;
    } else if (standardizedB < -5) {
      Z = twoSided(standardizedA, standardizedB);
      return mu + sigma * Z;
    } else {
      return tnormrnd(a, b, mu, sigma);
    }
  }
}

void Dist::tmvnrand(VectorXd &a, VectorXd &b, VectorXd &mu, MatrixXd &sigma,
                    MatrixXd &sample, VectorXd &sigmaVect) {
  /*
   * Uses both inversion and ar sampling, should be deprecated in favor
   * of tmultnorm
   */
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

MatrixXd Dist::tmultnorm(VectorXd &a, VectorXd &b, VectorXd &mu,
                         MatrixXd &sigma, int nSims) {
  /*
   * Uses both inversion and ar sampling
   */
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
  return sample;
}

MatrixXd Dist::tmultnorm(const VectorXd &a, const VectorXd &b,
                         const VectorXd &mu, const MatrixXd &sigma,
                         const int nSims) {
  /*
   * Uses both inversion and ar sampling
   */
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
  for (int sim = 1; sim < nSims; sim++) {
    for (int j = 0; j < J; j++) {
      Hxy << precision.row(j).head(j).transpose().eval(),
          precision.row(j).tail(Jminus1 - j).transpose().eval();
      muNotJ << mu.head(j), mu.tail(Jminus1 - j);
      xNotJ << sample.row(sim - 1).head(j).transpose().eval(),
          sample.row(sim - 1).segment(j + 1, Jminus1 - j).transpose().eval();
      sample(sim, j + J) = conditionalMean(Hxx(j), Hxy, muNotJ, xNotJ, mu(j));
      cout << "stuf " << a(j) << " " << b(j) << " " << sample(sim, j + J) << " "
           << sigmaVect(j) << endl;
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
  double Ta = cdf(tdist, a);
  double Tb = cdf(tdist, b);
  return pow(Tb - Ta, -1) * pdf(tdist, x);
}

VectorXd Dist::ttpdf(double a, double b, double df, double mu, double sigma,
                   const Ref<const VectorXd> &x) {

  boost::math::students_t tdist(df);
  double Ta = cdf(tdist, a);
  double Tb = cdf(tdist, b);
  VectorXd pdfVals(x.size());
  for(int i = 0; i < x.size(); i++ ){
	 pdfVals(i)  = ttpdf(a, b, df, mu, sigma, x(i)); 
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
double Dist::ghkTruncNormRnd(double a, double b, double mu, double sigma) {
  // Keep this method
  double Z;
  if (b >= inf) {
    if (a > 5) {
      Z = leftTruncation(a, b);
      return Z;
    } else {
      return tnormrnd(a, b, mu, sigma);
    }
  } else if (a <= -inf) {
    if (b < -5) {
      Z = rightTruncation(a, b);
      return Z;
    } else {
      return tnormrnd(a, b, mu, sigma);
    }
  } else {
    if (a > 5) {
      Z = twoSided(a, b);
      return Z;
    } else if (b < -5) {
      Z = twoSided(a, b);
      return Z;
    } else {
      return tnormrnd(a, b, mu, sigma);
    }
  }
}

void Dist::ghkLinearConstraints(VectorXd &a, VectorXd &b, VectorXd &mu,
                                MatrixXd &Sigma, MatrixXd &sample) {
  /*
   * Take into account multiple constraints
   */

  int J = Sigma.cols();
  if (a.size() != b.size()) {
    cout << "\nError: The number of constraints are not the same." << endl;
  } else if (a.size() != J) {
    cout << "Error: At least as many constraints as dimension in Sigma are "
            "needed."
         << endl;
  } else {
    int sims = sample.rows();
    MatrixXd lowerC = Sigma.llt().matrixL();
    MatrixXd offDiagMat = lowerC;
    offDiagMat.diagonal() = VectorXd::Zero(J);
    double update, aj, bj;
    for (int sim = 0; sim < sims; sim++) {
      for (int j = 0; j < J; j++) {
        update = mu(j) + (offDiagMat.row(j) * sample.row(sim).transpose());
        aj = (a(j) - update) / lowerC(j, j);
        bj = (b(j) - update) / lowerC(j, j);
        sample(sim, j) = ghkTruncNormRnd(aj, bj, 0, 1);
      }
    }
    sample = (lowerC * sample.transpose()).transpose();
    sample.rowwise() += mu.transpose();
  }
}

MatrixXd Dist::ghkLinearConstraints(VectorXd &a, VectorXd &b, VectorXd &mu,
                                    MatrixXd &Sigma, int sims, int burnin) {
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
      sample(sim, j) = ghkTruncNormRnd(aj, bj, 0, 1);
    }
  }
  sample = (lowerC * sample.transpose()).transpose();
  sample.rowwise() += mu.transpose();
  return sample.bottomRows(sims - burnin).matrix();
}

MatrixXd Dist::ghkT(const VectorXd &a, const VectorXd &b,
                    const MatrixXd &LinearConstraints, const VectorXd &mu,
                    const MatrixXd &Sigma, double df, int sims, int burnin) {
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
      sample(sim, j) = truncTrnd(aj, bj, 0, 1, df);
    }
  }
  sample =
      (LinearConstraints.inverse() * (lowerC * sample.transpose())).transpose();
  sample.rowwise() += mu.transpose();
  return sample.bottomRows(sims - burnin).matrix();
}

MatrixXd Dist::askGhkLinearConstraints(VectorXd &a, VectorXd &b, VectorXd &mu,
                                       MatrixXd &Sigma, int rows) {
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
    for (int sim = 0; sim < sims; sim++) {
      for (int j = 0; j < J; j++) {
        update = mu(j) + (offDiagMat.row(j) * sample.row(sim).transpose());
        aj = (a(j) - update) / lowerC(j, j);
        bj = (b(j) - update) / lowerC(j, j);
        sample(sim, j) = ghkTruncNormRnd(aj, bj, 0, 1);
      }
    }
    sample = (lowerC * sample.transpose()).transpose();
    sample.rowwise() += mu.transpose();
    return sample;
  }
}

MatrixXd Dist::asktmvnrand(VectorXd &a, VectorXd &b, VectorXd &mu,
                           MatrixXd &sigma, VectorXd &sigmaVect,
                           VectorXd &initVector, int sims) {
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
  double muj;
  for (int sim = 0; sim < nSims; sim++) {
    for (int j = 0; j < J; j++) {
      if (sim == 0) {
        Hxy << precision.row(j).head(j).transpose().eval(),
            precision.row(j).tail(Jminus1 - j).transpose().eval();
        muNotJ << mu.head(j), mu.tail(Jminus1 - j);
        xNotJ << initVector.head(j), initVector.tail(Jminus1 - j);
        muj = conditionalMean(Hxx(j), Hxy, muNotJ, xNotJ, mu(j));
        sample(sim, j) = truncNormalRnd(a(j), b(j), muj, sigmaVect(j));
      } else {
        Hxy << precision.row(j).head(j).transpose().eval(),
            precision.row(j).tail(Jminus1 - j).transpose().eval();
        muNotJ << mu.head(j), mu.tail(Jminus1 - j);
        xNotJ << sample.row(sim - 1).head(j).transpose().eval(),
            sample.row(sim - 1).tail(Jminus1 - j).transpose().eval();
        muj = conditionalMean(Hxx(j), Hxy, muNotJ, xNotJ, mu(j));
        sample(sim, j) = truncNormalRnd(a(j), b(j), muj, sigmaVect(j));
      }
    }
  }
  return sample;
}

double Dist::conditionalMean(double Hxx, VectorXd &Hxy, VectorXd &muNotJ,
                             VectorXd &xNotJ, double muxx) {
  return muxx - (1. / Hxx) * Hxy.dot(xNotJ - muNotJ);
}

double Dist::conditionalMean(double Hxx, const Ref<const VectorXd> &Hxy,
                             VectorXd &muNotJ, VectorXd &xNotJ, double muxx) {
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

double Dist::lrLikelihood(const VectorXd &y, const MatrixXd &X,
                          const Ref<const MatrixXd> &betas, double sigmasqd) {
  int N = X.rows();
  VectorXd e(N);
  double normConst = -(N / 2) * (log(sigmasqd) + log(2 * M_PI));
  double expNormalizingConst = pow(-2 * sigmasqd, -1);
  e = y - X * betas;
  double eTe = e.transpose() * e;
  return normConst + eTe * expNormalizingConst;
}

VectorXd Dist::loginvgammapdf(VectorXd &y, double alpha, double beta) {
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

VectorXd Dist::logmvnpdf(VectorXd &mu, MatrixXd &sigma, MatrixXd x) {
  int J = sigma.cols();
  double C1 = (J * log(2 * M_PI)) + log(sigma.determinant());
  x.rowwise() -= mu.transpose();
  return -.5 *
         (C1 + ((x * sigma.inverse()).array() * x.array()).rowwise().sum());
}



double Dist::logmvnpdf(VectorXd &mu, MatrixXd &sigma, VectorXd &x) {
  int J = sigma.cols();
  double C1 = (J * log(2 * M_PI)) + log(sigma.determinant());
  return -.5 * (C1 + ((x - mu).transpose() * sigma.inverse()) * (x - mu));
}

double Dist::logmvnpdfPrecision(const VectorXd &mu, const MatrixXd &precision,
                                const Ref<const MatrixXd> &x) {
  int J = precision.cols();
  double C1 = log( precision.determinant() / (pow(2 * M_PI, J)));
  return .5 * (C1 - ( ((x - mu).transpose() * precision) * (x - mu)).value());
}

VectorXd Dist::generateChiSquaredVec(double df, int rows) {
  std::mt19937 gen(now);
  std::chi_squared_distribution<double> csd(df);
  VectorXd chiSqs(rows);
  for (int i = 0; i < rows; i++) {
    chiSqs(i) = csd(gen);
  }
  return chiSqs;
}

MatrixXd Dist::generateChiSquaredMat(double df, int rows, int cols) {
  std::mt19937 gen(now);
  std::chi_squared_distribution<double> csd(df);
  MatrixXd chiSqs(rows, cols);
  for (int i = 0; i < rows; i++) {
	  for(int j = 0; j < cols; j++){
            chiSqs(i, j) = csd(gen);
          }
  }
  return chiSqs;
}

double Dist::truncTrnd(double a, double b, double mu, double sigma, double nu) {
  std::mt19937 gen(now);
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
    for (int j = 0; j < J; j++) {
    newChi = sqrt(chiSqs(i - 1) / df);
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
  int Jm1 = J-1;
  MatrixXd selector = selectorMat(J);
  MatrixXd syy((Jm1) * J, Jm1);
  int c = 0;
  for (int j = 0; j < J; j++) {
      syy.middleRows(c, Jm1) = (selector.block(j * (Jm1), 0, Jm1, J) *
         (selector.block(j * (Jm1), 0, Jm1, J) * Sigma).transpose())
            .transpose().inverse();
	  c = c + Jm1;
  }
  return syy;
}

MatrixXd Dist::mvttgeweke91(const VectorXd &a, const VectorXd &b,
                           const MatrixXd &LinearConstraints,
                           const VectorXd &mu, const MatrixXd &Sigma,
                           const int df, const int sims, const int burnin) {
  int J = Sigma.cols();
  int Jm1 = J - 1;
  MatrixXd chiSqs = (generateChiSquaredMat(df, sims, J).array()/df).sqrt();
  MatrixXd T = LinearConstraints * Sigma * LinearConstraints.transpose();
  MatrixXd precisionT = T.inverse();
  VectorXd Hii = precisionT.diagonal();
  VectorXd hii = Hii.array().pow(-1).sqrt();
  MatrixXd notj = selectorMat(J);
  MatrixXd precisionNotj = precisionNotjMatrix(J, precisionT, Hii);
  MatrixXd sample(sims, J);
  MatrixXd cmeans(sims, J);
  sample.setZero();
  VectorXd alpha = a - LinearConstraints * mu;
  VectorXd beta = b - LinearConstraints * mu;
  double innerProduct;
  for (int i = 1; i < sims; i++) {
    for (int j = 0; j < J; j++) {
      innerProduct = (precisionNotj.row(j) * (notj.block(j * (Jm1), 0, Jm1, J) *
                                    sample.row(i - 1).transpose()))
                                       .value();
	  cmeans(i,j) = innerProduct;
      sample(i, j) =
          innerProduct +
          hii(j) * truncNormalRnd(
                       ((alpha(j) - innerProduct) * chiSqs(i, j)) / hii(j),
                       ((beta(j) - innerProduct) * chiSqs(i, j)) / hii(j), 0,
                       1)/chiSqs(i,j);
    }
  }
  sample = (LinearConstraints.inverse() * sample.transpose()).transpose();
  sample.rowwise() += mu.transpose();
  cmeans.rowwise() += mu.transpose();
  MatrixXd SampleAndMeans(sims-burnin, 2*J);
  SampleAndMeans << sample.bottomRows(sims - burnin),
      cmeans.bottomRows(sims- burnin);
  return SampleAndMeans;
}

MatrixXd Dist::Hnotj(const MatrixXd &precision) {
  int J = precision.cols();
  int Jm1 = J - 1;
 MatrixXd sm = selectorMat(J);
  MatrixXd smReturn(J, Jm1);
  smReturn.setZero();
  for (int j = 0; j < J; j++) {
    smReturn.row(j) = ( (sm.block(j * (Jm1), 0, Jm1, J) *
                      precision.row(j).transpose())).transpose() ;
  }
  return smReturn;
}


MatrixXd Dist::selectorMat(int J){
	int Jm1 = J - 1;
	MatrixXd I = MatrixXd::Identity(J,J);
	MatrixXd selectors = MatrixXd::Zero(J*(Jm1), J);
	for(int j = 0; j < J; j++){
		if(j == 0){
			selectors.topRows(J-1) = I.bottomRows(Jm1);
		}
		else if(j > 0 & j < Jm1){
                  selectors.middleRows(j * (Jm1), Jm1) << I.topRows(j),
                      I.bottomRows((Jm1) - j);
                }
		else{
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
                      precision.row(j).transpose())).transpose() ;
  }
  return smReturn;
}

MatrixXd Dist::geweke91(const VectorXd &a, const VectorXd &b,
                        const MatrixXd &LinearConstraints,
                        const Ref<const VectorXd> &mu,
                        const Ref<const MatrixXd> &sigma, int sims,
                        int burnin) {
  /* Trunc. MVNormal according to Geweke 1991 */
  /* Tested against MATLAB */
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
  double innerProduct;
  for (int i = 1; i < sims; i++) {
    for (int j = 0; j < J; j++) {
      innerProduct = (precisionNotj.row(j) * (notj.block(j * (Jm1), 0, Jm1, J) *
                                    sample.row(i - 1).transpose()))
                                       .value();
      sample(i, j) =
          innerProduct +
          (hii(j) * truncNormalRnd((alpha(j) - innerProduct) / hii(j),
                                  (beta(j) - innerProduct) / hii(j), 0, 1));
    }
  }
  sample = (LinearConstraints.inverse() * sample.transpose()).transpose();
  sample.rowwise() += mu.transpose();
  return sample.bottomRows(sims - burnin);
}


