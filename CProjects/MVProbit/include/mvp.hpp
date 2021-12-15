#ifndef MVP_H
#define MVP_H
#include <Eigen/Dense>
#include "Distributions.hpp"
#include "EigenTools.hpp"
#include "IntegratedLikelihood.hpp"

using namespace Eigen;
using namespace std;

template <typename Tz, typename Ty, typename Tm>
void drawLatentData(MatrixBase<Tz> &zt, const MatrixBase<Ty> &yt, const MatrixBase<Tm> &mut)
{
    int K = zt.rows();
    int T = zt.cols();
    VectorXd ytt(K), mutt(K);
    double condmean;
    for (int t = 0; t < T; ++t)
    {
        ytt = yt.col(t);
        mutt = mutt.col(t);
        for (int k = 0; k < K; ++k)
        {
            if (ytt(k) > 0)
            {
                zt(k, t) = NormalTruncatedPositive(mutt(k), 1, 1).value();
            }
            else
            {
                zt(k, t) = -NormalTruncatedPositive(-mutt(k), 1, 1).value();
            }
        }
    }
}

class mvp : public LoadingsFactorTools, public BetaParameterTools
{
public:
    std::vector<MatrixXd> BetaPosterior;

    MatrixXd surX;
    MatrixXd Xbeta;
    RowVectorXd b0;
    MatrixXd B0;
    MatrixXd Ft; 
    MatrixXd Loadings; 
    MatrixXd Af; 

    void setModel(const MatrixXd &yt, const MatrixXd &Xt, const VectorXd &beta, const MatrixXd &Loadings, const MatrixXd &Ft,
                  const RowVectorXd &b0, const MatrixXd &B0, const double a0, const double A0, const Matrix<int, Dynamic, 2> &InfoMat)
    {
        int K = yt.rows();
        surX = surForm(Xt, K);
        Xbeta = surX * beta;
        this->b0 = b0;
        this->B0 = B0;
        this->Loadings = Loadings; 
        this->Ft = Ft; 
        Af = Loadings*Ft; 
        setPriors(a0, A0, InfoMat);
        
    }

    void runModel(int Sims, int burnin)
    {
        BetaPosterior.resize(Sims - burnin);
        for (int i = 0; i < Sims; ++i)
        {
            betaUpdater
            if (i > burnin)
            {
            }
        }
    }
};

#endif