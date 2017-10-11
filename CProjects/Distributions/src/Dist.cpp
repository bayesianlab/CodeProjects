#include <Eigen/Dense>
#include <boost/random/normal_distribution.hpp>
#include <boost/math/distributions/normal.hpp>
#include <boost/random/normal_distribution.hpp>
#include <boost/random/mersenne_twister.hpp>
#include <boost/random/variate_generator.hpp>
#include <boost/random/gamma_distribution.hpp>
#include <boost/random/uniform_01.hpp>
#include <boost/math/distributions/exponential.hpp>
#include <limits>
#include <math.h>
#include <ctime>
#include <assert.h>
#include <cstdint>
#include "Dist.hpp"

using namespace Eigen;
using namespace std;

#define LOG_E_2 0.693147180559945309417232121458
#define LOG_PI 1.14472988584940017414342735135305871165 
#define LOG_E_2_PI  0.693147180559945309417232121458 + 1.14472988584940017414342735135305871165 

/*
 * Things to do:
 * Implement Roberts method for truncated draws
 */

Dist::Dist(){
    now = time(0);
    rseed.seed(now);
	inf = numeric_limits<double>::max();
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

void Dist::unifrnd(double a, double b, VectorXd& unifVector){
	boost::random::uniform_01<> u;
	double diff = b - a;
	for(int i = 0; i < unifVector.size(); i++){
		unifVector(i) = a + u(rseed)*diff;
	} 
	
} 

double Dist::tnormrnd(double a, double b, double mu, double sigma){
	// Still used in truncNormalRnd, KEEP
    boost::math::normal s;
    boost::random::uniform_01<> u;
    double alpha = (a - mu) / sigma;
    double beta = (b - mu) / sigma;
    double Fa = cdf(s, alpha);
    double Fb = cdf(s, beta);
    double q = Fa + u(rseed)*(Fb - Fa);
    return mu + sigma*quantile(s, q);
} 

double Dist::shiftexprnd(double alpha, double shift){
	boost::random::uniform_01<> u;
	return shift - log(1. - u(rseed))/alpha;
} 

double Dist::shiftexppdf(double alpha, double shift, double z){
	return alpha*exp(-alpha*(z-shift));
}

double Dist::leftTruncation(double a, double b){
	int maxIterations = 0;
	boost::random::uniform_01<> u;
	double optimalScale, rho_z, z;
	optimalScale = (a + sqrt(pow(a,2) +4))/2.;
	while(maxIterations < 10000){
		z = shiftexprnd(optimalScale, a);
		rho_z = exp(-pow(z-optimalScale, 2));
		if(u(rseed) <= rho_z){
			return z;
		}	
		maxIterations ++;
	}
	cout << "Error leftTruncation: maxIterations exceeded, no truncation possible." << endl;
	return inf;
}

double Dist::rightTruncation(double a, double b){
	double optimalScale, rho_z, z,temp;
	temp = b;
	b = -a;
	a = -temp;
	int maxIterations = 0;
	boost::random::uniform_01<> u;
	optimalScale = (a + sqrt(pow(a,2) +4))/2.;
	while(maxIterations < 10000){
		z = shiftexprnd(optimalScale, a);
		rho_z = exp(-pow(z-optimalScale, 2));
		if(u(rseed) <= rho_z ){
			return -z;
		}	
		maxIterations ++;
	}
	cout << "Error rightTruncation: maxIterations exceeded, no truncation possible." << endl;
	return inf;
}

double Dist::twoSided(double a, double b){
	int maxIterations = 0;
	boost::random::uniform_01<> z;
	boost::random::uniform_01<> u;
	double zdouble, rho_z;
	while(maxIterations < 10000){
		zdouble = a + z(rseed)*(b-a);
		if(a < 0 && 0 < b){
			rho_z = exp(-pow(zdouble, 2));
		}	
		else if( b < 0 ){
			rho_z = exp((pow(b,2) - pow(zdouble,2))/2.);	
		}
		else{
			rho_z = exp((pow(a,2)- pow(zdouble, 2))/2.);
		}
		if(u(rseed) <= rho_z){
			return zdouble;
		}
	}
	cout << "Error in two sided truncation." << endl;
	return inf;
}


double Dist::truncNormalRnd(double a, double b, double mu, double sigma){
	double Z;
	if(b >= inf){
		double standardizedA;
		standardizedA = (a-mu)/ sigma;
		if(standardizedA > 5){
			Z = leftTruncation(standardizedA, b);
			return mu + sigma*Z; 
		}
		else{
			return tnormrnd(a,b,mu,sigma);
		}
	}
	else if(a <= -inf){
		double standardizedB;
		standardizedB = (b-mu)/sigma;
		if(standardizedB < -5){
			Z = rightTruncation(a, standardizedB);
			return mu + sigma*Z; 
		}
		else{
			return tnormrnd(a,b,mu,sigma);
		}
	}
	else{
		double standardizedA, standardizedB;
		standardizedA = (a-mu)/ sigma;
		standardizedB = (b-mu)/sigma;
		if(standardizedA > 5){
			Z = twoSided(standardizedA, standardizedB);
			return mu + sigma*Z; 
		}
		else if(standardizedB < -5){
			Z = twoSided(standardizedA, standardizedB);
			return mu + sigma*Z;
		}
		else{
			return tnormrnd(a,b,mu,sigma);
		}
	}

} 

void Dist::tmvnrand(VectorXd& a, VectorXd& b, VectorXd& mu, MatrixXd& sigma, MatrixXd& sample,
        VectorXd& sigmaVect){
	/* 
	 * Uses both inversion and ar sampling
	 */
	if(sample.cols() != 2*mu.size()){
		cout << "Error: Sample size needs to be 2x size of mu" << endl;
	}
	else{
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
			   sample(sim, j) = truncNormalRnd(a(j), b(j), sample(sim, j + J), sigmaVect(j)); 
		   } 
	   }
	}
}

