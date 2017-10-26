#include "CreateSampleData.hpp"
#include <iostream>

using namespace Eigen;
using namespace std;

int main(){
	cout << "\n\n\tCreate Sample Data Tests\n\n" << endl;
	VectorXd betas(4);
	betas << .55, .65, .75, .95;
	CreateSampleData csd(1000, betas);
	cout << csd.maxLikeEsts << endl;
	cout << endl;
	cout << csd.inverseFisher << endl;
	

}
