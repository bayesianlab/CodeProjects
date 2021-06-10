#include <Eigen/Dense>
#include "Optimization.hpp"
#include <iostream>
#include <limits>
#include <math.h>

using namespace std;
using namespace Eigen;

#define EPS numeric_limits<long double>::epsilon()

VectorXd Optimize::ForwardDifferences(const Ref<const VectorXd> &x0,
                            std::function<double(const Ref<const VectorXd> &xstar)> F)
{
    int n = x0.size();
    MatrixXd I = MatrixXd::Identity(n, n);
    long double h = sqrt(EPS);
    double fval0 = F(x0);
    VectorXd q = VectorXd::Zero(n);
    VectorXd grad = VectorXd::Zero(n);
    for (int i = 0; i < n; i++)
    {
        q = I.col(i) * h;
        grad(i) = (F(x0 + q) - fval0) / h;
    }
    return grad;
}

Optimize::Optimize(const Ref<const VectorXd> &guess,
                   std::function<double(const Ref<const VectorXd> &xstar)> F)
{
}

Optimize::Optimize(const Ref<const VectorXd> &guess,
                   std::function<double(const Ref<const VectorXd> &xstar)> F, int M_Iter)
{
    MaxIterations = M_Iter;
}

void Optimize::BFGS(VectorXd &guess, MatrixXd &B0,
                    std::function<double(const Ref<const VectorXd> &xstar)> F)
{
    double alpha = 1;
    int n = guess.size();
    VectorXd del1(n);
    VectorXd del0(n);
    VectorXd p0(n);
    del0 = ForwardDifferences(guess, F);
    B1 = B0;
    for (int k = 0; k < MaxIterations; k++)
    {
        p0 = -alpha * B0 * del0;
        x1 = guess + p0;
        del1 = ForwardDifferences(x1, F);
        VectorXd yk = del1 - del0;
        double p0tyk = p0.transpose() * yk;
        B1 = ((p0tyk + yk.transpose() * B0 * yk) / pow(p0tyk, 2)) * // scalar
                 (p0 * p0.transpose()) -
             (((p0 * yk.transpose() * B0).transpose() + (p0 * yk.transpose() * B0)) / p0tyk) +
             B0;

        /* The switch off */
        B0 = B1;
        guess = x1;
        del0 = del1;
        fval1 = F(x1); 
    }
}


