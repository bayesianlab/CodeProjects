#ifndef MVP_H
#define MVP_H
#include <Eigen/Dense>
#include "Distributions.hpp"
#include "EigenTools.hpp"
#include "IntegratedLikelihood.hpp"
#include "Optimization.hpp"
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

class MVP : public LoadingsFactorTools, public BetaParameterTools, public BayesBetaUpdater
{
public:
    std::vector<VectorXd> BetaPosterior;
    std::vector<MatrixXd> SigmaPosterior;
    std::vector<VectorXd> s0;
    std::vector<MatrixXd> S0;

    MatrixXd surX;
    RowVectorXd b0;
    MatrixXd B0;
    MatrixXd Ft;
    MatrixXd Loadings;
    MatrixXd Af;
    MatrixXd yt;
    VectorXd beta;
    int RedRuns;

    void setModel(const MatrixXd &yt, const MatrixXd &Xt, const VectorXd &beta, const RowVectorXd &b0,
                  const MatrixXd &B0, const std::vector<VectorXd> &s0, const std::vector<MatrixXd> &S0)
    {
        int K = yt.rows();
        surX = surForm(Xt, K);
        this->yt = yt;
        this->b0 = b0;
        this->B0 = B0;
        this->beta = beta;
        this->s0 = s0;
        this->S0 = S0;
    }

    void setModel(const MatrixXd &yt, const MatrixXd &Xt, const VectorXd &beta, const MatrixXd &Loadings, const MatrixXd &Ft,
                  const RowVectorXd &b0, const MatrixXd &B0, const double a0, const double A0, const Matrix<int, Dynamic, 2> &InfoMat)
    {
        int K = yt.rows();
        surX = surForm(Xt, K);
        this->b0 = b0;
        this->B0 = B0;
        this->Loadings = Loadings;
        this->Ft = Ft;
        this->yt = yt;
        this->beta = beta;
        Af = Loadings * Ft;
        // setPriors(a0, A0, InfoMat);
    }

    void runModel(int Sims, int burnin)
    {
        RedRuns = Sims - burnin;
        BetaPosterior.resize(Sims - burnin);
        SigmaPosterior.resize(Sims - burnin);
        int K = yt.rows();
        int T = yt.cols();
        int blocks = 2;
        MatrixXd zt(K, T);
        MatrixXd Sigma = MatrixXd::Identity(K, K);
        zt.setZero(K, T);
        Sigma = CreateSigma(.2, K);
        VectorXd guess(K - 1);
        double optim_options[5] = {1e-5, 1e-4, 1e-4, 1e-4, 20};
        Optimize optim(optim_options);
        int column = 0;
        MatrixXd Xbeta = surX * beta;
        Xbeta.resize(K, T);
        for (int i = 0; i < Sims; ++i)
        {
            for (int t = 0; t < T; ++t)
            {
                zt.col(t) = mvtnrnd(zt.col(t).transpose(), yt.col(t).transpose(), Xbeta.col(t).transpose(),
                                    Sigma, 1, 0);
            }
            updateSurBeta(zt, surX, Sigma, b0, B0);
            updateSigma(zt, Xbeta, Sigma, s0, S0, optim);
            if (i >= burnin)
            {
                BetaPosterior[i - burnin] = bnew.transpose();
                SigmaPosterior[i - burnin] = Sigma;
            }
        }
        cout << mean(BetaPosterior) << endl;
        cout << mean(SigmaPosterior) << endl;
    }

    template <typename T1, typename T2, typename T3>
    void updateSigma(const MatrixBase<T1> &zt, const MatrixBase<T2> &Xbeta, MatrixBase<T3> &Sigma,
                     const std::vector<VectorXd> &s0, const std::vector<MatrixXd> &S0, Optimize &optim)
    {
        int K = zt.rows();
        int T = zt.cols();
        int df = 12;
        double w, num, den, alpha;
        VectorXd guess;
        MatrixXd mu(K, T);
        mu = zt - Xbeta;
        MatrixXd H;
        MatrixXd S;
        VectorXd proposal;

        for (int column = 0; column < (K - 1); ++column)
        {
            w = chi2rnd(df);
            w = sqrt(w / df);
            guess = Sigma.col(column).tail(K - (column + 1));
            proposal = guess;
            auto SLL = [&column, &mu, &Sigma, &s0, &S0, this](const VectorXd &x0)
            {
                return -SigmaLogLikelihood(x0, column, mu, Sigma, s0[column], S0[column]);
            };
            optim.BFGS(proposal, SLL, 1);
            H = optim.ApproximateHessian(proposal, SLL);
            H = H.llt().solve(MatrixXd::Identity(H.rows(), H.cols()));
            S = Sigma;
            proposal = (proposal + (H.llt().matrixL() * normrnd(0, 1, H.rows()) / w));
            S.col(column).tail(proposal.size()) = proposal;
            S.row(column).tail(proposal.size()) = proposal.transpose();
            num = -SigmaLogLikelihood(proposal, column, mu, S, s0[column], S0[column]) + logmvtpdf(guess, s0[column], S0[column], df);
            den = -SigmaLogLikelihood(guess, column, mu, S, s0[column], S0[column]) + logmvtpdf(proposal, s0[column], S0[column], df);
            alpha = min(0.0, num - den);
            if (log(unifrnd(0, 1)) < alpha)
            {
                Sigma = S;
            }
        }
    }

