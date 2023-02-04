#include "GenerateFavarData.hpp"

int main()
{
    cout << "Test FAVAR" << endl; 
    int K = 2;
    int nFactors = 2; 
    GenerateFavarData gfd; 
    RowVectorXd gammas(2);
    gammas << .2, .4; 
    MatrixXd A = MatrixXd:: Ones(K, nFactors);
    gfd.genData(2, 100, 2, gammas);
    return 1; 
}