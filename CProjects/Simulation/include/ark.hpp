#ifndef ARK_H
#define ARK_H

#include "Dist.hpp"
#include <Eigen/Dense>

using namespace Eigen;

class Ark : public Dist {
private:
  VectorXd Hxx;
  string arkWarning =
      "  Exceed max iterations, use custom constructor to alter maximum.\n";

public:
  MatrixXd arSample(const VectorXd &, const VectorXd &, const VectorXd &,
                    const MatrixXd &, int, int);

  MatrixXd acceptRejectT(const VectorXd &a, const VectorXd &b,
                         const MatrixXd &LinearConstraints,
                         const VectorXd &theta, const MatrixXd &Sigma,
                         double df, int sSize, int maxIterations);

  int isVectVgreater(VectorXd &v, VectorXd &u);

  void conditionalMean(double, VectorXd &, VectorXd &, MatrixXd &, double,
                       VectorXd &);

  void tnormpdf(double, double, VectorXd &, double, double, VectorXd &);

  double ml(const VectorXd &, double, const VectorXd &, const MatrixXd &X,
            const MatrixXd &Kernel, const VectorXd &b0, const MatrixXd &B0,
            double a0, double d0);

  double mlT(VectorXd &betas, double sigma, const VectorXd &y,
             const MatrixXd &X, const MatrixXd &kernel, const VectorXd &b0,
             const MatrixXd &B0, double a0, double d0);

  double arkKernelT(const VectorXd &a, const VectorXd &b,
                    const MatrixXd &LinearConstraints, const VectorXd &theta,
                    const MatrixXd &Sigma, double df, const VectorXd &y,
                    const MatrixXd &X, const VectorXd b0, const MatrixXd B0,
                    double a0, double d0, int sims, int maxIterations);

  MatrixXd gibbsKernelT(const VectorXd &a, const VectorXd &b, double df,
                        const VectorXd &theta, const MatrixXd &Sigma,
                        const MatrixXd &draws, MatrixXd &xnot, VectorXd &zstar);

  void runSim(int nSims, int batches, const VectorXd &theta,
              const MatrixXd &sigma, const VectorXd &y, const MatrixXd &X,
              const VectorXd &ll, const VectorXd &ul, int sampleSize,
              int maxIterations, const VectorXd &b0, const MatrixXd &B0,
              double a0, double d0);

  void runTsim(int nSims, int batches, const VectorXd &a, const VectorXd &b,
               const MatrixXd &LinearConstraints, double df,
               const VectorXd &theta, const MatrixXd &Sigma, const VectorXd &y,
               const MatrixXd &X, int sims, int maxIter, const VectorXd &b0,
               const MatrixXd &B0, double a0, double d0);
};

#endif

