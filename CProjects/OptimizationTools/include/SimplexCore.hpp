#pragma once
#ifndef SIMPLEX_CORE
#define SIMPLEX_CORE

#include <Eigen/Dense>
#include <iostream>
#include <map>
#include <vector>
#include <math.h>
#include <boost/format.hpp>

using namespace std;
using namespace Eigen;
using namespace boost;

const vector<string> OPT_STATUSES = {"simple", "unallocated", "unfinished", "success", "Unbounded", "infeasible"};

class VariableTypes
{
public:
    int Num;
    string Type;
    int InBasis;
    double Value;
    double Cost;

    void setNum(int n)
    {
        if (n >= 0)
        {
            Num = n;
        }
        else
        {
            throw invalid_argument("Num must be positive or 0.");
        }
    }
    void setType(string type)
    {
        if (type == "Choice" || type == "Artificial" || type == "Slack" || type == "Surplus")
        {
            Type = type;
        }
        else
        {
            throw invalid_argument("Var type not valid.");
        }
    }

    void setInBasis(int b)
    {
        if (b == 0 || b == 1 || b == -1)
        {
            InBasis = b;
        }
        else
        {
            throw "Must either be in basis, not in basis, or set to -1 as na.";
        }
    }

    void setValue(double v)
    {
        Value = v;
    }

    void setCost(double c)
    {
        Cost = c;
    }

    void initializeVar(int b, double value, double cost, string type)
    {
        setInBasis(b);
        setValue(value);
        setType(type);
        setCost(cost);
    }
};

class LPVariableMap
{
private:
    void add_var(const VariableTypes &v)
    {
        int next = VariableMap.size();
        VariableMap[next] = v;
    }

public:
    map<int, VariableTypes> VariableMap;
    int SlackCnt = 0;
    int SurplusCnt = 0;
    int ChoiceCnt = 0;
    int ArtificialCnt = 0;

    void setUpBasics(int b, string type)
    {
        for (auto it = VariableMap.begin(); it != VariableMap.end(); ++it)
        {
            if ((it->second).Type == type)
            {
                (it->second).setInBasis(1);
            }
        }
    }

    void setUpNonBasics(int b, string type)
    {
        for (auto it = VariableMap.begin(); it != VariableMap.end(); ++it)
        {
            if ((it->second).Type == type)
            {
                (it->second).setInBasis(0);
            }
        }
    }

    void add_artificials(int R)
    {
        for (int i = 0; i < R; ++i)
        {
            VariableTypes v;
            v.initializeVar(-1, 0.0, 0, "Artificial");
            add_var(v);
            ++ArtificialCnt;
        }
    }

    void add_slack_surplus_vars(const vector<string> &constraint_types)
    {

        for (int i = 0; i < constraint_types.size(); ++i)
        {
            if (constraint_types[i] == "leq")
            {
                VariableTypes v;
                v.initializeVar(-1, 0.0, 0., "Slack");
                add_var(v);
                SlackCnt++;
            }
            else if (constraint_types[i] == "geq")
            {
                VariableTypes v;
                v.initializeVar(-1, 0.0, 0., "Surplus");
                add_var(v);
                SurplusCnt++;
            }
        }
    }

    void add_choice_vars(const VectorXd &costs)
    {
        for (int i = 0; i < costs.size(); ++i)
        {
            VariableTypes v;
            v.initializeVar(-1, 0, costs[i], "Choice");
            add_var(v);
            ChoiceCnt++;
        }
    }

    void deleteFromMap(int key)
    {
        if (VariableMap[key].Type == "Choice")
        {
            --ChoiceCnt;
        }
        if (VariableMap[key].Type == "Slack")
        {
            --SlackCnt;
        }
        if (VariableMap[key].Type == "Surplus")
        {
            --SurplusCnt;
        }
        VariableMap.erase(key);
    }

    void update(const map<int, int> BasicIndices,
                const map<int, int> NonBasicIndices, const VectorXd &solution)
    {
        int i = 0;
        for (auto it = BasicIndices.begin(); it != BasicIndices.end(); ++it)
        {
            VariableMap[it->second].setInBasis(1);
            VariableMap[it->second].setValue(solution(i));
            ++i;
        }
        for (auto it = NonBasicIndices.begin(); it != NonBasicIndices.end(); ++it)
        {
            VariableMap[it->second].setInBasis(0);
            VariableMap[it->second].setValue(0);
        }
    }


    void printDetailedSolution(LPVariableMap ModelVariables)
    {
        cout << format("%1%  %2%  %3%  %4%") % "Variable" % "In Basis" % "Label" % " Value" << endl;
        for (auto it = ModelVariables.VariableMap.begin(); it != ModelVariables.VariableMap.end(); it++)
        {

            cout << format("%1% %|9t| %2% %|19t| %3% %|35t| %4$d") % it->first % it->second.InBasis % it->second.Type % it->second.Value << endl;
        }
    }
};

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
        if (find(OPT_STATUSES.begin(), OPT_STATUSES.end(), opt_status) == OPT_STATUSES.end())
        {
            throw std::invalid_argument("Invalid opt_status");
        }
        optimization_status = opt_status;
        CurrentBasis = B;
        NonBasicBasis = D;
        current_solution = xb;
        BasicIndices = indx;
        NonBasicIndices = nonbindx;
        F_val = F;
    }

    void print_solution()
    {
        cout << "Optimization status: " << optimization_status << endl;
        cout << "F-Value: " << F_val << endl;
    }
};

