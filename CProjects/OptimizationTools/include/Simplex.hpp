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
    int get_slack_variable_cnt(const vector<string> &constraint_type)
    {
        int slack_count = 0;
        for (int i = 0; i < constraint_type.size(); ++i)
        {
            if (constraint_type[i] == "leq" || constraint_type[i] == "geq")
            {
                slack_count++;
            }
        }
        return slack_count;
    }

    void add_slack_surplus_vars(map<int, tuple<bool, string, double>> &ModelVariables,
                                const vector<string> &constraint_type)
    {

        if (ModelVariables.empty())
        {
            for (int i = 0; i < constraint_type.size(); ++i)
            {
                if (constraint_type[i] == "leq")
                {
                    ModelVariables[i] = make_tuple(false, "slack", 0.0);
                }
                else if (constraint_type[i] == "geq")
                {
                    ModelVariables[i] = make_tuple(false, "surplus", 0.0);
                }
            }
        }
        else
        {
            int last = ModelVariables.rbegin()->first;
            int u = last + 1;
            for (int i = 0; i < constraint_type.size(); ++i)
            {
                if (constraint_type[i] == "leq")
                {
                    ModelVariables[u] = make_tuple(false, "slack", 0.0);
                    ++u;
                }
                else if (constraint_type[i] == "geq")
                {
                    ModelVariables[u] = make_tuple(false, "surplus", 0.0);
                    ++u;
                }
            }
        }
    }


    void set_basis_vars(map<int, tuple<bool, string, double>> &ModelVariables, string label)
    {
        for (auto it = Phase1ModelVariables.begin(); it != Phase1ModelVariables.end(); ++it)
        {
            if (get<1>(it->second) == label)
            {
                get<0>(it->second) = true;
            }
        }
    }

    void set_basis_vars(map<int, tuple<bool, string, double>> &ModelVariables, const map<int, int> BasicIndices,
                        const map<int, int> NonBasicIndices, const VectorXd &solution)
    {
        int i = 0;
        for (auto it = BasicIndices.begin(); it != BasicIndices.end(); ++it)
        {
            get<0>(ModelVariables[it->second]) = true;
            get<2>(ModelVariables[it->second]) = solution(i);
            ++i;
        }
        for (auto it = NonBasicIndices.begin(); it != NonBasicIndices.end(); ++it)
        {
            get<0>(ModelVariables[it->second]) = false;
            get<2>(ModelVariables[it->second]) = 0;
        }
    }

    void setup_basis_vars(map<int, tuple<bool, string, double>> &ModelVariables, const map<int, int> BasicIndices,
                          const VectorXd &solution)
    {
        int i = 0;
        for (auto it = BasicIndices.begin(); it != BasicIndices.end(); ++it)
        {
            get<0>(ModelVariables[it->second]) = true;
            get<2>(ModelVariables[it->second]) = solution(i);
            ++i;
        }
    }

    void write_soln(map<int, tuple<bool, string, double>> &ModelVariables,
                    const VectorXd &solution, const map<int, int> &BasicIndices, const map<int, int> &NonBasicIndices)
    {
        int i = 0;
        for (auto it = BasicIndices.begin(); it != BasicIndices.end(); ++it)
        {
            get<2>(ModelVariables[it->second]) = solution(i);
            ++i;
        }
        for (auto it = NonBasicIndices.begin(); it != NonBasicIndices.end(); ++it)
        {
            get<2>(ModelVariables[it->second]) = 0;
        }
    }

    MatrixXd make_SlackMat(int slack_surplus_count, const vector<string> &constraint_type)
    {
        MatrixXd SlackMat = MatrixXd::Identity(slack_surplus_count, slack_surplus_count);
        for (int i = 0; i < constraint_type.size(); ++i)
        {
            if (constraint_type[i] == "geq")
            {
                SlackMat.row(i) = -SlackMat.row(i);
            }
        }
        return SlackMat;
    }

