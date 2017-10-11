#ifndef DIST
#define DIST
#include <iostream>
#include <Eigen/Dense>
#include <ctime>
#include <cstdint>
#include <boost/random/mersenne_twister.hpp>
#include <boost/math/distributions/normal.hpp>
#include <limits>

using namespace Eigen;
using namespace std;

class Dist{
	private:
		time_t now; 
		boost::random::mt19937 rseed; 
		boost::math::normal normalDistribution;
		double inf;
		
    public:
        Dist();
		void igammarnd(double shape, double scale, VectorXd& igamma);
		void normrnd(double mu, double sig, MatrixXd& normalMat);
		void mvnrnd(VectorXd mu, MatrixXd& sig, MatrixXd& mvnMatrix);
        double tnormrnd(double a,double b, double mu, double sigma);

		double shiftexprnd(double, double);
		double shiftexppdf(double, double, double);
		double leftTruncation(double, double);
		double rightTruncation(double, double);
		double twoSided(double, double);
		double truncNormalRnd(double, double, double, double);
		double ghkTruncNormRnd(double, double, double, double);
		void tmvnrand(VectorXd&, VectorXd&, VectorXd&, MatrixXd&, MatrixXd&, VectorXd&);
        void inversionTMVN(double a, double b, VectorXd& mu, MatrixXd& sigma, MatrixXd& sample,
                 VectorXd& sigmaVect);
        double conditionalMean(double Hxx, VectorXd& Hxy, VectorXd& muNotJ, VectorXd& xNotJ, double muxx);
        void tnormrndTEST(double a, double b, double mu, double sigma, VectorXd& variates);
		double tnormpdf(double a, double b, double mu, double sigma, double x);
		double mvnpdf(VectorXd, MatrixXd, VectorXd);
		double standardDev(VectorXd&);
		void ghkSampler(double, double, VectorXd&, MatrixXd&, int);
		MatrixXd ghkDraws;
		void ghkLinearConstraints(VectorXd&, VectorXd&, VectorXd&, MatrixXd&, MatrixXd&);
		void unifrnd(double, double, VectorXd&);
		void lrLikelihood(MatrixXd&, VectorXd&, VectorXd&, MatrixXd&);
		VectorXd linreglike;
		void logmvnpdf(MatrixXd&, VectorXd&, MatrixXd&);
		VectorXd lmvnpdf;
		void loginvgammapdf(VectorXd&, double, double);
		VectorXd ligampdf;
};
#endif

