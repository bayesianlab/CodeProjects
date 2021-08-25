#pragma once
#ifndef GP_H
#define GP_H
#include <iostream>
#include <stdlib.h>
#include <fstream>
#include <eigen-3.3.9/Eigen/Dense> 

using namespace Eigen; 
class GnuplotWrapper
{
    public: 
    GnuplotWrapper(const Ref<const MatrixXd> &xdata);
};

#endif