#ifndef DIST_H
#define DIST_H
#include <Eigen/Dense>
#include <boost/math/distributions/normal.hpp>
#include <boost/random/mersenne_twister.hpp>
#include <boost/random/normal_distribution.hpp>
#include <boost/random/uniform_01.hpp>
#include <iostream>
#include <limits>
#include <math.h>
#include <random>

using namespace Eigen;
using namespace std;

class Dist {
private:
  time_t now;
  int ROBERT_LIMIT;

public:
  double inf;
  Dist();
  Dist(int x);
  boost::mt19937 rseed;
  std::random_device rd;
  boost::math::normal normalDistribution;
  boost::random::uniform_01<> u;

  void igammarnd(double shape, double scale, VectorXd &igamma);

  double igammarnd(double shape, double scale);

  VectorXd gammarnd(double shape, double scale, int N);

  VectorXd igammarnd(double shape, double scale, int N);

  double igammapdf(double, double, double);

  double linearRegLikelihood(const VectorXd &y, const MatrixXd &X,
                             const Ref<const MatrixXd> &beta, double);

  double normrnd(double mu, double sig);

  VectorXd normrnd(double mu, double sig, int N);

  MatrixXd normrnd(double, double, int, int);

  MatrixXd mvnrnd2(VectorXd &mu, const Ref<const MatrixXd> &sig, int, int);

  MatrixXd mvnrnd(const VectorXd &mu, const MatrixXd &sig, int N);

  double tnormrnd(double, double, double, double);

  double shiftexprnd(double, double);

  double shiftexppdf(double, double, double);

  double leftTruncation(double);

  double rightTruncation(double);

  double twoSided(double, double);

  double truncNormalRnd(double a, double b, double mu, double sigma);

  void tmvnrand(VectorXd &, VectorXd &, VectorXd &, MatrixXd &, MatrixXd &,
                VectorXd &);

  MatrixXd tmultnorm(const VectorXd &a, const VectorXd &b, const VectorXd &mu,
                     const MatrixXd &sigma, const int nSims);

  MatrixXd tmultnorm(const VectorXd &, const VectorXd &,
                     const Ref<const MatrixXd> &, const VectorXd &,
                     const MatrixXd &, int);

  MatrixXd ghkLinearConstraints(const VectorXd &a, const VectorXd &b,
                                const VectorXd &mu, const MatrixXd &Sigma,
                                int sims);

  MatrixXd ghkLinearConstraints(const VectorXd &a, const VectorXd &b,
                                const VectorXd &mu, const MatrixXd &Sigma,
                                int sims, VectorXd &logpdf);

  MatrixXd returnNormalizingConstants(const VectorXd &a, const VectorXd &b,
                                      const VectorXd &mu, const MatrixXd &Sigma,
                                      int sims, MatrixXd &normC);

  void runSim(int nSims, int batches, const VectorXd &a, const VectorXd &b,
              const VectorXd &mu, const MatrixXd &Sigma, int sims);

  double conditionalMean(double Hxx, VectorXd &Hxy, VectorXd &muNotJ,
                         VectorXd &xNotJ, double muxx);

  double conditionalMean(double Hxx, const Ref<const VectorXd> &Hxy,
                         const Ref<const VectorXd> &muNotJ,
                         const Ref<const VectorXd> &xNotJ, double muxx);

  VectorXd conditionalMean(double, VectorXd &, VectorXd &, MatrixXd, double);

  double tnormpdf(double a, double b, double mu, double sigma, double x);

  double ttpdf(double a, double b, double df, double mu, double sigma,
               double x);

  VectorXd ttpdf(double a, double b, double df, double mu, double sigma,
                 const Ref<const VectorXd> &x);

  MatrixXd ttpdf(const VectorXd &a, const VectorXd &b, double df,
                 const VectorXd &mu, const VectorXd &sigma, const MatrixXd &X);

  VectorXd ttpdf(double a, double b, double df, const Ref<const VectorXd> &mu,
                 double sigma, double x);

