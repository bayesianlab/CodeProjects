#include <Eigen/Dense>
#include <iostream>
#include <map>
#include <vector>
#include <math.h>

#include "SimplexCore.hpp"

using namespace std;
using namespace Eigen;

class Simplex : public SimplexCore
{
private:
    void write_solution(const VectorXd &solution, const map<int, int> &BasicIndices,
                        const map<int, int> &NonBasicIndices, map<int, tuple<string, string, double>> &DetailedSolution)
    {
        int k = 0;
        pair<string, string> label = make_pair("error", "error");
        for (auto it = BasicIndices.begin(); it != BasicIndices.end(); ++it)
        {
            if (DetailedSolution.find(it->second) != DetailedSolution.end())
            {
                get<2>(DetailedSolution.find(it->second)->second) = solution[k];
            }
            else
            {
                cout << "Error in setup of problem, X_labels does not have a key in the basic index" << endl;
                return;
            }

            ++k;
        }
        for (auto it = NonBasicIndices.begin(); it != NonBasicIndices.end(); ++it)
        {
            if (DetailedSolution.find(it->second) != DetailedSolution.end())
            {
                get<2>(DetailedSolution.find(it->second)->second) = 0;
            }
            else
            {
                cout << "Error in setup of problem, X_labels does not have a key in the basic index" << endl;
                return;
            }

            ++k;
        }
    }

    int get_slack_variable_cnt(const vector<string> &constraint_type)
    {
        int slack_count = 0;
        for (int i = 0; i < constraint_type.size(); ++i)
        {
            if (constraint_type[i] == "leq")
            {
                slack_count++;
            }
        }
        return slack_count;
    }

public:
    int max_iterations = 100;

    void add_choice_variables(map<string, double> &costs)
    {
    }

    void presolve_1pos_incol(MatrixXd &B, VectorXd &soln_vec, map<int, int> &BasicIndices,
                             int col, int total_cols)
    {
        if (col >= total_cols)
        {
            return;
        }
        int rows = B.rows();
        int non_zero = 0;
        int delete_row = 0;
        for (int k = 0; k < rows; ++k)
        {
            if (B(k, col) != 0)
            {
                non_zero++;
                delete_row = k;
            }
        }
        if (non_zero == 1)
        {
            not_index_j(B, delete_row, col);
            not_index_j(soln_vec, delete_row);
            BasicIndices.erase(delete_row); 
            total_cols = B.cols();
            presolve_1pos_incol(B, soln_vec, BasicIndices, col, total_cols);
        }
        else
        {
            presolve_1pos_incol(B, soln_vec, BasicIndices, col + 1, total_cols);
        }
    }

    void Presolve(MatrixXd &CurrentBasis, VectorXd &current_solution, map<int, int> &BasicIndices)
    {
        presolve_1pos_incol(CurrentBasis, current_solution, BasicIndices, 0, CurrentBasis.cols());
    }

    void not_index_j(VectorXd &X, int j)
    {
        int n = 0;
        VectorXd Xcopy(X.rows() - 1);
        for (int i = 0; i < X.rows(); ++i)
        {
            if (i == j)
            {
                continue;
            }
            else
            {
                Xcopy(n) = X(i);
                ++n;
            }
        }
        X.resize(X.rows() - 1);
        X = Xcopy;
        return;
    }

    void not_index_j(MatrixXd &X, int i, int j)
    {
        int n = 0;
        MatrixXd Xcopy(X.cols() - 1, X.rows() - 1);
        for (int u = 0; u < X.rows(); ++u)
        {
            int m = 0;
            if (u == i)
            {
                continue;
            }
            for (int k = 0; k < X.cols(); ++k)
            {
                if (k == j)
                {
                    continue;
                }
                else
                {
                    Xcopy(n, m) = X(u, k);
                    ++m;
                }
            }
            ++n;
        }
        X.resize(X.cols() - 1, X.rows() - 1);
        X = Xcopy;

        return;
    }

    void drive_out_artificials(const VectorXd &costs, const MatrixXd &A, const VectorXd &b)
    {

        // if (optimization_status == "successful")
        // {
        //     int n = (int)costs.size();
        //     int m = (int)b.size();
        //     int artificial_in_basis_flag = 0;
        //     vector<string> artificials;
        //     for (int i = n; i < (n + m); ++i)
        //     {
        //         if (Solution.find("x_" + i) != Solution.end())
        //         {
        //             artificial_in_basis_flag = 1;
        //             cout << "drive out" << endl;
        //             artificials.push_back("x_" + i);
        //         }
        //     }
        //     if (artificial_in_basis_flag == 1)
        //     {
        //         cout << "Artificial variables found in basis" << endl;
        //     }
        // }
        // else
        // {
        //     return;
        // }
    }

    int phase1precheck(const VectorXd &b)
    {
        if (b.minCoeff() < 0)
        {
            cout << "All b elements must be positive" << endl;
            return -1;
        }
        return 0;
    }

    Solution phase1(const MatrixXd &A, const VectorXd &b, const vector<string> &constraint_type)
    {
        Solution phase1;
        if (phase1precheck(b) < 0)
        {
            return phase1;
        }
        cout << "Starting Phase-I To Determine Basic Feasible Solution" << endl;
        int slack_count = get_slack_variable_cnt(constraint_type);
        int choice_count = (int)A.cols();
        int artificial_count = (int)A.rows();
        int non_basic_var_count = choice_count + slack_count;
        map<int, tuple<string, string, double>> DetailedSolution;
        for (int i = 0; i < non_basic_var_count + artificial_count; ++i)
        {
            string label = "x_" + to_string(i);
            string type;
            if (i < choice_count)
            {
                type = "choice";
            }
            else if (i >= choice_count && i < choice_count + slack_count)
            {
                type = "slack";
            }
            else
            {
                type = "artificial";
            }
            DetailedSolution[i] = make_tuple(label, type, 0);
        }
        MatrixXd CB = MatrixXd::Identity(artificial_count, artificial_count);
        MatrixXd NonBasicBasis(artificial_count, non_basic_var_count);
        NonBasicBasis << A, MatrixXd::Identity(artificial_count, artificial_count);
        VectorXd basic_costs = VectorXd::Ones(artificial_count);
        VectorXd non_basic_costs = VectorXd::Zero(non_basic_var_count);
        phase1 = simplex(CB, NonBasicBasis, basic_costs, non_basic_costs, b, max_iterations);
        write_solution(phase1.current_solution, phase1.BasicIndices, phase1.NonBasicIndices, DetailedSolution);
        printDetailedSolution(DetailedSolution);
        return phase1;
    }

    void Simplex1(VectorXd &costs, MatrixXd &A, VectorXd &b, MatrixXd &_CurrentBasis)
    {
    }

    void Simplex2(const VectorXd &costs, const MatrixXd &A, const VectorXd &b, const vector<string> &constraint_type)
    {
        cout << "Two phase simplex" << endl;
        Solution phase1_solution = phase1(A, b, constraint_type);
        MatrixXd CurrentBasis = phase1_solution.CurrentBasis;
        VectorXd current_solution = phase1_solution.current_solution;
        Presolve(CurrentBasis, current_solution, phase1_solution.BasicIndices);
        // Solution phase2 = simplex(CurrentBasis, )
    }

    void printDetailedSolution(map<int, tuple<string, string, double>> &DetailedSolution)
    {
        cout << endl;
        for (auto it = DetailedSolution.begin(); it != DetailedSolution.end(); it++)
        {
            cout << it->first << " " << get<0>(it->second) << " " << get<1>(it->second) << " " << get<2>(it->second) << endl;
        }
    }
};