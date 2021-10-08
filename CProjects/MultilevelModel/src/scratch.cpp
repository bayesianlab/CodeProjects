#include <ctime>
#include <string.h>
#include <iostream>
#include <fstream>
#include "boost/filesystem.hpp"
#include "MultilevelModelFunctions.hpp"
#include "TimeSeriesTools.hpp"
#include "IntegratedLikelihood.hpp"
#include "GenerateMLFactorData.hpp"

using namespace std;
int main()
{
    // MatrixXd yt = readCSV("/home/dillon/CodeProjects/CProjects/MultilevelModel/kow.csv");
    // MatrixXd xvals = readCSV("/home/dillon/CodeProjects/CProjects/MultilevelModel/kowXt.csv");
    // MatrixXd I = readCSV("/home/dillon/CodeProjects/CProjects/MultilevelModel/factor_index_world_region_country.csv");
    // Matrix<int, Dynamic, 2> InfoMat = castToInfoMat(I);

    // const int T = yt.cols();
    // const int K = yt.rows();
    // const int nFactors = I.rows();
    // const int levels = calcLevels(InfoMat, K);
    // MatrixXd Factors = normrnd(0, 1, nFactors, T);
    // cout << Factors.leftCols(3) << endl
    //      << endl;
    // std::vector<MatrixXd> Xtk = groupByTime(xvals, K);
    // MatrixXd betanew = .5 * MatrixXd::Ones(K, xvals.cols());
    // int gammaRows = 3;
    // RowVectorXd g(3);
    // g << .01, .02, .03;
    // MatrixXd gammas = g.replicate(nFactors, 1);
    // gammas = unifrnd(0, 1, nFactors, gammaRows);
    // VectorXd factorVariance = VectorXd::Ones(nFactors);
    // VectorXd omVariance = VectorXd::Ones(K);
    // RowVectorXd b0 = RowVectorXd::Zero(xvals.cols());
    // MatrixXd B0 = MatrixXd::Identity(xvals.cols(), xvals.cols());

    // MatrixXd A = .5*MatrixXd::Ones(K, levels);
    int T = 50;
    int K = 10;
    int sims = 10;
    int burnin = 1;
    VectorXd betas = .5 * VectorXd::Ones(2, 1);
    Matrix<int, Dynamic, 2> InfoMat(1, 2);
    InfoMat << 0, K - 1;
    cout << InfoMat << endl;
    int nFactors = InfoMat.rows();
    MatrixXd Identity = MakeObsModelIdentity(InfoMat, K);
    MatrixXd A = .5 * Identity;
    VectorXd factorVariances = VectorXd::Ones(nFactors, 1);
    RowVectorXd phi(2);
    phi << .05, .25;
    GenerateMLFactorData mldata;
    mldata.genData(T, K, betas, InfoMat, phi, A, 1);
    double a0 = 1.0;
    double A0 = 1.0;
    double r0 = 6;
    double R0 = 12;
    RowVectorXd g0;
    MatrixXd G0;
    g0.setZero(phi.cols());
    G0 = MatrixXd::Identity(phi.cols(), phi.cols());
    MatrixXd yt = mldata.yt;
    MatrixXd Xt = mldata.Xt;
    MatrixXd Factors = mldata.Factors;
    RowVectorXd b0 = RowVectorXd::Zero(Xt.cols());
    MatrixXd B0 = MatrixXd::Identity(Xt.cols(), Xt.cols());
    MatrixXd gammas = mldata.gammas;
    VectorXd omVariance = VectorXd::Ones(K);
    std::vector<MatrixXd> Xtk = groupByTime(Xt, K);
    VectorXd factorVariance = VectorXd::Ones(nFactors);
    A = mldata.Loadings;

    BetaParameterTools bpt;

    MatrixXd P = MakePrecision(gammas, factorVariance, T);
    bpt.betaUpdater(yt, surForm(Xt,K), omVariance, A, P, mldata.b0, mldata.B0);

    MatrixXi FactorInfo = createFactorInfo(InfoMat, K);

    RowVectorXi i(FactorInfo.cols());
    VectorXd tfv(FactorInfo.cols());
    MatrixXd tf(FactorInfo.cols(), Factors.cols());
    MatrixXd tg(FactorInfo.cols(), gammas.cols());
    MatrixXd subFp;
    double o2;
    for (int k = 0; k < K; ++k)
    {
        i = FactorInfo.row(k);
        for (int j = 0; j < i.size(); ++j)
        {
            tg.row(j) = gammas.row(i(j));
            tfv(j) = factorVariance(i(j));
        }
        subFp = MakePrecision(tg, tfv, T);
        o2 = 1 / omVariance(k);
        bpt.betaUpdater(yt.row(k), Xtk[k], o2, A.row(k), subFp, b0, B0);
    }

    return 0;
}
