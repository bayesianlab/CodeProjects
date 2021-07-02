

#include <iostream>
#include <stdlib.h>
#include <fstream>
#include <map>
#include <string>
#include <eigen-3.3.9/Eigen/Dense>
#include <boost/random/mersenne_twister.hpp>
#include <chrono>
#include "MultilevelModel.hpp"
#include "Distributions.hpp"

using namespace std;
using namespace Eigen;

void writeToCSVfile(string name, MatrixXd matrix)
{
    ofstream file(name.c_str());
    if (file.is_open())
    {
        file << matrix << '\n';
        file.close();
    }
    else
    {
        cout << "error" << endl;
    }
}

int main(int argc, char *argv[])
{

    int on = 1;
    if (on)
    {
        // int n = 2;

        // cout << "Create Diagonal along the 0 diagonal" << endl;
        // ArrayXi d(1);
        // d << 0;
        // cout << CreateDiag(MatrixXd::Ones(10, 1), d, 10, 10) << endl;
        // cout << "Create Diagonal along -1 diagonal" << endl;
        // d(0) = -1;
        // cout << CreateDiag(MatrixXd::Ones(10, 1), d, 10, 10) << endl;
        // cout << "Create Diagonal along multiple diagonals" << endl;
        // VectorXd gammas5(4);
        // gammas5 << -.1, -.2, -.3, 1;
        // MatrixXd G5;
        // G5 = gammas5.transpose().replicate(10, 1);
        // cout << G5 << endl;
        // cout << CreateDiag(G5, sequence(-4, -1), 10, 10) << endl;
        // cout << "Positive and negative diagonals" << endl;
        // d.resize(2);
        // d << -1, 1;
        // cout << CreateDiag(MatrixXd::Ones(10, 2), d, 10, 10) << endl;
        // try
        // {
        //     sequence(-1, -3);
        // }
        // catch (invalid_argument)
        // {
        //     cout << "invalid arg test" << endl;
        // }
        // cout << "Non square test" << endl;
        // ArrayXi d2(3);
        // d2 << 0, 2, 3;
        // cout << CreateDiag(MatrixXd::Ones(2, 3), d2, 2, 8) << endl;
        // cout << "Non square test 2" << endl;
        // d2 << -2, -1, 0;
        // cout << CreateDiag(MatrixXd::Ones(3, 3), d2, 8, 2) << endl;
        // cout << "1-10" << endl;
        // cout << sequence(1, 10).transpose() << endl;
        // cout << "-3 - -1" << endl;
        // cout << sequence(-3, -1).transpose() << endl;
        // cout << "-10 10 by 2" << endl;
        // cout << sequence(-10, 10, 2).transpose() << endl;
        // cout << "-3 3 by 3" << endl;
        // cout << sequence(-3, 3, 3).transpose() << endl;
        // cout << "-5 to 10 by 3" << endl;
        // cout << sequence(-5, 10, 3).transpose() << endl;
        // cout << "make state space" << endl;
        // VectorXd gammas(n);
        // gammas << .2, .2;
        // cout << makeStateSpace(gammas.transpose()) << endl;
        // VectorXd gammas2(4);
        // gammas2 << .2, .2, .2, .2;
        // cout << "amke state sapce 2" << endl;
        // cout << makeStateSpace(gammas2.transpose()) << endl;
        // MatrixXd gammas3(2, 1);
        // gammas3 << .2, .2;
        // VectorXd vars3(2);
        // vars3 << 1, 1;
        // cout << "make state space 3" << endl;
        // cout << makeStateSpace(gammas3) << endl;
        // MatrixXd gammas4(2, 2);
        // gammas4 << .2, .2, .3, .3;
        // cout << "make state space 4" << endl;
        // cout << makeStateSpace(gammas4) << endl;
        // cout << "set covariance" << endl;
        // VectorXd vars(1);
        // vars << 1;
        // cout << setCovar(gammas.transpose(), vars) << endl;
        // cout << " set covariance 2" << endl;
        // VectorXd vars2 = VectorXd::Ones(1);
        // cout << setCovar(gammas2.transpose(), vars2) << endl;

        // cout << "Make Precision" << endl;
        // cout << MakePrecision(gammas.transpose(), vars, 10) << endl;
        // cout << "Make Precision 2" << endl;
        // cout << MakePrecision(gammas2.transpose(), vars2, 10) << endl;
        // cout << "Make Precision 3" << endl;
        // cout << MakePrecision(gammas3, vars3, 10) << endl;
        // cout << " Make Precision 4" << endl;
        // cout << MakePrecision(gammas4, vars3, 10) << endl;
        // Matrix<int, 1, 2> x1;
        // x1 << 0, 9;
        // Matrix<int, 1, 2> x2;
        // x2 << 6, 9;
        // map<string, Matrix<int, 1, 2>> m{
        //     {"L1", x1},
        //     {"L2", x2},
        // };
        // cout << "Make obs model identity" << endl;
        // MatrixXd ObsModelIden = MakeObsModelIdentity(m, 10);
        // cout << ObsModelIden << endl;
        // cout << "Zero out factor level" << endl;
        // cout << zeroOutFactorLevel(ObsModelIden, 0) << endl;
        // cout << "Zero out factor level" << endl;
        // cout << zeroOutFactorLevel(ObsModelIden, 1) << endl;
        // cout << "Sur Form" << endl;
        // MatrixXd stackedX(3 * 10, 3);
        // stackedX << MatrixXd::Ones(3 * 10, 1), normrnd(0, 1, 3 * 10, 2);
        // cout << stackedX << endl;
        // surForm(stackedX, 3);
        // cout << "Lag tests" << endl;
        // MatrixXd P = normrnd(0, 1, 4, 10);
        // cout << P << endl;
        // cout << endl;
        // cout << lag(P, 3) << endl;
        // P.resize(0, 0);
        // cout << "Lag 1, 1 series" << endl;
        // P = normrnd(0, 1, 1, 10);
        // cout << P << endl;
        // cout << lag(P, 3) << endl;

        // GenerateAutoRegressiveData ar(nObs, delta);
        // MatrixXd resids = ar.ythat;
        // MatrixXd g0 = ar.g0;
        // MatrixXd G0 = ar.G0;
        // MatrixXd yt_ar = ar.yt;
        // MatrixXd gnew = ar.g0;
        // MatrixXd Xthat = ar.Xthat;
        // int sims = 1000;
        // int burnin = 100;
        // int j = 0;
        // double sig2 = 1;
        // MatrixXd storeg(sims - burnin, ar.g0.cols());
        // for (int j = 0; j < sims; j++)
        // {
        //     resids = ar.ythat - gnew * Xthat;
        //     gnew = updateAR(gnew, yt_ar, sig2, g0, G0);
        //     if (j >= burnin)
        //     {
        //         storeg.row(j - burnin) = gnew;
        //     }
        // }
        // cout << endl;
        // cout << storeg.colwise().mean() << endl;

        int T = 25;
        int neqns = 8;
        int sims = 10;
        int burnin = 1;
        VectorXd betas = VectorXd::Ones(2, 1);
        Matrix<int, 1, 2> region1;
        region1 << 0, 3;
        Matrix<int, 1, 2> region2;
        region2 << 4, 7;
        map<string, Matrix<int, 1, 2>> InfoMap{{"L1", region1}, {"L2", region2}};
        int nFactors = InfoMap.size();
        MatrixXd Identity = MakeObsModelIdentity(InfoMap, neqns);
        MatrixXd A = MatrixXd::Ones(neqns, 2);
        VectorXd factorVariances = VectorXd::Ones(nFactors, 1);
        VectorXd phi(2);
        phi << .1, .3;
        A = Identity.array() * A.array();
        GenerateMLFactorData mld(T, neqns, betas, InfoMap, phi, factorVariances, A);

        MultilevelModel ml;
        ml.runMultilevelModel(mld.yt, mld.Xt, mld.Loadings, mld.gammas, InfoMap,
                              mld.b0, mld.B0, sims, burnin);

        VectorXd B(10); 
        B = normrnd(0,1,10,1);
        cout << B << endl; 
        B = normrnd(0,1,5,1);
        cout << endl;
         cout << B << endl; 
        // UpdateBeta ub;
        // LoadingsPriorsSetup lps(1, .1, InfoMap);
        // MatrixXd COM = zeroOutFactorLevel(Identity, 0);
        // MatrixXd mut = mld.Xbeta + COM * mld.Factors;
        // MatrixXd ytdemeaned = mld.yt - mut;

        // MatrixXd subyt = ytdemeaned.topRows(4);
        // MatrixXd a0priormean = lps.loadingsPriorMeans["L1"].transpose();
        // MatrixXd a0priorprecision = lps.loadingsPriorPrecision["L1"];
        // VectorXd subomPrecision = mld.om_precision.head(4);
        // MatrixXd subFt = mld.Factors.row(0);
        // MatrixXd subgammas = mld.gammas.row(0);
        // VectorXd subfv = mld.factorVariances.row(0);
        // MatrixXd subFp = MakePrecision(subgammas, subfv, T);
        // double optim_options[5] = {SEPS, EPS, EPS, 1e-5, 25};
        // Optimize optim(optim_options);

        // auto CLL = [&subyt, &a0priormean, &a0priorprecision,
        //             &subomPrecision, &subFt, &subFp](const VectorXd &x0)
        // {
        //     return -ConditionalLogLikelihood(x0, subyt, a0priormean, a0priorprecision,
        //                                      subomPrecision, subFt, subFp);
        // };
        // VectorXd subA = .5 * A.col(0).head(4);
        // optim.BFGS(subA, CLL, 1);
    }

    // VectorXd index = sequence(0, nObs-1).cast<double>();
    // MatrixXd data(nObs,2);
    // data << index, mld.yt.row(0).transpose();
    // data.col(0) = index;
    // data.col(1) = mld.yt.row(0).transpose();
    // cout << data << endl;
    // writeToCSVfile("foo.csv", data);
}
