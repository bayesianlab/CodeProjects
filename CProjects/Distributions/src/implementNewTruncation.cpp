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
	Dist dobject;
	
	int testN = 10000;
	const int dim = 4;
	VectorXd b(dim);
	b << .75, .55, .35, .15;//, .8, .85, .95, 1.1;
	CreateSampleData csd(testN, b);
	
	double inf = numeric_limits<double>::max();
	int Sims = 15;
	MatrixXd testSample(Sims, 2*(dim+1));
	VectorXd sigv(dim+1);
	VectorXd a1(5);
	VectorXd b1(5);
	a1 << 0, 0, 0, 0, 0;
	b1 << 1.5, 1.5, 1.5, 1.5,1.5;
	dobject.tmvnrand(a1, b1, csd.theta, csd.inverseFisher, testSample, sigv);
	

	MatrixXd S(3,3);
	S << 1, -.5, .25,
	  -.5, 1, -.5,
	  -.25, -.5 , 1;
	VectorXd m(3);
	m << 0, 1, 2;
	cout << S << endl;

	
	VectorXd aconstraint(3);
	VectorXd bconstraint(3);
	aconstraint << -1, -inf, 1.9;
	bconstraint << -.5, inf, 2.1;
	MatrixXd newtest(Sims, 6);
	MatrixXd ghkSample(Sims,3);
	VectorXd newsigma(3);
	dobject.tmvnrand(aconstraint, bconstraint, m, S, newtest, newsigma );
	dobject.ghkLinearConstraints(aconstraint, bconstraint, m, S, ghkSample);

	cout << newtest << endl;
	cout << endl;
	cout << ghkSample << endl;
	cout  << testSample << endl;
	return 1; 
	
}

