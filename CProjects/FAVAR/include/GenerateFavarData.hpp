#ifndef GENF_H
#define GENF_H
#include <iostream>
#include <Eigen/Dense>
#include <unsupported/Eigen/KroneckerProduct>
#include "stats.hpp"
#include "EigenTools.hpp"

using namespace Eigen;
using namespace std;

class GenerateFavarData
{

public:
    MatrixXd yt;
    template <typename Tg>
    void genData(const int K, const int T, const int nFactors, const MatrixBase<Tg> &gammas)
    {
        VectorXd v = VectorXd::Ones(nFactors);
        MatrixXd Gammas = kroneckerProduct(v, gammas);
        cout << Gammas << endl;

        ArrayXi diags(1);
        diags << -1;
        MatrixXd D = CreateDiag(-v, diags, 2, 2);
        MatrixXd X = kroneckerProduct(D, Gammas);
        MatrixXd I = MatrixXd::Identity(X.rows(), X.cols()); 
        X = X + I;
        MatrixXd Y = makeBlockDiagonal(-Gammas, 2, diags);
        
    }
};

#endif