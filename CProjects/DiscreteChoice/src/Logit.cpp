#include "Dist.hpp"
#include "Logit.hpp"
#include "CreateSampleData.hpp"
#include <Eigen/Dense>
#include <boost/math/distributions/logistic.hpp>
#include <math.h>
#include <iostream>
#include <algorithm>
#include <fstream>

using namespace boost::math;
using namespace std;

VectorXd Logit::logitPrime(const VectorXd &y, const MatrixXd &X,
                           const VectorXd &Params) {
  VectorXd vals = y.array() - logisticcdf(X * Params).array();
  return (X.array().colwise() * vals.array()).colwise().sum();
}

MatrixXd Logit::logitPrimePrime(const MatrixXd &X,
                                const VectorXd &Params) {
  VectorXd logisticcdfVals = logisticcdf(X * Params);
  MatrixXd sum(X.cols(), X.cols());
  sum.setZero();
  for (int i = 0; i < X.rows(); i++) {
    sum += (logisticcdfVals(i) * (1. - logisticcdfVals(i)) *
            (X.row(i).transpose() * X.row(i)).array())
               .matrix();
  }
  return -sum;
}

void Logit::computeBetaMle(const VectorXd &y, const MatrixXd &X,
                               VectorXd &beta0, MatrixXd &H0, int steps,
                               double tol) {
  VectorXd beta1(X.cols());
  VectorXd firstDeriv(beta0.size());
  int stopFlag = 0;
  int ns =0;
  while(stopFlag == 0 && ns < steps){
    firstDeriv = logitPrime(y, X, beta0);
    H0 = logitPrimePrime(X, beta0);
    beta1 =
        beta0 +
        H0.jacobiSvd(ComputeThinU | ComputeThinV).solve(-firstDeriv);
    if ((beta1 - beta0).norm() < tol) {
	  beta0 = beta1;
	  stopFlag = 1;
      cout << "Newton Iterations: " << ns << endl;
      cout << "Function Value:    " << firstDeriv.transpose() << endl;
      cout << "MLE:               " << beta1.transpose() << endl;
	  cout << "Hessian:           " << endl;
	  cout << H0 << endl;
	  cout << endl;
    } else {
      beta0 = beta1;
      ns++;
	}
  }
  if( ns == steps ){
	  cout << "ERROR: No convergence." << endl;
  }
}

double Logit::LogitLogLikelihood(const VectorXd &y, const MatrixXd &X,
                                 const VectorXd &beta) {
  VectorXd q = (2 * y.array()) - 1;
  double ll = logisticcdf(q.array() * (X * beta).array()).array().log().sum();
  return ll;
}

void Logit::LogitMetropolisHastings(const VectorXd &y, const MatrixXd &X,
                                    const VectorXd &priorMean,
                                    const MatrixXd &priorVariance, int nu,
                                    int iter, int burn) {
  cout << "Logit MH" << endl;
  VectorXd proposal(X.cols());
  VectorXd old(X.cols());
  VectorXd beta0 = MatrixXd::Zero(X.cols(), 1);
  MatrixXd H0(X.cols(), X.cols());
  computeBetaMle(y, X, beta0, H0, 20, 1e-4);
  boost::random::uniform_01<> u;
  double num, den, udraw, alpha;
  MatrixXd posterior(iter, X.cols());
  posterior.setZero();
  old.setZero();
  H0 = -H0.inverse();
  for (int i = 0; i < iter; i++) {
    proposal = mvtrnd(beta0, H0, nu, 1).transpose();
    num = LogitLogLikelihood(y, X, proposal) +
          logmvnpdf(priorMean, priorVariance, proposal) +
          log(mvtpdf(old, beta0, H0, nu));
    den = LogitLogLikelihood(y, X, old) +
          logmvnpdf(priorMean, priorVariance, old) +
          log(mvtpdf(proposal, beta0, H0, nu));
    alpha = min(0., num - den);
    udraw = log(u(rseed));
    if (udraw < alpha) {
      posterior.row(i) = proposal.transpose();
      old = proposal;
    } else {
      posterior.row(i) = old.transpose();
    }
  }
  cout << "Posterior Distribution Mean: " << endl;
  cout << posterior.bottomRows(iter -burn).colwise().mean() << endl;
  cout << endl;
  ofstream file("posterior.txt");
  if(file.is_open()){
	  file << posterior << endl;
	  cout << "File written" << endl;
  }else{
	  cout << "Error, no file." << endl;
  }
}

