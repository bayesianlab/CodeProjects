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

void Crb::setPriors(int J) {
  betaPrior = MatrixXd::Zero(J, 1);
  sigmaPrior = MatrixXd::Identity(J, J);
  igamA = 3;
  igamB = 6;
}

double Crb::getfzStarMeanAtCol(double a, double b, MatrixXd &sample, int col,
                               double sigma, double zStar) {
  VectorXd temp(sample.rows());
  for (int i = 0; i < sample.rows(); i++) {

    temp(i) = tnormpdf(a, b, sample(i, col), sigma, zStar);
  }
  return temp.mean();
}

void Crb::calcfzStar(VectorXd &fzStar, VectorXd &zStar, VectorXd &a,
                     VectorXd &b, MatrixXd &cMeans, VectorXd &sigmaVect) {
  int redRuns = fzStar.size() - 2;
  VectorXd temp(redRuns);
  for (int k = 0; k < redRuns; k++) {
    temp = cMeans.col(k);
    fzStar(k + 1) = Dist::tnormpdfMeanVect(a(k + 1), b(k + 1), temp,
                                           sigmaVect(k + 1), zStar(k + 1))
                        .mean();
  }
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
  conditionalMeanMatrix =
      conditionalMeanMatrix.bottomRows(rrSimsMburnin).eval();
  calcfzStar(fzStar, zStar, a, b, conditionalMeanMatrix, sigmaVect);
  Hxy = precision.row(Jminus1).head(Jminus1);
  muNotJ = mu.head(Jminus1);
  xNotJ = zStar.head(Jminus1);
  muj = conditionalMean(Hxx(Jminus1), Hxy, muNotJ, xNotJ, mu(Jminus1));
  fzStar(Jminus1) =
      tnormpdf(a(Jminus1), b(Jminus1), muj, sigmaVect(Jminus1), zStar(Jminus1));
  setBetas(Jminus1);
}

void Crb::setBetas(int Jm1) { betas = zStar.tail(Jm1); }

double Crb::ml(VectorXd &zStarTail, double zStarHead, VectorXd &y,
               MatrixXd &X) {
  double mLike = lrLikelihood(zStarTail, zStarHead, y, X) +
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
  for (int i = 0; i < nSims; i++) {
    chibRao(ll, ul, betas, sigma, sims, burnin, sims, burnin);
    b = zStar.tail(J - 1);
    mLike(i) = ml(b, zStar(0), y, X);
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