double Dist::ghkTruncNormRnd(double a, double b, double mu, double sigma){
	// Keep this method
	double Z;
	if(b >= inf){
		if(a > 5){
			Z = leftTruncation(a, b);
			return mu + sigma*Z; 
		}
		else{
			return tnormrnd(a,b,mu,sigma);
		}
	}
	else if(a <= -inf){
		if(b < -5){
			Z = rightTruncation(a, b);
			return mu + sigma*Z; 
		}
		else{
			return tnormrnd(a,b,mu,sigma);
		}
	}
	else{
		if(a > 5){
			Z = twoSided(a, b);
			return mu + sigma*Z; 
		}
		else if(b < -5){
			Z = twoSided(a, b);
			return mu + sigma*Z;
		}
		else{
			return tnormrnd(a,b,mu,sigma);
		}
	}
}
double Dist::conditionalMean(double Hxx, VectorXd& Hxy, VectorXd& muNotJ, VectorXd& xNotJ, 
        double muxx){
    return muxx - (1./Hxx)*Hxy.dot(xNotJ - muNotJ);
} 

double Dist::tnormpdf(double a, double b, double mu, double sigma, double x){
	/*sigmaZ = sigma.* (normcdf((b-mu)./sigma) - normcdf( (a-mu)./sigma ));
	 * tOrdinate = normpdf((x-mu)./sigma)./sigmaZ;
	 */
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

void Dist::ghkLinearConstraints(VectorXd& a, VectorXd& b, VectorXd& mu, MatrixXd& Sigma, 
		MatrixXd& sample){
	/*
	 * Take into account multiple constraints
	 */
	int J = Sigma.cols();
	if(a.size() != b.size()){
		cout << "\nError: The number of constraints are not the same." << endl;
	}
	else if(a.size() != J){
		cout << "Error: At least as many constraints as dimension in Sigma are needed."<< endl;
	}
	else{
		int sims = sample.rows();
		MatrixXd lowerC = Sigma.llt().matrixL();
		MatrixXd offDiagMat = lowerC;
		offDiagMat.diagonal() = VectorXd::Zero(J);
		double update, aj, bj;
		for(int sim = 0; sim < sims; sim++){
			for(int j = 0; j < J; j++){
				update = mu(j) + offDiagMat.row(j) * sample.row(sim).transpose(); 
				aj = (a(j) - update)/lowerC(j,j);
				bj = (b(j) - update)/lowerC(j,j);
				sample(sim, j) = ghkTruncNormRnd(aj, bj, 0, 1);
			} 
		}
	sample = (lowerC*sample.transpose()).transpose();
	sample.rowwise() += mu.transpose();
	}
} 

void Dist::lrLikelihood(MatrixXd& betas, VectorXd& sigmasqds, VectorXd& y,
	   	MatrixXd& X ){
	int N = X.rows();
	VectorXd e(X.rows());
	ArrayXd normConst = -(N/2)*(sigmasqds.array().log() + LOG_E_2_PI);
	ArrayXd expNormalizingConst = (-2*sigmasqds.array()).pow(-1);	
	linreglike = VectorXd::Zero(betas.rows());
	for(int i = 0; i < betas.rows(); i ++){
		e = y - X*betas.row(i).transpose();
		double eTe = e.transpose()*e;
		linreglike(i) = normConst(i) + eTe*expNormalizingConst(i);
	}
}

void Dist::logmvnpdf(MatrixXd& X, VectorXd& mu, MatrixXd& Sigma){
	int J = Sigma.cols();
	const double epi = LOG_E_2 + LOG_PI;
	MatrixXd Sigmainv;
    Sigmainv = Sigma.inverse();	
	double det = Sigma.determinant();
	double C1 = J*epi + log(det);
	X.rowwise() -= mu.transpose();
	lmvnpdf = -.5*(C1 +  (X*Sigmainv).array().pow(2).rowwise().sum());
}

void Dist::loginvgammapdf(VectorXd& y, double alpha, double beta){
	double C1 = -(alpha*log(beta) + lgamma(alpha));
    ligampdf = y.array().log();
	ligampdf *= -(alpha+1);
	ligampdf = ligampdf.array() - (y.array()*beta).pow(-1) + C1;
}



