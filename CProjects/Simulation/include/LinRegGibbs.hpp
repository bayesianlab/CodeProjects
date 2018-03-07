#ifndef LINREGDIST_H
#define LINREGDIST_H
#include "Dist.hpp"

class LinRegGibbs : public Dist {

public:
  void lrCondPriorsGibbs(const VectorXd &, const MatrixXd &, const int,
                         const int, const VectorXd &, const MatrixXd &, double,
                         double);

  MatrixXd gibbsLR(const VectorXd &, const MatrixXd &, const int, const int,
                   const VectorXd &, const MatrixXd &, double, double);

  MatrixXd gibbsLRCondtionalPrior(const VectorXd &, const MatrixXd &x,
                                  const int, const int, const VectorXd &b0,
                                  const MatrixXd &B0, const double a0,
                                  const double d0);

  MatrixXd gibbsRestrictBeta(const VectorXd &, const MatrixXd &,
                             const VectorXd &, const VectorXd &, const int,
                             const int, const VectorXd &, const MatrixXd &,
                             const double, const double);

  void gibbsBetaUpdatesCondtionalPrior(MatrixXd &, VectorXd &, const VectorXd &,
                                       const MatrixXd &, const VectorXd &,
                                       const MatrixXd &, const VectorXd &, int);

  void gibbsBetaUpdates(MatrixXd &, VectorXd &, const VectorXd &,
                        const MatrixXd &, const VectorXd &, const MatrixXd &,
                        const VectorXd &, int);

  MatrixXd calcOmega(const MatrixXd &);

  void analyticalLL(const VectorXd &y, const MatrixXd &x);

  int inTheta(const Ref<const MatrixXd> &, const Ref<const MatrixXd> &,
              const MatrixXd &);

  double gelfandDeyMLConditionalPrior(const MatrixXd &, const VectorXd &,
                                      const MatrixXd &, const VectorXd &,
                                      const MatrixXd &, double, double);

  double gelfandDeyML(const MatrixXd &, const VectorXd &, const MatrixXd &, 
                      const VectorXd &mle, const MatrixXd &ifish,
                      const VectorXd &, const MatrixXd &, double, double);

  double modifiedGelfandDey(const VectorXd &a, const VectorXd &b,
                            const MatrixXd &sample, const VectorXd &y,
                            const MatrixXd &X, const VectorXd &mle,
                            const MatrixXd &ifish, const VectorXd &b0,
                            const MatrixXd &B0, const double a0,
                            const double d0);

  double modifiedGelfandDeyT(const VectorXd &a, const VectorXd &b,
                             const MatrixXd &sample, const double df,
                             const VectorXd &y, const MatrixXd &X,
                             const VectorXd &mle, const MatrixXd &ifish,
                             const VectorXd &b0, const MatrixXd &B0,
                             const double a0, const double d0);

  double priorBetaMvnPdf(const VectorXd &mu,
                         const Ref<const MatrixXd> &precision,
                         const Ref<const MatrixXd> &x);

  double priorBetaMvnPdf(const VectorXd &mu,
                         const Ref<const MatrixXd> &precision, const double,
                         const Ref<const MatrixXd> &x);

  double lrRestrictMLGD(const VectorXd &mu, const MatrixXd &sigma,
                        const VectorXd &y, const MatrixXd &X, const VectorXd &a,
                        const VectorXd &b, const VectorXd &b0,
                        const MatrixXd &B0, const double a0, const double d0,
                        const int gibbsSteps, const int burnin);

  double lrRestrictModifiedGD(const VectorXd &mu, const MatrixXd &sigma,
                              const VectorXd &y, const MatrixXd &X,
                              const VectorXd &a, const VectorXd &b,
                              const VectorXd &b0, const MatrixXd &B0,
                              const double a0, const double d0,
                              const int gibbsSteps, const int burnin);

  double lrRestrictGDT(const VectorXd &mu, const MatrixXd &sigma,
                       const VectorXd &y, const MatrixXd &X, const VectorXd &a,
                       const VectorXd &b, const MatrixXd LinearConstraints,
                       double df, const VectorXd &b0, const MatrixXd &B0,
                       const double a0, const double d0, const int gibbsSteps,
                       const int burnin);

  double lrRestrictModifiedGDT(const VectorXd &mu, const MatrixXd &sigma,
                               const VectorXd &y, const MatrixXd &X,
                               const VectorXd &a, const VectorXd &b,
                               const MatrixXd LinearConstraints, double df,
                               const VectorXd &b0, const MatrixXd &B0,
                               const double a0, const double d0,
                               const int gibbsSteps, const int burnin);

  void runSim(int nSims, int batches, const VectorXd &lowerConstraint,
              const VectorXd &upperConstraint, const VectorXd &theta,
              const MatrixXd &sig, const VectorXd &y, const MatrixXd &X,
              const VectorXd &b0, const MatrixXd &B0, const double a0,
              const double d0, const int sims, const int burnin);

  void runSimModified(int nSims, int batches, const VectorXd &lowerConstraint,
              const VectorXd &upperConstraint, const VectorXd &theta,
              const MatrixXd &sig, const VectorXd &y, const MatrixXd &X,
              const VectorXd &b0, const MatrixXd &B0, const double a0,
              const double d0, const int sims, const int burnin);

  void runTsim(int nSims, int batches, const VectorXd &lowerConstraint,
               const VectorXd &upperConstraint,
               const MatrixXd LinearConstraints, double df,
               const VectorXd &theta, const MatrixXd &sig, const VectorXd &y,
               const MatrixXd &X, const VectorXd &b0, const MatrixXd &B0,
               const double a0, const double d0, const int sims,
               const int burnin);

  void runTsimModified(int nSims, int batches, const VectorXd &lowerConstraint,
                       const VectorXd &upperConstraint,
                       const MatrixXd LinearConstraints, double df,
                       const VectorXd &theta, const MatrixXd &sig,
                       const VectorXd &y, const MatrixXd &X, const VectorXd &b0,
                       const MatrixXd &B0, const double a0, const double d0,
                       const int sims, const int burnin);
};


#endif
