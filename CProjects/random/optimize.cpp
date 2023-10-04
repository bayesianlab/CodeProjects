#include "Distributions.hpp"
#include "stats.hpp"
#include <Eigen/Dense>
#include <iostream>
#include <random>
#include <vector>

using namespace std;
using namespace Eigen;
using namespace stats;
class Simulations
{
  private:
    double EPS = 1e-8;

  public:
    int rows;
    int cols;
    MatrixXd Margins;
    MatrixXd Prob;
    MatrixXd ExpRev;
    Simulations(int rows_, int cols_)
    {
        rows = rows_;
        cols = cols_;
        Margins = MatrixXd::Zero(rows, cols);
        Prob = Margins;
        ExpRev = Margins;
    }

    MatrixXd set_up_sims()
    {
        int num_sims = rows;
        Margins;
        for (int c = 0; c < cols; c++)
        {
            double minval = unifrnd(-1, -.3);
            double maxval = unifrnd(.25, 1);
            double m = (maxval - minval) / rows;

            for (int r = 0; r < rows; r++)
            {
                if (r == 0)
                {
                    Margins(r, c) = minval;
                    Prob(r, c) = normalCDF(-Margins(r, c) / .2);
                    ExpRev(r, c) = Margins(r, c) * Prob(r, c);
                }
                else
                {
                    Margins(r, c) = Margins(r - 1, c) + m;
                    Prob(r, c) = normalCDF(-Margins(r, c) / .2);
                    if (Prob(r, c) < EPS)
                        Prob(r, c) = 0;
                    if (Prob(r, c) > 1.0 - EPS)
                        Prob(r, c) = 1;
                    ExpRev(r, c) = Margins(r, c) * Prob(r, c);
                }
            }
        }
        return Margins;
    }
};

class SimluatedAnnealer
{
  public:
    MatrixXd SimSet;
    SimluatedAnnealer(Simulations S)
    {
        SimSet = S.ExpRev;
    }

    vector<int> simple_max()
    {
        vector<int> max_indices(SimSet.cols());
        for (int i = 0; i < SimSet.cols(); ++i) {
            double m = SimSet(0,i); 
            max_indices[i] = 0;
            for (int r = 0; r < SimSet.rows(); ++r) {
                if (SimSet(r, i) > m) {
                    m = SimSet(r,i);
                    max_indices[i] = r; 
                }
            }
        }
        return max_indices; 
    }

    vector<int> choose_random_path()
    {
        std::random_device rd;
        std::mt19937 eng(rd());
        std::uniform_int_distribution<> distr(0, SimSet.rows() - 1);
        vector<int> path;
        for (int c = 0; c < SimSet.cols(); ++c)
        {
            path.push_back(distr(eng));
            
        }
        return path;
    }

    double rev_path(vector<int> selected_path)
    {
        double rev = 0;
        for (int c = 0; c < SimSet.cols(); ++c)
        {
            rev += SimSet(selected_path[c], c);
        }
        return rev;
    }

    void max_annealer() {
        vector<int> sm = simple_max();
        double max = 0;
        cout << "Solution " << endl; 

        for (int i = 0; i < sm.size(); ++i)
        {
            cout << sm[i] << " ";
            max += SimSet(sm[i],i);
        }
        cout << endl << max << endl; 
        double Temp = .5; 
        vector<int> path0(SimSet.cols());
        double E0 = -rev_path(path0); 
        int reps = 0; 
        int Mk = 10000;
        double E = 0; 
        double Delta = E - E0; 
        double stop = 1e-4;
        while (Temp > stop)
        {
            int energy_drops = 0;
            while ((reps < Mk) && (energy_drops < 10))
            {
                vector<int> path = choose_random_path();
                E = -rev_path(path);
                Delta = E - E0;
                if (Delta < 0)
                {
                    path0 = path;
                    E0 = E;
                    energy_drops++; 
                }
                else
                {
                    double lp = -Delta / Temp;
                    double alpha = log(unifrnd());
                    if (alpha < lp)
                    {
                        path0 = path;
                        E0 = E;
                    }
                }
                ++reps;
            }
            Temp = Temp * 0.99;
            reps = 0;
            if (abs(Delta) < stop)
            {
                break; 
            }
        }
        cout << "Maximum revenue " << -E0 << endl; 
        for (int i = 0; i < path0.size(); ++i) {
            cout << path0[i] << " ";
        }
        cout << endl; 
     }
};

int main()
{
    cout << "set up practice matrix" << endl;
    Simulations S(10, 10);
    S.set_up_sims();

    cout << S.ExpRev << endl;

    SimluatedAnnealer A(S);

    A.max_annealer();
    //vector<int> x = A.choose_random_path();
    //for (int i = 0; i < x.size(); ++i) {
    //    cout << x[i] << endl; 
    //}
    //

    cout << "done" << endl;
}