#include "GenerateFavarData.hpp"

int main()
{
    cout << "Test FAVAR" << endl; 
    GenerateFavarData gfd; 
    RowVectorXd gammas(2);
    gammas << .4, .4; 
    gfd.genData(2, 100, 2, gammas);
    return 1; 
}