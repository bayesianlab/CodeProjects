#include "crb.hpp"
#include "CreateSampleData.hpp"
#include "Dist.hpp"
#include <Eigen/Dense>
#include <iomanip>
#include <iostream>
#include <math.h>

using namespace Eigen;
using namespace std;

double Crb::getfzStarMeanAtCol(double a, double b, MatrixXd &sample, int col,
                               double sigma, double zStar) {
  VectorXd temp(sample.rows());
  for (int i = 0; i < sample.rows(); i++) {
    temp(i) = tnormpdf(a, b, sample(i, col), sigma, zStar);
  }
  return temp.mean();
}

double Crb::getfzStarMeanAtColT(double a, double b, MatrixXd &sample, int colm,
                                double sigma, double zStar, double df) {
  return ttpdf(a, b, df, sample.col(colm), sigma, zStar).mean();
}

void Crb::calcfzStar(VectorXd &fzStar, const VectorXd &zStar, const VectorXd &a,
                     const VectorXd &b, const MatrixXd &cMeans,
                     const VectorXd &sigmaVect) {
  int redRuns = fzStar.size() - 2;
  VectorXd temp(redRuns);
  for (int k = 0; k < redRuns; k++) {
    temp = cMeans.col(k);
    fzStar(k + 1) = Dist::tnormpdfMeanVect(a(k + 1), b(k + 1), temp,
                                           sigmaVect(k + 1), zStar(k + 1))
                        .mean();
  }
}

void Crb::calcfzStarT(VectorXd &fzStar, VectorXd &zStar, const VectorXd &a,
                      const VectorXd &b, double df, MatrixXd &cMeans,
                      VectorXd &sigmaVect) {
  int redRuns = fzStar.size() - 2;
  for (int k = 0; k < redRuns; k++) {
    fzStar(k + 1) = Dist::ttpdf(a(k + 1), b(k + 1), df, cMeans.col(k),
                                sigmaVect(k + 1), zStar(k + 1))
                        .mean();
  }
}

MatrixXd Crb::chibRaoT(const VectorXd &a, const VectorXd &b,
                       const MatrixXd &LinearConstraints, const VectorXd &mu,
                       const MatrixXd &sigma, double df, int sims, int burnin,
                       int rrSims, int rrburnin) {
  /*
   * zStar5 unneeded. J - 2 Reduced Runs because 1 was just calculated and the
   * last will be given
   */
  int J = sigma.cols();
  int Jminus1 = J - 1;
  int redRuns = J - 2;
  int rrSimsMburnin = rrSims - rrburnin;
  double muj;
  MatrixXd precision = sigma.inverse();
  VectorXd Hxx = precision.diagonal();
  VectorXd sigmaVect = (1. / Hxx.array()).sqrt();
  MatrixXd sample = MatrixXd::Zero(sims, 2 * J);
  sample = mvttgeweke91(a, b, LinearConstraints, mu, sigma, df, sims, burnin);
  VectorXd Hxy(Jminus1);
  VectorXd xNotJ(Jminus1);
  VectorXd muNotJ(Jminus1);
  VectorXd zStar = MatrixXd::Zero(J, 1);
  VectorXd fzStar = MatrixXd::Zero(J, 1);
  zStar(0) = sample.col(0).mean();
  fzStar(0) = getfzStarMeanAtColT(a(0), b(0), sample, J, sigmaVect(0), zStar(0),
                                  df + Jminus1);
  MatrixXd newRedRunSample = MatrixXd::Zero(rrSims, J);
  newRedRunSample.col(0).fill(zStar(0));
  MatrixXd conditionalMeanMatrix(rrSims, redRuns);
  for (int rr = 0; rr < redRuns; rr++) {
    for (int sim = 1; sim < rrSims; sim++) {
      int truej = 0;
      for (int j = rr + 1; j < J; j++) {
        muNotJ << mu.head(j), mu.tail(Jminus1 - j);
        xNotJ << newRedRunSample.row(sim - 1).head(j).transpose().eval(),
            newRedRunSample.row(sim - 1).tail(Jminus1 - j).transpose().eval();
        Hxy << precision.row(j).head(j).transpose().eval(),
            precision.row(j).tail(Jminus1 - j).transpose().eval();
        muj = conditionalMean(Hxx(j), Hxy, muNotJ, xNotJ, mu(j));
        newRedRunSample(sim, j) =
            truncTrnd(a(j), b(j), muj, sigmaVect(j), df + Jminus1);
        if (truej == 0) {
          conditionalMeanMatrix(sim, rr) = muj;
        }
        truej++;
      }
    }
    if (rr == redRuns - 1) {
      zStar.tail(2) = newRedRunSample.rightCols(2)
                          .bottomRows(rrSimsMburnin)
                          .colwise()
                          .mean();
      newRedRunSample.col(rr + 1).fill(zStar(rr + 1));
    } else {
      zStar(rr + 1) = newRedRunSample.col(rr + 1).tail(rrSimsMburnin).mean();
      newRedRunSample.col(rr + 1).fill(zStar(rr + 1));
    }
  }
  newRedRunSample = newRedRunSample.bottomRows(rrSimsMburnin).eval();
  conditionalMeanMatrix =
      conditionalMeanMatrix.bottomRows(rrSimsMburnin).eval();
  calcfzStarT(fzStar, zStar, a, b, J + Jminus1, conditionalMeanMatrix,
              sigmaVect);
  Hxy = precision.row(Jminus1).head(Jminus1);
  muNotJ = mu.head(Jminus1);
  xNotJ = zStar.head(Jminus1);
  muj = conditionalMean(Hxx(Jminus1), Hxy, muNotJ, xNotJ, mu(Jminus1));
  fzStar(Jminus1) = ttpdf(a(Jminus1), b(Jminus1), J + Jminus1, muj,
                          sigmaVect(Jminus1), zStar(Jminus1));
  MatrixXd fzAndzStar(J, 2);
  fzAndzStar << fzStar, zStar;
  return fzAndzStar;
}

