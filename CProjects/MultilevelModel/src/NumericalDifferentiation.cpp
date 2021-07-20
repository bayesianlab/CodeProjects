#include "NumericalDifferentiation.hpp"

VectorXd NumericalDifferentiation::ForwardDifferences(const Ref<const VectorXd> &x0,
                                      std::function<double(const Ref<const VectorXd> &xstar)> F)
{
    int n = x0.size();
    MatrixXd I = MatrixXd::Identity(n, n);
    double fval0 = F(x0);
    VectorXd q = VectorXd::Zero(n);
    VectorXd grad = VectorXd::Zero(n);
    long double h = sqrt(EPS);
    for (int i = 0; i < n; i++)
    {
        q = I.col(i) * h;
        grad(i) = (F(x0 + q) - fval0) / h;
    }
    return grad;
}

void NumericalDifferentiation::AprroximateHessian(const Ref<const VectorXd> &point,
                                  std::function<double(const Ref<const VectorXd> &xstar)> F, double fval1)
{
    int n = point.size();
    MatrixXd ei = MatrixXd::Identity(n, n);
    VectorXd p1(n);
    VectorXd p2(n);
    VectorXd p3(n);
    double h = sqrt(1e-4);
    double h2 = h * h;
    Hess = MatrixXd::Zero(n, n);
    for (int i = 0; i < n; i++)
    {
        p1 = point;
        p2 = point;
        p3 = point;
        for (int j = 0; j < n; j++)
        {
            p1 += h * (ei.col(j) + ei.col(i));
            p2 += h * ei.col(i);
            p3 += h * ei.col(j);
            Hess(i, j) = (F(p1) - F(p2) - F(p3) + fval1) / pow(h, 2);
        }
    }
}

void NumericalDifferentiation::AprroximateDiagHessian(const Ref<const VectorXd> &point,
                                      std::function<double(const Ref<const VectorXd> &xstar)> F, double fval1)
{
    int n = point.size();
    MatrixXd ei = MatrixXd::Identity(n, n);
    VectorXd p1(n);
    VectorXd p2(n);
    VectorXd p3(n);
    double h = sqrt(1e-4);
    double h2 = h * h;
    Hess = MatrixXd::Zero(n, n);
    for (int i = 0; i < n; i++)
    {
        p1 = point;
        p2 = point;
        p3 = point;

        p1 += h * (ei.col(i) + ei.col(i));
        p2 += h * ei.col(i);
        p3 += h * ei.col(i);
        Hess(i, i) = (F(p1) - F(p2) - F(p3) + fval1) / pow(h, 2);
    }
}
