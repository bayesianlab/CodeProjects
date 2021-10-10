#pragma once
#ifndef GENARDATA_H
#define GENARDATA_H
#include <Eigen/Dense>
#include <Eigen/Sparse>
#include <eigen3/unsupported/Eigen/KroneckerProduct>
#include "MultilevelModelFunctions.hpp"
#include "TimeSeriesTools.hpp"
using namespace Eigen;
using namespace std;
class GenerateAutoRegressiveData
{
public:
    int lags;
    MatrixXd H;
    MatrixXd epsilon;
    MatrixXd yt;
    MatrixXd G0;
    MatrixXd g0;
    VectorXd sigma2;
    MatrixXd Xt; 
    GenerateAutoRegressiveData(int time, const MatrixXd &params);
    GenerateAutoRegressiveData(int time, const MatrixXd &arparams, const double &betaparams);
};
#endif 
