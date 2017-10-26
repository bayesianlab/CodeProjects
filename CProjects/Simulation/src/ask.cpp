#include <Eigen/Dense>
#include <assert.h>
#include <boost/math/distributions/bernoulli.hpp>
#include <boost/math/distributions/normal.hpp>
#include <boost/random/mersenne_twister.hpp>
#include <boost/random/uniform_01.hpp>
#include <boost/random/variate_generator.hpp>
#include <cstdint>
#include <ctime>
#include <limits>
#include <math.h>
#include <random>

#include "CreateSampleData.hpp"
#include "Dist.hpp"
#include "ask.hpp"

using namespace Eigen;
using namespace std;

Ask::Ask() {
  // Consider conservativeResize implementation and test to see if works
  // Review code for places where noalias can be implemented
  // Test autoCorr function. it is untested
  // sampleBlockRows, how many rows to recheck the probabilities of switching
  cout << "\n\n\tBegin ASK" << endl;
}

void Ask::askKernel(VectorXd &lowerConstraint, VectorXd &upperConstraint,
                    VectorXd &theta, MatrixXd &sig, int sims, int burnin,
                    int sampleBlockRows) {
  setTemporaries(lowerConstraint, upperConstraint, theta, sig, sims, burnin);
  setPriors(J - 1);
  adaptiveSampler(.5, sims, burnin, sampleBlockRows);
  zStar = sample.colwise().mean();
  xNotj = sample.rightCols(Jminus1);
  gibbsKernel();
}

void Ask::setPriors(VectorXd &b0, MatrixXd &S0, double a0, double d0) {
  betaPrior = b0;
  sigmaPrior = S0;
  igamA = a0;
  igamB = d0;
}
void Ask::setPriors(int betaDim) {
  betaPrior = MatrixXd::Zero(betaDim, 1);
  sigmaPrior = MatrixXd::Identity(betaDim, betaDim);
  igamA = 3;
  igamB = 6;
}

void Ask::setTemporaries(VectorXd &ll, VectorXd &ul, VectorXd &m, MatrixXd &S,
                         int sims, int burnin) {
  J = S.cols();
  Jminus1 = J - 1;
  sigma = S;
  precision = sigma.inverse();
  Hxx = precision.diagonal();
  sigmaVector = (1. / Hxx.array()).sqrt();
  lowerTruncPoints = ll;
  upperTruncPoints = ul;
  mu = m;
  Rows = sims - burnin;
  weight = MatrixXd::Zero(J, 1);
  weight.fill(.5);
  Kernel = MatrixXd::Zero(Rows, J);
  muNotj = MatrixXd::Zero(Jminus1, 1);
  Hxy = MatrixXd::Zero(Jminus1, 1);
  xNotj = MatrixXd::Zero(Rows, Jminus1);
}

void Ask::gibbsKernel() {
  VectorXd tempk(Rows);
  VectorXd cmeanVect(Rows);
  Hxy = precision.row(0).tail(Jminus1);
  muNotj = mu.tail(Jminus1);
  conditionalMean(Hxx(0), Hxy, muNotj, xNotj, mu(0), cmeanVect);
  tnormpdf(lowerTruncPoints(0), upperTruncPoints(0), cmeanVect, sigmaVector(0),
           zStar(0), tempk);
  Kernel.col(0) = tempk;
  xNotj.rightCols(Jminus1 - 1) = sample.rightCols(J - 2);

  for (int j = 1; j < Jminus1; j++) {
    muNotj << mu.head(j), mu.tail(Jminus1 - j);
    Hxy << precision.row(j).head(j).transpose().eval(),
        precision.row(j).tail(Jminus1 - j).transpose().eval();
    xNotj.col(j - 1).fill(zStar(j - 1));
    conditionalMean(Hxx(j), Hxy, muNotj, xNotj, mu(j), cmeanVect);
    tnormpdf(lowerTruncPoints(j), upperTruncPoints(j), cmeanVect,
             sigmaVector(j), zStar(j), tempk);
    Kernel.col(j) = tempk;
  }

  Hxy << precision.row(Jminus1).head(Jminus1).transpose();
  muNotj = mu.head(Jminus1);
  VectorXd xnotJ = zStar.head(Jminus1);
  double muJ =
      Dist::conditionalMean(Hxx(Jminus1), Hxy, muNotj, xnotJ, mu(Jminus1));
  double y =
      Dist::tnormpdf(lowerTruncPoints(Jminus1), upperTruncPoints(Jminus1), muJ,
                     sigmaVector(Jminus1), zStar(Jminus1));
  Kernel.col(Jminus1).fill(y);
}

void Ask::conditionalMean(double Hxx, VectorXd &Hxy, VectorXd &muNotj,
                          MatrixXd &xNotj, double muxx,
                          VectorXd &conditionalMeanVector) {
  xNotj.rowwise() -= muNotj.transpose();
  conditionalMeanVector = muxx - ((1 / Hxx) * xNotj * Hxy).array();
}

