#include "GelfandDey.cpp"
#include "LinRegGibbs.hpp"
#include "CreateSampleData.hpp"
#include "Dist.hpp"
#include <iostream>
#include <Eigen/Dense>

using namespace std;
using namespace Eigen;
int main(){
	int dim = 3;
	int gs = 10;
	VectorXd betas(dim);
	betas << .5, .6, .7;
	CreateSampleData csd(25, betas);
	LinRegGibbs lrg;
	cout << "\n\t Gelfand Dey Tests" << endl;
	cout << "MLE's" << endl;
	cout << csd.maxLikeEsts.transpose() << endl;
	lrg.gibbsLR(csd.y, csd.X, gs);

	
	return 0;
}
