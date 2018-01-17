#include "mh.hpp"
#include "Dist.hpp"
#include "CreateSampleData.hpp"
#include <Eigen/Dense>


int x(){
	VectorXd b(2); 
    b << 1, .3;
	CreateSampleData csd(25, b, 1, .5);
	cout << csd.mles << endl;
	VectorXd mu = MatrixXd::Zero(3,1);
	mu << .3, -.5, .9;
	MatrixXd Sigma = MatrixXd::Identity(3,3);
	Dist d; 
	cout << d.mvtrnd(mu, Sigma, 8, 10000).colwise().mean() << endl; 
	return 1;

}

