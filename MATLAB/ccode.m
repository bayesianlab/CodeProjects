#include "Dist.hpp"
#include <Eigen/Dense>
#include <boost/math/distributions/normal.hpp>
#include <cstdint>
#include <ctime>
#include <limits>
#include <math.h>
#include <algorithm>
#include <iostream>
#include <fstream>
#include <math.h>

#define epsilon 0.01
using namespace Eigen;
using namespace std;

double computeQ(const VectorXd Y) {
  int n = Y.size();
  VectorXd qcontain = MatrixXd::Zero(n, 1);
  int c = 0;
  for (int i = 0; i < n; i++) {
    if (abs(Y(i)) > epsilon) {
      qcontain(c) = Y(i);
      c++;
    }
  }
  if(qcontain.head(c).array().prod() == 1){
	return 0.;
  }else{
    return qcontain.head(c).array().prod();
  }
}

VectorXd distributionQ(double mu, double sigma2, int n, int M) {
  VectorXd Q(M);
  VectorXd X, Y;
  double Xbar;
  Dist d;
  for (int i = 0; i < M; i++) {
    X = d.normrnd(mu, sigma2, n, 1);
    Xbar = X.mean();
    Y = d.normrnd(Xbar, 1. / n, n, 1);
   	Q(i) = computeQ(Y);
  }
  std::sort(Q.data(), Q.data() + Q.size());
  return Q;
}

void experimentNvalues(string &path, double mu, double sigma2, const VectorXd nvals, int M){
	VectorXd Q;
	MatrixXd quantiles(nvals.size(), 3);
	for(int i = 0; i < nvals.size(); i ++){
	   Q = distributionQ(mu, sigma2, nvals(i), M);
	   quantiles.row(i) << Q(500), Q(750), Q(950);
	}
	cout << quantiles.array().log() << endl;
	ofstream file(path);
	if(file.is_open()){
		file << quantiles.array().log();
		file.close();
	}else{
		cout << "error" << endl;
	}
}

int main(){
	cout << "Stat 225 #5" << endl;
	VectorXd nvals(7);
	nvals << 15, 30, 45, 60, 75, 90, 105;
	string path1 = "quantiles.txt";
	string path2 = "largen.txt";
	experimentNvalues(path1, 0,1, nvals, 1000);



	return 0;
}
