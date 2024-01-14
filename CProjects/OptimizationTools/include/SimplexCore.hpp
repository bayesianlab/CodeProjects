#include <Eigen/Dense>
#include <iostream>
#include <map>
#include <vector>
#include <math.h>

using namespace std;
using namespace Eigen;

struct Solution
{
    string optimization_status;
    MatrixXd CurrentBasis;
    MatrixXd NonBasicBasis;
    VectorXd current_solution;
    map<int, int> BasicIndices;
    map<int, int> NonBasicIndices;
    double F_val;

    void set_solution(string opt_status, MatrixXd B, MatrixXd D, VectorXd xb, map<int, int> indx, map<int, int> nonbindx, double F)
    {
        optimization_status = opt_status;
        CurrentBasis = B;
        NonBasicBasis = D;
        current_solution = xb;
        BasicIndices = indx;
        NonBasicIndices = nonbindx;
        F_val = F;
    }
};

class SimplexCore
{

public:
    void set_basic_nonbasic_indxs(map<int, int> &BasicIndices, map<int, int> &NonBasicIndices, int basic_cnt, int non_basic_cnt)
    {
        int N = basic_cnt + non_basic_cnt;
        for (int i = 0; i < N; ++i)
        {
            if (i < non_basic_cnt)
            {
                NonBasicIndices[i] = i;
            }
            else
            {
                BasicIndices[i - non_basic_cnt] = i;
            }
        }
    }

    int determine_entering_col(const VectorXd &reduced_costs)
    {
        int entering_col = 0;
        while (reduced_costs(entering_col) > 0)
        {
            ++entering_col;
        }
        return entering_col;
    }

    int determine_exiting_col(const VectorXd &x_B, const VectorXd &denominator, const VectorXd &aq)
    {
        int exiting_col = 0;
        if (denominator.maxCoeff() < 0)
        {
            return -1;
        }
        double min_ratio = fabs(x_B.maxCoeff()) / fabs(denominator.minCoeff());
        for (int j = 0; j < aq.size(); ++j)
        {
            double can = (x_B(j) / denominator(j));
            if (denominator(j) > 0)
            {
                double can = (x_B(j) / denominator(j));
                if (can < min_ratio)
                {
                    min_ratio = can;
                    exiting_col = j;
                }
            }
        }
        return exiting_col;
    }

    Solution simplex(MatrixXd &B, MatrixXd &D, VectorXd &c_B, VectorXd &c_D, const VectorXd &b, int max_iterations)
    {
        /*
            Calculate a starting point for x_B
        */
        int basic_var_count = (int)B.cols();
        int non_basic_var_count = (int)D.cols();
        map<int, int> BasicIndices;
        map<int, int> NonBasicIndices;
        set_basic_nonbasic_indxs(BasicIndices, NonBasicIndices, basic_var_count, non_basic_var_count);
        VectorXd x_D = VectorXd::Zero(c_D.size());
        VectorXd reduced_costs(c_D.size());
        double F_val;
        VectorXd x_B = B.lu().solve(b);
        Solution Sol;
        Sol.set_solution("unallocated", B, D, x_B, BasicIndices, NonBasicIndices, Infinity);
        for (int i = 0; i < max_iterations; ++i)
        {
            cout << "Iteration " << i + 1 << endl;
            Sol.F_val = c_B.transpose() * x_B;
            cout << "\tCurrent F-Val= " << Sol.F_val << endl;
            VectorXd y = B.transpose().lu().solve(c_B);
            reduced_costs = c_D.transpose() - (y.transpose() * D);
            double reduced_cost_min_val = reduced_costs.minCoeff();
            if ((0 <= reduced_cost_min_val) && (Sol.F_val <= 0))
            {
                Sol.set_solution("success", B, D, x_B, BasicIndices, NonBasicIndices, F_val);
                return Sol;
            }
            else if ((0 <= reduced_cost_min_val) && (Sol.F_val > 0))
            {
                Sol.set_solution("infeasible", B, D, x_B, BasicIndices, NonBasicIndices, F_val);
                return Sol;
            }
            int entering_col = determine_entering_col(reduced_costs);

            VectorXd aq = D.col(entering_col);
            VectorXd denominator = B.lu().solve(aq);
            int exiting_col = determine_exiting_col(x_B, denominator, aq);
            if (exiting_col == -1)
            {
                Sol.set_solution("error", B, D, x_B, BasicIndices, NonBasicIndices, F_val);
                return Sol;
            }
            VectorXd t = B.col(exiting_col);
            B.col(exiting_col) = D.col(entering_col);
            D.col(entering_col) = t;
            x_B = B.lu().solve(b);
            double tt = c_B(exiting_col);
            c_B(exiting_col) = c_D(entering_col);
            c_D(entering_col) = tt;
            /* Housekeeping for basic and non-basic indices */
            int ti = BasicIndices[exiting_col];
            BasicIndices[exiting_col] = entering_col;
            NonBasicIndices[entering_col] = ti;
        }
        Sol.set_solution("unfinished", B, D, x_B, BasicIndices, NonBasicIndices, F_val);
        return Sol;
    }

