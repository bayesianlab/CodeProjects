#pragma once
#ifndef LINESEARCH_H
#define LINESEARCH_H

#include <Eigen/Dense>
#include <iostream>
#include <math.h>
#include <limits>
#include <vector> 

#include "NumericalDifferentiation.hpp"

using namespace Eigen;
using namespace std;

#define EPS numeric_limits<long double>::epsilon()
#define SEPS sqrt(EPS)
#define GR (0.5 * (sqrt(5) + 1))

void sort_swap(double &low, double &high);


class LineSearchRoutines : public NumericalDifferentiation
{
public:
    double line_search_tol;
    int gs_max_it = 15;
    int flag = 0; 

    double Zoom(double alo, double ahi, const Ref<const VectorXd> &point, const Ref<const VectorXd> &pk, std::function<double(const Ref<const VectorXd> &xstar)> F, double F0, double Fprime0);
    
    double LineSearch(const Ref<const VectorXd> &point, const Ref<const VectorXd> &pk,
                      const Ref<const VectorXd> &del0,
                      std::function<double(const Ref<const VectorXd> &xstar)> F);

    double CubicInterpolation(double f1, double f2, double fprime1, double fprime2, double x1, double x2);

    double GoldenSection(const Ref<const VectorXd> &point, const Ref<const VectorXd> &pk, double alast, double acurrent,
                         std::function<double(const Ref<const VectorXd> &xstar)> F, int max_it);


};

#endif