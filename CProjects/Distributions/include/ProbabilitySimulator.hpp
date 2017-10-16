#ifndef LIKELIHOOD
#define LIKELIHOOD

#include <Eigen/Dense>
#include "Dist.hpp"

using namespace Eigen;
class ProbabilitySimulator{
	private:
		Dist distributionObject;
    public:
	   ProbabilitySimulator();
       void chibRaoBlackwell(VectorXd& a, VectorXd& b, VectorXd& mu, MatrixXd& sigma, 
                VectorXd& zStar, VectorXd& fzStar, int, int, int, int );

	   int getReducedRunSampleColumnDimension(int );
	   void fillSigmaVect(VectorXd&, VectorXd&);
	   double getfzStarMeanAtCol(double, double, MatrixXd&, int, double, double);
	   void fillfzStar(VectorXd&, int, VectorXd&, VectorXd&, MatrixXd&, VectorXd&, VectorXd&);
	    
};

#endif
