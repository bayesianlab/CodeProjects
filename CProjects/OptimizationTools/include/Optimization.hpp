#pragma once
#ifndef OPTIM_H
#define OPTIM_H

#include <eigen-3.3.9/Eigen/Dense>
#include "Optimization.hpp"
#include <iostream>
#include <math.h>
#include <limits>
#include <boost/format.hpp>
#include <algorithm>
#include <vector> 

#include "LineSearchRoutines.hpp"
#include "NumericalDifferentiation.hpp"

using namespace std;
using namespace Eigen;
using namespace boost;

#define EPS numeric_limits<long double>::epsilon()
#define SEPS sqrt(EPS)
#define GR (0.5 * (sqrt(5) + 1))

void PressEnterToContinue();

class Optimize : public LineSearchRoutines
{
public:
    double F_tol, grad_tol, x_tol;
    VectorXd x1;
    double fval1;
    int MaxIterations;
    MatrixXd Hess;

    Optimize();

    Optimize(double options[5]);

    void BFGS(VectorXd &guess, std::function<double(const Ref<const VectorXd> &xstar)> F, int disp_on = 0);

    void BFGS_Display(VectorXd &guess, std::function<double(const Ref<const VectorXd> &xstar)> F);

    void BFGS_Display_Off(VectorXd &guess, std::function<double(const Ref<const VectorXd> &xstar)> F);

};



#endif
