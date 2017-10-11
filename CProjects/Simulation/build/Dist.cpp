#include "Dist.hpp"
#include <boost/random/normal_distribution.hpp>
#include <boost/math/distributions/normal.hpp>
#include <boost/random/normal_distribution.hpp>
#include <boost/random/mersenne_twister.hpp>
#include <boost/random/variate_generator.hpp>
#include <boost/random/gamma_distribution.hpp>
#include <boost/random/uniform_01.hpp>
#include <math.h>
#include <ctime>
#include <cstdint>
#include <boost/random/mersenne_twister.hpp>

using namespace Eigen;
using namespace std;

Dist::Dist(){
    now=time(0);
    rseed.seed(now);
}
    
 
void Dist::igammarnd(double shape, double scale, VectorXd& igamma){
	/*
    (1/theta^k gamma(k)) x^(k-1) e^(-x/theta) is the gamma 
	 parameterization 
     */
	boost::random::gamma_distribution<> gammavars(shape, scale);
    int rows = igamma.rows();
	for(int i =0; i<rows; i++){
		igamma(i) = 1.0/gammavars(rseed);
	} 
} 

void Dist::normrnd(double mu, double sig, MatrixXd& normalMat){
	boost::random::normal_distribution<> normalvar(mu, sig) ;
	int rows = normalMat.rows();
	int cols = normalMat.cols();
	for(int i=0; i<rows;i++ ){
		for(int j=0; j < cols;j++){
			double variate = normalvar(rseed);
			normalMat(i, j) = variate;
		}
	}
}

void Dist::mvnrnd(VectorXd mu, MatrixXd& sig, MatrixXd& mvnMatrix){
	LLT<MatrixXd> lltOfA(sig);	
	MatrixXd L = lltOfA.matrixL();
	normrnd(0, 1, mvnMatrix);
	L = L*mvnMatrix.transpose();
	for(int i = 0; i < L.cols(); i ++){
		mvnMatrix.transpose().col(i) = mu + L.col(i);
	}
}

void Dist::tnormrndTEST(double a, double b, double mu, double sigma, VectorXd& variates){
    boost::math::normal s;
    boost::random::uniform_01<> u;
    double alpha = (a - mu) / sigma;
    double beta = (b - mu) / sigma;
    double Fa = cdf(s, alpha);
    double Fb = cdf(s, beta);
    int N = variates.size();
    VectorXd u01(N);
    for(int i = 0; i < N; i++){
        u01(i) = u(rseed);
    } 
    for(int i = 0; i < N; i++){
        double q = Fa + u01(i)*(Fb - Fa);
        variates(i) = mu + sigma*quantile(s, q);
    } 
} 

double Dist::tnormrnd(double a, double b, double mu, double sigma){
    boost::math::normal s;
    boost::random::uniform_01<> u;
    double alpha = (a - mu) / sigma;
    double beta = (b - mu) / sigma;
    double Fa = cdf(s, alpha);
    double Fb = cdf(s, beta);
    double q = Fa + u(rseed)*(Fb - Fa);
    return mu + sigma*quantile(s, q);
} 
 


double Dist::conditionalMean(double Hxx, VectorXd& Hxy, VectorXd& muNotJ, VectorXd& xNotJ, 
        double muxx){
    return muxx - (1./Hxx)*Hxy.dot(xNotJ - muNotJ);
} 

void Dist::inversionTMVN(double a, double b, VectorXd& mu, MatrixXd& sigma, MatrixXd& sample,
        VectorXd& sigmaVect){
	/* 
	 * Fills sample with random numbers from trunc. dist. 
	 * And with the remaining cols. contain the conditional
	 * means. 
	 * The variances are stored in a smaller vector because
	 * they can be calculated without any conditioning. 
	 */
   int J = sigma.cols();
   int nSims = sample.rows();
   MatrixXd precision = sigma.inverse();
   VectorXd Hxx = precision.diagonal();
   VectorXd Hxy(J-1);
   VectorXd xNotJ(J-1);
   VectorXd muNotJ(J-1);
  for(int j = 0; j < J; j++){
    sigmaVect(j) = sqrt(1./Hxx(j)); 
  } 
   for(int sim = 1; sim < nSims; sim ++){
       for(int j = 0; j < J; j++){
           int c = 0;
           for(int k = 0; k < J; k++){
                if(j != k ){
                   Hxy(c) = precision(j, k); 
                   xNotJ(c) = sample(sim-1, k);
                   muNotJ(c) = mu(k);
                   c++;
                } 
           } 
           sample(sim, j + J) = conditionalMean(Hxx(j), Hxy, muNotJ, xNotJ, mu(j));
           sample(sim, j) = tnormrnd(a, b, sample(sim, j + J), sigmaVect(j)); 
       } 
   }
} 

double Dist::tnormpdf(double a, double b, double mu, double sigma, double x){
	/*sigmaZ = sigma.* (normcdf((b-mu)./sigma) - normcdf( (a-mu)./sigma ));
tOrdinate = normpdf((x-mu)./sigma)./sigmaZ;*/
	boost::math::normal normalDist;
	double sigmaZ = sigma * (cdf(normalDist, (b-mu)/sigma) - cdf(normalDist, (a-mu)/sigma));	
	return pdf(normalDist, (x - mu)/sigma)/sigmaZ;
} 

double Dist::mvnpdf(VectorXd mu, MatrixXd sigma, VectorXd x){
	int size = mu.size();
	VectorXd temp(size);
	temp = x - mu;
	temp = -.5*temp.transpose()*sigma.inverse() * temp;
	double constant = pow(2*M_PI, size);
	return (1./sqrt(constant*sigma.determinant())) * exp(temp(0));	
} 

double Dist::standardDev(VectorXd& v){
	ArrayXd t(v.size());
	t = v.array() - v.mean();
	return sqrt(t.square().sum()/(v.size()-1));
} 

