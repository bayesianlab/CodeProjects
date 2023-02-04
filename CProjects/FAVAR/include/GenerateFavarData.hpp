#ifndef GENF_H
#define GENF_H
#include <iostream>
#include <Eigen/Dense>
#include <unsupported/Eigen/KroneckerProduct>
#include "stats.hpp"
#include "EigenTools.hpp"
#include "Distributions.hpp"
#include "IntegratedLikelihood.hpp"

using namespace Eigen;
using namespace std;

class GenerateFavarData 
{

public:
    MatrixXd yt;
    MatrixXd Loadings; 

    template <typename Tb>
    MatrixXd ReturnBlockH(const MatrixBase<Tb> &Block, const int T)
    {
        ArrayXi diags(1);
        diags << -1;
        int n = Block.rows();
        MatrixXd Y = makeBlockDiagonal(-Block, T, diags);
        MatrixXd I = MatrixXd::Identity(n * T, n * T);
        return Y + I;
    }

    MatrixXd setLoadings(const Ref<const MatrixXd> &A, const Matrix<int, Dynamic, 2> &InfoMat,
                     double restriction)
    {
        MatrixXd X = A;
        for (int i = 0; i < InfoMat.rows(); ++i)
        {
            X(InfoMat.row(i).head(1).value(), i) = restriction;
        }
        return X; 
    }

    template <typename Tg, typename Tl>
    void genData(const int K, const int T, const int nFactors, const MatrixBase<Tg> &gammas,
                 const MatrixBase<Tl> &A)
    {
        VectorXd v = VectorXd::Ones(nFactors);
        MatrixXd Gammas = kroneckerProduct(v, gammas);
        cout << Gammas << endl;

        ArrayXi diags(1);
        diags << -1;
        MatrixXd Y = makeBlockDiagonal(-Gammas, 10, diags);
        VectorXd epsilon = normrnd(0, 1, nFactors * T);

        MatrixXd I = MatrixXd::Identity(nFactors * 10, nFactors * 10);
        MatrixXd H = ReturnBlockH(Gammas, T);
        MatrixXd P = H * H.transpose();
        MatrixXd Pinv = P.llt().solve(MatrixXd::Identity(P.rows(), P.rows()));
        MatrixXd Pinvlower = Pinv.llt().matrixL();
        MatrixXd Ft = Pinvlower * normrnd(0, 1, nFactors * T);
        Ft.resize(nFactors, T);
        Loadings = setLoadings(A, InfoMat, 1);
        cout << Loadings << endl; 
    }
};

#endif