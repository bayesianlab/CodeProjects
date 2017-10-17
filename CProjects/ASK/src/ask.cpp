#include <Eigen/Dense>
#include <boost/math/distributions/normal.hpp>
#include <boost/random/mersenne_twister.hpp>
#include <boost/random/variate_generator.hpp>
#include <boost/random/uniform_01.hpp>
#include <limits>
#include <math.h>
#include <ctime>
#include <assert.h>
#include <cstdint>
#include "Dist.hpp"
#include "ask.hpp"

using namespace Eigen;
using namespace std;


Ask::Ask(VectorXd& lowerConstraint, VectorXd& upperConstraint, VectorXd& theta, MatrixXd& sig, 			int sims, int burnin){
	cout << "\n\n\tBegin ASK" << endl;
	J = sig.cols();	
	Rows = sims - burnin;
	Jminus1 = J - 1;
	sigma = sig;
	lowerTruncPoints = lowerConstraint;	
	upperTruncPoints = upperConstraint;
	mu = theta;
	precision = sigma.inverse();
	MatrixXd tempsample(sims, J);
	Dist::ghkLinearConstraints(lowerTruncPoints, upperTruncPoints, mu, sigma, 
			tempsample);
	sample = tempsample.bottomRows(Rows); 
	zStar = sample.colwise().mean();
	Hxx = precision.diagonal();
	sigmaVector = (1./Hxx.array()).sqrt();	
	Kernel = MatrixXd::Zero(Rows, J);
	muNotj = MatrixXd::Zero(Jminus1, 1);
	Hxy = MatrixXd::Zero(Jminus1, 1);
	xNotj = MatrixXd::Zero(Rows,Jminus1);
	xNotj = sample.rightCols(Jminus1);
}
void Ask::gibbsKernel(){ 
	
	VectorXd tempk(Rows);
	VectorXd cmeanVect(Rows);
	Hxy = precision.row(0).tail(Jminus1);
	muNotj = mu.tail(Jminus1);
	conditionalMean(Hxx(0), Hxy, muNotj, xNotj, mu(0), cmeanVect);
	tnormpdf(lowerTruncPoints(0), upperTruncPoints(0), cmeanVect, sigmaVector(0), zStar(0),
		   	tempk); 
	Kernel.col(0) = tempk;
	xNotj.rightCols(Jminus1-1) = sample.rightCols(J-2);
	
	for(int j = 1; j < Jminus1; j++){
		muNotj << mu.head(j), mu.tail(Jminus1-j);
		Hxy << precision.row(j).head(j).transpose(),
		   	precision.row(j).tail(Jminus1-j).transpose(); 
		xNotj.col(j-1).fill(zStar(j-1));
		conditionalMean(Hxx(j), Hxy, muNotj, xNotj, mu(j), cmeanVect);
		tnormpdf(lowerTruncPoints(j), upperTruncPoints(j), cmeanVect, sigmaVector(j), 
				zStar(j), tempk);
		Kernel.col(j) = tempk;
	}
	
	Hxy << precision.row(Jminus1).head(Jminus1).transpose(); 
	muNotj = mu.head(Jminus1);
	VectorXd xnotJ = zStar.head(Jminus1);
	double muJ = Dist::conditionalMean(Hxx(Jminus1), Hxy, muNotj, xnotJ, mu(Jminus1));
	double y = Dist::tnormpdf(lowerTruncPoints(Jminus1), upperTruncPoints(Jminus1), 
						muJ, sigmaVector(Jminus1), zStar(Jminus1));
	Kernel.col(Jminus1).fill(y);
}

void Ask::conditionalMean(double Hxx, VectorXd& Hxy, VectorXd& muNotj, MatrixXd& xNotj, 
        double muxx, VectorXd& conditionalMeanVector){
	xNotj.rowwise() -= muNotj.transpose(); 
	conditionalMeanVector = muxx - ((1/Hxx)*xNotj*Hxy).array(); 
} 

void Ask::tnormpdf(double a, double b, VectorXd& mu, double sigma, double x, 
		VectorXd& k){
	boost::math::normal normalDist;
	double Fa, Fb;
	for(int i = 0;i < mu.size(); i++){
		Fa = cdf(normalDist, (a-mu(i))/sigma);
		Fb = cdf(normalDist, (b-mu(i))/sigma);
		double sigmaZ = sigma * (Fb - Fa);
		k(i) = pdf(normalDist, (x - mu(i))/sigma)/sigmaZ;
	}
} 
