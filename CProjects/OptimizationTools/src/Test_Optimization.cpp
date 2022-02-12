#include <chrono>
#include <iostream>
#include <Eigen/Dense>
#include "Optimization.hpp"

using namespace std;

double rosen(const Ref<const VectorXd> &);

double rosen(const Ref<const VectorXd> &x0)
{
    return 100 * pow((x0(1) - pow(x0(0), 2)), 2) + pow((1 - x0(0)), 2);
}

int main(int argc, char *argv[])
{
    Matrix2Xd sig(2, 2);
    sig << 1, 0,
        0, 1;
    VectorXd x(2);
    x << -1.9, 2;
    cout << rosen(x) << endl;
    auto f2 = [](const Ref<const VectorXd> &x0)
    { return rosen(x0); };
    Optimize f;
    cout << endl;
    cout << "BFGS" << endl;
    f.BFGS(x, f2, 1);
    f.ApproximateHessian(f.x1, f2);
    cout << "Correct solution:" << " 1, 1" << endl; 
    return 0;
}
