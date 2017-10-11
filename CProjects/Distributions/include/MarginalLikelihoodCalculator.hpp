#ifndef MARG_LIKE
#define MARG_LIKE
#include <Eigen/Dense>
#include "Dist.hpp"

using namespace Eigen;

class MarginalLikelihoodCalculator:public Dist{
	public:
		void linearRegressionLikelihood();
};
#endif 
