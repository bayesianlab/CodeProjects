#include <Eigen/Dense>
#include <ctime>
#include <cstdint>
#include <boost/random/mersenne_twister.hpp>

using namespace Eigen;
using namespace std;

#ifndef DIST
#define DIST 
class Dist{
	time_t now; 
    boost::random::mt19937 rseed; 
    public:
        Dist();
		void igammarnd(double shape, double scale, VectorXd& igamma);
		void normrnd(double mu, double sig, MatrixXd& normalMat);
		void mvnrnd(VectorXd mu, MatrixXd& sig, MatrixXd& mvnMatrix);
        double tnormrnd(double a,double b, double mu, double sigma);
        void inversionTMVN(double a, double b, VectorXd& mu, MatrixXd& sigma, MatrixXd& sample,
                 VectorXd& sigmaVect);
        double conditionalMean(double Hxx, VectorXd& Hxy, VectorXd& muNotJ, VectorXd& xNotJ, double muxx);
        void tnormrndTEST(double a, double b, double mu, double sigma, VectorXd& variates);
		double tnormpdf(double a, double b, double mu, double sigma, double x);
		double mvnpdf(VectorXd, MatrixXd, VectorXd);
		double standardDev(VectorXd&);
};
#endif

