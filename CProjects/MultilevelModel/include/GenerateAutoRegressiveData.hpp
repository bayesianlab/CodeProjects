#pragma once
#ifndef GENARDATA_H
#define GENARDATA_H
#include <eigen-3.3.9/Eigen/Dense>
#include <eigen-3.3.9/unsupported/Eigen/KroneckerProduct>
#include "Distributions.hpp"
#include "MultilevelModel.hpp"
#include "MultilevelModelFunctions.hpp"
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
    MatrixXd ythat;
    MatrixXd Xthat;
    double sigma2;
    GenerateAutoRegressiveData(int time, const MatrixXd &params);
};
#endif 
