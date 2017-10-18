#ifndef ASK_H 
#define ASK_H 

#include <Eigen/Dense>
#include "Dist.hpp"

using namespace Eigen;

class Ask: public Dist{
	private:

		MatrixXd xNotj;
		VectorXd Hxy;
		VectorXd muNotj;

		int startingPlace;

	public:
		Ask(VectorXd&, VectorXd&, VectorXd&, MatrixXd&, int, int);
		MatrixXd sample;
		int J;
		int Jminus1;
		VectorXd sigmaVector;
		VectorXd mu;
		MatrixXd Kernel;
		void gibbsKernel();
		VectorXd lowerTruncPoints;
		VectorXd upperTruncPoints;
		VectorXd theta;
		MatrixXd sigma;
		MatrixXd precision;	
		VectorXd zStar;
		VectorXd Hxx;
		int Rows;

		void conditionalMean(double, VectorXd&, VectorXd&,
			   	MatrixXd&, double, VectorXd&);
		
		void tnormpdf(double, double, VectorXd&, double, double, 
		VectorXd&);

		void adaptiveSampler(double, int, int );

};

#endif

