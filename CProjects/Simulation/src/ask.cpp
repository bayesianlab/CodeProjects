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

MatrixXd Ask::adaptiveSampler(const VectorXd &a, const VectorXd &b, const VectorXd &mu,
                              const MatrixXd &Sigma, double initPeta,
                              int sampleSize, int burnin, int sampleBlockRows) {
  /*
   * Should be similar to the average of GHK and Geweke 1991
   */

  int nBlocks, nBlockCount, retaSampled, rzSampled, startingPlace, remainder,
      remainderStartPlace, J;
  J = Sigma.cols();
  VectorXd rz(J);
  VectorXd reta(J);
  VectorXd colj(sampleBlockRows);
  MatrixXd tempSample;
  double peta = initPeta;
  startingPlace = burnin;
  nBlocks = floor((sampleSize - burnin) / sampleBlockRows);
  nBlockCount = nBlocks;
  remainder = (sampleSize - burnin) - (nBlocks * sampleBlockRows);
  remainderStartPlace = sampleSize - remainder;
  VectorXd sigmaVector = Sigma.inverse().diagonal().array().pow(-1).sqrt();
  tempSample = MatrixXd::Zero(sampleSize, J);
  // Burnin period
  tempSample.topRows(burnin) =
      burninAdaptive(a, b, mu, Sigma, sigmaVector, burnin, J, .5);
  retaSampled = 0;
  rzSampled = 0;
  VectorXd weight = MatrixXd::Ones(J,1);
  weight.fill(1);
  for (int i = 0; i < nBlockCount; i++) {
    if (bernoulli(peta) == 1) {
      tempSample.middleRows(startingPlace, sampleBlockRows) =
          askGhkLinearConstraints(a, b, mu, Sigma,
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
          asktmvnrand(a, b, mu, Sigma,
                      sigmaVector, initVector, sampleBlockRows);
      colj.resize(sampleBlockRows * (i + 1));
      for (int j = 0; j < J; j++) {
        colj = tempSample.col(j).head(sampleBlockRows * (i + 1));
        rz[j] = 1. / (1 - autoCorr(colj));
      }
      rzSampled = 1;
    }
    if (rzSampled + retaSampled == 2) {
      peta = calcPeta(rz, reta, weight);
    }
    startingPlace = startingPlace + sampleBlockRows;
  }
  if (remainder != 0) {
    startingPlace = remainderStartPlace;
    if (bernoulli(peta) == 1) {
      tempSample.middleRows(startingPlace, remainder) = askGhkLinearConstraints(
          a, b, mu, Sigma, remainder);
    } else {
      VectorXd initVector = tempSample.row(startingPlace - 1).transpose();
      tempSample.middleRows(startingPlace, remainder) =
          asktmvnrand(a, b, mu, Sigma,
                      sigmaVector, initVector, remainder);
    }
  }
  return tempSample.bottomRows(sampleSize - burnin);
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

MatrixXd Ask::burninAdaptive(const VectorXd &a, const VectorXd &b,
                             const VectorXd &mu, const MatrixXd &Sigma,
                             const VectorXd &sigmaVector, int sims, int J,
                             double initPeta) {
  MatrixXd Sample(sims, J);
  VectorXd initVector(J);
  initVector = MatrixXd::Zero(J, 1);
  if (bernoulli(initPeta)) {
    Sample = askGhkLinearConstraints(a, b, mu, Sigma, sims);
    return Sample;
  } else {
    Sample = asktmvnrand(a, b, mu, Sigma, sigmaVector, initVector, sims);
    return Sample;
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

double Ask::calcPeta(VectorXd &rz, VectorXd &reta, const VectorXd &weight) {
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
double Ask::ml(const VectorXd &betas, double sigmas, const VectorXd &y,
               const MatrixXd &X, const MatrixXd &kernel, const VectorXd &b0,
               const MatrixXd &B0, double a0, double d0) {

  double mLike = lrLikelihood(betas, sigmas, y, X) + logmvnpdf(b0, B0, betas) +
                 loginvgammapdf(sigmas, a0, d0) -
                 log(kernel.rowwise().prod().mean());
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

void Ask::runSim(int nSims, int batches, VectorXd &a, VectorXd &b,
                 VectorXd &theta, MatrixXd &sig, VectorXd &y, MatrixXd &X,
                 int sims, int burnin, int sampleBlockRows, const VectorXd &b0,
                 const MatrixXd &B0, double a0, double d0) {
  int J = sig.cols();
  int Jm1 = J - 1;
  VectorXd zStar(J);
  VectorXd betas(Jm1);
  VectorXd mLike(nSims);
  MatrixXd Sample(sims, burnin);
  MatrixXd xNotj(sims-burnin, J-1);
  for (int i = 0; i < nSims; i++) {
    Sample = adaptiveSampler(a, b, theta, sig, .5, sims, burnin, sampleBlockRows);
    zStar = Sample.colwise().mean();
    xNotj = Sample.rightCols(Jm1);
    MatrixXd K = gibbsKernel(a, b, theta, sig, Sample, zStar);
    betas = zStar.tail(Jm1);
    mLike(i) = ml(betas, zStar(0), y, X, K, b0, B0, a0, d0);
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

void Ask::runTsim(int nSims, int batches, const VectorXd &a, const VectorXd &b,
                  const MatrixXd &LinearConstraints, double df,
                  const VectorXd &theta, const MatrixXd &Sigma,
                  const VectorXd &y, const MatrixXd &X, int sims, int burnin,
                  int sampleBlockRows, double initPeta, const VectorXd &b0,
                  const MatrixXd &B0, double a0, double d0,
                  const VectorXd &weight) {
  VectorXd mLike(nSims);
  for (int i = 0; i < nSims; i++) {
    mLike(i) =
        askKernelT(a, b, LinearConstraints, df, theta, Sigma, sims, burnin,
                   sampleBlockRows, initPeta, y, X, b0, B0, a0, d0, weight);
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
