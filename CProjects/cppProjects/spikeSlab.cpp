#include <iostream>
#include <Eigen/Dense>
#include <ctime>
#include <cstdint>
#include <boost/random/normal_distribution.hpp>
#include <boost/random/mersenne_twister.hpp>
#include <boost/random/variate_generator.hpp>
#include <boost/random/gamma_distribution.hpp>
#include <random>
#include <fstream>

using namespace Eigen;
using namespace std;

void igammarnd(double shape, double scale, VectorXd& igamma){
	/*(1/theta^k gamma(k)) x^(k-1) e^(-x/theta) is the gamma 
	 parameterization */
	time_t now = time(0);
	boost::random::mt19937 seed(static_cast<uint32_t>(now));
	boost::random::gamma_distribution<> gammavars(shape, scale);
    int rows = igamma.rows();
	double variate;
	for(int i =0; i<rows; i++){
		igamma(i) = 1.0/gammavars(seed);
	} 
} 

void normrnd(double mu, double sig, MatrixXd& normalMat){
	time_t now = time(0);
	boost::random::mt19937 seed(static_cast<std::uint32_t>(now));
	boost::random::normal_distribution<> normalvar(mu, sig) ;
	int rows = normalMat.rows();
	int cols = normalMat.cols();
	for(int i=0; i<rows;i++ ){
		for(int j=0; j < cols;j++){
			double variate = normalvar(seed);
			normalMat(i, j) = variate;
		}
	} 
}

void mvnrnd(VectorXd mu, MatrixXd sig, MatrixXd& mvnMatrix){
	int J = mu.size();
	int rows = mvnMatrix.rows();
	LLT<MatrixXd> lltOfA(sig);	
	MatrixXd L = lltOfA.matrixL();
	normrnd(0, 1, mvnMatrix);
	L = L*mvnMatrix.transpose();
	for(int i = 0; i < L.cols(); i ++){
		mvnMatrix.transpose().col(i) = mu + L.col(i);
	}
} 


int main()
{
	MatrixXd normalMat(20,3); 
	normrnd(0,1,normalMat);
	cout << "Normal random variable test" << endl;
	cout << endl << normalMat << endl;
	VectorXd mu(3);
	mu << 10,10,10;
	MatrixXd sig(3,3);
	sig << .7, .3, .3, 
		.3, .7, .45, 
		.45, .3, .7;
	MatrixXd mvn(10,3); 
	cout << "Multivariate normal test" << endl;
	mvnrnd(mu, sig, mvn);
	cout << endl << mvn << endl<<endl;

	VectorXd inverseGammas(20);
	cout << "inverse gamma tests" << endl;
	igammarnd(1,10, inverseGammas);
	cout << endl << inverseGammas << endl;
}
