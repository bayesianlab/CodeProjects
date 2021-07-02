#ifndef OPTIM_H
#define OPTIM_H

#include <eigen-3.3.9/Eigen/Dense>
#include "Optimization.hpp"
#include <iostream>
#include <math.h>
#include <limits>
#include <boost/format.hpp>

using namespace std;
using namespace Eigen;
using namespace boost;

#define EPS numeric_limits<long double>::epsilon()
#define SEPS sqrt(EPS)
#define GR (0.5 * (sqrt(5) + 1))

void PressEnterToContinue();

class Optimize
{
public:
    double F_tol, grad_tol, x_tol, line_search_tol;
    VectorXd x1;
    MatrixXd B1;
    double fval1;
    int MaxIterations;
    MatrixXd Hess;

    Optimize();

    Optimize(double options[5]);

    void BFGS(VectorXd &guess, std::function<double(const Ref<const VectorXd> &xstar)> F, int disp_on = 0);

    void BFGS_Display(VectorXd &guess, std::function<double(const Ref<const VectorXd> &xstar)> F);

    void BFGS_Display_Off(VectorXd &guess, std::function<double(const Ref<const VectorXd> &xstar)> F);

    VectorXd ForwardDifferences(const Ref<const VectorXd> &x0, std::function<double(const Ref<const VectorXd> &xstar)> F);

    void AprroximateHessian(const Ref<const VectorXd> &point, std::function<double(const Ref<const VectorXd> &xstar)> F);

    void AprroximateDiagHessian(const Ref<const VectorXd> &point,
                                  std::function<double(const Ref<const VectorXd> &xstar)> F);

    double BTLineSearch(const Ref<const VectorXd> &point, const Ref<const VectorXd> &pk, const Ref<const VectorXd> &del0,
                        std::function<double(const Ref<const VectorXd> &xstar)> F);

    double LineSearch(const Ref<const VectorXd> &point, const Ref<const VectorXd> &pk,
                      const Ref<const VectorXd> &del0,
                      std::function<double(const Ref<const VectorXd> &xstar)> F);

    double CubicInterpolation(double f1, double f2, double fprime1, double fprime2, double x1, double x2);

    double GoldenSection(const Ref<const VectorXd> &point, const Ref<const VectorXd> &pk, double alast, double acurrent,
                         std::function<double(const Ref<const VectorXd> &xstar)> F);
};

#endif
