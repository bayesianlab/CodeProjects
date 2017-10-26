#include <iostream>
#include <fstream>
#include <math.h>
#include <limits> 
#include <ctime>
#include <Eigen/Dense>
#include "Dist.hpp"
#include "ProbabilitySimulator.hpp"
#include "CreateSampleData.hpp"

using namespace std;
using namespace Eigen;

#define N 10

int main(){
	cout << "Chib Tests" << endl;	
	Dist d;
	ProbabilitySimulator p;	
	int testN = 2000;
	int dim = 4;
	double a = 0;
	double inf = numeric_limits<double>::max();
/*	VectorXd betas(4);
	betas << .75, .55, .35, .15;
	CreateSampleData csd(testN, betas);
	VectorXd lowerLimit(dim+1); 
	VectorXd upperLimit(dim+1);
	VectorXd zStar(dim+1);
	VectorXd fzStar(dim+1);

	lowerLimit << .99, -inf, -inf, -inf, -inf;
	upperLimit <<  1., inf, inf , inf, inf;
	CreateSampleData(testN, betas)/;
	p.chibRaoBlackwell(lowerLimit, upperLimit, csd.theta, csd.inverseFisher, zStar, fzStar, 10, 1, 10, 1);
	
*/

	VectorXd crbmu(3);
    crbmu << 0, .5, 1.;
	MatrixXd crbsigma(3,3);
    crbsigma << 1, -.7, .49,
		 		-.7, 1, -.7,
				 .49, -.7, 1;		
	VectorXd x(3);
	x << .33, .33, .33;
	cout << "MVN Normal PDF Tests "<< endl;
	cout << d.mvnpdf(crbmu, crbsigma, x) << endl;
	VectorXd zs(3);	
	VectorXd fzs(3);
	cout << "CHIB" << endl;
	cout << endl;
	clock_t begin = clock();
	VectorXd ll(3);
	VectorXd ul(3);
	ll << 0,0,0;
	ul << inf, inf, inf;
	p.chibRaoBlackwell(ll, ul, crbmu, crbsigma, zs, fzs, 11000, 1000, 11000, 1000);
	clock_t end = clock();
	cout << "Time to execute ->" << double(end - begin)/CLOCKS_PER_SEC << endl;
	cout << " Simulated Prob. " << endl;
	double prob = log(d.mvnpdf(crbmu, crbsigma, zs)/fzs.prod());
	cout << prob << endl;
	if(abs(prob + 1.55) > .02){
		cout << "PROB TEST FAILED" << endl;
	} 
	else{
		cout << "PROB TEST PASSED" << endl;
	} 
	cout << "\n\t\tTESTS COMPLETE" << endl;

	return 0; 
} 