MatrixXd Crb::chibRao(const VectorXd &a, const VectorXd &b, const VectorXd &mu,
                      const MatrixXd &sigma, int sims, int burnin, int rrSims,
                      int rrburnin) {
  int J = sigma.cols();
  int Jminus1 = J - 1;
  int redRuns = J - 2;
  int simsMburin = sims - burnin;
  int rrSimsMburnin = rrSims - rrburnin;
  double muj;
  MatrixXd notjMat = selectorMat(J);
  MatrixXd precision = sigma.inverse();
  VectorXd Hxx = precision.diagonal();
  VectorXd sigmaVect = (1. / Hxx.array()).sqrt();
  MatrixXd sample = MatrixXd::Zero(sims, 2 * J);
  sample = tmultnorm(a, b, mu, sigma, sims);
  sample = sample.bottomRows(simsMburin).eval();
  VectorXd Hxy(Jminus1);

  VectorXd xNotJ(Jminus1);
  VectorXd muNotJ(Jminus1);
  VectorXd zStar = MatrixXd::Zero(J, 1);
  VectorXd fzStar = MatrixXd::Zero(J, 1);
  zStar(0) = sample.col(0).mean();
  fzStar(0) =
      tnormpdfMeanVect(a(0), b(0), sample.col(J), sigmaVect(0), zStar(0))
          .mean();
  MatrixXd newRedRunSample = MatrixXd::Zero(rrSims, J);
  newRedRunSample.col(0).fill(zStar(0));
  MatrixXd conditionalMeanMatrix(rrSims, redRuns);
  VectorXd updateVec(J);
  updateVec = newRedRunSample.row(0).transpose();
  for (int rr = 0; rr < redRuns; rr++) {
    for (int sim = 1; sim < rrSims; sim++) {
      int truej = 0;
      for (int j = rr + 1; j < J; j++) {
        muNotJ = notjMat.block(j * (Jminus1), 0, Jminus1, J) * mu;
        xNotJ = notjMat.block(j * (Jminus1), 0, Jminus1, J) * updateVec;
        Hxy = notjMat.block(j * (Jminus1), 0, Jminus1, J) *
              precision.row(j).transpose();
        muj = conditionalMean(Hxx(j), Hxy, muNotJ, xNotJ, mu(j));
        updateVec(j) = truncNormalRnd(a(j), b(j), muj, sigmaVect(j));
        if (truej == 0) {
          conditionalMeanMatrix(sim, rr) = muj;
        }
        truej++;
      }
      newRedRunSample.row(sim) = updateVec.transpose();
    }
    if (rr == redRuns - 1) {

      zStar.tail(2) = newRedRunSample.rightCols(2)
                          .bottomRows(rrSimsMburnin)
                          .colwise()
                          .mean();
      newRedRunSample.col(rr + 1).fill(zStar(rr + 1));
    } else {
      zStar(rr + 1) = newRedRunSample.col(rr + 1).tail(rrSimsMburnin).mean();
      newRedRunSample.col(rr + 1).fill(zStar(rr + 1));
    }
  }
  newRedRunSample = newRedRunSample.bottomRows(rrSimsMburnin).eval();
  conditionalMeanMatrix =
      conditionalMeanMatrix.bottomRows(rrSimsMburnin).eval();
  calcfzStar(fzStar, zStar, a, b, conditionalMeanMatrix, sigmaVect);
  Hxy = precision.row(Jminus1).head(Jminus1);
  muNotJ = mu.head(Jminus1);
  xNotJ = zStar.head(Jminus1);
  muj = conditionalMean(Hxx(Jminus1), Hxy, muNotJ, xNotJ, mu(Jminus1));
  fzStar(Jminus1) =
      tnormpdf(a(Jminus1), b(Jminus1), muj, sigmaVect(Jminus1), zStar(Jminus1));

  VectorXd betas = zStar.tail(Jminus1);
  MatrixXd T(J, 2);
  T << fzStar, zStar;
  return T;
}

