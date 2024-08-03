#include <Eigen/Dense>
#include <iostream> 
#include "VAR.hpp"
#include "Distributions.hpp"

using namespace std;
using namespace Eigen;

int main(){
    cout << "Test VAR" << endl; 

    
    int K = 3; 
    int T = 15;
    int p = 3; 
    VarData vd(K, T, p); 
    vd.coefs(.5); 
    cout << vd.Beta << endl; 

    MatrixXd Y = normrnd(0,1, K, 10);
    VectorXd y = MatrixXd::Ones(K, 1); 
    vd.cycle(Y, y);

    vd.generate(.5); 

}