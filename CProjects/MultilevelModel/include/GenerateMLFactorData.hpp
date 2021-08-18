#ifndef DGPML_H
#define DGPML_H
#include <map>
#include <eigen-3.3.9/Eigen/Dense>
#include <eigen-3.3.9/unsupported/Eigen/KroneckerProduct>
#include "Distributions.hpp"
#include "MultilevelModel.hpp"

using namespace Eigen;
using namespace std;
class GenerateMLFactorData
{
    /* betas will be same for every equation, 
    X should be stacked over T
    gammas should include greatest lag in 0th column, stacked over equations
    loadings should be a matrix equaling the number of equaitons in the row dimension
    factors will be nFactors = rows time = cols */
public:
    int T;
    int K;
    int nFactors;
    int nEqnsP;
    VectorXd betas;
    MatrixXd Xt;
    MatrixXd surX;
    VectorXd allBetas;
    MatrixXd Xbeta;
    MatrixXd Identity;
    MatrixXd gammas;
    VectorXd factorVariances;
    MatrixXd Loadings;
    MatrixXd P0;
    MatrixXd FactorPrecision;
    MatrixXd Factors;
    MatrixXd AF;
    MatrixXd mu;
    MatrixXd epsilon;
    MatrixXd yt;
    VectorXd om_variance;
    VectorXd om_precision;
    MatrixXd b0;
    MatrixXd B0;
    MatrixXd H;
    MatrixXd resids;
    GenerateMLFactorData(int nObs, int nEqns, const VectorXd &coeffValues,
                         const map<string, Matrix<int, 1, 2>> &InfoMap,
                         const VectorXd &factorCoeff,
                         const MatrixXd &_Loadings, const double &omVar);

    void setLoadings(const Ref<const MatrixXd> &A, const map<string, Matrix<int, 1, 2>> &InfoMap,
                     MatrixXd &Identity, double restriction)
    {

        Loadings = A;
        int c = 0;
        for (auto m = InfoMap.begin(); m != InfoMap.end(); ++m)
        {

            Loadings(m->second(0), c) = restriction;
            ++c;
        }
        Loadings = Identity.array() * Loadings.array();
    }
};
#endif 