MatrixXd Crb::chibRao(const VectorXd &a, const VectorXd &b, const VectorXd &mu,
                      const MatrixXd &sigma, int sims, int burnin, int rrSims,
                      int rrburnin, int updatezStar) {
  int J = sigma.cols();
  int Jminus1 = J - 1;
  int redRuns = J - 2;
  int simsMburin = sims - burnin;
  int rrSimsMburnin = rrSims - rrburnin;
  double muj;
  MatrixXd notjMat = selectorMat(J);
  MatrixXd precision = sigma.inverse();
  VectorXd Hxx = precision.diagonal();
  VectorXd sigmaVect = (1. / Hxx.array()).sqrt();
  MatrixXd sample = MatrixXd::Zero(sims, 2 * J);
  sample = tmultnorm(a, b, mu, sigma, sims);
  sample = sample.bottomRows(simsMburin).eval();
  MatrixXd Hxy(J, Jminus1);
  for (int j = 0; j < J; j++) {
    Hxy.row(j) = notjMat.block(j * (Jminus1), 0, Jminus1, J) *
                     precision.row(j).transpose();
  }
  VectorXd xNotJ(Jminus1);
  VectorXd muNotJ(Jminus1);
  VectorXd zStar = MatrixXd::Zero(J, 1);
  VectorXd fzStar = MatrixXd::Zero(J, 1);
  zStar(0) = sample.col(0).mean();
  fzStar(0) =
      tnormpdfMeanVect(a(0), b(0), sample.col(J), sigmaVect(0), zStar(0))
          .mean();
  MatrixXd newRedRunSample = MatrixXd::Zero(rrSims, J);
  newRedRunSample.col(0).fill(zStar(0));
  MatrixXd conditionalMeanMatrix(rrSims, redRuns);
  VectorXd updateVec(J);
  updateVec = newRedRunSample.row(0).transpose();
  for (int rr = 0; rr < redRuns; rr++) {
    for (int sim = 1; sim < rrSims; sim++) {
      int truej = 0;
      for (int j = rr + 1; j < J; j++) {
        muNotJ = notjMat.block(j * (Jminus1), 0, Jminus1, J) * mu;
        xNotJ = notjMat.block(j * (Jminus1), 0, Jminus1, J) * updateVec;
        muj = conditionalMean(Hxx(j), Hxy.row(j), muNotJ, xNotJ, mu(j));
        updateVec(j) = truncNormalRnd(a(j), b(j), muj, sigmaVect(j));
        if (truej == 0) {
          conditionalMeanMatrix(sim, rr) = muj;
        }
        truej++;
      }
      newRedRunSample.row(sim) = updateVec.transpose();
    }
    if (rr == redRuns - 1) {
      if (updatezStar) {
        zStar.tail(2) = newRedRunSample.rightCols(2)
                            .bottomRows(rrSimsMburnin)
                            .colwise()
                            .mean();
      }
      fzStar(rr + 1) = tnormpdfMeanVect(a(rr + 1), b(rr + 1),
                                        conditionalMeanMatrix.col(rr).tail(
                                            rrSims - rrburnin),
                                        sigmaVect(rr + 1), zStar(rr + 1))
                           .mean();
      muj = conditionalMean(Hxx(Jminus1), Hxy.row(Jminus1),
                            mu.head(Jminus1), zStar.head(Jminus1), mu(Jminus1));
      fzStar(Jminus1) = tnormpdf(a(Jminus1), b(Jminus1), muj,
                                 sigmaVect(Jminus1), zStar(Jminus1));
    } else {
      if (updatezStar) {
        zStar(rr + 1) = newRedRunSample.col(rr + 1).tail(rrSimsMburnin).mean();
      }
      newRedRunSample.col(rr + 1).fill(zStar(rr + 1));
      fzStar(rr + 1) =
          tnormpdfMeanVect(
              a(rr + 1), b(rr + 1),
              conditionalMeanMatrix.col(rr).tail(rrSimsMburnin),
              sigmaVect(rr + 1), zStar(rr + 1))
              .mean();
    }
  }
  MatrixXd T(J, 2);
  T << fzStar, zStar;
  return T;
}

