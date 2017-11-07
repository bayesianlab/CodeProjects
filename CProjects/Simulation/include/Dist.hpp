#ifndef DIST_H
#define DIST_H
#include <Eigen/Dense>
#include <boost/math/distributions/normal.hpp>
#include <boost/random/mersenne_twister.hpp>
#include <boost/random/normal_distribution.hpp>
#include <boost/random/uniform_01.hpp>

#include <iostream>
#include <limits>

using namespace Eigen;
using namespace std;

class Dist {
private:
  time_t now;

public:
  double inf;
  Dist();
  boost::mt19937 rseed;
  boost::math::normal normalDistribution;
  boost::random::uniform_01<> u;

  void igammarnd(double shape, double scale, VectorXd &igamma);

  double igammarnd(double shape, double scale);

  double igammapdf(double, double, double);
  
  double linearRegLikelihood(const VectorXd &y, const MatrixXd &X,
                             const Ref<const MatrixXd> &beta, double);

  double normrnd(double mu, double sig);

  VectorXd normrnd(double, double, int);

  MatrixXd normrnd(double, double, int, int);

  MatrixXd mvnrnd(VectorXd mu, MatrixXd &sig, int, int);
  MatrixXd mvnrnd2(VectorXd mu, const Ref<const MatrixXd> &sig, int, int);

  double tnormrnd(double, double, double, double);

  double shiftexprnd(double, double);

  double shiftexppdf(double, double, double);

  double leftTruncation(double, double);

  double rightTruncation(double, double);

  double twoSided(double, double);

  double truncNormalRnd(double, double, double, double);

  double ghkTruncNormRnd(double, double, double, double);

  void tmvnrand(VectorXd &, VectorXd &, VectorXd &, MatrixXd &, MatrixXd &,
                VectorXd &);

  MatrixXd tmultnorm(VectorXd &, VectorXd &, VectorXd &, MatrixXd &, int);

  double conditionalMean(double Hxx, VectorXd &Hxy, VectorXd &muNotJ,
                         VectorXd &xNotJ, double muxx);
  VectorXd conditionalMean(double, VectorXd &, VectorXd &, MatrixXd, double);

  double tnormpdf(double a, double b, double mu, double sigma, double x);

  VectorXd tnormpdfVect(double a, double b, double mu, double sigma,
                        VectorXd &x);

  MatrixXd tnormpdfMat(VectorXd &a, VectorXd &b, VectorXd &mu, VectorXd &sigma,
                       MatrixXd &x);

  template <typename D>
  VectorXd tnormpdfMeanVect(double a, double b, const MatrixBase<D> &mu,
                            double sigma, double x);

  double mvnpdfPrecision(const Ref<const MatrixXd> &, const MatrixXd &,
                const Ref<const MatrixXd> &);

  double mvnpdf(const Ref<const MatrixXd> &, const MatrixXd &,
                const Ref<const MatrixXd> &);

  double standardDev(VectorXd &);

  void ghkLinearConstraints(VectorXd &, VectorXd &, VectorXd &, MatrixXd &,
                            MatrixXd &);

  MatrixXd ghkLinearConstraints(VectorXd &, VectorXd &, VectorXd &, MatrixXd &,
                                int, int);

  void unifrnd(double, double, VectorXd &);

  VectorXd lrLikelihood(MatrixXd &, VectorXd &, VectorXd &, MatrixXd &);

  double lrLikelihood(VectorXd &, double, VectorXd &, MatrixXd &);

  VectorXd linreglike;

  VectorXd lmvnpdf;

  VectorXd loginvgammapdf(VectorXd &, double, double);

  double loginvgammapdf(double y, double alpha, double beta);

  MatrixXd asktmvnrand(VectorXd &, VectorXd &, VectorXd &, MatrixXd &,
                       VectorXd &, VectorXd &, int);

  int bernoulli(double p);

  MatrixXd askGhkLinearConstraints(VectorXd &, VectorXd &, VectorXd &,
                                   MatrixXd &, int);

  double autoCorr(VectorXd &);

  VectorXd logmvnpdf(VectorXd &, MatrixXd &, MatrixXd &);
  double logmvnpdf(VectorXd &, MatrixXd &, VectorXd &);
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
