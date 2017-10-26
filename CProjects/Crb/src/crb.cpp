#include "Crb.hpp"
#include "CreateSampleData.hpp"
#include "Dist.hpp"
#include <Eigen/Dense>
#include <iomanip>
#include <iostream>
#include <math.h>

using namespace Eigen;
using namespace std;

Crb::Crb(int Jm1) {
  cout << "\n\n\tCRB Begin\n\n" << endl;
  setPriors(Jm1);
}

void Crb::setPriors(int J){
  betaPrior = MatrixXd::Zero(J, 1);
  sigmaPrior = MatrixXd::Identity(J, J);
  igamA = 3;
  igamB = 6;
}

int Crb::getReducedRunSampleColumnDimension(int Jminus1) {
  int rrSampleDim = 0;
  for (int j = 2; j <= Jminus1; j++) {
    rrSampleDim = rrSampleDim + j;
  }
  return rrSampleDim;
}

void Crb::fillSigmaVect(VectorXd &sv, VectorXd &Hxx) {
  for (int j = 0; j < sv.size(); j++) {
    sv(j) = sqrt(1 / Hxx(j));
  }
}

double Crb::getfzStarMeanAtCol(double a, double b, MatrixXd &sample, int col,
                               double sigma, double zStar) {
  VectorXd temp(sample.rows());
  for (int i = 0; i < sample.rows(); i++) {

    temp(i) = tnormpdf(a, b, sample(i, col), sigma, zStar);
  }
  return temp.mean();
}

void Crb::fillfzStar(VectorXd &fzStar, int redRuns, VectorXd &a, VectorXd &b,
                     MatrixXd &sample, VectorXd &sigma, VectorXd &zStar) {
  int condMeanIndex = 0;
  int JdimReductionIndex = zStar.size() - 1;
  for (int k = 0; k < redRuns; k++) {
    fzStar(k + 1) = getfzStarMeanAtCol(a(k + 1), b(k + 1), sample,
                                       condMeanIndex + JdimReductionIndex,
                                       sigma(k + 1), zStar(k + 1));
    condMeanIndex = condMeanIndex + JdimReductionIndex * 2;
    JdimReductionIndex--;
  }
}

void Crb::calcfzStar(VectorXd &fzStar, VectorXd &zStar, VectorXd &a,
                     VectorXd &b, MatrixXd &cMeans, VectorXd &sigmaVect) {
  int redRuns = fzStar.size() - 2;
  VectorXd temp(redRuns);
  for (int k = 0; k < redRuns; k++) {
    temp = cMeans.col(k);
    fzStar(k+1) = Dist::tnormpdfMeanVect(a(k + 1), b(k + 1), temp,
                                           sigmaVect(k + 1), zStar(k + 1)).mean();
  }
}

