#include <iostream>
#include <Eigen/Dense>
#include <ctime>
#include "IntegratedLikelihood.hpp"
#include "Plotter.hpp"
#include "GenerateMLFactorData.hpp"
#include "MultilevelModelFunctions.hpp"
#include "FullConditionals.hpp"
#include "EigenTools.hpp"

int main(int argc, char *argv[])
{
    string ytpath = argv[1];
    string xtpath = argv[2];

    cout << ytpath << endl;
    cout << xtpath << endl; 
    
    char h[256];
    getcwd(h, 256);
    string x = h;
    size_t t = x.find("build");
    string path = x.substr(0, t);
    // string ytpath = path + "kow.csv";
    // string xtpath = path + "kowXt.csv";
    string indexpath = path + "factor_index_world_region.csv";
    MatrixXd yt = readCSV(ytpath);
    MatrixXd xvals = readCSV(xtpath);
    MatrixXd I = readCSV(indexpath);
    Matrix<int, Dynamic, 2> InfoMat = castToInfoMat(I);
    int K = yt.rows();
    int T = yt.cols();
    cout << T << endl; 
    int nFactors = InfoMat.rows();
    int levels = calcLevels(InfoMat, K);
    MatrixXd Xt2(K * T, xvals.cols() + 1);
    Xt2 << VectorXd::Ones(K * T), xvals;
    int nXs = Xt2.cols();

    RowVectorXd otrokb0 = RowVectorXd::Zero(nXs + levels);
    MatrixXd otrokB0 = MatrixXd::Identity(nXs + levels, nXs + levels);
    MatrixXd Factors = normrnd(0, .1, nFactors, T);
    FullConditionals mlotrok;
    RowVectorXd g2(1);
    g2 << .01;
    MatrixXd gammas(nFactors, 1);
    gammas = g2.replicate(nFactors, 1);
    RowVectorXd g0 = RowVectorXd::Zero(gammas.cols());
    MatrixXd G0 = MatrixXd::Identity(gammas.cols(), gammas.cols());
    double r0 = 6;
    double R0 = 6;
    int id = 2; 
    mlotrok.setModel(yt, Xt2, Factors, gammas, InfoMat, otrokb0, otrokB0,
                     r0, R0, g0, G0, id);
    int sims = 10000;
    int burnin = 1000;
    mlotrok.runModel(sims, burnin);
    mlotrok.ml();

    std::ofstream file(mlotrok.fname, ios_base::app | ios_base::out);
    if(file.is_open())
    {
        file << ytpath << endl;
        file << xtpath << endl;
        file << argv[0] << endl;
        file.close();
    }
    return 0;
}