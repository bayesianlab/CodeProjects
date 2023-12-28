#include <iostream>
#include <Eigen/Dense>

using namespace std; 
using namespace Eigen; 

void swap_col(MatrixXd &A, MatrixXd &B, int a, int b)
{
    VectorXd t = A.col(a);
    A.col(a) = B.col(b);
    B.col(b) = t;
}

void swap_col(VectorXd &A, VectorXd &B, int a, int b)
{
    double t = A(a);
    A(a) = B(b);
    B(b) = t;
}

void simplex(VectorXd &costs, MatrixXd &A, VectorXd &b)
{
    cout << "started simplex" << endl; 
    int m = A.rows(); 
    VectorXd non_basic_costs = costs;  
    VectorXd basic_costs = VectorXd::Zero(m); 
    VectorXd reduced_costs(m); 
    MatrixXd NonBasicBasis = A; 
    MatrixXd CurrentBasis = MatrixXd::Identity(m, m);
    VectorXd current_sol = CurrentBasis*b; 
    cout << "Current Sol" << endl; 
    cout << current_sol.transpose() << endl; 
    int entering_col = -1; 
    for (int i = 0; i < 2; ++i)
    {
        cout << "Current F - Val= " << costs.transpose()*current_sol << endl; 
        VectorXd y = CurrentBasis.lu().solve(basic_costs); 
        reduced_costs = non_basic_costs.transpose() - y.transpose() * NonBasicBasis; 
        cout << "reduced costs" << endl; 
        cout << reduced_costs.transpose() << endl; 
        for (int j = 0; j < reduced_costs.size(); ++j)
        {
            if (reduced_costs(j) < 0)
            {
                entering_col = j; 
            }
        }
        cout << "entering vector= " << entering_col << endl; 
        VectorXd aq = NonBasicBasis.col(entering_col);
        VectorXd denominator = CurrentBasis.lu().solve(aq);
        if (denominator.maxCoeff() < 0)
        {
            cout << "problem is unbounded" << endl; 
            break; 
        }
        double min_ratio = current_sol(0)/denominator(0); 
        int exiting_col = 0; 

        for (int j = 0; j < aq.size(); ++j)
        {
            if (denominator(j) > 0)
            {
                double can = (current_sol(j) / denominator(j));
                if (can < min_ratio)
                {
                    min_ratio = can; 
                    exiting_col = j; 
                }
            }
        }
        cout << "exiting vector= " << exiting_col << endl; 
        swap_col(CurrentBasis, NonBasicBasis, entering_col, exiting_col);
        swap_col(basic_costs, non_basic_costs, entering_col, exiting_col);
        cout << "CurrentBasis" << endl; 
        cout << CurrentBasis << endl; 
        cout << "NonBasicBasis" << endl;
        cout << NonBasicBasis << endl; 
        cout << "basic costs" << endl;
        cout << basic_costs.transpose() << endl; 
        cout << "non basic costs" << endl; 
        cout << non_basic_costs.transpose() << endl; 
        
        current_sol = CurrentBasis.lu().solve(b); 
        cout << endl; 
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
    VectorXd b(2);
    b << 2, 6;

    simplex(c, A, b);
    

	return 0; 
}