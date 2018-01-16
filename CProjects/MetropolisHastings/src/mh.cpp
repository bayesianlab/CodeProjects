#include "mh.hpp"
#include "Dist.hpp"
#include "CreateSampleData.hpp"
#include <Eigen/Dense>


int x(){
	VectorXd b(2); 
    b << 1, .3;
	CreateSampleData csd(25, b, 1, .5);
	cout << csd.mles << endl;
     
	return 1;

}

