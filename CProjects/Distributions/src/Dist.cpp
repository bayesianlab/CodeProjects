#include "Dist.hpp"
#include <Eigen/Dense>
#include <assert.h>
#include <boost/math/distributions/exponential.hpp>
#include <boost/math/distributions/normal.hpp>
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
  rseed.seed(now);
  inf = numeric_limits<double>::max();
}

void Dist::igammarnd(double shape, double scale, VectorXd &igamma) {
  /*
(1/theta^k gamma(k)) x^(k-1) e^(-x/theta) is the gamma
   parameterization
*/
  boost::random::gamma_distribution<> gammavars(shape, scale);
  int rows = igamma.rows();
  for (int i = 0; i < rows; i++) {
    igamma(i) = 1.0 / gammavars(rseed);
  }
}

double Dist::normrnd(double mu, double sig) {
  boost::random::normal_distribution<> normalDist;
  return normalDist(rseed);
}

VectorXd Dist::normrnd(double mu, double sig, int N) {
  VectorXd Z(N);
  for (int i = 0; i < N; i++) {
    Z(i) = normrnd(mu, sig);
  }
  return Z;
}

MatrixXd Dist::normrnd(double mu, double sig, int N, int J) {
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

void Dist::unifrnd(double a, double b, VectorXd &unifVector) {
  boost::random::uniform_01<> u;
  double diff = b - a;
  for (int i = 0; i < unifVector.size(); i++) {
    unifVector(i) = a + u(rseed) * diff;
  }
}

double Dist::tnormrnd(double a, double b, double mu, double sigma) {
  // Still used in truncNormalRnd, KEEP
  boost::math::normal s;
  boost::random::uniform_01<> u;
  double alpha = (a - mu) / sigma;
  double beta = (b - mu) / sigma;
  double Fa = cdf(s, alpha);
  double Fb = cdf(s, beta);
  double randomU = u(rseed);
  double q = Fa + u(rseed) * (Fb - Fa);
  return mu + (sigma * quantile(s, q));
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
    }
    maxIterations++;
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
      rho_z = exp(-pow(zdouble, 2));
    } else if (b < 0) {
      rho_z = exp((pow(b, 2) - pow(zdouble, 2)) / 2.);
    } else {
      rho_z = exp((pow(a, 2) - pow(zdouble, 2)) / 2.);
    }
    if (u(rseed) <= rho_z) {
      return zdouble;
    }
  }
  cout << "Error in two sided truncation." << endl;
  return inf;
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
   * Uses both inversion and ar sampling
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
    /*for(int j = 0; j < J; j++){
                 sigmaVect(j) = sqrt(1./Hxx(j));
    }*/

    for (int sim = 1; sim < nSims; sim++) {
      for (int j = 0; j < J; j++) {
        Hxy << precision.row(j).head(j).transpose(),
            precision.row(j).tail(Jminus1 - j).transpose();

        muNotJ << mu.head(j), mu.tail(Jminus1 - j);

        xNotJ << sample.row(sim - 1).head(j).transpose(),
            sample.row(sim - 1).segment(j + 1, Jminus1 - j).transpose();

        sample(sim, j + J) = conditionalMean(Hxx(j), Hxy, muNotJ, xNotJ, mu(j));
        sample(sim, j) =
            truncNormalRnd(a(j), b(j), sample(sim, j + J), sigmaVect(j));
      }
    }
  }
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

double Dist::tnormpdf(double a, double b, double mu, double sigma, double x) {
  /*sigmaZ = sigma.* (normcdf((b-mu)./sigma) - normcdf( (a-mu)./sigma ));
   * tOrdinate = normpdf((x-mu)./sigma)./sigmaZ;
   */
  boost::math::normal normalDist;
  double sigmaZ = sigma * (cdf(normalDist, (b - mu) / sigma) -
                           cdf(normalDist, (a - mu) / sigma));
  return pdf(normalDist, (x - mu) / sigma) / sigmaZ;
}

double Dist::mvnpdf(VectorXd mu, MatrixXd sigma, VectorXd x) {
  int size = mu.size();
  VectorXd temp(size);
  temp = x - mu;
  temp = -.5 * temp.transpose() * sigma.inverse() * temp;
  double constant = pow(2 * M_PI, size);
  return (1. / sqrt(constant * sigma.determinant())) * exp(temp(0));
}

double Dist::standardDev(VectorXd &v) {
  ArrayXd t(v.size());
  t = v.array() - v.mean();
  return sqrt(t.square().sum() / (v.size() - 1));
}

void Dist::lrLikelihood(MatrixXd &betas, VectorXd &sigmasqds, VectorXd &y,
                        MatrixXd &X) {
  int N = X.rows();
  VectorXd e(X.rows());
  ArrayXd normConst = -(N / 2) * (sigmasqds.array().log() + LOG_E_2_PI);
  ArrayXd expNormalizingConst = (-2 * sigmasqds.array()).pow(-1);
  linreglike = VectorXd::Zero(betas.rows());
  for (int i = 0; i < betas.rows(); i++) {
    e = y - X * betas.row(i).transpose();
    double eTe = e.transpose() * e;
    linreglike(i) = normConst(i) + eTe * expNormalizingConst(i);
  }
}

void Dist::logmvnpdf(MatrixXd &X, VectorXd &mu, MatrixXd &Sigma) {
  int J = Sigma.cols();
  const double epi = LOG_E_2 + LOG_PI;
  MatrixXd Sigmainv;
  Sigmainv = Sigma.inverse();
  double det = Sigma.determinant();
  double C1 = J * epi + log(det);
  X.rowwise() -= mu.transpose();
  lmvnpdf = -.5 * (C1 + (X * Sigmainv).array().pow(2).rowwise().sum());
}

void Dist::loginvgammapdf(VectorXd &y, double alpha, double beta) {
  double C1 = -(alpha * log(beta) + lgamma(alpha));
  ligampdf = y.array().log();
  ligampdf *= -(alpha + 1);
  ligampdf = ligampdf.array() - (y.array() * beta).pow(-1) + C1;
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

