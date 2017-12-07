#ifndef ASK_H
#define ASK_H

#include "Dist.hpp"
#include <Eigen/Dense>

using namespace Eigen;

class Ask : public Dist {
private:
  MatrixXd xNotj;
  VectorXd Hxy;
  VectorXd muNotj;
  VectorXd betaPrior;
  MatrixXd sigmaPrior;
  double igamA, igamB;
  void setPriors(VectorXd &b0, MatrixXd &S0, double, double);
  void setPriors(int);
  void setTemporaries(VectorXd &, VectorXd &, VectorXd &, MatrixXd &, int, int);

public:
  Ask();
  MatrixXd sample;
  int J;
  int Jminus1;
  VectorXd sigmaVector;
  VectorXd mu;
  MatrixXd Kernel;
  void gibbsKernel();

  MatrixXd gibbsKernelT(const VectorXd &a, const VectorXd &b, double df,
                        const VectorXd &theta, const MatrixXd &Sigma,
                        const MatrixXd &draws, MatrixXd &xnot, VectorXd &zstar);

  VectorXd lowerTruncPoints;
  VectorXd upperTruncPoints;
  MatrixXd sigma;
  MatrixXd precision;
  VectorXd zStar;
  VectorXd Hxx;
  int Rows;
  VectorXd weight;

  void conditionalMean(double, VectorXd &, VectorXd &, MatrixXd &, double,
                       VectorXd &);

  void tnormpdf(double, double, VectorXd &, double, double, VectorXd &);

  void adaptiveSampler(double, int, int, int);

  MatrixXd adaptiveSamplerT(const VectorXd &a, const VectorXd &b,
                            const MatrixXd &LinearConstraints,
                            const VectorXd &theta, const MatrixXd &Sigma,
                            double df, double initPeta, int sims, int burnin,
                            int sampleBlockRows, const VectorXd &weight);

  int isVectVgreater(VectorXd &, VectorXd &);

  MatrixXd burninAdaptive(int, int, double);

  MatrixXd burninAdaptiveT(const VectorXd &a, const VectorXd &b,
                           const MatrixXd &LinearConstraints,
                           const VectorXd &mu, const MatrixXd &Sigma, double df,
                           int sims, double initPeta);

  double calcPeta(VectorXd &, VectorXd &);

  double calcPetaT(VectorXd &, VectorXd &, const VectorXd &weight);

  void askKernel(VectorXd &, VectorXd &, VectorXd &, MatrixXd &, int, int, int);

  double askKernelT(const VectorXd &a, const VectorXd &b,
                    const MatrixXd &LinearConstraints, double df,
                    const VectorXd &theta, const MatrixXd &Sigma, int sims,
                    int burnin, int sampleBlockRows, double initPeta,
                    const VectorXd &y, const MatrixXd &X, const VectorXd b0,
                    const MatrixXd &B0, double a0, double d0,
                    const VectorXd &weight);

  double ml(VectorXd &, double, VectorXd &, MatrixXd &);

  double mlT(VectorXd &betas, double sigma, const VectorXd &y,
             const MatrixXd &X, const MatrixXd &kernel, const VectorXd &b0,
             const MatrixXd &B0, double a0, double d0);

  void runSim(int, int, VectorXd &, VectorXd &, VectorXd &, MatrixXd &,
              VectorXd &, MatrixXd &, int, int, int);

  void runTsim(int nSims, int batches, const VectorXd &lowerConstraint,
               const VectorXd &upperConstraint,
               const MatrixXd &LinearConstraints, double df,
               const VectorXd &theta, const MatrixXd &Sigma, const VectorXd &y,
               const MatrixXd &X, int sims, int burnin, int sampleBlockRows,
               double initPeta, const VectorXd &b0, const MatrixXd &B0,
               double a0, double d0, const VectorXd &weight);
};

#endif

