#include "LinRegGibbs.hpp"
#include <Eigen/Dense>
#include <Eigen/Sparse>
#include <boost/math/distributions/chi_squared.hpp>
#include <math.h>

using namespace Eigen;

MatrixXd LinRegGibbs::gibbsLR(const VectorXd &y, const MatrixXd &x,
                              const int gibbsSteps, const int burnin) {
  /* No prior specification
   */
  int J = x.cols();
  int N = x.rows();
  int sampSize = gibbsSteps - burnin;

  double a0, d0, aG, dG;
  a0 = 6.;
  d0 = 2.5;
  MatrixXd B0 = 4 * MatrixXd::Identity(J, J);
  MatrixXd B0inv = B0.inverse();
  VectorXd b0 = MatrixXd::Zero(J, 1);

  MatrixXd B1 = MatrixXd::Zero(J, J);
  VectorXd betaBar = MatrixXd::Zero(J, 1);

  VectorXd Xpy = x.transpose() * y;
  MatrixXd XpX = x.transpose() * x;

  VectorXd sigma2 = MatrixXd::Ones(gibbsSteps, 1);
  MatrixXd beta = MatrixXd::Zero(gibbsSteps, J);

  MatrixXd store = MatrixXd::Zero(J, J);

  aG = a0 + N;

  for (int i = 1; i < gibbsSteps; i++) {
    gibbsBetaUpdates(B1, betaBar, sigma2, XpX, Xpy, B0inv, b0, i);
    store = sigma2(i - 1) * B1;
    beta.row(i) = mvnrnd(betaBar, store, 1, J);

    dG = d0 + y.array().pow(2).sum() + (b0.transpose() * B0inv * b0) -
         (betaBar.transpose() * B1.inverse() * betaBar);
    sigma2(i) = igammarnd(aG * .5,  1./(.5*dG));
  }
  MatrixXd Sample(sampSize, J + 1);
  Sample << sigma2.tail(sampSize), beta.bottomRows(sampSize);
  return Sample;
}

MatrixXd LinRegGibbs::gibbsLR(const VectorXd &y, const MatrixXd &x,
                              const int gibbsSteps, const int burnin,
                              const VectorXd &b0, const MatrixXd &B0,
                              const double a0, const double d0) {
  /* Allow prior specificiation manually
   */
  int J = x.cols();
  int N = x.rows();
  int sampSize = gibbsSteps - burnin;

  double aG, dG;
  MatrixXd B0inv = B0.inverse();

  MatrixXd B1 = MatrixXd::Zero(J, J);
  VectorXd betaBar = MatrixXd::Zero(J, 1);

  VectorXd Xpy = x.transpose() * y;
  MatrixXd XpX = x.transpose() * x;

  VectorXd sigma2 = MatrixXd::Ones(gibbsSteps, 1);
  MatrixXd beta = MatrixXd::Zero(gibbsSteps, J);

  aG = a0 + N;

  for (int i = 1; i < gibbsSteps; i++) {
    gibbsBetaUpdates(B1, betaBar, sigma2, XpX, Xpy, B0inv, b0, 1);
    beta.row(i) = mvnrnd(betaBar, B1, 1, J);

    dG = d0 + (y - (x * beta.row(i).transpose())).array().pow(2).sum();
    sigma2(i) = igammarnd(aG / 2., 2. / dG);
  }
  MatrixXd Sample(sampSize, J + 1);
  Sample << sigma2.tail(sampSize), beta.bottomRows(sampSize);
  return Sample;
}

MatrixXd LinRegGibbs::gibbsRestrictBeta(const VectorXd &y, const MatrixXd &x,
                                        const int gibbsSteps, const int burnin,
                                        const int restrictions) {
  int J = x.cols() - restrictions;
  int N = x.rows();
  int sampSize = gibbsSteps - burnin;
  double a0, d0, aG, dG;
  a0 = 6.;
  d0 = 1. / 5.;
  MatrixXd B0 = 4 * MatrixXd::Identity(J, J);
  MatrixXd B0inv = B0.inverse();
  VectorXd b0 = MatrixXd::Zero(J, 1);
  MatrixXd B1 = MatrixXd::Zero(J, J);
  VectorXd betaBar = MatrixXd::Zero(J, 1);
  VectorXd Xpy = x.transpose() * y;
  MatrixXd XpX = x.transpose() * x;
  VectorXd sigma2 = MatrixXd::Ones(gibbsSteps, 1);
  MatrixXd beta = MatrixXd::Zero(gibbsSteps, J);
  aG = a0 + N;
  for (int i = 1; i < gibbsSteps; i++) {
    gibbsBetaUpdates(B1, betaBar, sigma2, XpX, Xpy, B0inv, b0, 1);
    beta.row(i) = mvnrnd(betaBar, B1, 1, J);
    dG = d0 + (y - (x * beta.row(i).transpose())).array().pow(2).sum();
    sigma2(i) = igammarnd(aG / 2., 1. / (.5 * 2.5));
  }
  MatrixXd Sample(sampSize, J + 1);
  Sample << sigma2.tail(sampSize), beta.bottomRows(sampSize);
  return Sample;
}

