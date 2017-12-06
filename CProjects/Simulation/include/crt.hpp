#ifndef CRT_H
#define CRT_H
#include "Dist.hpp"
#include <Eigen/Dense>

using namespace Eigen;

class Crt : public Dist {
private:
  MatrixXd precision;
  VectorXd Hxx;
  MatrixXd xNotj;
  VectorXd muNotj;
  VectorXd Hxy;
  int J;
  int Rows;
  int Jminus1;
  VectorXd ll;
  VectorXd ul;
  VectorXd mu;
  MatrixXd Sigma;
  VectorXd xnotJ;
  VectorXd betaPrior;
  MatrixXd sigmaPrior;
  double igamB, igamA;

public:
  Crt();

  void crtKernel(VectorXd &, VectorXd &, VectorXd &, MatrixXd &, int, int);

  double crtTML(const VectorXd &a, const VectorXd &b,
                const MatrixXd &LinearConstraints, const VectorXd &mu,
                const MatrixXd &Sigma, const VectorXd &y, const MatrixXd &X,
                double df, int sims, int burnin, const VectorXd &b0,
                const MatrixXd &B0, double a0, double d0);

  void gibbsKernel();

  MatrixXd gibbsTKernel(const VectorXd &a, const VectorXd &b,
                        const MatrixXd &LinearConstraints,
                        const MatrixXd &sample, VectorXd &zstar, double df,
                        const VectorXd &mu, const MatrixXd &Sigma,
                        const VectorXd &y, const MatrixXd &X, int sims,
                        int burnin);
  MatrixXd Kernel;
  VectorXd zStar;
  MatrixXd truncatedSample;
  VectorXd sigmaVector;

  double getKernelColumn(double a, double b, MatrixXd &sample, int col,
                         double sigma, double zStar);

  VectorXd conditionalMean(double, VectorXd &, VectorXd &, MatrixXd , double);

  void tnormpdf(double, double, VectorXd &, double, double, VectorXd &);

  double ml(VectorXd &, double, VectorXd &, MatrixXd &);

  double mlT(const VectorXd &, double, const VectorXd &, const MatrixXd &,
             MatrixXd &Kernel, const VectorXd &b0, const MatrixXd &B0,
             double a0, double d0);

  void runSim(int nsims, int batches, VectorXd &lowerconstraint,
            VectorXd &upperconstraint, VectorXd &theta, MatrixXd &sig,
            VectorXd &y, MatrixXd &x, int sims, int burnin);

  void runTsim(int nsims, int batches, const VectorXd &a, const VectorXd &b,
               const MatrixXd &LinearConstraints, double df,
               const VectorXd &theta, const MatrixXd &Sigma, const VectorXd &y,
               const MatrixXd &X, int sims, int burnin, const VectorXd &b0,
               const MatrixXd &B0, double a0, double d0);
};
#endif