    Solution simplex(VectorXd &x_B, MatrixXd &B, MatrixXd &D, VectorXd &c_B, VectorXd &c_D, const VectorXd &b, int max_iterations)
    {
        /*
            Current basis and x_B are known
        */
        int basic_var_count = (int)B.cols();
        int non_basic_var_count = (int)D.cols();
        map<int, int> BasicIndices;
        map<int, int> NonBasicIndices;
        set_basic_nonbasic_indxs(BasicIndices, NonBasicIndices, basic_var_count, non_basic_var_count);
        VectorXd x_D = VectorXd::Zero(c_D.size());
        VectorXd reduced_costs(c_D.size());
        double F_val;
        Solution Sol;
        Sol.set_solution("unallocated", B, D, x_B, BasicIndices, NonBasicIndices, Infinity);
        for (int i = 0; i < max_iterations; ++i)
        {
            cout << "Iteration " << i + 1 << endl;
            Sol.F_val = c_B.transpose() * x_B;
            cout << "\tCurrent F-Val= " << Sol.F_val << endl;
            VectorXd y = B.transpose().lu().solve(c_B);
            reduced_costs = c_D.transpose() - (y.transpose() * D);
            double reduced_cost_min_val = reduced_costs.minCoeff();
            if ((0 <= reduced_cost_min_val) && (Sol.F_val <= 0))
            {
                Sol.set_solution("success", B, D, x_B, BasicIndices, NonBasicIndices, F_val);
                return Sol;
            }
            else if ((0 <= reduced_cost_min_val) && (Sol.F_val > 0))
            {
                Sol.set_solution("infeasible", B, D, x_B, BasicIndices, NonBasicIndices, F_val);
                return Sol;
            }
            int entering_col = determine_entering_col(reduced_costs);

            VectorXd aq = D.col(entering_col);
            VectorXd denominator = B.lu().solve(aq);
            int exiting_col = determine_exiting_col(x_B, denominator, aq);
            if (exiting_col == -1)
            {
                Sol.set_solution("error", B, D, x_B, BasicIndices, NonBasicIndices, F_val);
                return Sol;
            }
            VectorXd t = B.col(exiting_col);
            B.col(exiting_col) = D.col(entering_col);
            D.col(entering_col) = t;
            x_B = B.lu().solve(b);
            double tt = c_B(exiting_col);
            c_B(exiting_col) = c_D(entering_col);
            c_D(entering_col) = tt;
            /* Housekeeping for basic and non-basic indices */
            int ti = BasicIndices[exiting_col];
            BasicIndices[exiting_col] = entering_col;
            NonBasicIndices[entering_col] = ti;
        }
        Sol.set_solution("unfinished", B, D, x_B, BasicIndices, NonBasicIndices, F_val);
        return Sol;
    }
};