void LinRegGibbs::gibbsBetaUpdates(MatrixXd &B1, VectorXd &betaBar,
                                   const VectorXd &sigma2, const MatrixXd &XpX,
                                   const VectorXd &Xpy, const MatrixXd &B0inv,
                                   const VectorXd &b0, int currIteration) {
  B1 = (/*pow(sigma2(currIteration), -1) **/ XpX + B0inv).inverse();
  betaBar = B1 * (/*pow(sigma2(currIteration), -1) * */ Xpy + B0inv * b0);
}

MatrixXd LinRegGibbs::calcOmega(const MatrixXd &theta) {
  int N = theta.rows();
  VectorXd thetaBar = theta.colwise().mean();
  VectorXd temp(theta.cols());
  MatrixXd sum = MatrixXd::Zero(theta.cols(), theta.cols());
  for (int i = 0; i < N; i++) {
    sum += ((theta.row(i) - thetaBar.transpose()).transpose() *
            (theta.row(i) - thetaBar.transpose()))
               .eval();
  }
  return (sum.array() / float(N));
}

int LinRegGibbs::inTheta(const Ref<const MatrixXd> &theta,
                         const Ref<const MatrixXd> &thetaBar,
                         const MatrixXd &Omega) {
  int rt = theta.rows();
  int rtb = thetaBar.rows();
  if (rt != rtb) {
    cout << "Rows not equal: see inTheta" << endl;
    return -1;
  } else if (rt != 1) {
    cout << "Should be row vector: see inTheta" << endl;
    return -1;
  } else {
    int J = Omega.cols();
    boost::math::chi_squared chi(J);
    double chiQuant = quantile(chi, .99);
    if ((((theta - thetaBar) * Omega.inverse()) *
         (theta - thetaBar).transpose())
            .value() <= chiQuant) {
      return 1;
    } else {
      return 0;
    }
  }
}

void LinRegGibbs::analyticalLL(const VectorXd &y, const MatrixXd &x) {
  /* Matlab confirmed */
  int N, J;
  N = x.rows();
  J = x.cols();
  double a0, d0, aG, dG, piterm, Bterm, alphaterm, deltaterm;
  a0 = 6.;
  d0 = 2.5;
  MatrixXd B0 = 4 * MatrixXd::Identity(J, J);
  MatrixXd B0inv = B0.inverse();
  VectorXd b0 = MatrixXd::Zero(J, 1);
  VectorXd Xpy = x.transpose() * y;
  MatrixXd XpX = x.transpose() * x;
  MatrixXd B1 = (XpX + B0inv).inverse();
  VectorXd betaBar = B1 * (Xpy + B0inv * b0);
  aG = a0 + N;
  dG = d0 + y.array().pow(2).sum() + (b0.transpose() * B0inv * b0).value() -
       (betaBar.transpose() * B1.inverse() * betaBar).value();
  piterm = pow(M_PI, -N * .5);
  Bterm = pow(B1.determinant() / B0.determinant(), .5);
  alphaterm = tgamma(aG * .5) / tgamma(a0 * .5);
  deltaterm = pow(d0, a0 * .5) / pow(dG, aG * .5);
  cout << "analytical " << endl;
  cout << log(piterm * alphaterm * Bterm * deltaterm) << endl;
}

void LinRegGibbs::gelfandDeyML(const MatrixXd &sample, const VectorXd &y,
                               const MatrixXd &X) {
  int N = sample.rows();
  int J = sample.cols();
  double a0, d0;
  a0 = 6;
  d0 = 2.5;
  VectorXd thetaBar = sample.colwise().mean();
  MatrixXd Omega = calcOmega(sample);
  MatrixXd OmegaInv = Omega.inverse();
  MatrixXd betaPrior = MatrixXd::Zero(J - 1, 1);
  MatrixXd sigmaPrior = 4 * MatrixXd::Identity(J - 1, J - 1);
  MatrixXd sigmaPriorInv = sigmaPrior.inverse();
  double post, pbeta, psigma, like;
  VectorXd weight = MatrixXd::Zero(N, 1);
  int nonZero = 0;
  for (int i = 0; i < N; i++) {
    if (inTheta(sample.row(i), thetaBar.transpose(), Omega) == 1) {
      nonZero++;
      post = mvnpdfPrecision(thetaBar, OmegaInv, sample.row(i).transpose()) * 1.0101;
      pbeta =
          pow(2 * M_PI * sample(i, 0), -.5*(J - 1) ) *
          pow(sigmaPrior.determinant(), -.5) *
          exp(-pow(2 * sample(i, 0), -1) *
              (sample.row(i).tail(J - 1).transpose() - betaPrior).transpose() *
              sigmaPriorInv *
              (sample.row(i).tail(J - 1).transpose() - betaPrior));
      psigma = igammapdf(.5*a0, 1./(.5*d0), sample(i,0)); 
      like = linearRegLikelihood(y, X, sample.row(i).tail(J - 1).transpose(),
                                 sample(i, 0));
      weight(i) = post / (pbeta * psigma * like);
    }
  }
  VectorXd nzWeights(nonZero);
  cout << nonZero << endl;
  int j = 0;
  for (int i = 0; i < N; i++) {
    if (weight(i) != 0) {
      nzWeights(j) = weight(i);
      j++;
    }
  }
  cout << "gelfand dey" << endl;
  cout << -log(nzWeights.mean()) << endl;
}

