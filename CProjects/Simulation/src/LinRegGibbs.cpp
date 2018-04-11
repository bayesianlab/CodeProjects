#include "LinRegGibbs.hpp"
#include <Eigen/Dense>
#include <boost/math/distributions/chi_squared.hpp>
#include <math.h>

using namespace Eigen;

LinRegGibbs::LinRegGibbs(){};

LinRegGibbs::LinRegGibbs(int x){
	rseed.seed(x);
}

void LinRegGibbs::lrCondPriorsGibbs(const VectorXd &y, const MatrixXd &x,
                                    const int gibbsSteps, const int burnin,
                                    const VectorXd &b0, const MatrixXd &B0,
                                    double a0, double d0) {
  MatrixXd sample =
      gibbsLRCondtionalPrior(y, x, gibbsSteps, burnin, b0, B0, a0, d0);
  double ml = gelfandDeyMLConditionalPrior(sample, y, x, b0, B0, a0, d0);
  cout << "\nPosterior Means: " << endl;
  cout << sample.colwise().mean() << endl;
  cout << "Log Marginal Likelihood of model Gelfand-Dey: " << endl;
  cout << ml << endl;
  cout << "Log Analytical Marginal Likelihood: " << endl;
  analyticalLL(y, x);
}

MatrixXd LinRegGibbs::gibbsLR(const VectorXd &y, const MatrixXd &x,
                              const int gibbsSteps, const int burnin,
                              const VectorXd &b0, const MatrixXd &B0, double a0,
                              double d0) {
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
    gibbsBetaUpdates(B1, betaBar, sigma2, XpX, Xpy, B0inv, b0, i);
    beta.row(i) = mvnrnd(betaBar, B1, 1);
    dG = d0 + y.array().pow(2).sum() + (b0.transpose() * B0inv * b0) -
         (betaBar.transpose() * B1.inverse() * betaBar);
    sigma2(i) = igammarnd(aG * .5, 1. / (.5 * dG));
  }
  MatrixXd Sample(sampSize, J + 1);
  Sample << sigma2.tail(sampSize), beta.bottomRows(sampSize);
  return Sample;
}

MatrixXd
LinRegGibbs::gibbsLRCondtionalPrior(const VectorXd &y, const MatrixXd &x,
                                    const int gibbsSteps, const int burnin,
                                    const VectorXd &b0, const MatrixXd &B0,
                                    const double a0, const double d0) {
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
  MatrixXd store = MatrixXd::Zero(J, J);
  for (int i = 1; i < gibbsSteps; i++) {
    gibbsBetaUpdatesCondtionalPrior(B1, betaBar, sigma2, XpX, Xpy, B0inv, b0,
                                    i);
    store = sigma2(i - 1) * B1;
    beta.row(i) = mvnrnd(betaBar, store, 1);
    dG = d0 + (y - (x * beta.row(i).transpose())).array().pow(2).sum();
    sigma2(i) = igammarnd(aG / 2., 2. / dG);
  }
  MatrixXd Sample(sampSize, J + 1);
  Sample << sigma2.tail(sampSize), beta.bottomRows(sampSize);
  return Sample;
}

MatrixXd LinRegGibbs::gibbsRestrictBeta(const VectorXd &y, const MatrixXd &x,
                                        const VectorXd &a, const VectorXd &b,
                                        const int gibbsSteps, const int burnin,
                                        const VectorXd &b0, const MatrixXd &B0,
                                        const double a0, const double d0) {
  int N = x.rows();
  int J = x.cols();
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
    gibbsBetaUpdates(B1, betaBar, sigma2, XpX, Xpy, B0inv, b0, i);
    beta.row(i) =
        tmultnorm(a, b, beta.row(i - 1), betaBar, B1, 2).row(1).head(J);
    dG = d0 + (y - (x * beta.row(i).transpose())).array().pow(2).sum();
    sigma2(i) = igammarnd(aG * .5, 1. / (.5 * dG));
  }
  MatrixXd Sample(sampSize, J + 1);
  Sample << sigma2.tail(sampSize), beta.bottomRows(sampSize);
  return Sample;
}

void LinRegGibbs::gibbsBetaUpdatesCondtionalPrior(
    MatrixXd &B1, VectorXd &betaBar, const VectorXd &sigma2,
    const MatrixXd &XpX, const VectorXd &Xpy, const MatrixXd &B0inv,
    const VectorXd &b0, int currIteration) {
  B1 = (XpX + B0inv).inverse();
  betaBar = B1 * (Xpy + B0inv * b0);
}