public:
    int max_iterations = 100;
    map<int, tuple<bool, string, double>> Phase1ModelVariables;
    map<int, tuple<bool, string, double>> Phase2ModelVariables;

    void add_vars(map<int, tuple<bool, string, double>> &ModelVariables, string label, int cnt)
    {
        if (ModelVariables.empty())
        {
            int i = 0;
            while (i < cnt)
            {
                ModelVariables[i] = make_tuple(false, label, 0.0);
                ++i;
            }
        }
        else
        {
            int last = ModelVariables.rbegin()->first;
            int i = last + 1;
            while (i < last + cnt + 1)
            {
                ModelVariables[i] = make_tuple(false, label, 0.0);
                ++i;
            }
        }
    }

    void presolve_1pos_incol(MatrixXd &B, VectorXd &soln_vec, map<int, int> &BasicIndices,
                             int col, int total_cols, VectorXd &b, vector<string> &constraint_type,
                             int &del_cols)
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
            constraint_type.erase(constraint_type.begin() + delete_row);
            not_index_j(B, delete_row, col);
            not_index_j(soln_vec, delete_row);
            not_index_j(b, delete_row);
            BasicIndices.erase(delete_row);
            total_cols = B.cols();
            ++del_cols;
            presolve_1pos_incol(B, soln_vec, BasicIndices, col, total_cols, b, constraint_type, del_cols);
        }
        else
        {
            presolve_1pos_incol(B, soln_vec, BasicIndices, col + 1, total_cols, b, constraint_type, del_cols);
        }
    }

    void Presolve(MatrixXd &CurrentBasis, VectorXd &current_solution, map<int, int> &BasicIndices, VectorXd &b,
                  vector<string> &constraint_type)
    {
        int d = 0;
        presolve_1pos_incol(CurrentBasis, current_solution, BasicIndices, 0, CurrentBasis.cols(), b,
                            constraint_type, d);
        if (d > 0)
            cout << "Removed " << d << " rows in presolve" << endl;
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

    bool phase1precheck(MatrixXd &A, VectorXd &b, const vector<string> &constraint_type)
    {
        int all_pos = 0;
        int less_than = 0;
        for (int i = 0; i < b.size(); ++i)
        {
            if (b(i) < 0)
            {
                ++all_pos;
                b(i) = -b(i);
                A.row(i) = -A.row(i);
            }
            if ((constraint_type[i] == "geq") || (constraint_type[i] == "eq"))
            {
                ++less_than;
                less_than = 1;
            }
        }
        if ((all_pos == b.size()) && (less_than == constraint_type.size()))
        {
            return true;
        }
        else if ((all_pos == 0) && (less_than == 0))
        {
            return true;
        }
        else
        {
            return false;
        }
    }

    Solution phase1(MatrixXd &A, VectorXd &b, vector<string> &constraint_type)
    {
        cout << "Starting Phase-I To Determine Basic Feasible Solution" << endl;
        if (!Phase1ModelVariables.empty())
        {
            Phase1ModelVariables.clear();
        }
        Solution p1_soln;
        int choice_count = A.cols();
        add_vars(Phase1ModelVariables, "choice", choice_count);
        int constraint_count = (int)A.rows();
        VectorXd basic_costs = VectorXd::Ones(constraint_count);
        MatrixXd CurrentBasis;
        int slack_surplus_count = get_slack_variable_cnt(constraint_type);
        add_slack_surplus_vars(Phase1ModelVariables, constraint_type);
        bool simple_solution_exists = phase1precheck(A, b, constraint_type);
        int non_basic_var_count;
        MatrixXd NonBasicBasis;
        MatrixXd SlackMat;
        VectorXd guess;
        if (simple_solution_exists)
        {
            cout << "Simple solution exists" << endl;
            non_basic_var_count = choice_count;
            NonBasicBasis.resize(constraint_count, non_basic_var_count);
            CurrentBasis = make_SlackMat(slack_surplus_count, constraint_type);
            NonBasicBasis = A;
            guess = b;
        }
        else
        {
            if (slack_surplus_count > 0)
            {
                non_basic_var_count = choice_count + slack_surplus_count;
                SlackMat = make_SlackMat(slack_surplus_count, constraint_type);
                NonBasicBasis.resize(constraint_count, non_basic_var_count);
                NonBasicBasis << A, SlackMat;
            }
            else
            {
                non_basic_var_count = choice_count;
                NonBasicBasis.resize(constraint_count, non_basic_var_count);
                NonBasicBasis << A;
            }
            add_vars(Phase1ModelVariables, "artificial", constraint_count);
            set_basis_vars(Phase1ModelVariables, "artificial");
            CurrentBasis = MatrixXd::Identity(constraint_count, constraint_count);
            guess = CurrentBasis.lu().solve(b);
        }
        VectorXd non_basic_costs = VectorXd::Zero(non_basic_var_count);

        p1_soln = simplex(guess, CurrentBasis, NonBasicBasis, basic_costs, non_basic_costs, b,
                          Phase1ModelVariables, max_iterations);
        set_basis_vars(Phase1ModelVariables, p1_soln.BasicIndices, p1_soln.NonBasicIndices, p1_soln.current_solution);
        cout << "Phase-I Solution" << endl;
        printDetailedSolution(Phase1ModelVariables);
        return p1_soln;
    }

    void Simplex1(VectorXd &costs, MatrixXd &A, VectorXd &b, MatrixXd &_CurrentBasis)
    {
    }

    void Simplex2(VectorXd &costs, MatrixXd &A, VectorXd &b, vector<string> &constraint_type)
    {
        cout << "Two phase simplex" << endl;
        if (!Phase2ModelVariables.empty())
        {
            Phase2ModelVariables.clear();
        }
        int choice_count = (int)A.cols();
        Solution phase1_solution = phase1(A, b, constraint_type);
        VectorXd current_solution = phase1_solution.current_solution;
        Presolve(phase1_solution.CurrentBasis, phase1_solution.current_solution,
                 phase1_solution.BasicIndices, b, constraint_type);
        int slack_surplus_count = get_slack_variable_cnt(constraint_type);
        int constraint_count = phase1_solution.CurrentBasis.rows();
        add_vars(Phase2ModelVariables, "choice", choice_count);
        setup_basis_vars(Phase2ModelVariables, phase1_solution.BasicIndices,
                       phase1_solution.current_solution);
        printDetailedSolution(Phase2ModelVariables);
        // MatrixXd D = make_SlackMat(slack_surplus_count, constraint_type);
        // VectorXd c_D = VectorXd::Zero(D.rows());
        // add_vars(Phase2ModelVariables, "choice", choice_count);
        // add_slack_surplus_vars(Phase2ModelVariables, constraint_type);
        // set_basis_vars(Phase2ModelVariables, phase1_solution.BasicIndices);
        // write_soln(Phase2ModelVariables, phase1_solution.current_solution, phase1_solution.BasicIndices);
        // cout << "Starting Phase-II" << endl;
        // Solution phase2_solution = simplex(phase1_solution.current_solution, phase1_solution.CurrentBasis, D,
        //                                    costs, c_D, b, Phase2ModelVariables, max_iterations);
        // write_soln(Phase2ModelVariables, phase2_solution.current_solution, phase2_solution.BasicIndices);
        // printDetailedSolution(Phase2ModelVariables);
        // cout << phase2_solution.optimization_status << endl;
    }

    void printDetailedSolution(map<int, tuple<bool, string, double>> ModelVariables)
    {
        for (auto it = ModelVariables.begin(); it != ModelVariables.end(); it++)
        {
            cout << it->first << " " << get<0>(it->second) << " " << get<1>(it->second) << " " << get<2>(it->second) << endl;
        }
    }
};