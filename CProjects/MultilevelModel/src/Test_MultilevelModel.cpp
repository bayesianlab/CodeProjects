#include <iostream>
#include <Eigen/Dense>

#include "IntegratedLikelihood.hpp"
#include "Plotter.hpp"
#include "GenerateMLFactorData.hpp"
#include "MultilevelModelFunctions.hpp"
#include "FullConditionals.hpp"

using namespace std;
using namespace Eigen;

int main(int argc, char *argv[])
{

    DynamicFactorsArErrors dfae;
    int T = 50;
    int K = 10;
    int nXs = 2;
    double beta = .5;
    RowVectorXd gam(2);
    gam << .05, .25;
    Matrix<int, Dynamic, 2> InfoMat(1, 2);
    InfoMat << 0, K - 1;

    dfae.genData(T, K, nXs, beta, InfoMat, gam, gam, 1);
    FullConditionals mlotrok;
    double r0 = 6;
    double R0 = 12;
    RowVectorXd g0 = RowVectorXd::Zero(gam.size());
    MatrixXd G0 = MatrixXd::Identity(gam.size(), gam.size());
    MatrixXd Xt = dfae.Xt.leftCols(nXs);

    mlotrok.setModel(dfae.yt, Xt, dfae.Factors, dfae.gammas, dfae.deltas, InfoMat,
                     dfae.b0, dfae.B0, r0, R0, g0, G0, g0, G0);

    mlotrok.fullConditionals(10, 1);
    mlotrok.ml();
    MatrixXd Factorbar = mean(mlotrok.FactorPosteriorDraws);
    cout << mean(mlotrok.BetaPosteriorDraws) << endl;
    cout << mean(mlotrok.DeltasPosteriorDraws).colwise().mean() << endl;
    cout << mean(mlotrok.GammasPosteriorDraws).colwise().mean() << endl;

    plotter("plot.p", Factorbar.row(0).transpose(),
            dfae.Factors.row(0).transpose(), "fest", "ftrue");

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

        // int T = 50;
        // int K = 10;
        // int sims = 10;
        // int burnin = 1;
        // VectorXd betas = .5 * VectorXd::Ones(2, 1);
        // Matrix<int, Dynamic, 2> InfoMat(1, 2);
        // InfoMat << 0, K - 1;
        // cout << InfoMat << endl;
        // int nFactors = InfoMat.rows();
        // MatrixXd Identity = MakeObsModelIdentity(InfoMat, K);
        // MatrixXd A = .5 * Identity;
        // VectorXd factorVariances = VectorXd::Ones(nFactors, 1);
        // RowVectorXd phi(2);
        // phi << .05, .25;
        // GenerateMLFactorData dfae;
        // dfae.genData(T, K, betas, InfoMat, phi, A, 1);
        // double a0 = 1.0;
        // double A0 = 1.0;
        // double r0 = 6;
        // double R0 = 12;
        // RowVectorXd g0;
        // MatrixXd G0;
        // g0.setZero(phi.cols());
        // G0 = MatrixXd::Identity(phi.cols(), phi.cols());
        // MultilevelModel ml;
        // ml.setModel(dfae.yt, dfae.Xt, dfae.Loadings, dfae.Factors, dfae.gammas, InfoMat, dfae.b0,
        //             dfae.B0, a0, A0, r0, R0, dfae.g0, dfae.G0);

        // ml.runModel(sims, burnin);
        // ml.ml();
        // cout << "Beta avg" << endl;
        // cout << mean(ml.BetaPosteriorDraws) << endl;
        // cout << "Loading avg" << endl;
        // cout << mean(ml.LoadingsPosteriorDraws) << endl;
        // cout << "Gamma avg" << endl;
        // cout << mean(ml.GammasPosteriorDraws) << endl;
        // cout << "Factor Variance" << endl;
        // cout << mean(ml.FactorVariancePosteriorDraws) << endl;
        // cout << "OM Variance" << endl;
        // cout << 1. / mean(ml.ObsPrecisionPosteriorDraws).array() << endl;

        // MatrixXd Ftbar = mean(ml.FactorPosteriorDraws);
        // plotter("plot.p", Ftbar.row(0).transpose(),
        //         dfae.Factors.row(0).transpose(), "fest", "ftrue");
    }

    return 0;
}
