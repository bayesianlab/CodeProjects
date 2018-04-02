#include "Dist.hpp"
#include "timeseries.hpp"
#include <Eigen/Dense>
#include <math.h>
#include <stdio.h>

using namespace std;
using namespace Eigen;

MatrixXd TimeSeries::VAR(const MatrixXd &Yt, int lag) { 
	int N = Yt.rows() - lag;
	int C = Yt.cols();
	VectorXd constant = MatrixXd::Ones(N, 1);
	MatrixXd Xt(N, C*lag+1);
	for(int i = 0; i < lag; i ++){
		Xt.block(0, C*i + 1, N, C) = Yt.block(i, 0, N, C);
	}
	Xt.col(0) = constant;
	MatrixXd Phi(C*lag + 1 , C);
	for(int c = 0; c < C; c++){
		Phi.col(c) = Xt.jacobiSvd(ComputeThinU | ComputeThinV).solve(Yt.bottomRows(N).col(c));
	}
	return Phi;
}


