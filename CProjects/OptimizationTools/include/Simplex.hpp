#include <Eigen/Dense>
#include <iostream>
#include <map>
using namespace std;
using namespace Eigen;

class Simplex
{
public:
    map<string, double> Solution;
    string optimization_status;
    double F_val;
    int max_iterations = 100;

    void phase1(VectorXd &costs, MatrixXd &A, VectorXd &b)
    {
        cout << "Starting Phase-I To Determine Basic Feasible Solution" << endl; 
        Solution.clear();
        optimization_status = "unallocated";
        int m = A.rows();
        int n = costs.size();
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
        VectorXd basic_costs = VectorXd::Ones(m);
        VectorXd reduced_costs(m);
        MatrixXd NonBasicBasis = A;
        MatrixXd CurrentBasis = MatrixXd::Identity(m, m);
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
            cout << "Iteration " << i + 1 << endl;
            F_val = basic_costs.transpose() * current_sol;
            cout << "\tCurrent F - Val= " << F_val << endl;
            VectorXd y = CurrentBasis.transpose().lu().solve(basic_costs);
            reduced_costs = non_basic_costs.transpose() - (y.transpose() * NonBasicBasis);
            cout << "\treduced costs" << endl;
            cout << "\t" << reduced_costs.transpose() << endl;
            int continue_bool = reduced_costs.minCoeff();
            if (0 <= continue_bool)
            {
                cout << "\tcurrent solution is optimal" << endl;
                cout << "\tFound Basic Feasible Solution" << endl; 
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

        }
    }

    void optimize(VectorXd &costs, MatrixXd &A, VectorXd &b)
    {
        Solution.clear();
        optimization_status = "unallocated";
        int m = A.rows();
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
        MatrixXd CurrentBasis = MatrixXd::Identity(m, m);
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
            int continue_bool = reduced_costs.minCoeff();
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
        for (auto it = Solution.begin(); it != Solution.end(); it++)
        {
            cout << it->first << " " << it->second << endl;
        }
    }
};