  double mvtpdf(const VectorXd &x, const VectorXd &mu, const MatrixXd &Variance,
                int df);

  VectorXd logmvtpdf(double df, const Ref<const VectorXd> &mu,
                     const MatrixXd &Sigma, MatrixXd X);

  double mvtpdfHelp(const Ref<const VectorXd> &x, const VectorXd &mu,
                    const MatrixXd &Variance, int df);

  VectorXd mvtpdf(const MatrixXd &X, const VectorXd &mu,
                  const MatrixXd &Variance, int df);

  VectorXd tnormpdfVect(double a, double b, double mu, double sigma,
                        VectorXd &x);

  MatrixXd tnormpdfMat(VectorXd &a, VectorXd &b, VectorXd &mu, VectorXd &sigma,
                       MatrixXd &x);

  MatrixXd tnormpdfMat(const VectorXd &a, const VectorXd &b, const VectorXd &mu,
                       const VectorXd &sigma, const MatrixXd &x);

  template <typename D>
  VectorXd tnormpdfMeanVect(double a, double b, const MatrixBase<D> &mu,
                            double sigma, double x);
  double mvnpdfPrecision(const Ref<const MatrixXd> &, const MatrixXd &,
                         const Ref<const MatrixXd> &);

  double mvnpdf(const Ref<const MatrixXd> &, const MatrixXd &,
                const Ref<const MatrixXd> &);

  double standardDev(VectorXd &);

  MatrixXd ghkT(const VectorXd &a, const VectorXd &b,
                const MatrixXd &LinearConstraints, const VectorXd &mu,
                const MatrixXd &Sigma, double df, int sims);

  MatrixXd ghkT(const VectorXd &a, const VectorXd &b,
                const MatrixXd &LinearConstraints, const VectorXd &mu,
                const MatrixXd &Sigma, double df, int sims, VectorXd &logpdf);

  void unifrnd(double, double, VectorXd &);

  VectorXd lrLikelihood(MatrixXd &, VectorXd &, VectorXd &, MatrixXd &);

  VectorXd lrLikelihood(const Ref<const MatrixXd> &betas,
                        const Ref<const VectorXd> &sigmasqds, const VectorXd &y,
                        const MatrixXd &X);

  double lrLikelihood(VectorXd &betas, double sigSqd, VectorXd &y, MatrixXd &X);

  double lrLikelihood(const VectorXd &betas, double sigSqd, const VectorXd &y,
                      const MatrixXd &X);

  double lrLikelihoodASK(const VectorXd &betas, double sigSqd,
                         const VectorXd &y, const MatrixXd &X);

  VectorXd linreglike;

  VectorXd lmvnpdf;

  VectorXd loginvgammapdf(const Ref<const VectorXd> &, double, double);

  double loginvgammapdf(double y, double alpha, double beta);

  MatrixXd asktmvnrand(const VectorXd &a, const VectorXd &b, const VectorXd &mu,
                       const MatrixXd &Sigma, const VectorXd &sigmavector,
                       const VectorXd &initvector, int);

  int bernoulli(double p);

  MatrixXd askGhkLinearConstraints(const VectorXd &, const VectorXd &,
                                   const VectorXd &, const MatrixXd &, int);

  double autoCorr(VectorXd &);

  VectorXd logmvnpdfV(const VectorXd &mu, const MatrixXd &Sigma, MatrixXd x);

  double logmvnpdfVect(const VectorXd &mu, const MatrixXd &Sigma,
                       const VectorXd &x);

  double logmvnpdfPrecision(const VectorXd &mu, const MatrixXd &sigma,
                            const Ref<const MatrixXd> &x);

  double logmvnpdf(const VectorXd &, const MatrixXd &, const VectorXd &);

  double truncTrnd(double a, double b, double mu, double sigma, double nu);

  MatrixXd mvtruncT(const VectorXd &a, const VectorXd &b,
                    const MatrixXd &LinearConstraints, const VectorXd &mu,
                    const MatrixXd &Sigma, const int df, const int sims);

