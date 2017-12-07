#include <Eigen/Dense>
#include <boost/math/distributions/normal.hpp>
#include <cstdint>
#include <ctime>
#include <limits>
#include <math.h>

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

double Ask::askKernelT(const VectorXd &a, const VectorXd &b,
                       const MatrixXd &LinearConstraints, double df,
                       const VectorXd &theta, const MatrixXd &Sigma, int sims,
                       int burnin, int sampleBlockRows, double initPeta,
                       const VectorXd &y, const MatrixXd &X, const VectorXd b0,
                       const MatrixXd &B0, double a0, double d0,
                       const VectorXd &weight) {
  int J = Sigma.cols();
  MatrixXd draws =
      adaptiveSamplerT(a, b, LinearConstraints, theta, Sigma, df, initPeta,
                       sims, burnin, sampleBlockRows, weight);
  VectorXd zstar = draws.colwise().mean();
  MatrixXd xnot = draws.rightCols(J-1);
  MatrixXd kernel = gibbsKernelT(a, b, df, theta, Sigma, draws, xnot, zstar);
  VectorXd betas = zstar.tail(J - 1);
  return mlT(betas, zstar(0), y, X, kernel, b0, B0, a0, d0);
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
  igamA = 6;
  igamB = 12;
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
  VectorXd cmeanVect(Rows);
  Hxy = precision.row(0).tail(Jminus1);
  muNotj = mu.tail(Jminus1);
  Kernel.col(0) = Dist::tnormpdfMeanVect(
      lowerTruncPoints(0), upperTruncPoints(0),
      Dist::conditionalMean(Hxx(0), Hxy, muNotj, xNotj, mu(0)), sigmaVector(0),
      zStar(0));
  xNotj.rightCols(Jminus1 - 1) = sample.rightCols(J - 2);
  for (int j = 1; j < Jminus1; j++) {
    muNotj << mu.head(j), mu.tail(Jminus1 - j);
    Hxy << precision.row(j).head(j).transpose().eval(),
        precision.row(j).tail(Jminus1 - j).transpose().eval();
    xNotj.col(j - 1).fill(zStar(j - 1));
    Kernel.col(j) = Dist::tnormpdfMeanVect(
        lowerTruncPoints(j), upperTruncPoints(j),
        Dist::conditionalMean(Hxx(j), Hxy, muNotj, xNotj, mu(j)),
        sigmaVector(j), zStar(j));
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

MatrixXd Ask::gibbsKernelT(const VectorXd &a, const VectorXd &b, double df,
                           const VectorXd &theta, const MatrixXd &Sigma,
                           const MatrixXd &draws, MatrixXd &xnot,
                           VectorXd &zstar) {
  int J = Sigma.cols();
  int Jm1 = J - 1;
  MatrixXd kernel(xnot.rows(), J);
  MatrixXd H = Sigma.inverse();
  VectorXd Hinoti = H.row(0).tail(Jm1);
  VectorXd Hii = H.diagonal();
  VectorXd sigVect = Hii.array().pow(-1).sqrt();
  MatrixXd notj = selectorMat(J);
  VectorXd thetanot = theta.tail(Jm1);
  kernel.col(0) = Dist::ttpdf(
      a(0), b(0), df + Jm1,
      Dist::conditionalMean(Hii(0), Hinoti, thetanot, xnot, theta(0)),
      sigVect(0), zstar(0));
  xnot.rightCols(Jm1 - 1) = draws.rightCols(J - 2);
  for (int j = 1; j < Jm1; j++) {
    thetanot = notj.block(j * (Jm1), 0, Jm1, J) * theta;
    Hinoti = notj.block(j * (Jm1), 0, Jm1, J) * H.row(j).transpose();
    xnot.col(j - 1).fill(zstar(j - 1));
    kernel.col(j) = Dist::ttpdf(
        a(j), b(j), df + Jm1,
        Dist::conditionalMean(Hii(j), Hinoti, thetanot, xnot, theta(j)),
        sigVect(j), zstar(j));
  }
  Hinoti = H.row(Jm1).head(Jm1).transpose();
  thetanot = theta.head(Jm1);
  VectorXd xnotJ = zstar.head(Jm1);
  double thetaJ =
      Dist::conditionalMean(Hii(Jm1), Hinoti, thetanot, xnotJ, theta(Jm1));
  double y =
      Dist::ttpdf(a(Jm1), b(Jm1), df + Jm1, thetaJ, sigVect(Jm1), zstar(Jm1));
  kernel.col(Jm1).fill(y);
  return kernel;
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
      tempSample.middleRows(startingPlace, remainder) = askGhkLinearConstraints(
          lowerTruncPoints, upperTruncPoints, mu, sigma, remainder);
    } else {
      VectorXd initVector = tempSample.row(startingPlace - 1).transpose();
      tempSample.middleRows(startingPlace, remainder) =
          asktmvnrand(lowerTruncPoints, upperTruncPoints, mu, sigma,
                      sigmaVector, initVector, remainder);
    }
  }
  sample = tempSample.bottomRows(sampleSize - burnin);
}

