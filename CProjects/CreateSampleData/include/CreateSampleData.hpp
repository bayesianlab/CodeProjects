#include <Eigen/Dense>
#include "Dist.hpp"
using namespace Eigen;

class CreateSampleData:public Dist{
	public:
		CreateSampleData(int, VectorXd&);
		MatrixXd X;
		MatrixXd epsilon;
		VectorXd y;
		VectorXd mles;
		VectorXd resids;
		MatrixXd inverseFisher;
		double residsTresids;
		double sigmaSqdHat;
		VectorXd theta;
		int dimension;
		
};