  MatrixXd MVTruncT(const VectorXd &a, const VectorXd &b,
                    const MatrixXd &LinearConstraints, const VectorXd &mu,
                    const MatrixXd &Sigma, const int df, const int sims,
                    const int burnin);

  MatrixXd SigmayyInverse(const MatrixXd &);

  MatrixXd mvttgeweke91(const VectorXd &a, const VectorXd &b,
                        const MatrixXd &LinearConstraints, const VectorXd &mu,
                        const MatrixXd &Sigma, const double df, const int sims,
                        const int burnin);

  MatrixXd askMvttgeweke91(const VectorXd &a, const VectorXd &b,
                           const MatrixXd &LinearConstraints,
                           const VectorXd &mu, const MatrixXd &Sigma,
                           const double df, const int sims, const int burnin,
                           VectorXd &initVector);

  MatrixXd selectorMat(int J);

  MatrixXd Hnotj(const MatrixXd &precision);

  void cleanP(MatrixXd &P);

  MatrixXd geweke91(const VectorXd &a, const VectorXd &b,
                    const MatrixXd &LinearConstraints,
                    const Ref<const VectorXd> &mu,
                    const Ref<const MatrixXd> &CovarianceMatrix, int sims,
                    int burnin);

  MatrixXd precisionNotjMatrix(int J, const MatrixXd &precision,
                               const VectorXd &Hii);

  VectorXd generateChiSquaredVec(double df, int rows);

  MatrixXd generateChiSquaredMat(double df, int rows, int cols);

  MatrixXd mvtrunctrnd(const VectorXd &mu, const MatrixXd &Sigma,
                       const double nu, const int N);

  VectorXd studenttrnd(const double mu, const double sigma, const double nu,
                       const int N, const int J);

  MatrixXd mvtstudtrnd(const VectorXd &a, const VectorXd &b,
                       const MatrixXd &LinearConstraints, const VectorXd &mu,
                       const MatrixXd &Sigma, const double df, const int sims,
                       const int burnin);

  MatrixXd mvtstudtrnd(const VectorXd &a, const VectorXd &b,
                       const MatrixXd &LinearConstraints, const VectorXd &mu,
                       const MatrixXd &Sigma, const double df, const int sims,
                       const int burnin, VectorXd &init);

  MatrixXd gibbsKernel(const VectorXd &a, const VectorXd &b, const VectorXd &mu,
                       const MatrixXd &Sigma, const MatrixXd &Sample,
                       const VectorXd &zStar);

  double pdfavg(const Ref<const VectorXd> &logpdf);

  double pdfmean(const Ref<const VectorXd> &logpdf);

  MatrixXd gibbsTKernel(const VectorXd &a, const VectorXd &b,
                        const MatrixXd &LinearConstraints,
                        const MatrixXd &sample, VectorXd &zstar,
                        const double df, const VectorXd &mu,
                        const MatrixXd &Sigma, const VectorXd &y,
                        const MatrixXd &X, const int sims, const int burnin);

  MatrixXd wishartrnd(const MatrixXd &Sigma, const int df);

  MatrixXd MatricVariateRnd(const MatrixXd &Mu, const MatrixXd &Sigma,
                            const MatrixXd &V);

  MatrixXd CovToCorr(const MatrixXd &Cov);

  VectorXd logisticrnd(int N);

  VectorXd logisticcdf(const VectorXd &x);

  MatrixXd mvtrnd(const VectorXd &mu, const MatrixXd &Sigma, int nu, int N);

  MatrixXd CredibleIntervals(MatrixXd & X);

  MatrixXd CreateSigma(double rho, int size);

  MatrixXd Cov(const MatrixXd &X, int dim);
};

template <typename D>
VectorXd Dist::tnormpdfMeanVect(double a, double b, const MatrixBase<D> &mu,
                                double sigma, double x) {
  VectorXd fx(mu.size());
  for (int i = 0; i < mu.size(); i++) {
    fx(i) = Dist::tnormpdf(a, b, mu(i), sigma, x);
  }
  return fx;
}
#endif
