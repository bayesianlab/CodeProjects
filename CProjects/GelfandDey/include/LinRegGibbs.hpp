#include "Dist.hpp"

class LinRegGibbs:public Dist{
	
	public:
          void gibbsLR(const VectorXd &, const MatrixXd &x, const int);
          void gibbsBetaUpdates(MatrixXd &, VectorXd &, const VectorXd &,
                            const MatrixXd &, const VectorXd &,
                            const MatrixXd &, const VectorXd &, int);
};
