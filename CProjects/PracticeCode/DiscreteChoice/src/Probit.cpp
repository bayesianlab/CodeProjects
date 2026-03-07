#include "Probit.hpp"
#include <fstream>
#include <algorithm>
using namespace std;
double Probit::ProbitLogLike(const VectorXd &y, const MatrixXd &X,
                             const VectorXd &beta) {
  VectorXd q = 2 * y.array() - 1;
  VectorXd vals = q.array() * (X * beta).array();
  VectorXd ll(y.size());
  for (int i = 0; i < y.size(); i++) {
    ll(i) = cdf(normalDistribution, vals(i));
  }
  return ll.array().log().sum();
}

void Probit::ProbitMaxLike() {}

void Probit::yStarUpdate(const VectorXd &y, VectorXd &yStar, const MatrixXd &X,
                         const Ref<const VectorXd> &beta) {
  int N = y.size();
  VectorXd vals = X * beta;
  for (int i = 0; i < N; i++) {
    if (y(i) == 0) {
      yStar(i) = truncNormalRnd(-inf, 0, vals(i), 1);
    } else {
      yStar(i) = truncNormalRnd(0, inf, vals(i), 1);
    }
  }
}

void Probit::ProbitDataAug(const VectorXd &y, const MatrixXd &X, VectorXd &b0,
                           MatrixXd &B0, int Sims, int burnin) {
  MatrixXd XpX = X.transpose() * X;
  MatrixXd priorPrecision = B0.inverse();
  int c = 0;
  MatrixXd betaMat(Sims - burnin, X.cols());
  betaMat.setZero();
  VectorXd yStar(y.size());
  B0 = (XpX + priorPrecision).inverse();
  MatrixXd priorsMultiplied = B0 * priorPrecision * b0;
  VectorXd betaBar(X.cols());
  for (int i = 0; i < Sims; i++) {
    yStarUpdate(y, yStar, X, b0);
    betaBar = B0 * (X.transpose() * yStar) + priorsMultiplied;
    b0 = mvnrnd(betaBar, B0, 1).transpose();
    if (i >= burnin) {
      betaMat.row(c) = b0.transpose();
      c++;
    }
  }
  cout << "Posterior Means:" << endl;
  cout << betaMat.colwise().mean() << endl;
  VectorXd betaCol(betaMat.rows());
  betaCol = betaMat.col(0);
  vector<double> post(betaMat.col(0).data(), betaMat.col(0).data() + betaMat.col(0).size());
  sort(post.begin(), post.end());
  cout << "Bayesian Credible Intervals" << endl;
  cout << CredibleIntervals(betaMat) << endl;
  ofstream file("probitPosterior.txt");
  if (file.is_open()) {
    file << betaMat << endl;
    cout << "File written" << endl;
  } else {
    cout << "Error, no file." << endl;
  }
}
