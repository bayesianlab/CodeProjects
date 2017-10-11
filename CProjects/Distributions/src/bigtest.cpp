#include <Eigen/Dense>
#include <iostream>
#include <fstream>
#include <math.h>
#include <limits> 
#include <ctime>
#include "MarginalLikelihoodCalculator.hpp"
#include "Dist.hpp"
#include "ProbabilitySimulator.hpp"
#include "CreateSampleData.hpp"

using namespace std;
using namespace Eigen;

int main(){
	int N = 10000;
	int dim = 4;
	VectorXd beta(dim);
	CreateSampleData csd(N, beta);
	Dist dist;
	double a = 0;
	double inf = numeric_limits<double>::max();
	
	dist.ghkSampler(a, inf, csd.theta, csd.inverseFisher, N);	
	VectorXd y = dist.ghkDraws.col(0);
	dist.loginvgammapdf(y, 3, 6);
	cout << "TEST of log inverse gamma pdf function " << endl;
	cout << dist.ligampdf.mean() << endl;
	
}