void LinRegGibbs::gibbsBetaUpdates(MatrixXd &B1, VectorXd &betaBar,
                                   const VectorXd &sigma2, const MatrixXd &XpX,
                                   const VectorXd &Xpy, const MatrixXd &B0inv,
                                   const VectorXd &b0, int currIteration) {
  B1 = (pow(sigma2(currIteration), -1) * XpX + B0inv).inverse();
  betaBar = B1 * (pow(sigma2(currIteration), -1) * Xpy + B0inv * b0);
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
                         const MatrixXd &precision) {

  int J = precision.cols();
  boost::math::chi_squared chi(J);
  double chiQuant = quantile(chi, .99);
  VectorXd xMmu = theta - thetaBar;
  if ((xMmu.transpose() * precision * xMmu).value() <= chiQuant) {
    return 1;
  } else {
    return 0;
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
  cout << log(piterm * alphaterm * Bterm * deltaterm) << endl;
}

double LinRegGibbs::gelfandDeyMLConditionalPrior(
    const MatrixXd &sample, const VectorXd &y, const MatrixXd &X,
    const VectorXd &b0, const MatrixXd &B0, const double a0, const double d0) {
  int N = sample.rows();
  int J = sample.cols();
  VectorXd thetaBar = sample.colwise().mean();
  MatrixXd Omega = calcOmega(sample);
  MatrixXd OmegaInv = Omega.inverse();
  MatrixXd sigmaPriorInv = B0.inverse();
  double post, pbeta, psigma, like;
  VectorXd weight = MatrixXd::Zero(N, 1);
  VectorXd logWeight = MatrixXd::Zero(N, 1);
  int nonZero = 0;
  double normalizer = 1/.99;
  for (int i = 0; i < N; i++) {
    if (inTheta(sample.row(i).transpose(), thetaBar, OmegaInv) == 1) {
      post = mvnpdfPrecision(thetaBar, OmegaInv, sample.row(i).transpose()) *
             normalizer;
      pbeta = priorBetaMvnPdf(b0, sigmaPriorInv, sample(i, 0),
                              sample.row(i).tail(J - 1).transpose());
      psigma = igammapdf(.5 * a0, 1. / (.5 * d0), sample(i, 0));
      like = linearRegLikelihood(y, X, sample.row(i).tail(J - 1).transpose(),
                                 sample(i, 0));
      weight(nonZero) = post / (pbeta * psigma * like);
      logWeight(nonZero) = -log(post) + log(pbeta * psigma * like);
      nonZero++;
    }
  }
  return -log(weight.head(nonZero).mean());
}

double LinRegGibbs::modifiedGelfandDey(const VectorXd &a, const VectorXd &b,
                                       const MatrixXd &sample, VectorXd &logpdf,
                                       const VectorXd &y, const MatrixXd &X,
                                       const VectorXd &mle,
                                       const MatrixXd &ifish,
                                       const VectorXd &b0, const MatrixXd &B0,
                                       const double a0, const double d0) {

  int N = sample.rows();
  int J = sample.cols();
  MatrixXd OmegaInv = ifish.inverse();
  int nonZero = 0;
  VectorXd post(N);
  VectorXd pbeta(N);
  VectorXd psigma(N);
  VectorXd like(N);
  double normalizer = 1. / .99;
  for (int i = 0; i < N; i++) {
    if (inTheta(sample.row(i).transpose(), mle, OmegaInv) == 1) {
	  post(nonZero) =  logpdf(i);
      pbeta(nonZero) = logmvnpdf(
          b0, B0, sample.row(i).tail(J - 1).transpose());
      psigma(nonZero) = loginvgammapdf(sample(i, 0), a0, d0);
      like(nonZero) = lrLikelihood(sample.row(i).tail(J - 1).transpose(),
                                   sample(i, 0), y, X);
      nonZero++;
    }
  }
  if (nonZero == N) {
    return pdfmean(-post + pbeta + psigma + like);
  } else {
    post = post.array() + log(normalizer);
    return pdfmean(-post.head(nonZero) + pbeta.head(nonZero) +
                   psigma.head(nonZero) + like.head(nonZero));
  }
}

double LinRegGibbs::modifiedGelfandDeyT(
    const VectorXd &a, const VectorXd &b, const MatrixXd &sample,
    VectorXd &logpdf, const double df, const VectorXd &y, const MatrixXd &X,
    const VectorXd &mle, const MatrixXd &ifish, const VectorXd &b0,
    const MatrixXd &B0, const double a0, const double d0) {
  int N = sample.rows();
  int J = sample.cols();
  MatrixXd OmegaInv = ifish.inverse();
  int nonZero = 0;
  VectorXd post(N);
  VectorXd pbeta(N);
  VectorXd psigma(N);
  VectorXd like(N);
  double normalizer = 1. / .99;
  for (int i = 0; i < N; i++) {
    if (inTheta(sample.row(i).transpose(), mle, OmegaInv) == 1) {
      post(nonZero) = logpdf(i);
      pbeta(nonZero) = logmvnpdfPrecision(
          b0, B0.inverse(), sample.row(i).tail(J - 1).transpose());
      psigma(nonZero) = loginvgammapdf(sample(i, 0), a0, d0);
      like(nonZero) = lrLikelihood(sample.row(i).tail(J - 1).transpose(),
                                   sample(i, 0), y, X);
      nonZero++;
    }
  }
  if (nonZero == N) {
    return pdfmean(-post + pbeta + psigma + like);
  } else {
    post = post.array() + log(normalizer);
    return pdfmean(-post.head(nonZero) + pbeta.head(nonZero) +
                   psigma.head(nonZero) + like.head(nonZero));
  }
}

double LinRegGibbs::priorBetaMvnPdf(const VectorXd &mu,
                                    const Ref<const MatrixXd> &precision,
                                    const Ref<const MatrixXd> &x) {
  int J = mu.rows();
  int K = x.rows();
  int C = x.cols();
  if (J != K) {
    cout << "x and mu must be same, see LinRegGibbs::priorBetaMvnPdf" << endl;
    return -inf;
  } else if (C != 1) {
    cout << "x must be column vector see LinRegGibbs::priorBetaMvnPdf" << endl;
    return -inf;
  } else {
    return pow(2 * M_PI, -.5 * J) * pow(precision.determinant(), .5) *
           exp(-.5 * ((x - mu).transpose() * precision * (x - mu)).value());
  }
}

double LinRegGibbs::priorBetaMvnPdf(const VectorXd &mu,
                                    const Ref<const MatrixXd> &precision,
                                    const double scale,
                                    const Ref<const MatrixXd> &x) {
  int J = mu.rows();
  int K = x.rows();
  int C = x.cols();
  if (J != K) {
    cout << "x and mu must be same, see LinRegGibbs::priorBetaMvnPdf" << endl;
    return -inf;
  } else if (C != 1) {
    cout << "x must be column vector see LinRegGibbs::priorBetaMvnPdf" << endl;
    return -inf;
  } else {
    return pow(2 * M_PI * scale, -.5 * J) * pow(precision.determinant(), .5) *
           exp(-.5 * pow(scale, -1) *
               ((x - mu).transpose() * precision * (x - mu)).value());
  }
}



double LinRegGibbs::lrRestrictModifiedGD(
    const VectorXd &mu, const MatrixXd &sigma, const VectorXd &y,
    const MatrixXd &X, const VectorXd &a, const VectorXd &b, const VectorXd &b0,
    const MatrixXd &B0, const double a0, const double d0, const int gibbsSteps,
    const int burnin) {
  int J = sigma.cols();
  VectorXd logpdf(gibbsSteps);
  MatrixXd R = ghkLinearConstraints(a, b, mu, sigma, gibbsSteps, logpdf);
  return modifiedGelfandDey(a, b, R, logpdf, y, X, mu, sigma, b0, B0, a0, d0);
}


double LinRegGibbs::lrRestrictModifiedGDT(
    const VectorXd &mu, const MatrixXd &sigma, const VectorXd &y,
    const MatrixXd &X, const VectorXd &a, const VectorXd &b,
    const MatrixXd LinearConstraints, double df, const VectorXd &b0,
    const MatrixXd &B0, const double a0, const double d0, const int gibbsSteps,
    const int burnin) {
  int J = sigma.cols();
  VectorXd iV = MatrixXd::Zero(J, 1);
  VectorXd logpdf(gibbsSteps);
  MatrixXd R = ghkT(a, b, LinearConstraints, mu, sigma, df, gibbsSteps, logpdf);
  return modifiedGelfandDeyT(a,b,R,logpdf, J+1, y, X, mu, sigma, b0, B0, a0, d0);
}

void LinRegGibbs::runSimModified(int nSims, int batches,
                                 const VectorXd &lowerConstraint,
                                 const VectorXd &upperConstraint,
                                 const VectorXd &theta, const MatrixXd &sig,
                                 const VectorXd &y, const MatrixXd &X,
                                 const VectorXd &b0, const MatrixXd &B0,
                                 const double a0, const double d0,
                                 const int sims, const int burnin) {
  int J = sig.cols();
  int Jminus1 = J - 1;
  VectorXd mLike(nSims);
  for (int i = 0; i < nSims; i++) {
    mLike(i) =
        lrRestrictModifiedGD(theta, sig, y, X, lowerConstraint,
                              upperConstraint, b0, B0, a0, d0, sims, burnin);
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

void LinRegGibbs::runTsimModified(
    int nSims, int batches, const VectorXd &lowerConstraint,
    const VectorXd &upperConstraint, const MatrixXd LinearConstraints,
    double df, const VectorXd &theta, const MatrixXd &sig, const VectorXd &y,
    const MatrixXd &X, const VectorXd &b0, const MatrixXd &B0, const double a0,
    const double d0, const int sims, const int burnin) {
  int J = sig.cols();
  int Jminus1 = J - 1;
  VectorXd mLike(nSims);
  for (int i = 0; i < nSims; i++) {
    mLike(i) = lrRestrictModifiedGDT(theta, sig, y, X, lowerConstraint,
                                     upperConstraint, LinearConstraints, df, b0,
                                     B0, a0, d0, sims, burnin);
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
