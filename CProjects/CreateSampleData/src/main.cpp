#include "CreateSampleData.hpp"
#include <iostream>

using namespace Eigen;
using namespace std;

int main(){
	cout << "Create Sample Data Tests" << endl;
	VectorXd betas(4);
	betas << .55, .65, .75, .95;
	CreateSampleData csd(10, betas);
	cout << csd.y << endl;
	cout << csd.resids << endl;
	

}
