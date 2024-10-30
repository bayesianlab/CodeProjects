#pragma once
#ifndef SIMPLEX
#define SIMPLEX

#include <Eigen/Dense>
#include <iostream>
#include <map>
#include <vector>
#include <math.h>
#include <boost/format.hpp>
#include "SimplexCore.hpp"

using namespace std;
using namespace Eigen;
using namespace boost;


void remove_row(MatrixXd &matrix, int rowToRemove)
{
    unsigned int numRows = matrix.rows() - 1;
    unsigned int numCols = matrix.cols();

    if (rowToRemove < numRows)
        matrix.block(rowToRemove, 0, numRows - rowToRemove, numCols) = matrix.block(rowToRemove + 1, 0, numRows - rowToRemove, numCols);

    matrix.conservativeResize(numRows, numCols);
}

void remove_vector_row(VectorXd &X, int j)
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

class Simplex : public SimplexCore
{
private:

    double EPSILON = 1e-14; 

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

    void set_basis_vars(map<int, tuple<int, string, double>> &ModelVariables, string label)
    {
        for (auto it = ModelVariables.begin(); it != ModelVariables.end(); ++it)
        {
            if (get<1>(it->second) == label)
            {
                get<0>(it->second) = 1;
            }
        }
    }

    MatrixXd make_slack_mat(int slack_surplus_count, const vector<string> &constraint_type)
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
    int max_iterations = 5;

    map<int, tuple<int, string, double>> Phase2Variables;


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



    void presolve_1nonzero_inrow(VectorXd &costs, MatrixXd &A, VectorXd &b, vector<string> &constraint_type,
                                 map<int, tuple<int, string, double>> &ModelVariables, int &row, int &last_row,
                                 int &var_cnt, int &deleted_rows, double &solved_cost)
    {
        if (A.rows() == 0)
        {
            return;
        }
        if (row >= last_row)
        {
            return;
        }
        int non_zero = 0;
        int k = -1;
        for (int j = 0; j < A.cols(); ++j)
        {
            if (A(row, j) != 0)
            {
                non_zero++;
                k = j;
            }
        }
        if (non_zero <= 1)
        {
            if (k != -1)
            {
                double v = b(row) / A(row, k);
                get<0>(ModelVariables[k + deleted_rows]) = -1;
                get<2>(ModelVariables[k + deleted_rows]) = v;
                solved_cost += v * costs(k);
                for (int i = 0; i < A.rows(); ++i)
                {
                    if (i != row)
                    {
                        b(i) -= (A(i, k) * v);
                    }
                }
                not_index_j(A, row, k);
                not_index_j(b, row);
                not_index_j(costs, k);
                constraint_type.erase(constraint_type.begin() + row);
                last_row = A.rows();
                presolve_1nonzero_inrow(costs, A, b, constraint_type, ModelVariables, row,
                                        last_row, ++var_cnt, ++deleted_rows, solved_cost);
            }
            else
            {
                remove_row(A, row);
                not_index_j(b, row);
                not_index_j(costs, row);
                constraint_type.erase(constraint_type.begin() + row);
                last_row = A.rows();
                presolve_1nonzero_inrow(costs, A, b, constraint_type, ModelVariables, row,
                                        last_row, ++var_cnt, ++deleted_rows, solved_cost);
            }
        }
        else
        {
            presolve_1nonzero_inrow(costs, A, b, constraint_type, ModelVariables, ++row,
                                    last_row, ++var_cnt, deleted_rows, solved_cost);
        }
    }

