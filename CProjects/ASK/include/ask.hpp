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


	public:
		Ask(VectorXd&, VectorXd&, VectorXd&, MatrixXd&, int, int, int);
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
		VectorXd weight;

		void conditionalMean(double, VectorXd&, VectorXd&,
			   	MatrixXd&, double, VectorXd&);
		
		void tnormpdf(double, double, VectorXd&, double, double, 
		VectorXd&);

		void adaptiveSampler(double, int, int, int );
		int isVectVgreater(VectorXd&, VectorXd&);
		MatrixXd burninAdaptive(int, int, double);
		double calcPeta(VectorXd&, VectorXd&);


};

#endif

