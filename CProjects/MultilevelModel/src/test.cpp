#include <iostream>
#include <Eigen/Dense>
#include "Distributions.hpp"
#include <boost/random/mersenne_twister.hpp>
#include "/home/dillon/CodeProjects/CProjects/matplotlib-cpp/matplotlibcpp.h"
#include "Optimization.hpp"
using namespace std;

double rosen(const Ref<const VectorXd> &, double y);

double rosen(const Ref<const VectorXd> &x0, double y)
{
    return .5 * (pow(100 * (x0(1) - x0(0)), 2) + pow((1 - x0(0)), 2));
}

int main()
{
    MatrixXd sig(2, 2);
    sig << 1, 0, 0, 1;
    cout << sig << endl;
    cout << normrnd(0, 1) << endl;
    VectorXd mu(2);
    mu << .5, .5;
    cout << "\n";
    cout << mu << endl;
    VectorXd x(2);
    x << 0, 0;
    cout << "mvnrnd" << endl;
    cout << mvnrnd(mu, sig, 5) << endl;
    cout << "Uniform" << endl;
    cout << unifrnd(0, 1, 10, 10) << endl;
    cout << "Chi squared" << endl;
    cout << chi2rnd(1, 10) << endl;
    cout << chi2rnd(1, 5, 5) << endl;
    cout << "Wishart" << endl;
    cout << wishrnd(MatrixXd::Identity(10, 10), 10) << endl;
    cout << "Optimization" << endl;
    x << -1, 1;
    cout << rosen(x, 0) << endl;
    auto f1 = std::bind(rosen, std::placeholders::_1, 0);
    double y = 0;
    auto f2 = [y] (const Ref<const VectorXd> &x0){ return rosen(x0, y); };
    Optimize f(x, f2);
    cout << "BFGS" << endl;
    f.BFGS(x, sig, f2);
    cout << f.x1 << endl; 
    cout << f.B1 << endl; 

    return 0;
}
