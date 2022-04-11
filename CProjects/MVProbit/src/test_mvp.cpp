
#include <iostream>
#include "mvp.hpp"

int main()
{
    cout << " Test mvp" << endl;
    int N = 100;
    int p = 2;
    int K = 4;
    MatrixXd B0 = MatrixXd::Identity((p + 1) * K, (p + 1) * K);
    RowVectorXd b0((p + 1) * K);
    b0.setZero();
    MatrixXd xt = normrnd(0, 1, N * K, p);
    MatrixXd Xt(K * N, p + 1);
    Xt << VectorXd::Ones(K * N), xt;
    VectorXd beta(p + 1);
    beta << 1, 1, 1;
    MatrixXd zt = Xt * beta + normrnd(0, 1, N * K, 1);
    zt.resize(K, N);
    MatrixXd yt(K, N);
    for (int i = 0; i < N; ++i)
    {
        for (int j = 0; j < K; ++j)
        {
            if (zt(j, i) > 0)
            {
                yt(j, i) = 1;
            }
            else
            {
                yt(j, i) = 0;
            }
        }
    }
    int blocks = K - 1;
    std::vector<VectorXd> s0;
    std::vector<MatrixXd> S0;
    s0.resize(blocks);
    S0.resize(blocks);
    int dim;
    for (int i = 0; i < K - 1; ++i)
    {
        dim = (K - 1) - i;
        s0[i] = VectorXd::Zero(dim);
        S0[i] = MatrixXd::Identity(dim, dim);
    }

    MVP mv;
    double optim_options[5] = {1e-5, 1e-4, 1e-4, 1e-4, 20};
    Optimize optim(optim_options);
    mv.setModel(yt, Xt, beta.replicate(K, 1), b0, B0, s0, S0, optim);

    mv.runModel(100, 10);
    mv.ml();
    return 1;
}