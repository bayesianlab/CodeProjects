#include <iostream>
#include <Eigen/Dense>
#include <ctime>
#include "IntegratedLikelihood.hpp"
#include "Plotter.hpp"
#include "GenerateMLFactorData.hpp"
#include "MultilevelModelFunctions.hpp"
#include "FullConditionals.hpp"
#include "EigenTools.hpp"

using namespace std;
using namespace Eigen;

int main()
{

    int on = 0;
    if (on)
    {
        int n = 2;

        cout << "Create Diagonal along the 0 diagonal" << endl;
        ArrayXi d(1);
        d << 0;
        cout << CreateDiag(MatrixXd::Ones(10, 1), d, 10, 10) << endl;
        cout << "Create Diagonal along -1 diagonal" << endl;
        d(0) = -1;
        cout << CreateDiag(MatrixXd::Ones(10, 1), d, 10, 10) << endl;
        cout << "Create Diagonal along multiple diagonals" << endl;
        VectorXd gammas5(4);
        gammas5 << -.1, -.2, -.3, 1;
        MatrixXd G5;
        G5 = gammas5.transpose().replicate(10, 1);
        cout << G5 << endl;
        cout << CreateDiag(G5, sequence(-4, -1), 10, 10) << endl;
        cout << "Positive and negative diagonals" << endl;
        d.resize(2);
        d << -1, 1;
        cout << CreateDiag(MatrixXd::Ones(10, 2), d, 10, 10) << endl;
        try
        {
            sequence(-1, -3);
        }
        catch (invalid_argument const &)
        {
            cout << "invalid arg test" << endl;
        }
        cout << "Non square test" << endl;
        ArrayXi d2(3);
        d2 << 0, 2, 3;
        cout << CreateDiag(MatrixXd::Ones(2, 3), d2, 2, 8) << endl;
        cout << "Non square test 2" << endl;
        d2 << -2, -1, 0;
        cout << CreateDiag(MatrixXd::Ones(3, 3), d2, 8, 2) << endl;
        cout << "1-10" << endl;
        cout << sequence(1, 10).transpose() << endl;
        cout << "-3 - -1" << endl;
        cout << sequence(-3, -1).transpose() << endl;
        cout << "-10 10 by 2" << endl;
        cout << sequence(-10, 10, 2).transpose() << endl;
        cout << "-3 3 by 3" << endl;
        cout << sequence(-3, 3, 3).transpose() << endl;
        cout << "-5 to 10 by 3" << endl;
        cout << sequence(-5, 10, 3).transpose() << endl;
        cout << "make state space" << endl;
        VectorXd gammas(n);
        gammas << .2, .2;
        cout << makeStateSpace(gammas.transpose()) << endl;
        VectorXd gammas2(4);
        gammas2 << .2, .2, .2, .2;
        cout << "amke state sapce 2" << endl;
        cout << makeStateSpace(gammas2.transpose()) << endl;
        MatrixXd gammas3(2, 1);
        gammas3 << .2, .2;
        VectorXd vars3(2);
        vars3 << 1, 1;
        cout << "make state space 3" << endl;
        cout << makeStateSpace(gammas3) << endl;
        MatrixXd gammas4(2, 2);
        gammas4 << .2, .2, .3, .3;
        cout << "make state space 4" << endl;
        cout << makeStateSpace(gammas4) << endl;
    }

    int otrokwhitemantest = 0;
    int chanandj = 0;
    int comparemethods = 0;
    int realdata_kow = 0;
    int realdata_intlike = 1;
    if (otrokwhitemantest)
    {
        /* Run the standard otrok whiteman model, 1 factor*/
        DynamicFactorsArErrors dfae;
        int T = 50;
        int K = 180;
        int nXs = 2;
        double beta = .5;
        RowVectorXd gam(1);
        gam << .25;
        // Matrix<int, Dynamic, 2> InfoMat(1, 2);
        // InfoMat << 0, K - 1;

        Matrix<int, Dynamic, 2> InfoMat(9, 2);
        InfoMat << 0, K - 1,
            0, 89,
            90, K - 1,
            0, 29,
            30, 59,
            60, 89,
            90, 119,
            120, 149,
            150, 179;

        dfae.genData(T, K, nXs, beta, InfoMat, gam, gam, 1);
        FullConditionals mlotrok;
        double r0 = 6;
        double R0 = 6;
        double d0 = 6;
        double D0 = 6;
        int id = 2;
        RowVectorXd g0 = RowVectorXd::Zero(gam.size());
        MatrixXd G0 = MatrixXd::Identity(gam.size(), gam.size());
        MatrixXd Xt = dfae.Xt.leftCols(nXs);

        mlotrok.setModel(dfae.yt, Xt, dfae.Factors, dfae.gammas, dfae.deltas, InfoMat,
                         dfae.b0, dfae.B0, r0, R0, d0, D0, g0, G0, g0, G0, id);

        int sims1 = 100;
        int burnin1 = 10;
        mlotrok.runModel(sims1, burnin1);
        mlotrok.ml();

        MatrixXd Factorbar = mean(mlotrok.FactorPosteriorDraws);
        plotter("plot.p", Factorbar.row(0).transpose(),
                dfae.Factors.row(0).transpose(), "fest", "ftrue");
        plotter("plot.p", Factorbar.row(1).transpose(),
                dfae.Factors.row(1).transpose(), "fest", "ftrue");
    }
    if (chanandj)
    {
        int T = 50;
        int K = 25;
        int sims = 100;
        int burnin = 10;
        VectorXd betas = .5 * VectorXd::Ones(2, 1);
        Matrix<int, Dynamic, 2> InfoMat(6, 2);
        InfoMat << 0, K - 1,
        0,4,
        5,9,
        10,15,
        16,19,
        20,24;
        
   
        int nFactors = InfoMat.rows();
        MatrixXd Identity = MakeObsModelIdentity(InfoMat, K);
        MatrixXd A = .5 * Identity;
        VectorXd factorVariances = VectorXd::Ones(nFactors, 1);
        RowVectorXd phi(1);
        phi << .25;
        GenerateMLFactorData mldata;
        mldata.genData(T, K, betas, InfoMat, phi, A, 1);
        double a0 = 0.0;
        double A0 = 10.0;
        double r0 = 6;
        double R0 = 4;
        RowVectorXd g0;
        MatrixXd G0;
        g0.setZero(phi.cols());
        G0 = MatrixXd::Identity(phi.cols(), phi.cols());
        MultilevelModel ml;
        ml.setModel(mldata.yt, mldata.Xt, mldata.Loadings, mldata.Factors, mldata.gammas, InfoMat, mldata.b0,
                    mldata.B0, a0, A0, r0, R0, mldata.g0, mldata.G0);

        ml.runModel(sims, burnin);
        ml.ml();
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

        MatrixXd Ftbar = mean(ml.FactorPosteriorDraws);
        plotter("plot.p", Ftbar.row(0).transpose(),
                mldata.Factors.row(0).transpose(), "fest", "ftrue");
    }
    if (comparemethods)
    {
        int T = 50;
        int K = 10;
        int sims = 10;
        int burnin = 1;
        int nXs = 2;
        double omVar = 1.0;
        VectorXd betas = .5 * VectorXd::Ones(nXs, 1);
        Matrix<int, Dynamic, 2> InfoMat(1, 2);
        InfoMat << 0, K - 1;
        int nFactors = InfoMat.rows();
        MatrixXd Identity = MakeObsModelIdentity(InfoMat, K);
        MatrixXd A = .5 * Identity;
        VectorXd factorVariances = VectorXd::Ones(nFactors, 1);
        RowVectorXd phi(2);
        phi << .05, .25;
        GenerateMLFactorData mldata;
        mldata.genData(T, K, betas, InfoMat, phi, A, omVar);

        FullConditionals mlotrok;
        double r0 = 6;
        double R0 = 12;

        RowVectorXd g0 = RowVectorXd::Zero(phi.size());
        MatrixXd G0 = MatrixXd::Identity(phi.size(), phi.size());
        RowVectorXd otrokb0 = RowVectorXd::Zero(mldata.Xt.cols() + nFactors);
        MatrixXd otrokB0 = 100 * MatrixXd::Identity(mldata.Xt.cols() + nFactors, mldata.Xt.cols() + nFactors);
        mlotrok.setModel(mldata.yt, mldata.Xt, mldata.Factors, mldata.gammas, InfoMat,
                         otrokb0, otrokB0, r0, R0, g0, G0);

        mlotrok.runModel(sims, burnin);
        MatrixXd Ftbar = mean(mlotrok.FactorPosteriorDraws);
        plotter("plot.p", Ftbar.row(0).transpose(), mldata.Factors.row(0).transpose(), "fest", "ftrue");
        cout << "OM Variance" << endl;
        cout << mean(mlotrok.OmVariancePosteriorDraws).transpose() << endl;
        cout << "Beta" << endl;
        cout << mean(mlotrok.BetaPosteriorDraws) << endl;
        mlotrok.ml();
        std::ofstream fname1;
        fname1.open("marginal_likelihood_kow.txt");
        fname1 << "MarginalLikelihood" << endl
               << mlotrok.marginal_likelihood << endl;
        fname1.close();

        double a0 = 1.0;
        double A0 = 1.0;
        g0.setZero(phi.cols());
        G0 = MatrixXd::Identity(phi.cols(), phi.cols());
        MultilevelModel ml;
        ml.setModel(mldata.yt, mldata.Xt, mldata.Loadings, mldata.Factors, mldata.gammas, InfoMat, mldata.b0,
                    mldata.B0, a0, A0, r0, R0, mldata.g0, mldata.G0);

        ml.runModel(sims, burnin);
        ml.ml();

        std::ofstream fname2;
        fname2.open("marginal_likelihood.txt");
        fname2 << "MarginalLikelihood" << endl
               << ml.marginal_likelihood << endl;
        fname2.close();
        cout << "Beta avg" << endl;
        cout << mean(ml.BetaPosteriorDraws) << endl;
        cout << "Loading avg" << endl;
        cout << mean(ml.LoadingsPosteriorDraws) << endl;
        cout << "Gamma avg" << endl;
        cout << mean(ml.GammasPosteriorDraws) << endl;
        cout << "Factor Variance" << endl;
        cout << mean(ml.FactorVariancePosteriorDraws) << endl;
        cout << "OM Variance" << endl;
        cout << 1. / mean(ml.ObsPrecisionPosteriorDraws).array() << endl;

        ml.storePosterior("betacj.csv", ml.BetaPosteriorDraws);
        ml.storePosterior("loadingcj.csv", ml.LoadingsPosteriorDraws);
        ml.storePosterior("gammacj.csv", ml.GammasPosteriorDraws);
        ml.storePosterior("factorcj.csv", ml.FactorVariancePosteriorDraws);
        ml.storePosterior("omprecison.csv", ml.ObsPrecisionPosteriorDraws);
        ml.storePosterior("factors.csv", ml.FactorPosteriorDraws);

        Ftbar = mean(ml.FactorPosteriorDraws);
        plotter("plot.p", Ftbar.row(0).transpose(), mldata.Factors.row(0).transpose(), "fest", "ftrue");
    }
    if (realdata_kow)
    {
        /* Models to run, model with no country factors
        * standard kow model
        * model with country factors and country vars */
        char h[256];
        getcwd(h, 256);
        string x = h;
        size_t t = x.find("build");
        string path = x.substr(0, t);
        string ytpath = path + "kow.csv";
        string indexpath = path + "factor_index_world_region_country.csv";
        MatrixXd yt = readCSV(ytpath);
        VectorXd ytmean = yt.rowwise().mean();
        yt = (yt.colwise() - ytmean);

        MatrixXd I = readCSV(indexpath);
        Matrix<int, Dynamic, 2> InfoMat = castToInfoMat(I);
        int K = yt.rows();
        int T = yt.cols();
        int sims = 10000;
        int burnin = 1000;
        int nFactors = InfoMat.rows();

        MatrixXd Xt(K * T, 1);
        Xt << VectorXd::Ones(K * T);
        int nXs = Xt.cols();
        MatrixXd Factors = normrnd(0, 1, nFactors, T);
        int gammaCols = 3;
        RowVectorXd g(gammaCols);
        g << .0, .05, .1;
        MatrixXd gammas = g.replicate(nFactors, 1);
        MatrixXd deltas;
        deltas = g.replicate(K, 1);
        RowVectorXd g0 = RowVectorXd::Zero(gammaCols);
        VectorXd G0diag(gammaCols);
        G0diag << .25, .5, 1;
        MatrixXd G0 = G0diag.asDiagonal();
        int levels = calcLevels(InfoMat, K);
        RowVectorXd otrokb0 = RowVectorXd::Zero(nXs + levels);
        MatrixXd otrokB0 = 10 * MatrixXd::Identity(nXs + levels, nXs + levels);
        // otrokB0.block(0, 0, nXs, nXs) = MatrixXd::Identity(nXs, nXs);

        double r0 = 6;
        double R0 = 8;
        double d0 = 6;
        double D0 = 6;
        int id = 2;
        FullConditionals mlotrok;

        mlotrok.setModel(yt, Xt, Factors, gammas, deltas, InfoMat, otrokb0, otrokB0,
                         r0, R0, d0, D0, g0, G0, g0, G0, id);
        mlotrok.runModel(sims, burnin);
        mlotrok.ml();
    }
    if (realdata_intlike)
    {
        char h[256];
        getcwd(h, 256);
        string x = h;
        size_t t = x.find("build");
        string path = x.substr(0, t);
        string ytpath = path + "kowz.csv";
        string xtpath = path + "kowXtz.csv";
        string indexpath = path + "factor_index_world_region_country.csv";
        MatrixXd yt = readCSV(ytpath);
        MatrixXd xvals = readCSV(xtpath);
        MatrixXd I = readCSV(indexpath);
        Matrix<int, Dynamic, 2> InfoMat = castToInfoMat(I);
        int K = yt.rows();
        int T = yt.cols();
        int sims = 100;
        int burnin = 10;
        int nFactors = InfoMat.rows();
        MatrixXd Xt2(K * T,  xvals.cols() + 1);
        Xt2 << VectorXd::Ones(K * T), xvals;
        MultilevelModel intlike;
        int betacols = K * Xt2.cols();
        double a0 = 1.0;
        double A0 = 1.0;
        MatrixXd Identity = MakeObsModelIdentity(InfoMat, K);
        MatrixXd A = .01 * Identity;
        RowVectorXd b02 = RowVectorXd::Zero(betacols);
        MatrixXd B02 = 10 * MatrixXd::Identity(betacols, betacols);
        double r0 = 6;
        double R0 = 4;

        RowVectorXd g2(1);
        g2 << .01;
        MatrixXd gammas2(nFactors, 1);
        gammas2 = g2.replicate(nFactors, 1);
        RowVectorXd g0 = RowVectorXd::Zero(gammas2.cols());
        MatrixXd G0 = MatrixXd::Identity(gammas2.cols(), gammas2.cols());
        MatrixXd Factors = normrnd(0, .1, nFactors, T);

        intlike.setModel(yt, Xt2, A, Factors, gammas2, InfoMat, b02, B02, a0, A0, r0, R0, g0, G0);
        intlike.runModel(sims, burnin);
        intlike.ml();
    }
    return 0;
}
