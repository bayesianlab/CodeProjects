#include <Eigen/Dense>

using namespace Eigen;

#ifndef LIKELIHOOD
#define LIKELIHOOD
class ProbabilitySimulator{
    public:
       
       void chibRaoBlackwell(double a, double b, VectorXd& mu, MatrixXd& sigma, 
                VectorXd& zStar, VectorXd& fzStar, int, int, int, int );
} ;

#endif
