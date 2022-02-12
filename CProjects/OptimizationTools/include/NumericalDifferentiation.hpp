#pragma once
#ifndef NUMERICALDIFF_H
#define NUMERICALDIFF_H
#include <iostream> 
#include <Eigen/Dense>

using namespace Eigen;
using namespace std;

#define EPS numeric_limits<long double>::epsilon()
#define SEPS sqrt(EPS)
#define GR (0.5 * (sqrt(5) + 1))

class NumericalDifferentiation
{
public:
    
    VectorXd ForwardDifferences(const Ref<const VectorXd> &x0, std::function<double(const Ref<const VectorXd> &xstar)> F);
    
    VectorXd CentralDifferences(const Ref<const VectorXd> &x0, std::function<double(const Ref<const VectorXd> &xstar)> F);

    MatrixXd ApproximateHessian(const Ref<const VectorXd> &point, std::function<double(const Ref<const VectorXd> &xstar)> F);

    MatrixXd AprroximateDiagHessian(const Ref<const VectorXd> &point,
                                std::function<double(const Ref<const VectorXd> &xstar)> F);
};

#endif