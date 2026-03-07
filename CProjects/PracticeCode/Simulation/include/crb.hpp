#ifndef LIKELIHOOD
#define LIKELIHOOD
#include "Dist.hpp"
#include <Eigen/Dense>
using namespace Eigen;

class Crb : public Dist {
public:
  Crb();
  
  Crb(int x);

  MatrixXd chibRao(const VectorXd &a, const VectorXd &b, const VectorXd &mu,
                   const MatrixXd &sigma, int sims, int burnin, int rrSims,
                   int rrburnin);

  MatrixXd chibRaoStuT(const VectorXd &a, const VectorXd &b,
                       const MatrixXd &LinConstraint, const VectorXd &mu,
                       const MatrixXd &Sigma, double nu, int sims, int burnin,
                       int rrSims, int rrburnin);

  MatrixXd chibRaoT(const VectorXd &a, const VectorXd &b,
                    const MatrixXd &LinearConstraints, const VectorXd &mu,
                    const MatrixXd &sigma, double df, int, int, int, int);

  int getReducedRunSampleColumnDimension(int);

  void fillSigmaVect(VectorXd &, VectorXd &);

  double getfzStarMeanAtCol(double, double, MatrixXd &, int, double, double);

  double getfzStarMeanAtColT(double, double, MatrixXd &, int, double, double,
                             double df);

  void fillfzStar(VectorXd &, int, VectorXd &, VectorXd &, MatrixXd &,
                  VectorXd &, VectorXd &);

  double ml(const VectorXd &fz, const VectorXd &zStarTail, double zStarHead,
            const VectorXd &y, const MatrixXd &X, const VectorXd &b0,
            const MatrixXd &B0, const double igamA, const double igamB);

  double mlCRB(const VectorXd &fzStar, const VectorXd &, double, VectorXd &,
               MatrixXd &, VectorXd &b0, MatrixXd &B0, double a0, double d0);

  void runSim(VectorXd &mu, MatrixXd &sigma, VectorXd &y, MatrixXd &X,
              VectorXd &ll, VectorXd &ul, int sims, int burnin, int nSims,
              int batches, const VectorXd &b0, const MatrixXd &B0,
              const double a0, const double d0);

  void runTsim(VectorXd &betas, MatrixXd &sigma, double df, VectorXd &y,
               MatrixXd &X, VectorXd &ll, VectorXd &ul,
               const MatrixXd &LinearConstraints, VectorXd &b0, MatrixXd &B0,
               double a0, double d0, int, int, int, int);

  void calcfzStar(VectorXd &, const VectorXd &, const VectorXd &,
                  const VectorXd &, const MatrixXd &, const VectorXd &);

  void calcfzStarT(VectorXd &fzstar, VectorXd &zstar, const VectorXd &a,
                   const VectorXd &b, double df, MatrixXd &cMeans,
                   VectorXd &sigmavect);
};
#endif