    template <typename T1, typename T2, typename T3>
    double alphaG(const MatrixBase<T1> &zt, const MatrixBase<T2> &Xbeta,
                  const std::vector<VectorXd> &s0, const std::vector<MatrixXd> &S0, Optimize &optim)
    {
        VectorXd gdraws(RedRuns * (K - 1));
        int c = 0;
        for (int r = 0; r < RedRuns; ++r)
        {
            MatrixXd Sigma = SigmaPosterior[r];
            int K = zt.rows();
            int T = zt.cols();
            int df = 12;
            double w, num, den, alpha;
            VectorXd guess;
            MatrixXd mu(K, T);
            mu = zt - Xbeta;
            MatrixXd H;
            MatrixXd S;
            VectorXd proposal;
            for (int column = 0; column < (K - 1); ++column)
            {
                ++c;
                w = chi2rnd(df);
                w = sqrt(w / df);
                guess = Sigma.col(column).tail(K - (column + 1));
                proposal = guess;
                auto SLL = [&column, &mu, &Sigma, &s0, &S0, this](const VectorXd &x0)
                {
                    return -SigmaLogLikelihood(x0, column, mu, Sigma, s0[column], S0[column]);
                };
                optim.BFGS(proposal, SLL, 1);
                H = optim.ApproximateHessian(proposal, SLL);
                H = H.llt().solve(MatrixXd::Identity(H.rows(), H.cols()));
                S = Sigma;
                proposal = (proposal + (H.llt().matrixL() * normrnd(0, 1, H.rows()) / w));
                S.col(column).tail(proposal.size()) = proposal;
                S.row(column).tail(proposal.size()) = proposal.transpose();
                num = -SigmaLogLikelihood(proposal, column, mu, S, s0[column], S0[column]) + logmvtpdf(guess, s0[column], S0[column], df);
                den = -SigmaLogLikelihood(guess, column, mu, S, s0[column], S0[column]) + logmvtpdf(proposal, s0[column], S0[column], df);
                alpha = min(0.0, num - den);
                gdraws(c) = alpha + logmvtpdf(guess, s0[column], S0[column], df);
            }
        }
        return logavg(gdraws);
    }

    template <typename T1, typename T2, typename T3>
    double alphaJ(const MatrixBase<T1> &zt, const MatrixBase<T2> &Xbeta,
                  const std::vector<VectorXd> &s0, const std::vector<MatrixXd> &S0, Optimize &optim)
    {
        VectorXd gdraws(RedRuns * (K - 1));
        int c = 0;
        MatrixXd SigmaStar = mean(SigmaPosterior);
        // std vectors for holding the maximized values of Sigma Star
        // Run that once and calc alpha based on that, 
        // use the maximized values to produce j draws
        for (int r = 0; r < RedRuns; ++r)
        {
            MatrixXd Sigma = SigmaPosterior[r];
            int K = zt.rows();
            int T = zt.cols();
            int df = 12;
            double w, num, den, alpha;
            VectorXd guess;
            MatrixXd mu(K, T);
            mu = zt - Xbeta;
            MatrixXd H;
            MatrixXd S;
            VectorXd proposal;
            for (int column = 0; column < (K - 1); ++column)
            {
                ++c;
                w = chi2rnd(df);
                w = sqrt(w / df);
                guess = Sigma.col(column).tail(K - (column + 1));
                proposal = guess;
                auto SLL = [&column, &mu, &Sigma, &s0, &S0, this](const VectorXd &x0)
                {
                    return -SigmaLogLikelihood(x0, column, mu, Sigma, s0[column], S0[column]);
                };
                optim.BFGS(proposal, SLL, 1);
                H = optim.ApproximateHessian(proposal, SLL);
                H = H.llt().solve(MatrixXd::Identity(H.rows(), H.cols()));
                S = Sigma;
                proposal = (proposal + (H.llt().matrixL() * normrnd(0, 1, H.rows()) / w));
                S.col(column).tail(proposal.size()) = proposal;
                S.row(column).tail(proposal.size()) = proposal.transpose();
                num = -SigmaLogLikelihood(proposal, column, mu, S, s0[column], S0[column]) + logmvtpdf(guess, s0[column], S0[column], df);
                den = -SigmaLogLikelihood(guess, column, mu, S, s0[column], S0[column]) + logmvtpdf(proposal, s0[column], S0[column], df);
                alpha = min(0.0, num - den);
                gdraws(c) = alpha + logmvtpdf(guess, s0[column], S0[column], df);
            }
        }
    }

    double SigmaLogLikelihood(const VectorXd &guess, const int column, const MatrixXd &mu, const MatrixXd &Sigma, const VectorXd &guesspriorMean,
                              const MatrixXd &guesspriorVar)
    {
        MatrixXd S = Sigma;
        VectorXd old = guess;
        S.col(column).tail(guess.size()) = guess;
        S.row(column).tail(guess.size()) = guess.transpose();
        MatrixXd S0inv = guesspriorVar.llt().solve(MatrixXd::Identity(guesspriorVar.rows(), guesspriorVar.cols()));
        int K = mu.rows();
        int T = mu.cols();
        MatrixXd Precision = S.llt().solve(MatrixXd::Identity(Sigma.rows(), Sigma.cols()));
        int c1 = 0;
        double tmu = -.5 * ((guess - guesspriorMean).transpose() * S0inv * (guess - guesspriorMean)).value();
        tmu += (-.5 * K) * logdet(S);
        if (isnan(tmu))
        {
            return -1e14;
        }
        else
        {
            for (int t = 0; t < T; ++t)
            {
                tmu += -.5 * (mu.col(t).transpose() * Precision * mu.col(t)).value();
                c1 += K;
            }
            return tmu;
        }
    }

    void ml()
    {
    }
};

#endif
