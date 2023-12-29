#include <iostream>
#include <Eigen/Dense>

using namespace std; 
using namespace Eigen; 

void simplex(VectorXd &costs, MatrixXd &A, VectorXd &b){
    cout << "starting simplex algorithm" << endl; 
    int n_vars = costs.size(); 
    int n_constraints = A.rows();
    VectorXd cb = VectorXd::Zero(n_constraints);
    VectorXd cd = VectorXd::Zero(n_constraints); 
    
    MatrixXd B = MatrixXd::Identity(n_constraints,n_constraints); 
    MatrixXd D = B; 
    VectorXd reduced_costs(n_constraints);
    for (int iter =0; iter < 10; iter++){
        VectorXd y = B.lu().solve(cb); 
        reduced_costs = cd.transpose() - y.transpose()*D; 
        // cout << reduced_costs << endl; 


    }
    
}


int main()
{
    cout << "tableau" << endl; 
    cout << "Problem" << endl; 
    cout << "min -x1 + x2" << endl;
    cout << "s.t. x1 -x2 <= 2" << endl; 
    cout << "     x1 + x2 <= 6" << endl; 
    VectorXd c(2);
        c << -1, 1;
    MatrixXd A(2, 2); 
        A << 1, -1, 1, 1;
    cout << "Costs " << endl; 
    cout << c << endl; 
    cout << "Constraints" << endl;
    cout << A << endl; 
    VectorXd b(2);
    b << 2, 6;
    cout << "Aux problem" << endl << endl; 
    cout << "min qu"
         << " q = (1,...,1)T" << endl; 
    cout << "s.t. Ax + u = b" << endl << endl;
     
    cout << "Initial Basis is identity dim(2,2)" << endl; 
    MatrixXd B = MatrixXd::Identity(2,2);
    cout << B << endl; 

    VectorXd cd(2);
    cd << -1, 1; 
    VectorXd cb(2);
    cb << 1, 1; 

    cout << "solve linear system for B-1" << endl;
    VectorXd y = B.lu().solve(cb); 
    cout << y << endl; 
    cout << "Matrix D" << endl; 
    MatrixXd D(2,2);
    D << -1, 1, -1, -1;
    VectorXd costs = cd.transpose() - y.transpose() * D;
    cout << "costs" << endl;
    cout << costs << endl; 

    simplex(c, A, b);
    

	return 0; 
}