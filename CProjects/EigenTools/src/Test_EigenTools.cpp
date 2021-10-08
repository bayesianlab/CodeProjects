#include <iostream>
#include "EigenTools.hpp"
#include <Eigen/Dense>
#include <Eigen/Sparse>
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

    return 0;
}