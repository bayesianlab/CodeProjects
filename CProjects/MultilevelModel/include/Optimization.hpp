#ifndef OPTIM_H
#define OPTIM_H

#include <Eigen/Dense>

using namespace Eigen;

class Optimize
{
public:
    VectorXd x0;
    VectorXd x1;
    MatrixXd B1; 
    double fval1;
    double fval0;
    int MaxIterations = 10;
    MatrixXd Hess;

    Optimize(const Ref<const VectorXd> &x0,
             std::function<double(const Ref<const VectorXd> &xstar)> F);

    Optimize(const Ref<const VectorXd> &guess,
             std::function<double(const Ref<const VectorXd> &xstar)> F, int M_Iter);

    void BFGS(VectorXd &guess, MatrixXd &B0, std::function<double(const Ref<const VectorXd> &xstar)> F);

    VectorXd ForwardDifferences(const Ref<const VectorXd> &x0, std::function<double(const Ref<const VectorXd> &xstar)> F);
};

#endif
