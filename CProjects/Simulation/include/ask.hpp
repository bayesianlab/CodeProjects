#ifndef ASK_H
#define ASK_H

#include "Dist.hpp"
#include <Eigen/Dense>

using namespace Eigen;

class Ask : public Dist {

public:

  MatrixXd gibbsKernelT(const VectorXd &a, const VectorXd &b, double df,
                        const VectorXd &theta, const MatrixXd &Sigma,
                        const MatrixXd &draws, MatrixXd &xnot, VectorXd &zstar);


  void conditionalMean(double, VectorXd &, VectorXd &, MatrixXd &, double,
                       VectorXd &);

  void tnormpdf(double, double, VectorXd &, double, double, VectorXd &);

  MatrixXd adaptiveSampler(const VectorXd &a, const VectorXd &b, const VectorXd &mu, 
                           const MatrixXd &Sigma, double initPeta,
                           int sampleSize, int burnin, int sampleBlockRows);

  MatrixXd adaptiveSamplerT(const VectorXd &a, const VectorXd &b,
                            const MatrixXd &LinearConstraints,
                            const VectorXd &theta, const MatrixXd &Sigma,
                            double df, double initPeta, int sims, int burnin,
                            int sampleBlockRows, const VectorXd &weight);

  int isVectVgreater(VectorXd &, VectorXd &);

  MatrixXd burninAdaptive(const VectorXd &a, const VectorXd &b,
                          const VectorXd &mu, const MatrixXd &Sigma,
                          const VectorXd &sigmaVectorint, int sims, int J,
                          double initPeta);

  MatrixXd burninAdaptiveT(const VectorXd &a, const VectorXd &b,
                           const MatrixXd &LinearConstraints,
                           const VectorXd &mu, const MatrixXd &Sigma, double df,
                           int sims, double initPeta);

  double calcPeta(VectorXd &rz, VectorXd &reta, const VectorXd &weight);

  double calcPetaT(VectorXd &, VectorXd &, const VectorXd &weight);

  double askKernelT(const VectorXd &a, const VectorXd &b,
                    const MatrixXd &LinearConstraints, double df,
                    const VectorXd &theta, const MatrixXd &Sigma, int sims,
                    int burnin, int sampleBlockRows, double initPeta,
                    const VectorXd &y, const MatrixXd &X, const VectorXd b0,
                    const MatrixXd &B0, double a0, double d0,
                    const VectorXd &weight);

  double ml(const VectorXd &betas, double sigmas, const VectorXd &y,
            const MatrixXd &X, const MatrixXd &kernel, const VectorXd &b0,
            const MatrixXd &B0, double a0, double d0);

  double mlT(VectorXd &betas, double sigma, const VectorXd &y,
             const MatrixXd &X, const MatrixXd &kernel, const VectorXd &b0,
             const MatrixXd &B0, double a0, double d0);

  void runSim(int nSims, int batches, VectorXd &a, VectorXd &b, VectorXd &theta,
              MatrixXd &sig, VectorXd &y, MatrixXd &X, int sims, int burnin,
              int sampleBlockRowsa, const VectorXd &b0, const MatrixXd &B0,
              double a0, double d0);

  void runTsim(int nSims, int batches, const VectorXd &lowerConstraint,
               const VectorXd &upperConstraint,
               const MatrixXd &LinearConstraints, double df,
               const VectorXd &theta, const MatrixXd &Sigma, const VectorXd &y,
               const MatrixXd &X, int sims, int burnin, int sampleBlockRows,
               double initPeta, const VectorXd &b0, const MatrixXd &B0,
               double a0, double d0, const VectorXd &weight);
};

#endif