void Crb::chibRaoBlackwell(VectorXd &a, VectorXd &b, VectorXd &mu,
                           MatrixXd &sigma, VectorXd &zStar, VectorXd &fzStar,
                           int sims, int burnin, int rrSims, int rrburnin) {
  /*
   * zStar5 unneeded. J - 2 Reduced Runs because 1 was just calculated and the
   * last will be given
   */
  int J = sigma.cols();
  int Jminus1 = J - 1;
  MatrixXd tmvnsample(sims, 2 * J);
  VectorXd sigv(J);
  tmvnrand(a, b, mu, sigma, tmvnsample, sigv);
  tmvnsample = tmvnsample.bottomRows(sims - burnin).eval();

  int redRuns = J - 2;
  int rrSampleDim = 2 * getReducedRunSampleColumnDimension(Jminus1);
  MatrixXd redRunSample(rrSims, rrSampleDim);
  int sampleSize = sims - burnin;
  int rrSampleSize = rrSims - rrburnin;

  MatrixXd precision = sigma.inverse();
  VectorXd Hxx = precision.diagonal();
  VectorXd sigmaVect(J);
  fillSigmaVect(sigmaVect, Hxx);
  cout << "SIGMA V" << endl;
  cout << sigmaVect << endl;

  VectorXd Hxy(J - 1);
  VectorXd xNotJ(J - 1);
  VectorXd muNotJ(J - 1);

  zStar(0) = tmvnsample.col(0).mean();
  VectorXd temp(sampleSize);
  fzStar(0) = getfzStarMeanAtCol(a(0), b(0), tmvnsample, J, sigv(0), zStar(0));
  double muj;
  int condMeanIndex;
  int JdimensionReductionIndex = Jminus1;
  int drawIndex = 0;
  int drawIndexStartValue = 0;
  int currentDim = Jminus1;
  // Counters:
  // rr = {0, 1, 2, ..., reducedRuns}
  // sim = {1, 2, 3, ..., reducedRunSimulations}
  // decrement = {J,...,2,1,0} Counts down to take less elements becaue the
  // redRunsample dimensions changes drawIndex points to the element of
  // redRunSample where random variates should be put condMeanIndex points  to
  // the element of redRunSample where the conditional mean is put countj =
  // {0,1,2,...,J-1} counts upwards, depends on dimension currentDim =
  // {J-1,...,2}
  for (int rr = 0; rr < redRuns; rr++) {
    for (int sim = 1; sim < rrSims; sim++) {
      int decrement = 0;
      int countj = 0;
      drawIndex = drawIndexStartValue;
      for (int j = rr + 1; j < J; j++) {
        decrement = J - (j + 1);
        muNotJ << mu.head(j), mu.tail(decrement);
        xNotJ.head(rr + 1) = zStar.head(rr + 1);
        xNotJ.tail(currentDim - 1) << redRunSample.row(sim - 1)
                                          .segment(drawIndex - countj, countj)
                                          .transpose()
                                          .eval(),
            redRunSample.row(sim - 1)
                .segment(drawIndex + 1, decrement)
                .transpose()
                .eval();
        countj++;
        Hxy << precision.row(j).head(countj + rr).transpose().eval(),
            precision.row(j).tail(decrement).transpose().eval();
        condMeanIndex = drawIndex + JdimensionReductionIndex;
        muj = conditionalMean(Hxx(j), Hxy, muNotJ, xNotJ, mu(j));
        redRunSample(sim, drawIndex) =
            truncNormalRnd(a(j), b(j), muj, sigmaVect(j));
        redRunSample(sim, condMeanIndex) = muj;
        drawIndex++;
      }
    }
    if (rr == redRuns - 1) {
      zStar.tail(2) << redRunSample.col(drawIndex - JdimensionReductionIndex)
                           .tail(rrSampleSize)
                           .mean(),
          redRunSample.col(drawIndex - JdimensionReductionIndex + 1)
              .tail(rrSampleSize)
              .mean();

    } else {
      zStar(rr + 1) = redRunSample.col(drawIndex - JdimensionReductionIndex)
                          .tail(rrSampleSize)
                          .mean();
      drawIndexStartValue = condMeanIndex + 1;
      drawIndex = drawIndexStartValue;
      JdimensionReductionIndex--;
    }
    currentDim--;
  }

  redRunSample = redRunSample.bottomRows(rrSampleSize);
  fillfzStar(fzStar, redRuns, a, b, redRunSample, sigmaVect, zStar);
  Hxy = precision.row(Jminus1).head(Jminus1);
  muNotJ = mu.head(Jminus1);
  xNotJ = zStar.head(Jminus1);
  muj = conditionalMean(Hxx(Jminus1), Hxy, muNotJ, xNotJ, mu(Jminus1));
  fzStar(Jminus1) =
      tnormpdf(a(Jminus1), b(Jminus1), muj, sigmaVect(Jminus1), zStar(Jminus1));
  cout << "zStar" << endl;
  cout << zStar << endl;
  cout << endl;
  cout << fzStar.transpose() << endl;
}