    double presolve_row_singletons(VectorXd &costs, MatrixXd &A, VectorXd &b,
                                   map<int, tuple<int, string, double>> &ModelVariables,
                                   vector<string> &constraint_type)
    {

        int d = 0;
        int lr = A.rows();
        int row = 0;
        int cnt = 0;
        double sc = 0;
        presolve_1nonzero_inrow(costs, A, b, constraint_type, ModelVariables, row, lr, cnt, d, sc);
        if (d > 0)
            cout << "Removed " << d << " rows and " << d << " columns in presolve" << endl;
        return sc;
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



    void make_b_pos(MatrixXd &A, VectorXd &b, vector<string> &constraints){  
        cout << "check constraints" << endl; 
        for(auto i = 0; i<b.size(); ++i){
            if(b(i)< 0){
                b(i) = -b(i);
                A.row(i) = -A.row(i);
                if(constraints[i] == "geq"){constraints[i]="leq";}
                else if(constraints[i] == "leq"){constraints[i]="geq";}
            }
        }
    }

    MatrixXd make_slack_basis(const vector<string> &constraints, int slack_cnt){
        MatrixXd SlackBasis = MatrixXd::Identity(slack_cnt, slack_cnt);
        for (int i = 0; i < constraints.size(); ++i){
            if(constraints[i]=="eq"){
                SlackBasis(i,i) = 0; 
            }
            if(constraints[i]=="geq"){
                SlackBasis(i,i) = -1;
            }
        }
        return SlackBasis;
    }

    bool check_simple_solution(MatrixXd &A, VectorXd &b, vector<string> &constraint_type)
    {
        // All constraints to leq constraints
        // Assumed in standard form, no geq constraints
        int no_simple = 0;
        if (b.minCoeff() < 0)
        {
            if (b.maxCoeff() < 0)
            {
                for (int i = 0; i < constraint_type.size(); ++i)
                {
                    if (constraint_type[i] != "geq")
                    {
                        no_simple = 1;
                    }
                }
                if (no_simple == 0)
                {
                    return true;
                }
            }
        }
        else
        {
            int no_simple = 0;
            for (int i = 0; i < constraint_type.size(); ++i)
            {
                if (constraint_type[i] != "leq")
                {
                    no_simple = 1;
                }
            }
            if (no_simple == 0)
            {
                return true;
            }
        }
        return false;
    }

    Solution phase1(VectorXd &costs, MatrixXd &A, VectorXd &b, vector<string> &constraint_type)
    {
        cout << "Starting Phase-I To Determine Basic Feasible Solution" << endl;
        if((A.rows() != b.size()) ||  (constraint_type.size() != b.size())){
            throw invalid_argument("Problem with constraints. A.rows() != b.rows() or != to constraint_type.size()"); 
        }


        LPVariableMap VarMap;         
        Solution p1_soln;
        MatrixXd NonBasicBasis;
        MatrixXd CurrentBasis;        
        VectorXd guess;
        int non_basic_var_count;
        int choice_count = A.cols();
        double solved_cost =0; 
        
        // double solved_cost = presolve_row_singletons(costs, A, b, Phase1Variables, constraint_type);

        cout << "Simple solution exists" << endl;
        make_b_pos(A, b, constraint_type);

        for(int i = 0; i < constraint_type.size(); ++i){
            cout << constraint_type[i] << endl; 
        }

        // Choice vars have 0 cost in the 1st phase of 2-phase simplex
        VarMap.add_choice_vars(VectorXd::Zero(costs.size()));
        VarMap.add_slack_surplus_vars(constraint_type);
        VectorXd non_basic_costs = VectorXd::Zero(VarMap.SlackCnt + VarMap.SurplusCnt + VarMap.ChoiceCnt);
        
        // Artificials vars have cost 1 in the 1st phase 
        VectorXd basic_costs = VectorXd::Ones(A.rows());
        VarMap.add_artificials(VectorXd::Ones(basic_costs.size()));
        CurrentBasis = MatrixXd::Identity(VarMap.ArtificialCnt, VarMap.ArtificialCnt);

        // Artificials are the initial basic feasible solution
        VarMap.setUpBasics(basic_costs, "Artificial");
        VarMap.setUpNonBasics(0, "Slack");
        VarMap.setUpNonBasics(0, "Surplus");
        VarMap.setUpNonBasics(0, "Choice");

        if (VarMap.SlackCnt + VarMap.SurplusCnt > 0)
        {
            MatrixXd SlackBasis = make_slack_basis(constraint_type, VarMap.SlackCnt + VarMap.SurplusCnt);
            
            NonBasicBasis.resize(A.rows(), A.cols() + SlackBasis.cols());
            NonBasicBasis << A, SlackBasis;
        }
        else{
            NonBasicBasis.resize(A.rows(), A.rows());
            NonBasicBasis << A; 
        }
        
        
        map<int, int> BasicIndices;
        map<int, int> NonBasicIndices;
        set_basic_nonbasic_indxs(BasicIndices, NonBasicIndices, VarMap);

        
        VarMap.printVariables();

        guess = b; 
        

        p1_soln = simplex(guess, CurrentBasis, NonBasicBasis, basic_costs, non_basic_costs, b,
                            max_iterations, VarMap);


        
        if (p1_soln.F_val>EPSILON){
            p1_soln.optimization_status="infeasible";
        }

        if (VarMap.artificials_in_basis() == 0)
        {
            VarMap.delete_by_type("Artificial");
        }
        else
        {
            // Force out artificials in Basis 
            force_out(p1_soln, VarMap, NonBasicBasis, CurrentBasis, basic_costs, non_basic_costs,
             b, BasicIndices, NonBasicIndices, constraint_type);
        }
        VarMap.printVariables();
      

        return p1_soln;
    }

    void force_out(Solution &p1_soln, LPVariableMap &VarMap, Eigen::MatrixXd &NonBasicBasis,
                   Eigen::MatrixXd &CurrentBasis, Eigen::VectorXd &basic_costs, Eigen::VectorXd &non_basic_costs,
                   Eigen::VectorXd &b, std::map<int, int> &BasicIndices, std::map<int, int> &NonBasicIndices,
                   std::vector<std::string> &constraint_type)
    {
        // Check if an artificials is in the basis
        VectorXi zeros = VectorXi::Zero(p1_soln.BasicIndices.size());
        vector<int> variables_to_delete;
        for (auto it = p1_soln.BasicIndices.begin(); it != p1_soln.BasicIndices.end(); ++it)
        {
            if (VarMap.VariableMap[it->second].Type == "Artificial")
            {
                // Found an artificial in the basis, check for a column to pivot in
                for (int d = 0; d < NonBasicBasis.cols(); ++d)
                {
                    VectorXd dlj = CurrentBasis.transpose().lu().solve(NonBasicBasis.col(d));
                    if (abs(dlj(it->first)) > EPSILON)
                    {
                        // Drive out the artificial variables of the basis.

                        // TEST THIS PART
                        while (VarMap.VariableMap[it->second].InBasis)
                        {
                            int entering_col = 0;
                            for (int j = 0; j < dlj.size(); ++j)
                            {
                                if (abs(dlj(j)) > EPSILON)
                                {
                                    entering_col = j;
                                    break;
                                }
                            }
                            pivot(entering_col, it->first, p1_soln.current_solution, CurrentBasis, NonBasicBasis,
                                  basic_costs, non_basic_costs, b, BasicIndices, NonBasicIndices);
                            VarMap.update(BasicIndices, NonBasicIndices, p1_soln.current_solution);
                        }
                    }
                    else
                    {
                        ++zeros(it->first);
                    }
                }
            }

            // Remove redundant linearly dependent rows
            if (zeros(it->first) == zeros.size())
            {
                variables_to_delete.push_back(it->second);
                remove_row(CurrentBasis, it->first);
                remove_row(NonBasicBasis, it->first);
                remove_vector_row(b, it->first);
                constraint_type.erase(constraint_type.begin() + it->first);
            }
        }
        for (auto d = variables_to_delete.begin(); d != variables_to_delete.end(); ++d)
        {
            VarMap.VariableMap.erase(*d);
        }
    }

    void Simplex1(VectorXd &costs, MatrixXd &A, VectorXd &b, MatrixXd &_CurrentBasis)
    {
    }

    void Simplex2(VectorXd &costs, MatrixXd &A, VectorXd &b, vector<string> &constraint_type)
    {
        cout << "Two phase simplex" << endl;

        MatrixXd D;
        VectorXd c_D;
        VectorXd c_B;
        Solution phase1_solution = phase1(costs, A, b, constraint_type);
        int choice_count = (int)A.cols();
        VectorXd current_solution = phase1_solution.current_solution;
        int slack_surplus_count = get_slack_variable_cnt(constraint_type);
        if (phase1_solution.optimization_status == "simple")
        {
            D = A;
            c_D = costs;
            c_B = VectorXd::Zero(slack_surplus_count);
            // set_phase2_variables();
            // Solution phase2_solution = simplex(phase1_solution.current_solution, phase1_solution.CurrentBasis, D,
            //                                    c_B, c_D, b, max_iterations, Phase2Variables);
            // update_model_variables(Phase2Variables, phase2_solution.BasicIndices,
            //                        phase2_solution.NonBasicIndices,
            //                        phase2_solution.current_solution);
            // cout << "Optimization status: " << phase2_solution.optimization_status << endl;
            // printDetailedSolution(Phase2Variables);
        }
        else
        {
            // D = make_SlackMat(slack_surplus_count, constraint_type);
            // c_D = VectorXd::Zero(D.rows());
            // Presolve(phase1_solution.CurrentBasis, phase1_solution.current_solution,
            //         phase1_solution.BasicIndices, b, constraint_type);
            // int slack_surplus_count = get_slack_variable_cnt(constraint_type);
            // int constraint_count = phase1_solution.CurrentBasis.rows();
            // add_choice_vars(Phase2Variables, "choice", choice_count);
            // setup_basis_vars(Phase2Variables, phase1_solution.BasicIndices,
            //                 phase1_solution.current_solution);
            // printDetailedSolution(Phase2Variables);
            // add_slack_surplus_vars(Phase2Variables, constraint_type);
            // set_basis_vars(Phase2Variables, phase1_solution.BasicIndices);
            // write_soln(Phase2Variables, phase1_solution.current_solution, phase1_solution.BasicIndices);
            // cout << "Starting Phase-II" << endl;
            // Solution phase2_solution = simplex(phase1_solution.current_solution, phase1_solution.CurrentBasis, D,
            //                                 costs, c_D, b, Phase2Variables, max_iterations);
            // write_soln(Phase2Variables, phase2_solution.current_solution, phase2_solution.BasicIndices);
            // printDetailedSolution(Phase2Variables);
            // cout << phase2_solution.optimization_status << endl;
        }
    }



    void printBasis(const map<int, int> &Basis)
    {
        cout << "Print Basis" << endl;
        for (auto it = Basis.begin(); it != Basis.end(); ++it)
        {
            cout << it->first << " " << it->second << endl;
        }
    }
};


#endif