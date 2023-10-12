#include <iostream>
#include <Eigen/Dense>

using namespace std; 
using namespace Eigen; 
int main()
{
    cout << "tableau" << endl; 

    int n_objective_x = 3; 
    int n_constraints = 7;
    int n_constraint_x = 5;  
    VectorXd xb = VectorXd::Ones(n_objective_x); 
    VectorXd c(3);
    c << 3,1,1;
    cout << "Initial obj" << endl;  
    cout << c.transpose() * xb << endl;  


    MatrixXd A(n_constraints, n_constraint_x); 
    A<< 2,1,1,1,0, 
        1,-1,-1,0,1,
        1,0,0,0,0,
        0,1,0,0,0,
        0,0,1,0,0,
        0,0,0,1,0,
        0,0,0,0,1;
    
    cout << "A" << endl; 
    cout << A << endl; 

    MatrixXd Slack = MatrixXd::Identity(n_constraints, n_constraints);

    MatrixXd AI(n_constraints, n_constraint_x + n_constraints);
    AI<<A, Slack; 
    cout << AI << endl; 
    cout << "Phase I" << endl; 
    VectorXd c_slack = VectorXd::Ones(n_constraints);
    MatrixXd B = Slack; 
    

    VectorXd y = c_slack.transpose()*B; 
    VectorXd cD = VectorXd::Zero(n_constraint_x);
    cout << y.size() << endl; 
    cout << A.rows() << " " << A.cols() << endl; 
    cout << cD.size() << endl; 
    cout << y.transpose()*A << endl; 
    VectorXd rD = cD.transpose() - y.transpose()*A; 
    cout << "cost coefs" << endl; 
    cout << rD << endl; 


	return 0; 
}