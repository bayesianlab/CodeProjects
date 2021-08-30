#include <stdio.h>
#include "GenerateAutoRegressiveData.hpp"
#include "AutoregressiveModel.hpp"
#include "MultilevelModelFunctions.hpp"

int main()
{
    int T = 50;
    MatrixXd p(1, 3);
    p << .1, .15, .3;
    MatrixXd params = p.replicate(3, 1);

    // GenerateAutoRegressiveData gar(T, params, .5);
    // AutoregressiveModel ar;
    // double r0 = 6;
    // double R0 = 8;
    // RowVectorXd b0 = RowVectorXd::Zero(gar.Xt.cols());
    // MatrixXd B0 = 10*MatrixXd::Identity(gar.Xt.cols(), gar.Xt.cols());
    // ar.setModel(gar.yt, gar.Xt, params,  r0, R0, b0, B0);
    // ar.runAr(3);

    MatrixXd Y(1, 10);
    Y << 1, 2, 3, 4, 5, 6, 7, 8, 9, 10;
    MatrixXd X = Y.replicate(3, 1);
    VectorXd sigma2 = VectorXd::Ones(3);
    cout << makeStationary(X.transpose(), params, sigma2, 1) << endl;

    return 0;
}
