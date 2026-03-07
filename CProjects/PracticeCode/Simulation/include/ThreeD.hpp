#ifndef THREED
#define THREED
#include <Eigen/Dense>
#include <iostream>
using namespace std;
using namespace Eigen;

class ThreeD{
  public:
    MatrixXd A;	  
	MatrixXd B;
	void store(const MatrixXd &X, const MatrixXd &Y){ A=X;B=Y;}
};
#endif
