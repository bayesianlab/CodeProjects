#include <Eigen/Dense>
#include <iostream>
#include <fstream>
#include <math.h>
#include <limits> 
#include <ctime>
#include "Dist.hpp"
#include "CRT.hpp"
#include "ProbabilitySimulator.hpp"
#include "CreateSampleData.hpp"
#include "MarginalLikelihoodCalculator.hpp"

using namespace std;
using namespace Eigen;

int main(){
	double a = 0.;
	double inf = numeric_limits<double>::max();
	cout << "Gibbs kernel" << endl;
	VectorXd crbmu(3);
    crbmu << 0, .5, 1.;
	MatrixXd crbsigma(3,3);
    crbsigma << 1, -.7, .49, 
		 		-.7, 1, -.7,
				 .49, -.7, 1;	
	VectorXd ll(3);
	VectorXd ul(3);
	ll.fill(a);	
	ul.fill(inf);
	cout << ll << " " << ul <<endl;
	
	crt.gibbsKernel();

	double num = crt.mvnpdf( crbmu, crbsigma, crt.zStar); 
	cout << num << endl;
    double den = crt.Kernel.rowwise().prod().mean(); 
	cout << num/den << endl;
	cout << den << endl;
	double ans = log(num/den); 
	double testval = abs(ans - (-1.55)) ;	
	if(testval < .01){
		cout << "CRT Test PASSED" << endl;
		cout << ans << " " << testval << " " << endl;
	}
	else{
		cout << "CRT Test FAILED" << endl;
		cout << ans << " " << testval << " " << endl;
	}

	
	
}
