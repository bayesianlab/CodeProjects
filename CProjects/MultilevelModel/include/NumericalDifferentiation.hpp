#ifndef NUMERICALDIFF_H
#define NUMERICALDIFF_H

#include <eigen-3.3.9/Eigen/Dense>

using namespace Eigen;
using namespace std;

#define EPS numeric_limits<long double>::epsilon()
#define SEPS sqrt(EPS)
#define GR (0.5 * (sqrt(5) + 1))

class NumericalDifferentiation
{
public:
    MatrixXd Hess;

    VectorXd ForwardDifferences(const Ref<const VectorXd> &x0, std::function<double(const Ref<const VectorXd> &xstar)> F);

    void AprroximateHessian(const Ref<const VectorXd> &point, std::function<double(const Ref<const VectorXd> &xstar)> F, double fval1);

    void AprroximateDiagHessian(const Ref<const VectorXd> &point,
                                std::function<double(const Ref<const VectorXd> &xstar)> F, double fval1);
};

#endif