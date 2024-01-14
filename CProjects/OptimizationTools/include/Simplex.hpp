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
    map<int, tuple<string, string, double>> write_solution(const VectorXd &solution, const map<int, int> &BasicIndices,
                        const map<int, int> &NonBasicIndices, int choice_count, int non_basic_var_count,
                        int slack_count, int artificial_count)
    {
        map<int, tuple<string, string, double>> DetailedSolution = fill_detailed_solution(choice_count, non_basic_var_count,
                                                                                          slack_count, artificial_count);
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
                return DetailedSolution;
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
                return DetailedSolution;
            }

            ++k;
        }
        return DetailedSolution;
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

    double solve(RowVectorXd basic_row, VectorXd x_values, double solution, int solve_indx)
    {
        double v = 0;
        for (int i = 0; i < basic_row.size(); i++)
        {
            if (i != solve_indx)
            {
                v += basic_row(i) * x_values(i);
            }
        }
        return solution - v;
    }

public:
    int max_iterations = 100;

    void add_choice_variables(map<string, double> &costs)
    {
    }

    void presolve_1pos_incol(MatrixXd &B, VectorXd &soln_vec, map<int, int> &BasicIndices,
                             int col, int total_cols, VectorXd &b, map<int, double> &solved_solutions,
                             vector<string> &constraint_type)
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
            double sln = solve(B.row(delete_row), soln_vec, b(delete_row), delete_row);
            solved_solutions[BasicIndices[delete_row]] = sln;
            constraint_type.erase(constraint_type.begin() + delete_row);
            not_index_j(B, delete_row, col);
            not_index_j(soln_vec, delete_row);
            not_index_j(b, delete_row);
            BasicIndices.erase(delete_row);
            total_cols = B.cols();
            presolve_1pos_incol(B, soln_vec, BasicIndices, col, total_cols, b, solved_solutions, constraint_type);
        }
        else
        {
            presolve_1pos_incol(B, soln_vec, BasicIndices, col + 1, total_cols, b, solved_solutions, constraint_type);
        }
    }

    void Presolve(MatrixXd &CurrentBasis, VectorXd &current_solution, map<int, int> &BasicIndices, VectorXd &b,
                  map<int, double> &other_solutions, vector<string> &constraint_type)
    {
        presolve_1pos_incol(CurrentBasis, current_solution, BasicIndices, 0, CurrentBasis.cols(), b, other_solutions,
                            constraint_type);
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

    map<int, tuple<string, string, double>> fill_detailed_solution(int choice_count,
                                                                   int non_basic_var_count, int slack_count, int artificial_count)
    {
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
        return DetailedSolution;
    }

    Solution phase1(const MatrixXd &A, const VectorXd &b, vector<string> &constraint_type)
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
        MatrixXd CB = MatrixXd::Identity(artificial_count, artificial_count);
        MatrixXd NonBasicBasis(artificial_count, non_basic_var_count);
        NonBasicBasis << A, MatrixXd::Identity(artificial_count, artificial_count);
        VectorXd basic_costs = VectorXd::Ones(artificial_count);
        VectorXd non_basic_costs = VectorXd::Zero(non_basic_var_count);
        phase1 = simplex(CB, NonBasicBasis, basic_costs, non_basic_costs, b, max_iterations);
        map<int, tuple<string, string, double>> DetailedSolution = write_solution(phase1.current_solution, phase1.BasicIndices, phase1.NonBasicIndices, choice_count,
                       non_basic_var_count, slack_count, artificial_count);
        printDetailedSolution(DetailedSolution);
        return phase1;
    }

    void Simplex1(VectorXd &costs, MatrixXd &A, VectorXd &b, MatrixXd &_CurrentBasis)
    {
    }

    void Simplex2(VectorXd &costs, MatrixXd &A, VectorXd &b, vector<string> &constraint_type)
    {
        cout << "Two phase simplex" << endl;
        int choice_count = (int)A.cols();
        Solution phase1_solution = phase1(A, b, constraint_type);
        // VectorXd current_solution = phase1_solution.current_solution;
        // map<int, double> other_solutions;
        // Presolve(phase1_solution.CurrentBasis, phase1_solution.current_solution, phase1_solution.BasicIndices, b, other_solutions, constraint_type);
        // MatrixXd D = MatrixXd::Identity(phase1_solution.CurrentBasis.rows(), phase1_solution.CurrentBasis.rows());
        // VectorXd c_D = VectorXd::Zero(b.size());
        // Solution phase2 = simplex(phase1_solution.current_solution, phase1_solution.CurrentBasis, D, costs, c_D, b, 10);
        // map<int, tuple<string, string, double>> DetailedSolution;
        // int slack_count = phase1_solution.CurrentBasis.rows();
        // int non_basic_var_count = phase1_solution.CurrentBasis.rows();
        // fill_detailed_solution(DetailedSolution, choice_count, non_basic_var_count, slack_count, 0);
        // write_solution(phase1_solution.current_solution, phase1_solution.BasicIndices, phase1_solution.NonBasicIndices, DetailedSolution);
        // printDetailedSolution(DetailedSolution);
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