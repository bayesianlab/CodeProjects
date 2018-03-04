#ifndef CRT_H
#define CRT_H
#include "Dist.hpp"
#include <Eigen/Dense>

using namespace Eigen;

class Crt : public Dist {
public:

  double crtTML(const VectorXd &a, const VectorXd &b,
                const MatrixXd &LinearConstraints, const VectorXd &mu,
                const MatrixXd &Sigma, const VectorXd &y, const MatrixXd &X,
                double df, int sims, int burnin, const VectorXd &b0,
                const MatrixXd &B0, double a0, double d0);



  double getKernelColumn(double a, double b, MatrixXd &sample, int col,
                         double sigma, double zStar);

  VectorXd conditionalMean(double, VectorXd &, VectorXd &, MatrixXd , double);

  void tnormpdf(double, double, VectorXd &, double, double, VectorXd &);

  double ml(const VectorXd &zStarTail, double zStarHead, const MatrixXd &Kernel,
            const VectorXd &y, const MatrixXd &X, const VectorXd &b0,
            const MatrixXd &B0, double a0, double d0);

  double mlT(const VectorXd &, double, const VectorXd &, const MatrixXd &,
             MatrixXd &Kernel, const VectorXd &b0, const MatrixXd &B0,
             double a0, double d0);

  void runSim(int nsims, int batches, const VectorXd &a, const VectorXd &b,
              VectorXd &mu, MatrixXd &Sigma, VectorXd &y, MatrixXd &X, int sims,
              int burnin, const VectorXd &b0, const MatrixXd &B0, double a0,
              double d0);

  void runTsim(int nsims, int batches, const VectorXd &a, const VectorXd &b,
               const MatrixXd &LinearConstraints, double df,
               const VectorXd &theta, const MatrixXd &Sigma, const VectorXd &y,
               const MatrixXd &X, int sims, int burnin, const VectorXd &b0,
               const MatrixXd &B0, double a0, double d0);
};
#endif
