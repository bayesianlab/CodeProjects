#include "MultilevelModelFunctions.hpp"

MatrixXd makeOtrokXt(const Matrix<int, Dynamic, 2> &InfoMat,  const Ref<MatrixXd> &Factors,
                     const int &nXs, const int &K)
{
    int start;
    int start2 = 0;
    int nrows;
    int nFactors = Factors.rows();
    int T = Factors.cols();
    MatrixXd Xt; 
    Xt.setZero(K*T, nFactors);
    for (int t = 0; t < T; ++t)
    {
        for (int i = 0; i < nFactors; ++i)
        {
            start = InfoMat.row(i).head(1).value();
            nrows = InfoMat.row(i).tail(1).value() - start + 1;
            Xt.col(i).middleRows(start + start2, nrows) = Factors.row(i).col(t).replicate(nrows, 1);
        }
        start2 += K;
    }
    return Xt;
}

VectorXd var(const Ref<const MatrixXd> &A, int row_col)
{
    MatrixXd centered = (A.colwise() - A.rowwise().mean()).array().pow(2);
    return (1. / A.cols()) * centered.rowwise().sum();
}

MatrixXd MakeObsModelIdentity(const Matrix<int, Dynamic, 2> &m, int eqns)
{
    int nFactors = m.rows();
    MatrixXd X = MatrixXd::Zero(eqns, nFactors);
    int factor = 0;
    for (int i = 0; i < nFactors; ++i)
    {
        int begin = m.row(i).head(1).value();
        int end = m.row(i).tail(1).value();
        if (end > eqns)
        {
            throw invalid_argument("In MakeObsModelIdentity, index passed number of equations.");
        }
        for (int u = begin; u <= end; ++u)
        {
            X(u, factor) = 1;
        }
        ++factor;
    }
    return X;
}

void vectorize(MatrixXd &mat)
{
    mat.resize(mat.rows() * mat.cols(), 1);
}

VectorXi sequence(int b, int e)
{
    if (e < b)
    {
        throw invalid_argument("Error in sequence, end point less than beginning.");
    }
    VectorXi c(e - b + 1);
    int h = 0;
    for (int i = b; i <= e; ++i)
    {
        c(h) = b + h;
        ++h;
    }
    return c;
}

VectorXi sequence(int b, int e, int skip)
{
    if (e < b)
    {
        throw invalid_argument("Error in sequence, end point less than beginning.");
    }
    int N = (e - b + skip) / skip;
    VectorXi c(N);
    int h = 0;
    for (int i = b; i <= e; i += skip)
    {
        c(h) = b + h * skip;
        ++h;
    }
    return c;
}

MatrixXd updateFactor(const MatrixXd &residuals, const MatrixXd &Loadings, const MatrixXd &FactorPrecision,
                      const VectorXd &precision, int T)
{
    int K = precision.size();
    int nFactors = Loadings.cols();
    int nFactorsT = nFactors * T;
    MatrixXd AtO = Loadings.transpose() * precision.asDiagonal();
    MatrixXd FplusAtOinv = FactorPrecision + kroneckerProduct(MatrixXd::Identity(T, T), AtO * Loadings);
    FplusAtOinv = FplusAtOinv.ldlt().solve(MatrixXd::Identity(FplusAtOinv.rows(), FplusAtOinv.rows()));
    MatrixXd lower = FplusAtOinv.llt().matrixL();
    MatrixXd musum = AtO * residuals;
    Map<VectorXd> vecmu(musum.data(), musum.size());
    VectorXd mu = FplusAtOinv * vecmu;
    FplusAtOinv = mu + lower * normrnd(0, 1, nFactorsT, 1);
    FplusAtOinv.resize(nFactors, T);
    return FplusAtOinv;
}