double Crb::ml(const VectorXd &fzStar, const VectorXd &zStarTail,
               double zStarHead, const VectorXd &y, const MatrixXd &X,
               const VectorXd &b0, const MatrixXd &B0, const double igamA,
               const double igamB) {
  double mLike = lrLikelihood(zStarTail, zStarHead, y, X) +
                 logmvnpdf(b0, B0, zStarTail) +
                 loginvgammapdf(zStarHead, igamA, igamB) - log(fzStar.prod());
  return mLike;
}

double Crb::mlCRB(const VectorXd &fzStar, const VectorXd &zStarTail,
                  double zStarHead, VectorXd &y, MatrixXd &X, VectorXd &b0,
                  MatrixXd &B0, double a0, double d0) {
  double mLike = lrLikelihood(zStarTail, zStarHead, y, X) +
                 logmvnpdfVect(b0, B0, zStarTail) +
                 loginvgammapdf(zStarHead, a0, d0) - log(fzStar.prod());
  return mLike;
}

void Crb::runSim(VectorXd &betas, MatrixXd &sigma, VectorXd &y, MatrixXd &X,
                 VectorXd &ll, VectorXd &ul, int sims, int burnin, int nSims,
                 int batches) {
  int J = betas.size();
  VectorXd b(J);
  VectorXd fz(J);
  MatrixXd fzandz(J,2);
  VectorXd mLike(nSims);
  VectorXd b0 = MatrixXd::Zero(J - 1, 1);
  MatrixXd B0 = MatrixXd::Identity(J - 1, J - 1);
  for (int i = 0; i < nSims; i++) {
    fzandz = chibRao(ll, ul, betas, sigma, sims, burnin, sims, burnin);
    b = fzandz.col(1).tail(J - 1);
    fz = fzandz.col(0);
    mLike(i) = ml(fz, b, fzandz(0, 1), y, X, b0, B0, 6, 12);
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

void Crb::runTsim(VectorXd &betas, MatrixXd &sigma, double df, VectorXd &y,
                  MatrixXd &X, VectorXd &ll, VectorXd &ul,
                  const MatrixXd &LinearConstraints, VectorXd &b0, MatrixXd &B0,
                  double a0, double d0, int sims, int burnin, int nSims,
                  int batches) {
  int J = betas.size();
  VectorXd mLike(nSims);
  MatrixXd fzAndz(J, 2);
  VectorXd fz;
  VectorXd z;
  for (int i = 0; i < nSims; i++) {

    fzAndz = chibRaoT(ll, ul, LinearConstraints, betas, sigma, df, sims, burnin,
                      sims, burnin);
    fz = fzAndz.col(0);
    z = fzAndz.col(1);
    mLike(i) = mlCRB(fz, z.tail(J - 1), z(0), y, X, b0, B0, a0, d0);
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

