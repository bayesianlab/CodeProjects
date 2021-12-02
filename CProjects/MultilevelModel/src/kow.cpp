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
    

    cout << ytpath << endl;
    

    char h[256];
    getcwd(h, 256);
    string x = h;
    size_t t = x.find("build");
    string path = x.substr(0, t);
    // string ytpath = path + "kow.csv";
    // string xtpath = path + "kowXt.csv";
    string indexpath = path + "factor_index_world_region_country.csv";
    MatrixXd yt = readCSV(ytpath);
    
    MatrixXd I = readCSV(indexpath);
    Matrix<int, Dynamic, 2> InfoMat = castToInfoMat(I);
    int K = yt.rows();
    int T = yt.cols();
    int sims = 1000;
    int burnin = 100;
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
    double D0 = 4;
    int id = 2;
    FullConditionals mlotrok;

    mlotrok.setModel(yt, Xt, Factors, gammas, deltas, InfoMat, otrokb0, otrokB0,
                     r0, R0, d0, D0, g0, G0, g0, G0, id);
    mlotrok.runModel(sims, burnin);
    mlotrok.ml();

    std::ofstream file(mlotrok.fname, ios_base::app | ios_base::out);
    if (file.is_open())
    {
        file << ytpath << endl;
        
        file.close();
    }
    return 0;
}