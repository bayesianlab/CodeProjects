#include <Eigen/Dense>
#include <iostream>
#include <map>
#include "Simplex.hpp"

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


int main()
{
    // cout << "tableau" << endl;
    // cout << "Problem" << endl;
    // cout << "min -x0 + x1" << endl;
    // cout << "s.t. x0 -x1 <= 2" << endl;
    // cout << "     x0 + x1 <= 6" << endl;
    // VectorXd c(2);
    // c << -1, 1;
    // MatrixXd A(2, 2);
    // A << 1, -1, 1, 1;
    // VectorXd b(2);
    // b << 2, 6;
    Simplex S; 
    // S.optimize(c, A, b);
    // for (auto it = S.Solution.begin(); it != S.Solution.end(); ++it)
    // {
    //     cout << it->first << " " << it->second << endl;
    // }

     cout << "Problem 2" << endl;
     cout << "min -10x1 - 12x2 -12x3" << endl;
     cout << "s.t. x1 + 2x2 + 2x3 <= 20" << endl;
     cout << "s.t. 2x1 + 1x2 + 2x3 <= 20" << endl;
     cout << "s.t. 2x1 + 2x2 + 1x3 <= 20" << endl;

     VectorXd c2(3);
     c2 << -10, -12, -12;
     MatrixXd A2(3, 3);
     A2 << 1, 2, 2, 2, 1, 2, 2, 2, 1;
     VectorXd b2(3);
     b2 << 20, 20, 20;
     vector<string> constraint_type = { "leq", "leq", "leq"};

     S.Simplex2(c2, A2, b2, constraint_type);
     S.print_solution();
    // for (auto it = S.Solution.begin(); it != S.Solution.end(); ++it)
    // {
    //     cout << it->first << " " << it->second << endl;
    // }

    //cout << "Problem 3 Luenberger & Ye" << endl;
    //cout << "min 4x1 + x2 + x3" << endl;
    //cout << "s.t. 2x1 + 1x2 + 2x3 = 4" << endl;
    //cout << "s.t. 3x1 + 3x2 + 1x3 = 3" << endl;
    //VectorXd c3(3);
    //c3 << 4, 1, 1;
    //MatrixXd A3(2, 3);
    //A3 << 2, 1, 2, 
    //      3, 3, 1;
    //VectorXd b3(2);
    //b3 << 4, 3;

    //S.Simplex2(c3, A3, b3);
    //
    //S.print_solution(); 

    cout << "Problem 4 Chen Baston & D" << endl; 
    cout << "max 5x1 - 2x2" << endl; 
    cout << "-x1 + 2x2 <= 5" << endl; 
    cout << "3x1 + 2x2 <= 19" << endl; 
    cout << "-x1 - 3x2 <= -9" << endl; 

	VectorXd c4(2);
	c4 << -5, 2;
	MatrixXd A4(2, 2);
	A4 << 
	    3, 2, 
        1, 3;
	VectorXd b4(2);
	b4 <<  19, -9;

    vector<string> constraint_type4 = { "leq", "leq" };

	S.Simplex2(c4, A4, b4, constraint_type4);

	S.print_solution();

    return 0;
}