class SimplexCore
{

public:
    void set_basic_nonbasic_indxs(map<int, int> &BasicIndices, map<int, int> &NonBasicIndices,
                                  LPVariableMap &ModelVariables)
    {
        int k = 0;
        int m = 0;
        for (auto it = ModelVariables.VariableMap.begin(); it != ModelVariables.VariableMap.end(); ++it)
        {
            if ((it->second).InBasis == 1)
            {
                BasicIndices[k] = it->first;
                ++k;
            }
            else if ((it->second).InBasis == 0)
            {
                NonBasicIndices[m] = it->first;
                ++m;
            }
        }
    }

    int determine_exiting_col(const VectorXd &x_B, const VectorXd &aq)
    {
        int exiting_col = 0;
        if (aq.maxCoeff() < 0)
        {
            return -1;
        }
        double min_ratio = (fabs(x_B.maxCoeff()) / fabs(aq.minCoeff())) + 1;
        for (int j = 0; j < aq.size(); ++j)
        {
            if (aq(j) > 0)
            {
                double can = (x_B(j) / aq(j));
                if (can <= min_ratio)
                {
                    min_ratio = can;
                    exiting_col = j;
                }
            }
        }
        return exiting_col;
    }

    Solution simplex(VectorXd &x_B, MatrixXd &B, MatrixXd &D, VectorXd &c_B, VectorXd &c_D, const VectorXd &b,
                     int max_iterations, LPVariableMap &ModelVariables)
    {
        /*
            Current basis and x_B are known
        */
        int basic_var_count = (int)B.cols();
        int non_basic_var_count = (int)D.cols();
        map<int, int> BasicIndices;
        map<int, int> NonBasicIndices;
        VectorXd x_D = VectorXd::Zero(c_D.size());
        VectorXd reduced_costs(c_D.size());
        double F_val;
        Solution Sol;
        set_basic_nonbasic_indxs(BasicIndices, NonBasicIndices, ModelVariables);
        Sol.set_solution("unallocated", B, D, x_B, BasicIndices, NonBasicIndices, Infinity);
        for (int i = 0; i < max_iterations; ++i)
        {
            cout << "Iteration " << i + 1 << endl;
            F_val = c_B.transpose() * x_B;
            cout << "\tCurrent F-Val= " << F_val << endl;
            VectorXd y = B.transpose().lu().solve(c_B);
            reduced_costs = c_D.transpose() - (y.transpose() * D);
            Index entering_col;
            double reduced_cost_min_val = reduced_costs.minCoeff(&entering_col);
            cout << reduced_cost_min_val << endl;
            if ((0 <= reduced_cost_min_val) && (F_val <= 0))
            {
                Sol.set_solution("success", B, D, x_B, BasicIndices, NonBasicIndices, F_val);
                break;
            }
            else if ((0 <= reduced_cost_min_val) && (F_val > 0))
            {
                Sol.set_solution("infeasible", B, D, x_B, BasicIndices, NonBasicIndices, F_val);
                break;
            }

            VectorXd aq = B.lu().solve(D.col(entering_col));
            if (aq.maxCoeff() < 0)
            {
                Sol.set_solution("Unbounded", B, D, x_B, BasicIndices, NonBasicIndices, F_val);
                break;
            }
            int exiting_col = determine_exiting_col(x_B, aq);
            cout << "entering" << endl;
            cout << entering_col << endl;
            cout << "exiting" << endl;
            cout << exiting_col << endl;

            VectorXd t = B.col(exiting_col);
            B.col(exiting_col) = D.col(entering_col);
            D.col(entering_col) = t;
            x_B = B.lu().solve(b);
            double tt = c_B(exiting_col);
            c_B(exiting_col) = c_D(entering_col);
            c_D(entering_col) = tt;
            /* Housekeeping for basic and non-basic indices */
            int ti = BasicIndices[exiting_col];
            BasicIndices[exiting_col] = NonBasicIndices[entering_col];
            NonBasicIndices[entering_col] = ti;
        }
        for (auto it = BasicIndices.begin(); it != BasicIndices.end(); ++it)
        {
            cout << it->first << " " << it->second << endl;
        }
        for (auto it = NonBasicIndices.begin(); it != NonBasicIndices.end(); ++it)
        {
            cout << it->first << " " << it->second << endl;
        }
        ModelVariables.update(BasicIndices, NonBasicIndices, x_B);
        return Sol;
    }
};
#endif