#include <Eigen/Dense>
#include <iostream>
#include <map>
#include <vector> 
#include <math.h>

using namespace std;
using namespace Eigen;

class Simplex
{
public:
    MatrixXd CurrentBasis;
    map<string, double> Solution;
    string optimization_status;
    double F_val;
    int max_iterations = 100;

    void drive_out_artificials(const VectorXd &costs, const MatrixXd &A, const VectorXd &b)
    {
        
        if(optimization_status=="successful")
        {
            int n = (int)costs.size(); 
            int m = (int)b.size(); 
            int artificial_in_basis_flag = 0;
            vector<string> artificials; 
            for(int i = n; i < (n + m); ++i)
            {
                if(Solution.find("x_"+i) != Solution.end())
                {
                    artificial_in_basis_flag=1;
                    cout << "drive out" << endl; 
                    artificials.push_back("x_"+i);
                }
            }
            if(artificial_in_basis_flag==1)
            {   
                cout << "Artificial variables found in basis" << endl; 
            }
        }
        else{
            return; 
        }
    }

    void phase1(const MatrixXd &A, const VectorXd &b, const vector<string> &constraint_type)
    {
        cout << "Starting Phase-I To Determine Basic Feasible Solution" << endl; 
        int slack_count = 0;
        for (int i = 0; i < constraint_type.size(); ++i)
        {
            if (constraint_type[i] == "leq")
            {
                slack_count++;
            }

        }
        int m = (int)A.rows();
        VectorXd basic_costs = VectorXd::Ones(m);
        int n = (int)A.cols(); 
        CurrentBasis = MatrixXd::Identity(m, m);
        Solution.clear();
        optimization_status = "unallocated";
        map<int, int> Basic_indxs;
        map<int, int> NonBasic_indxs;
        map<int, string> X_labels;

        int c = 0;
        for (int i = 0; i < m + n; ++i)
        {
            if (i < n)
            {
                NonBasic_indxs[i] = i;
            }
            else
            {
                Basic_indxs[i - n] = i;
            }
            string x = "x_" + to_string(i);
            X_labels[i] = x;
        }
        VectorXd non_basic_costs = VectorXd::Zero(n);
        VectorXd reduced_costs(m);
        MatrixXd NonBasicBasis = A;
        VectorXd current_sol = CurrentBasis.lu().solve(b);
        int k = 0;
        for (auto it = Basic_indxs.begin(); it != Basic_indxs.end(); ++it)
        {
            Solution[X_labels[it->second]] = current_sol[k];
        }
        int entering_col = -1;
        cout << "Solving with " << slack_count << " slack variables and with " << m << " choice variables" << endl; 
        for (int i = 0; i < max_iterations; ++i)
        {
            // cout << "Current Sol" << endl;
            // cout << current_sol.transpose() << endl;
            cout << "Iteration " << i + 1 << endl;
            F_val = basic_costs.transpose() * current_sol;
            cout << "\tCurrent F - Val= " << F_val << endl;
            VectorXd y = CurrentBasis.transpose().lu().solve(basic_costs);
            reduced_costs = non_basic_costs.transpose() - (y.transpose() * NonBasicBasis);
            cout << "\treduced costs" << endl;
            cout << "\t" << reduced_costs.transpose() << endl;
            double continue_bool = reduced_costs.minCoeff();
            if ((0 <= continue_bool) && (F_val <= 0)) 
            {
                cout << "Found basic feasible solution" << endl; 
                int k = 0;
                for (auto it = Basic_indxs.begin(); it != Basic_indxs.end(); ++it)
                {
                    Solution[X_labels[it->second]] = current_sol[k];
                    ++k;
                }
                for (auto it = NonBasic_indxs.begin(); it != NonBasic_indxs.end(); ++it)
                {
                    Solution[X_labels[it->second]] = 0;
                }
                optimization_status = "successful";
                return;
            }
            else if((0 <= continue_bool) && (F_val > 0))
            {
                optimization_status = "infeasible"; 
                return;
            }
            for (int j = 0; j < reduced_costs.size(); ++j)
            {
                if (reduced_costs(j) < 0)
                {
                    entering_col = j;
                    break;
                }
            }
            cout << "\tentering vector= " << entering_col << " x" << NonBasic_indxs[entering_col] << endl;
            VectorXd aq = NonBasicBasis.col(entering_col);
            VectorXd denominator = CurrentBasis.lu().solve(aq);
            if (denominator.maxCoeff() < 0)
            {
                optimization_status = "unbounded";
                return;
            }
            double min_ratio = fabs(current_sol.maxCoeff()) / fabs(denominator.minCoeff());
            int exiting_col = 0;
            for (int j = 0; j < aq.size(); ++j)
            {
                double can = (current_sol(j) / denominator(j));
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

            cout << "\texiting vector= " << exiting_col << " x" << Basic_indxs[exiting_col] << endl;
            VectorXd t = CurrentBasis.col(exiting_col);
            CurrentBasis.col(exiting_col) = NonBasicBasis.col(entering_col);
            NonBasicBasis.col(entering_col) = t;
            current_sol = CurrentBasis.lu().solve(b);
            double tt = basic_costs(exiting_col);
            basic_costs(exiting_col) = non_basic_costs(entering_col);
            non_basic_costs(entering_col) = tt;

            int ti = Basic_indxs[exiting_col];
            Basic_indxs[exiting_col] = entering_col;
            NonBasic_indxs[entering_col] = ti;
            for (auto it = Basic_indxs.begin(); it != Basic_indxs.end(); ++it)
            {
                cout << it->first << " " << it->second << endl; 
            }
            cout << basic_costs << endl; 
            cout << non_basic_costs << endl; 
        }
    }

    void Simplex1(VectorXd &costs, MatrixXd &A, VectorXd &b, MatrixXd &_CurrentBasis)
    {
        cout << "Simplex with known starting basis" << endl; 
        CurrentBasis = _CurrentBasis; 
        Solution.clear();
        optimization_status = "unallocated";
        int m = (int)A.rows();
        map<int, int> Basic_indxs;
        map<int, int> NonBasic_indxs;
        map<int, string> X_labels;

        int c = 0;
        for (int i = 0; i < (2 * m); ++i)
        {
            if (i < m)
            {
                NonBasic_indxs[i] = i;
            }
            else
            {
                Basic_indxs[i - m] = i;
            }
            string x = "x_" + to_string(i);
            X_labels[i] = x;
        }
        VectorXd non_basic_costs = costs;
        VectorXd basic_costs = VectorXd::Zero(m);
        VectorXd reduced_costs(m);
        MatrixXd NonBasicBasis = A;
        VectorXd current_sol = CurrentBasis.lu().solve(b);
        int k = 0;
        for (auto it = Basic_indxs.begin(); it != Basic_indxs.end(); ++it)
        {
            Solution[X_labels[it->second]] = current_sol[k];
        }
        int entering_col = -1;
        for (int i = 0; i < 10; ++i)
        {
            // cout << "Current Sol" << endl;
            // cout << current_sol.transpose() << endl;
            cout << "Iteration " << i << endl;
            F_val = basic_costs.transpose() * current_sol;
            cout << "\tCurrent F - Val= " << F_val << endl;
            VectorXd y = CurrentBasis.transpose().lu().solve(basic_costs);
            reduced_costs = non_basic_costs.transpose() - y.transpose() * NonBasicBasis;
            cout << "\treduced costs" << endl;
            cout << "\t" << reduced_costs.transpose() << endl;
            double continue_bool = reduced_costs.minCoeff();
            if (0 <= continue_bool)
            {
                cout << "\tcurrent solution is optimal" << endl;
                optimization_status = "successful";
                return;
            }
            for (int j = 0; j < reduced_costs.size(); ++j)
            {
                if (reduced_costs(j) < 0)
                {
                    entering_col = j;
                    break;
                }
            }
            cout << "\tentering vector= " << entering_col << " " << NonBasic_indxs[entering_col] << endl;
            VectorXd aq = NonBasicBasis.col(entering_col);
            VectorXd denominator = CurrentBasis.lu().solve(aq);
            if (denominator.maxCoeff() < 0)
            {
                optimization_status = "Problem is unbounded";
                return;
            }
            double min_ratio = current_sol(0) / denominator(0);
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

            cout << "\texiting vector= " << exiting_col << " " << Basic_indxs[exiting_col] << endl;

            VectorXd t = CurrentBasis.col(exiting_col);
            CurrentBasis.col(exiting_col) = NonBasicBasis.col(entering_col);
            NonBasicBasis.col(entering_col) = t;
            current_sol = CurrentBasis.lu().solve(b);
            double tt = basic_costs(exiting_col);
            basic_costs(exiting_col) = non_basic_costs(entering_col);
            non_basic_costs(entering_col) = tt;

            int ti = Basic_indxs[exiting_col];
            Basic_indxs[exiting_col] = entering_col;
            NonBasic_indxs[entering_col] = ti;

            int k = 0;
            for (auto it = Basic_indxs.begin(); it != Basic_indxs.end(); ++it)
            {
                Solution[X_labels[it->second]] = current_sol[k];
                ++k;
            }
            for (auto it = NonBasic_indxs.begin(); it != NonBasic_indxs.end(); ++it)
            {
                Solution[X_labels[it->second]] = 0;

                ++k;
            }
        }
        optimization_status = "exceeded max iterations";
    }

    void Simplex2(const VectorXd &costs, const MatrixXd &A, const VectorXd &b, const vector<string> &constraint_type)
    {
        cout << "Two phase simplex" << endl; 

        phase1(A, b, constraint_type); 
        drive_out_artificials(costs, A, b);
        return ;
        if ((optimization_status=="infeasible") || (optimization_status=="unbounded")){
            return ;
        }
        Solution.clear();
        optimization_status = "unallocated";
        int m = (int)A.rows();
        map<int, int> Basic_indxs;
        map<int, int> NonBasic_indxs;
        map<int, string> X_labels;

        int c = 0;
        for (int i = 0; i < (2 * m); ++i)
        {
            if (i < m)
            {
                NonBasic_indxs[i] = i;
            }
            else
            {
                Basic_indxs[i - m] = i;
            }
            string x = "x_" + to_string(i);
            X_labels[i] = x;
        }
        VectorXd non_basic_costs = costs;
        VectorXd basic_costs = VectorXd::Zero(m);
        VectorXd reduced_costs(m);
        MatrixXd NonBasicBasis = A;
        VectorXd current_sol = CurrentBasis.lu().solve(b);
        int k = 0;
        for (auto it = Basic_indxs.begin(); it != Basic_indxs.end(); ++it)
        {
            Solution[X_labels[it->second]] = current_sol[k];
        }
        int entering_col = -1;
        for (int i = 0; i < 10; ++i)
        {
            // cout << "Current Sol" << endl;
            // cout << current_sol.transpose() << endl;
            cout << "Iteration " << i << endl;
            F_val = basic_costs.transpose() * current_sol;
            cout << "\tCurrent F - Val= " << F_val << endl;
            VectorXd y = CurrentBasis.transpose().lu().solve(basic_costs);
            reduced_costs = non_basic_costs.transpose() - y.transpose() * NonBasicBasis;
            cout << "\treduced costs" << endl;
            cout << "\t" << reduced_costs.transpose() << endl;
            double continue_bool = reduced_costs.minCoeff();
            if (0 <= continue_bool)
            {
                cout << "\tcurrent solution is optimal" << endl;
                optimization_status = "successful";
                return;
            }
            for (int j = 0; j < reduced_costs.size(); ++j)
            {
                if (reduced_costs(j) < 0)
                {
                    entering_col = j;
                    break;
                }
            }
            cout << "\tentering vector= " << entering_col << " " << NonBasic_indxs[entering_col] << endl;
            VectorXd aq = NonBasicBasis.col(entering_col);
            VectorXd denominator = CurrentBasis.lu().solve(aq);
            if (denominator.maxCoeff() < 0)
            {
                optimization_status = "Problem is unbounded";
                return;
            }
            double min_ratio = current_sol(0) / denominator(0);
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

            cout << "\texiting vector= " << exiting_col << " " << Basic_indxs[exiting_col] << endl;

            VectorXd t = CurrentBasis.col(exiting_col);
            CurrentBasis.col(exiting_col) = NonBasicBasis.col(entering_col);
            NonBasicBasis.col(entering_col) = t;
            current_sol = CurrentBasis.lu().solve(b);
            double tt = basic_costs(exiting_col);
            basic_costs(exiting_col) = non_basic_costs(entering_col);
            non_basic_costs(entering_col) = tt;

            int ti = Basic_indxs[exiting_col];
            Basic_indxs[exiting_col] = entering_col;
            NonBasic_indxs[entering_col] = ti;

            int k = 0;
            for (auto it = Basic_indxs.begin(); it != Basic_indxs.end(); ++it)
            {
                Solution[X_labels[it->second]] = current_sol[k];
                ++k;
            }
            for (auto it = NonBasic_indxs.begin(); it != NonBasic_indxs.end(); ++it)
            {
                Solution[X_labels[it->second]] = 0;

                ++k;
            }
        }
        optimization_status = "exceeded max iterations";
    }

    void print_solution()
    {
        cout << "Solution" << endl;
        cout << optimization_status << endl; 
        for (auto it = Solution.begin(); it != Solution.end(); it++)
        {
            cout << it->first << " " << it->second << endl;
        }
    }
};