MatrixXd Ask::adaptiveSamplerT(const VectorXd &a, const VectorXd &b,
                               const MatrixXd &LinearConstraints,
                               const VectorXd &theta, const MatrixXd &Sigma,
                               double df, double initPeta, int sampleSize,
                               int burnin, int sampleBlockRows, const VectorXd &weight) {
  /*
   * Should be similar to the average of GHK and Geweke 1991
   */
  int K = Sigma.cols();
  VectorXd rz(K), reta(K);
  VectorXd colj(sampleBlockRows);
  MatrixXd tempSample(sampleSize, K);
  tempSample.setZero();
  tempSample.topRows(burnin) = burninAdaptiveT(a, b, LinearConstraints, theta,
                                               Sigma, df, burnin, initPeta);
  double peta = initPeta;
  int nBlocks, nBlockCount, retaSampled, rzSampled, startingPlace, remainder,
      remainderStartPlace;
  startingPlace = burnin;
  nBlocks = floor((sampleSize - burnin) / sampleBlockRows);
  nBlockCount = nBlocks;
  remainder = (sampleSize - burnin) - (nBlocks * sampleBlockRows);
  remainderStartPlace = sampleSize - remainder;
  retaSampled = 0;
  rzSampled = 0;
  for (int i = 0; i < nBlockCount; i++) {
    if (bernoulli(peta) == 1) {
      tempSample.middleRows(startingPlace, sampleBlockRows) =
          ghkT(a, b, LinearConstraints, theta, Sigma, df, sampleBlockRows, 0);
      colj.resize(sampleBlockRows * (i + 1));
      for (int j = 0; j < K; j++) {
        colj = tempSample.col(j).head(sampleBlockRows * (i + 1));
        reta[j] = 1. / (1. - autoCorr(colj));
      }
      retaSampled = 1;
    } else {
      VectorXd initVector = tempSample.row(startingPlace - 1).transpose();
      tempSample.middleRows(startingPlace, sampleBlockRows) =
          askMvttgeweke91(a, b, LinearConstraints, theta, Sigma, df,
                          sampleBlockRows + 1, 1, initVector);
      colj.resize(sampleBlockRows * (i + 1));
      for (int j = 0; j < K; j++) {
        colj = tempSample.col(j).head(sampleBlockRows * (i + 1));
        rz[j] = 1. / (1 - autoCorr(colj));
      }

      rzSampled = 1;
    }
    if (rzSampled + retaSampled == 2) {
      peta = calcPetaT(rz, reta, weight);
    }
    startingPlace = startingPlace + sampleBlockRows;
  }
  if (remainder != 0) {
    startingPlace = remainderStartPlace;
    if (bernoulli(peta) == 1) {
      tempSample.middleRows(startingPlace, remainder) =
          ghkT(a, b, LinearConstraints, theta, Sigma, df, remainder, 0);
    } else {
      VectorXd initVector = tempSample.row(startingPlace - 1).transpose();
      tempSample.middleRows(startingPlace, remainder) =
          askMvttgeweke91(a, b, LinearConstraints, theta, Sigma, df,
                          remainder + 1, 1, initVector);
    }
  }
  return tempSample.bottomRows(sampleSize - burnin);
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
    sample = askGhkLinearConstraints(lowerTruncPoints, upperTruncPoints, mu,
                                     sigma, sims);
    return sample;
  } else {
    sample = asktmvnrand(lowerTruncPoints, upperTruncPoints, mu, sigma,
                         sigmaVector, initVector, sims);
    return sample;
  }
}

MatrixXd Ask::burninAdaptiveT(const VectorXd &a, const VectorXd &b,
                              const MatrixXd &LinearConstraints,
                              const VectorXd &mu, const MatrixXd &Sigma,
                              double df, int sims, double initPeta) {
  int dim = Sigma.cols();
  MatrixXd draws(sims, dim);
  VectorXd initVector(dim);
  initVector = MatrixXd::Zero(dim, 1);
  if (bernoulli(initPeta)) {
    draws = ghkT(a, b, LinearConstraints, mu, Sigma, df, sims, 0);
    return draws;
  } else {
    draws = askMvttgeweke91(a, b, LinearConstraints, mu, Sigma, df, sims+1, 1, initVector);
    return draws;
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

double Ask::calcPetaT(VectorXd &rz, VectorXd &reta, const VectorXd &weight) {
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

double Ask::mlT(VectorXd &betas, double sigma,const  VectorXd &y, const MatrixXd &X,
               const MatrixXd &kernel, const VectorXd &b0, const MatrixXd &B0,
               double a0, double d0) {
  double mLike = lrLikelihood(betas, sigma, y, X) +
                 logmvnpdfVect(b0, B0, betas) +
                 loginvgammapdf(sigma, a0, d0) -
                 log(kernel.rowwise().prod().mean());
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
  cout << endl;
  cout << setprecision(10) << mLike.mean() << endl;
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

void Ask::runTsim(int nSims, int batches, const VectorXd &lowerConstraint,
                  const VectorXd &upperConstraint,
                  const MatrixXd &LinearConstraints, double df,
                  const VectorXd &theta, const MatrixXd &Sigma,
                  const VectorXd &y, const MatrixXd &X, int sims, int burnin,
                  int sampleBlockRows, double initPeta, const VectorXd &b0,
                  const MatrixXd &B0, double a0, double d0,
                  const VectorXd &weight) {
  VectorXd mLike(nSims);
  for (int i = 0; i < nSims; i++) {
    mLike(i) = askKernelT(lowerConstraint, upperConstraint, LinearConstraints,
                          df, theta, Sigma, sims, burnin, sampleBlockRows,
                          initPeta, y, X, b0, B0, a0, d0, weight);
  }
  cout << setprecision(10) << mLike.mean() << endl;
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
