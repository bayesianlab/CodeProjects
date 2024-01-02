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

// map<string, int> simplex(VectorXd &costs, MatrixXd &A, VectorXd &b)
// {
//     cout << "started simplex" << endl;
//     int m = A.rows();
//     map<int, int> Basic_indxs;
//     map<int, int> NonBasic_indxs;
//     map<int, string> X_labels;
//     map<string, int> Solution;
//     int c = 0;
//     for (int i = 0; i < (2 * m); ++i)
//     {
//         if (i < m)
//         {
//             NonBasic_indxs[i] = i;
//         }
//         else
//         {
//             Basic_indxs[i - m] = i;
//         }
//         string x = "x_" + to_string(i);
//         X_labels[i] = x;
//     }
//     VectorXd non_basic_costs = costs;
//     VectorXd basic_costs = VectorXd::Zero(m);
//     VectorXd reduced_costs(m);
//     MatrixXd NonBasicBasis = A;
//     MatrixXd CurrentBasis = MatrixXd::Identity(m, m);
//     VectorXd current_sol = b;

//     current_sol = CurrentBasis.lu().solve(b);
//     int k = 0;
//     for (auto it = Basic_indxs.begin(); it != Basic_indxs.end(); ++it)
//     {
//         Solution[X_labels[it->second]] = current_sol[k];
//     }
//     int entering_col = -1;
//     for (int i = 0; i < 10; ++i)
//     {
//         // cout << "Current Sol" << endl;
//         // cout << current_sol.transpose() << endl;
//         cout << "Iteration " << i << endl;
//         cout << "\tCurrent F - Val= " << basic_costs.transpose() * current_sol << endl;
//         VectorXd y = CurrentBasis.transpose().lu().solve(basic_costs);
//         reduced_costs = non_basic_costs.transpose() - y.transpose() * NonBasicBasis;
//         cout << "\treduced costs" << endl;
//         cout << "\t" << reduced_costs.transpose() << endl;
//         int continue_bool = reduced_costs.minCoeff();
//         if (0 <= continue_bool)
//         {
//             cout << "\tcurrent solution is optimal" << endl;
//             return Solution;
//         }
//         for (int j = 0; j < reduced_costs.size(); ++j)
//         {
//             if (reduced_costs(j) < 0)
//             {
//                 entering_col = j;
//             }
//         }
//         cout << "\tentering vector= " << entering_col << " " <<NonBasic_indxs[entering_col] << endl;
//         VectorXd aq = NonBasicBasis.col(entering_col);
//         VectorXd denominator = CurrentBasis.lu().solve(aq);
//         if (denominator.maxCoeff() < 0)
//         {
//             cout << "\tProblem is unbounded" << endl;
//             break;
//         }
//         double min_ratio = current_sol(0) / denominator(0);
//         int exiting_col = 0;

//         for (int j = 0; j < aq.size(); ++j)
//         {
//             if (denominator(j) > 0)
//             {
//                 double can = (current_sol(j) / denominator(j));
//                 if (can < min_ratio)
//                 {
//                     min_ratio = can;
//                     exiting_col = j;
//                 }
//             }
//         }

//         cout << "\texiting vector= " << exiting_col << " " << Basic_indxs[exiting_col] << endl;

//         VectorXd t = CurrentBasis.col(exiting_col);
//         CurrentBasis.col(exiting_col) = NonBasicBasis.col(entering_col);
//         NonBasicBasis.col(entering_col) = t;
//         current_sol = CurrentBasis.lu().solve(b);
//         double tt = basic_costs(exiting_col);
//         basic_costs(exiting_col) = non_basic_costs(entering_col);
//         non_basic_costs(entering_col) = tt;

//         int ti = Basic_indxs[exiting_col];
//         Basic_indxs[exiting_col] = entering_col;
//         NonBasic_indxs[entering_col] = ti;

//         int k = 0;
//         for (auto it = Basic_indxs.begin(); it != Basic_indxs.end(); ++it)
//         {
//             Solution[X_labels[it->second]] = current_sol[k];

//             ++k;
//         }
//         for (auto it = NonBasic_indxs.begin(); it != NonBasic_indxs.end(); ++it)
//         {
//             Solution[X_labels[it->second]] = 0;

//             ++k;
//         }
//     }
//     return Solution;
// }

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

    // cout << "Problem 2" << endl;
    // cout << "min -10x1 - 12x2 -12x3" << endl;
    // cout << "s.t. x1 + 2x2 + 2x3 <= 20" << endl;
    // cout << "s.t. 2x1 + 1x2 + 2x3 <= 20" << endl;
    // cout << "s.t. 2x1 + 2x2 + 1x3 <= 20" << endl;

    // VectorXd c2(3);
    // c2 << -10, -12, -12;
    // MatrixXd A2(3, 3);
    // A2 << 1, 2, 2, 2, 1, 2, 2, 2, 1;
    // VectorXd b2(3);
    // b2 << 20, 20, 20;

    // S.optimize(c2, A2, b2);
    // for (auto it = S.Solution.begin(); it != S.Solution.end(); ++it)
    // {
    //     cout << it->first << " " << it->second << endl;
    // }

    cout << "Problem 3" << endl;
    cout << "min 4x1 + x2 + x3" << endl;
    cout << "s.t. 2x1 + 1x2 + 2x3 = 4" << endl;
    cout << "s.t. 3x1 + 3x2 + 1x3 = 3" << endl;
    VectorXd c3(3);
    c3 << 4, 1, 1;
    MatrixXd A3(2, 3);
    A3 << 2, 1, 2, 
          3, 3, 1;
    VectorXd b3(2);
    b3 << 4, 3;

    S.phase1(c3, A3, b3);
    S.print_solution(); 
    return 0;
}