void Crb::chibRao(VectorXd &a, VectorXd &b, VectorXd &mu, MatrixXd &sigma,
                  int sims, int burnin, int rrSims, int rrburnin) {
  /*
   * zStar5 unneeded. J - 2 Reduced Runs because 1 was just calculated and the
   * last will be given
   */
  int J = sigma.cols();
  int Jminus1 = J - 1;
  int redRuns = J - 2;
  int simsMburin = sims - burnin;
  int rrSimsMburnin = rrSims - rrburnin;
  double muj;
  MatrixXd precision = sigma.inverse();
  VectorXd Hxx = precision.diagonal();
  VectorXd sigmaVect = (1. / Hxx.array()).sqrt();
  MatrixXd sample = MatrixXd::Zero(sims, 2 * J);
  sample = tmultnorm(a, b, mu, sigma, sims);
  sample = sample.bottomRows(simsMburin).eval();
  VectorXd Hxy(Jminus1);
  VectorXd xNotJ(Jminus1);
  VectorXd muNotJ(Jminus1);
  zStar = MatrixXd::Zero(J, 1);
  fzStar = MatrixXd::Zero(J, 1);
  zStar(0) = sample.col(0).mean();
  fzStar(0) = getfzStarMeanAtCol(a(0), b(0), sample, J, sigmaVect(0), zStar(0));

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
        newRedRunSample(sim, j) = truncNormalRnd(a(j), b(j), muj, sigmaVect(j));
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
  conditionalMeanMatrix = conditionalMeanMatrix.bottomRows(rrSimsMburnin).eval();
  calcfzStar(fzStar, zStar, a, b, conditionalMeanMatrix, sigmaVect);
  Hxy = precision.row(Jminus1).head(Jminus1);
  muNotJ = mu.head(Jminus1);
  xNotJ = zStar.head(Jminus1);
  muj = conditionalMean(Hxx(Jminus1), Hxy, muNotJ, xNotJ, mu(Jminus1));
  fzStar(Jminus1) =
      tnormpdf(a(Jminus1), b(Jminus1), muj, sigmaVect(Jminus1), zStar(Jminus1));
  setBetas(Jminus1);
}

void Crb::setBetas(int Jm1){
	betas = zStar.tail(Jm1);
}

double Crb::ml(VectorXd &zStarTail, double zStarHead, VectorXd &y,
               MatrixXd &X) {
  double mLike = lrLikelihood(zStarTail,zStarHead, y, X) +
                 logmvnpdf(betaPrior, sigmaPrior, zStarTail) +
                 loginvgammapdf(zStarHead, igamA, igamB) - log(fzStar.prod());
  return mLike;
}

void Crb::runSim(VectorXd &betas, MatrixXd &sigma, VectorXd &y, MatrixXd &X,
                 VectorXd &ll, VectorXd &ul, int sims, int burnin, int nSims,
                 int batches) {
  int J = betas.size();
  VectorXd b;
  VectorXd mLike(nSims);
  /*for (int i = 0; i < nSims; i++) {
    cout << i << endl;
    chibRaoBlackwell(ll, ul, betas, sigma, zStar, fzStar, sims, burnin, sims,
                     burnin);
    b = zStar.tail(J - 1);
    mLike(i) = ml(b, zStar(0), fzStar, y, X);
  }
  cout << mLike << endl;
  cout << setprecision(10) << mLike.mean() << endl;
  int obsInMean = floor(nSims / batches);
  int remainder = nSims - (batches * obsInMean);
  if (remainder == 0) {
    VectorXd yBar(batches);
    int startIndex = 0;
    for (int j = 0; j < batches; j++) {
      yBar(j) = mLike.segment(startIndex, obsInMean).mean();
      startIndex = startIndex + obsInMean;
    }
  } else {
    VectorXd yBar(batches + 1);
    int startIndex = 0;
    for (int j = 0; j < batches; j++) {
      yBar(j) = mLike.segment(startIndex, obsInMean).mean();
      startIndex = startIndex + obsInMean;
    }
    yBar(batches) = mLike.segment(startIndex, remainder).mean();
    cout << setprecision(10) << standardDev(yBar) << endl;
    ;
  }*/
}

