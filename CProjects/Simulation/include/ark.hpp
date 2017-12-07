#ifndef ARK_H
#define ARK_H

#include "Dist.hpp"
#include <Eigen/Dense>

using namespace Eigen;

class Ark : public Dist {
private:
  MatrixXd xNotj;
  VectorXd muNotj;
  VectorXd Hxy;
  VectorXd Hxx;
  VectorXd sigmaVector;
  VectorXd ll;
  VectorXd ul;
  MatrixXd precision;
  MatrixXd sigma;
  int Rows, J, Jminus1;
  string arkWarning =
      "  Exceed max iterations, use custom constructor to alter maximum.\n";
  VectorXd betaPrior;
  MatrixXd sigmaPrior;
  double igamA, igamB;

public:
  Ark();

  MatrixXd arSample(VectorXd &, VectorXd &, VectorXd &, MatrixXd &, int, int);

  MatrixXd acceptRejectT(const VectorXd &a, const VectorXd &b,
                         const MatrixXd &LinearConstraints,
                         const VectorXd &theta, const MatrixXd &Sigma,
                         double df, int sSize, int maxIterations);

  int isVectVgreater(VectorXd &v, VectorXd &u);

  void gibbsKernel();

  void conditionalMean(double, VectorXd &, VectorXd &, MatrixXd &, double,
                       VectorXd &);

  void tnormpdf(double, double, VectorXd &, double, double, VectorXd &);

  void displayMLike();

  MatrixXd arkSample;

  MatrixXd Kernel;

  VectorXd zStar;

  VectorXd mu;

  double ml(VectorXd &, double, VectorXd &, MatrixXd &);

  double mlT(VectorXd &betas, double sigma, const VectorXd &y,
             const MatrixXd &X, const MatrixXd &kernel, const VectorXd &b0,
             const MatrixXd &B0, double a0, double d0);
  
  void arkKernel(VectorXd &, VectorXd &, VectorXd &, MatrixXd &, int, int);

  double arkKernelT(const VectorXd &a, const VectorXd &b,
                    const MatrixXd &LinearConstraints, const VectorXd &theta,
                    const MatrixXd &Sigma, double df, const VectorXd &y,
                    const MatrixXd &X, const VectorXd b0, const MatrixXd B0,
                    double a0, double d0, int sims, int maxIterations);

  MatrixXd gibbsKernelT(const VectorXd &a, const VectorXd &b, double df,
                        const VectorXd &theta, const MatrixXd &Sigma,
                        const MatrixXd &draws, MatrixXd &xnot, VectorXd &zstar);

  void runSim(int nSims, int batches, VectorXd &theta, MatrixXd &sigma,
              VectorXd &y, MatrixXd &X, VectorXd &ll, VectorXd &ul,
              int sampleSize, int );

  void runTsim(int nSims, int batches, const VectorXd &a, const VectorXd &b,
               const MatrixXd &LinearConstraints, double df,
               const VectorXd &theta, const MatrixXd &Sigma, const VectorXd &y,
               const MatrixXd &X, int sims, int maxIter, const VectorXd &b0,
               const MatrixXd &B0, double a0, double d0);
};

#endif

