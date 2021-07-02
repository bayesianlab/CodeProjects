#include <eigen-3.3.9/Eigen/Dense>
#include <iostream>

using namespace Eigen;
using namespace std;

// template <typename D>
void f(MatrixXd &resids)
{
    cout << resids << endl; 
    resids(0,0) = 11; 
    resids.resize(resids.rows()*resids.cols(), 1);
}

int main()
{
    MatrixXd T = MatrixXd::Random(4,1);
    f(T);
    cout << T << endl; 
}