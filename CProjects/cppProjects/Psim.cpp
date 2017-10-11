#include <iostream>
#include <fstream>
#include <math.h>
#include <limits> 
#include "Dist.hpp"
#include "ProbabilitySimulator.hpp"

using namespace Eigen;
using namespace std;


int main(){
    ProbabilitySimulator p;
	Dist d;
	double a = 0;
	double inf = numeric_limits<double>::max();
	cout << "\t\tBegin PSIM TESTS" <<endl;
	cout << endl;
	
	VectorXd crbmu(3);
    crbmu << 0, .5, 1.;
	MatrixXd crbsigma(3,3);
    crbsigma << 1, -.7, .49,
		 		-.7, 1, -.7,
				 .49, -.7, 1;		
	cout << "CHIB" << endl;
	cout << endl;
	VectorXd zs(3);	
	VectorXd fzs(3);
	p.chibRaoBlackwell(a, inf, crbmu, crbsigma, zs, fzs, 10, 1, 10, 1);
	
	cout << zs.transpose() << endl;
	cout << fzs.transpose() << endl;
	cout << " Prob. " << endl;
	cout << log(d.mvnpdf(crbmu,crbsigma, zs)) << endl;
 	cout << log(fzs.prod()) << endl;
	cout << log(d.mvnpdf(crbmu, crbsigma, zs)/fzs.prod()) << endl;
	cout << "\n\t\tTESTS COMPLETE" << endl;
	// TO DO fzStar last element in 3 dim test is wrong, too low. 
	// Recheck main body of crbsim code. 	
	return 0;
} 
