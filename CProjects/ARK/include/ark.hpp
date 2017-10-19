#ifndef ARK_H 
#define ARK_H 

#include <Eigen/Dense>
#include "Dist.hpp"

using namespace Eigen;

class Ark:public Dist{
	private:
	
	public:
		Ark();
		
		MatrixXd arSample(VectorXd&, VectorXd&, VectorXd&, MatrixXd&, int, int );
		
		int isVectVgreater(VectorXd& v, VectorXd& u);
};


#endif


