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

    vector<int> choose_path()
    {
        cout << SimSet.rows() << " " << SimSet.cols() << endl;
        std::random_device rd;
        std::mt19937 eng(rd());
        std::uniform_int_distribution<> distr(0, SimSet.rows() - 1);
        vector<int> rows(SimSet.rows());
        for (int c = 0; c < SimSet.cols(); ++c)
        {
            rows.push_back(distr(eng));
        }
        return rows;
    }

    double rev_path(vector<int> selected_path)
    {
        double rev = 0;
        for (int c = 0; c < SimSet.cols(); ++c)
        {
            cout <<SimSet(selected_path[c], c) << endl;  
            rev += SimSet(selected_path[c], c);
        }
        return rev;
    }
};

int main()
{
    cout << "set up practice matrix" << endl;
    Simulations S(10, 10);
    S.set_up_sims();

    cout << S.ExpRev << endl;

    SimluatedAnnealer A(S);
    A.choose_path();
    cout << "done" << endl;
}