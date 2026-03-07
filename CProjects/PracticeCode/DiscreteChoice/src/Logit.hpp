#ifndef LOGIT_H
#define LOGIT_H
#include "Dist.hpp"
class Logit:public Dist{
	public:
  VectorXd logitPrime(const VectorXd &y, const MatrixXd &X,
                      const VectorXd &Params);

  MatrixXd logitPrimePrime(const MatrixXd &X, const VectorXd &Params);

  void computeBetaMle(const VectorXd &y, const MatrixXd &X, VectorXd &beta0,
                          MatrixXd &H0, int steps, double tol);

  double LogitLogLikelihood(const VectorXd &y, const MatrixXd &X, const VectorXd &beta);

  void LogitMetropolisHastings(const VectorXd &y, const MatrixXd &X,
                               const VectorXd &priorMean,
                               const MatrixXd &priorVariance, int nu, int iter, int burn);
};
#endif
