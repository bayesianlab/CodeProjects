#include <stdio.h>
#include <Eigen/Dense>
#include "GenerateAutoRegressiveData.hpp"
#include "AutoregressiveModel.hpp"
#include "MultilevelModelFunctions.hpp"

using namespace std;
using namespace Eigen;

int main()
{
    int on = 1;
    if (on == 1)
    {
        int T = 150;
        MatrixXd p(1, 3);
        p << 0.05, 0.15, 0.25;
        MatrixXd params = p.replicate(1, 1);

        GenerateAutoRegressiveData gar(T, params, -.25);
        AutoregressiveModel ar;
        double r0 = 6;
        double R0 = 8;
        RowVectorXd b0 = RowVectorXd::Zero(gar.Xt.cols());
        MatrixXd B0 = 10 * MatrixXd::Identity(gar.Xt.cols(), gar.Xt.cols());
        RowVectorXd g0 = RowVectorXd::Zero(gar.lags);
        MatrixXd G0 = MatrixXd::Identity(gar.lags, gar.lags);
        ar.setModel(gar.yt, gar.Xt, g0, G0, r0, R0, b0, B0);
        ar.runAr(25, 5);
        cout << mean(ar.storeBeta) << endl;
        cout << mean(ar.storeArParams) << endl; 
        cout << mean(ar.storeSigma2) << endl; 
        
    }

    return 0;
}
