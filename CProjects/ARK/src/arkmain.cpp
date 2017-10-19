#include <Eigen/Dense>
#include <iostream>
#include <fstream>
#include <math.h>
#include <limits> 
#include <ctime>
#include "Dist.hpp"
#include "CreateSampleData.hpp"
#include "ark.hpp"

using namespace std;
using namespace Eigen;

int main(){
	Ark ark;
	double a = 0.;
	double inf = numeric_limits<double>::max();

	VectorXd mu(3);
	MatrixXd sig(3,3);
   	mu << 0., .5, 1.;
    sig << 1, -.7, .49, 
	 		-.7, 1, -.7,
			 .49, -.7, 1;	


	VectorXd m(3);
	MatrixXd s;
	s = MatrixXd::Identity(3,3);
	m << .5,.5,.5;
	cout << "Mvn rnd test, should all be .5" << endl;
	cout << ark.mvnrnd(m, s, 10000,3).colwise().mean() << endl;
	
	VectorXd ll(3);
	VectorXd ul(3);
	ll.fill(a);	
	ul.fill(inf);

	ark.arSample(ll,ul, mu,sig, 10, 5, 10, 10);
 	
}
