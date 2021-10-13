#include <iostream>
#include "EigenTools.hpp"
#include <Eigen/Dense>
#include <Eigen/Sparse>
#include "TimeSeriesTools.hpp"
int main()
{

    MatrixXd A(2, 2);
    A << 1,10, 10, 1;
    int T = 6;
    MatrixXd B = A.replicate(T, 1);
    

    MatrixXd Y = blockDiag(B, 2);
    MatrixXd X = makeBlockDiagonal(A, 5); 

    SparseMatrix<double> S(T*A.rows(), T*A.cols());
    
    makeBigBlockDiag(S, A, T); 
    cout << S << endl;

    RowVectorXd p(1); 
    p << .4;
    MatrixXd params = p; 
    VectorXd var = VectorXd::Ones(1); 
    cout << MakePrecisionBig(params, var, 10) << endl; 

    return 0;
}