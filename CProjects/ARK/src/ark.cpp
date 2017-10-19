#include <Eigen/Dense>
#include <boost/math/distributions/normal.hpp>
#include <boost/random/mersenne_twister.hpp>
#include <boost/random/variate_generator.hpp>
#include <boost/random/uniform_01.hpp>
#include <boost/math/distributions/bernoulli.hpp>
#include <limits>
#include <math.h>
#include <ctime>
#include <assert.h>
#include <cstdint>
#include <random>

#include "Dist.hpp"
#include "ark.hpp"

using namespace Eigen;
using namespace std;

Ark::Ark(){

	cout << "\n\n\tARK begin" << endl;
	cout << normrnd(0,1, 10) << endl;
	cout << normrnd(0,1, 10, 3) << endl;
	cout << endl;
}

MatrixXd Ark::arSample(VectorXd& ll, VectorXd& ul, VectorXd& mu, MatrixXd& sigma, int sSize,
	   	int maxIterations ){
	int J,i,n, maxit;
	J = sigma.cols();
	MatrixXd arSample(sSize,J);
	i = 0;
	n = 0;	
	while(n < sSize){
		MatrixXd t = mvnrnd(mu,sigma,1,J).array();  
		if( (t.array() > ll.transpose().array()).all() == 1){
		    arSample.row(n) = t;
		    n++;
		    maxit = 0;
		}		
		else if(maxit == maxIterations){
		    arSample.row(n) = MatrixXd::Zero(1,J);
		    n ++;
		}
		else{
			maxit++;
		}
	}
	return arSample;
}

int Ark::isVectVgreater(VectorXd& v, VectorXd& u) {
	if( (v.array() > u.array()).all() == 1 ){
		return 1;
	}
	else{
		return 0;
	}
}

