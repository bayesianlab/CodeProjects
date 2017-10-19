#include <Eigen/Dense>
#include <iostream>
#include "CreateSampleData.hpp"

using namespace std;
using namespace Eigen;

CreateSampleData::CreateSampleData(int sampleSize, VectorXd& betas){
	/*dimension = betas.size();
	X = MatrixXd::Zero(sampleSize, dimension);		
	epsilon = VectorXd::Zero(sampleSize); 
	normrnd(0, 1, X);
	normrnd(0,1, epsilon);
	y = X*betas + epsilon;	
	MatrixXd XpX = X.transpose() * X;
	MatrixXd XpXinv = XpX.inverse();
	MatrixXd Xpy = X.transpose()*y;
	mles = XpXinv*Xpy; 
	resids = y - X*mles;
	residsTresids = resids.transpose()*resids;	
	sigmaSqdHat = residsTresids/sampleSize;
	inverseFisher = MatrixXd::Zero(dimension+1, dimension+1);	
	inverseFisher(0,0) = 2*pow(sigmaSqdHat, 2)/sampleSize;
	inverseFisher.block(1,1,dimension, dimension) = sigmaSqdHat*XpXinv;
	theta = VectorXd::Zero(dimension+1);
	theta << sigmaSqdHat, mles;*/
}
