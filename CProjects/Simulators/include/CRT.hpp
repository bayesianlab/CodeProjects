#ifndef CRT_H 
#define CRT_H 

#include <Eigen/Dense>
#include "Dist.hpp"

using namespace Eigen;
class CRT:public Dist{
	private:
		MatrixXd precision;
		VectorXd Hxx;
		MatrixXd xNotj;
		VectorXd muNotj;
		VectorXd Hxy;
		int J;
		int Rows;
		int Jminus1;
		VectorXd ll;
		VectorXd ul;
		VectorXd mu;
		MatrixXd Sigma;
		VectorXd xnotJ;
	public:
		CRT(VectorXd&, VectorXd&, VectorXd&, MatrixXd&, int, int);
		
		
		void gibbsKernel();

		MatrixXd Kernel;

		VectorXd zStar;

		MatrixXd truncatedSample;
		
		VectorXd sigmaVector;	
		double getKernelColumn(double a, double b, MatrixXd& sample, int col,
	   					double sigma, double zStar);

		void conditionalMean(double, VectorXd&, VectorXd&, MatrixXd&, 
				double, VectorXd&);

		void tnormpdf(double, double, VectorXd&, double, double, VectorXd&);
		
}; 


#endif