void Ask::tnormpdf(double a, double b, VectorXd &mu, double sigma, double x,
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

void Ask::adaptiveSampler(double initPeta, int sampleSize, int burnin,
                          int sampleBlockRows) {
  /*
   * Should be similar to the average of GHK and Geweke 1991
   */

  VectorXd rz(J), reta(J);
  VectorXd colj(sampleBlockRows);
  MatrixXd tempSample;
  double peta = initPeta;
  int nBlocks, nBlockCount, retaSampled, rzSampled, startingPlace, remainder,
      remainderStartPlace;
  startingPlace = burnin;
  nBlocks = floor((sampleSize - burnin) / sampleBlockRows);
  nBlockCount = nBlocks;
  remainder = (sampleSize - burnin) - (nBlocks * sampleBlockRows);
  remainderStartPlace = sampleSize - remainder;
  tempSample = MatrixXd::Zero(sampleSize, J);
  // Burnin period
  tempSample.topRows(burnin) = burninAdaptive(burnin, J, .5);
  retaSampled = 0;
  rzSampled = 0;

  for (int i = 0; i < nBlockCount; i++) {
    if (bernoulli(peta) == 1) {
      cout << "sample with ghk" << endl;
      tempSample.middleRows(startingPlace, sampleBlockRows) =
          askGhkLinearConstraints(lowerTruncPoints, upperTruncPoints, mu, sigma,
                                  sampleBlockRows);
      colj.resize(sampleBlockRows * (i + 1));
      for (int j = 0; j < J; j++) {
        colj = tempSample.col(j).head(sampleBlockRows * (i + 1));
        reta[j] = 1. / (1. - autoCorr(colj));
      }
      retaSampled = 1;
    } else {
      cout << "sample with geweke 91" << endl;
      VectorXd initVector = tempSample.row(startingPlace - 1).transpose();
      tempSample.middleRows(startingPlace, sampleBlockRows) =
          asktmvnrand(lowerTruncPoints, upperTruncPoints, mu, sigma,
                      sigmaVector, initVector, sampleBlockRows);
      colj.resize(sampleBlockRows * (i + 1));
      for (int j = 0; j < J; j++) {
        colj = tempSample.col(j).head(sampleBlockRows * (i + 1));
        rz[j] = 1. / (1 - autoCorr(colj));
      }
      rzSampled = 1;
    }
    if (rzSampled + retaSampled == 2) {
      peta = calcPeta(rz, reta);
    }
    startingPlace = startingPlace + sampleBlockRows;
  }
  if (remainder != 0) {
    startingPlace = remainderStartPlace;
    if (bernoulli(peta) == 1) {
      cout << "sample with ghk remainder" << endl;
      tempSample.middleRows(startingPlace, remainder) = askGhkLinearConstraints(
          lowerTruncPoints, upperTruncPoints, mu, sigma, remainder);
    } else {
      cout << "sample with geweke 91 remainder" << endl;
      VectorXd initVector = tempSample.row(startingPlace - 1).transpose();
      tempSample.middleRows(startingPlace, remainder) =
          asktmvnrand(lowerTruncPoints, upperTruncPoints, mu, sigma,
                      sigmaVector, initVector, remainder);
    }
  }
  sample = tempSample.bottomRows(sampleSize - burnin);
}

int Ask::isVectVgreater(VectorXd &v, VectorXd &u) {
  if ((v.array() > u.array()).all() == 1) {
    return 1;
  } else {
    return 0;
  }
}

MatrixXd Ask::burninAdaptive(int sims, int J, double initPeta) {
  MatrixXd sample(sims, J);
  VectorXd initVector(J);
  initVector = MatrixXd::Zero(J, 1);
  if (bernoulli(initPeta)) {
    cout << "sample with ghk init" << endl;
    sample = askGhkLinearConstraints(lowerTruncPoints, upperTruncPoints, mu,
                                     sigma, sims);
    return sample;
  } else {
    cout << "sample with geweke 1991 init" << endl;
    sample = asktmvnrand(lowerTruncPoints, upperTruncPoints, mu, sigma,
                         sigmaVector, initVector, sims);
    return sample;
  }
}

double Ask::calcPeta(VectorXd &rz, VectorXd &reta) {
  if (isVectVgreater(rz, reta) == 1) {
    return 1.;
  } else if (isVectVgreater(reta, rz) == 1) {
    return 0.;
  } else {
    double wTrz = weight.transpose() * rz;
    return wTrz / (wTrz + (weight.transpose() * reta));
  }
}

double Ask::ml(VectorXd &betas, double sigmas, VectorXd &y, MatrixXd &X) {
  double mLike = lrLikelihood(betas, sigmas, y, X) +
                 logmvnpdf(betaPrior, sigmaPrior, betas) +
                 loginvgammapdf(sigmas, igamA, igamB) -
                 log(Kernel.rowwise().prod().mean());
  return mLike;
}

void Ask::runSim(int nSims, int batches, VectorXd &lowerConstraint,
                 VectorXd &upperConstraint, VectorXd &theta, MatrixXd &sig,
                 VectorXd &y, MatrixXd &X, int sims, int burnin,
                 int sampleBlockRows) {
  VectorXd mLike(nSims);
  VectorXd b(Jminus1);
  for (int i = 0; i < nSims; i++) {
    askKernel(lowerConstraint, upperConstraint, theta, sig, sims, burnin,
              sampleBlockRows);
    b = zStar.tail(Jminus1);
    mLike(i) = ml(b, zStar(0), y, X);
  }
  int obsInMean = floor(nSims / batches);
  int remainder = nSims - (batches * obsInMean);
  if (remainder == 0) {
    VectorXd yBar(batches);
    int startIndex = 0;
    for (int j = 0; j < batches; j++) {
      yBar(j) = mLike.segment(startIndex, obsInMean).mean() ;
      startIndex = startIndex + obsInMean;
    }
	cout << yBar << endl;
  } else {
    VectorXd yBar(batches + 1);
    int startIndex = 0;
    for (int j = 0; j < batches; j++) {
      yBar(j) = mLike.segment(startIndex, obsInMean).mean();
      startIndex = startIndex + obsInMean;
    }
    yBar(batches) = mLike.segment(startIndex, remainder).mean();
	cout << setprecision(10) << yBar << endl;
	cout << endl;
	cout << setprecision(10) << standardDev(yBar) << endl;;
  }

}
