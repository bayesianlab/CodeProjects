#ifndef DIST_H
#define DIST_H
#include <Eigen/Dense>
#include <boost/math/distributions/normal.hpp>
#include <boost/random/mersenne_twister.hpp>

using namespace Eigen;
using namespace std;

class Dist {
private:
  time_t now;

  boost::math::normal normalDistribution;

public:
  double inf;
  Dist();

  boost::random::mt19937 rseed;

  void igammarnd(double shape, double scale, VectorXd &igamma);

  double normrnd(double mu, double sig);

  VectorXd normrnd(double, double, int);

  MatrixXd normrnd(double, double, int, int);

  MatrixXd mvnrnd(VectorXd mu, MatrixXd &sig, int, int);



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

  double conditionalMean(double Hxx, VectorXd &Hxy, VectorXd &muNotJ,
                         VectorXd &xNotJ, double muxx);

  double tnormpdf(double a, double b, double mu, double sigma, double x);

  double mvnpdf(VectorXd, MatrixXd, VectorXd);

  double standardDev(VectorXd &);

  void ghkLinearConstraints(VectorXd &, VectorXd &, VectorXd &, MatrixXd &,
                            MatrixXd &);

  MatrixXd ghkLinearConstraints(VectorXd &, VectorXd & , VectorXd &, MatrixXd &,
		  int, int );

  void unifrnd(double, double, VectorXd &);

  VectorXd lrLikelihood(MatrixXd &, VectorXd &, VectorXd &, MatrixXd &);

  double lrLikelihood(VectorXd&, double, VectorXd&, MatrixXd&);

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
  double logmvnpdf(VectorXd&,  MatrixXd&, VectorXd&);

};

#endif
