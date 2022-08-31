#ifndef MVP_H
#define MVP_H
#include <Eigen/Dense>

#include "Distributions.hpp"
#include "EigenTools.hpp"
#include "FullConditionals.hpp"
#include "IntegratedLikelihood.hpp"
#include "Optimization.hpp"
using namespace Eigen;
using namespace std;

template <typename Tz, typename Ty, typename Tm>
void drawLatentData(MatrixBase<Tz> &zt, const MatrixBase<Ty> &yt,
                    const MatrixBase<Tm> &mut) {
  int K = zt.rows();
  int T = zt.cols();
  VectorXd ytt(K), mutt(K);
  double condmean;
  for (int t = 0; t < T; ++t) {
    ytt = yt.col(t);
    mutt = mutt.col(t);
    for (int k = 0; k < K; ++k) {
      if (ytt(k) > 0) {
        zt(k, t) = NormalTruncatedPositive(mutt(k), 1, 1).value();
      } else {
        zt(k, t) = -NormalTruncatedPositive(-mutt(k), 1, 1).value();
      }
    }
  }
}

class MVP : public LoadingsFactorTools,
            public BetaParameterTools,
            public SurBetaUpdater,
            public FullConditionals {
 public:
  std::vector<VectorXd> BetaPosterior;
  std::vector<MatrixXd> SigmaPosterior;
  std::vector<VectorXd> s0;
  std::vector<MatrixXd> S0;
  std::vector<VectorXd> BetaJ;

  MatrixXd surX;
  RowVectorXd b0;
  MatrixXd B0;
  MatrixXd Ft;
  MatrixXd Loadings;
  MatrixXd Af;
  MatrixXd yt;
  MatrixXd zt;
  MatrixXd Xt;
  MatrixXd gammas;
  VectorXd beta;
  int Sims;
  int burnin;
  Optimize optim;
  double tune1 = 1.;
  Matrix<int, Dynamic, 2> InfoMat;
  std::vector<MatrixXd> Xtk;

  int sigmaAcceptance = 0;

  void setModel(const MatrixXd &yt, const MatrixXd &zt, const MatrixXd &Xt,
                const VectorXd &beta, const RowVectorXd &b0, const MatrixXd &B0,
                const std::vector<VectorXd> &s0,
                const std::vector<MatrixXd> &S0, Optimize &optim,
                double tune1) {
    int K = yt.rows();
    surX = surForm(Xt, K);
    this->Xt = Xt;
    this->yt = yt;
    this->zt = zt;
    this->b0 = b0;
    this->B0 = B0;
    this->beta = beta;
    this->s0 = s0;
    this->S0 = S0;
    this->optim = optim;
    this->tune1 = tune1;
  }

  void setModel(const MatrixXd &yt, const MatrixXd &Xt, const VectorXd &beta,
                const MatrixXd &Loadings, const MatrixXd &Ft,
                const MatrixXd gammas, const RowVectorXd &b0,
                const MatrixXd &B0, const Matrix<int, Dynamic, 2> &InfoMat) {
    this->b0 = b0;
    this->B0 = B0;
    this->Loadings = Loadings;
    this->Ft = Ft;
    this->yt = yt;
    this->Xt = Xt;
    this->beta = beta;
    Af = Loadings * Ft;
    this->InfoMat = InfoMat;
    Xtk.resize(yt.rows());
    this->gammas = gammas;
  }

  void runModel(int Sims, int burnin) {
    // Chib Greenberg method
    this->Sims = Sims;
    this->burnin = burnin;
    BetaPosterior.resize(Sims - burnin);
    SigmaPosterior.resize(Sims - burnin);
    int K = yt.rows();
    int T = yt.cols();
    int blocks = 2;
    MatrixXd Sigma = MatrixXd::Identity(K, K);
    Sigma = CreateSigma(0, K);
    VectorXd guess(K - 1);
    MatrixXd Xbeta = surX * beta;
    Xbeta.resize(K, T);
    for (int i = 0; i < Sims; ++i) {
      cout << "Sim " << i + 1 << endl;
      for (int t = 0; t < T; ++t) {
        zt.col(t) = mvtnrnd(zt.col(t).transpose(), yt.col(t).transpose(),
                            Xbeta.col(t).transpose(), Sigma, 1, 0);
      }
      updateSurBeta(zt, surX, Sigma, b0, B0);
      Xbeta = surX * bnew.transpose();
      Xbeta.resize(K, T);
      updateSigma(zt, Xbeta, Sigma, optim);
      if (i >= burnin) {
        BetaPosterior[i - burnin] = bnew.transpose();
        SigmaPosterior[i - burnin] = Sigma;
      }
    }
    cout << mean(BetaPosterior) << endl;
    cout << mean(SigmaPosterior) << endl;
    cout << "Sigma Acceptance Rate " << sigmaAcceptance / (double)Sims << endl;
  }

  void runFactorModel(int Sims, int burnin) {
    // New method
    this->Sims = Sims;
    this->burnin = burnin;
    int K = yt.rows();
    int T = yt.cols();
    int nXs = Xt.cols();
    int nFactors = InfoMat.rows();
    MatrixXd Xtfull(K * T, nXs + nFactors);
    Xtfull.rightCols(levels) = packageFactorsInXt(InfoMat, Ft, K);
    surX = surForm(Xtfull, K);
    Sigma = MatrixXd::Identity(K, K);
    for (int i = 0; i < Sims; ++i) {
      cout << "Sim " << i + 1 << endl;
      for (int t = 0; t < T; ++t) {
        zt.col(t) = mvtnrnd(zt.col(t).transpose(), yt.col(t).transpose(),
                            Xbeta.col(t).transpose(), Sigma, 1, 0);
      }
      updateSurBeta(zt, surX, Sigma, b0, B0);
      Xbeta = surX * bnew.transpose();
      Xbeta.resize(K, T);
      MatrixXd btemp = bnew; 
      btemp.resize(K, nFactors + nXs);
      Ft = updateFactor2(Ft, zt, Xtfull, InfoMat, btemp, 1, 1, gammas);
    
      if (i >= burnin) {
      }
    }
  }

  template <typename T1, typename T2, typename T3>
  void updateSigma(const MatrixBase<T1> &zt, const MatrixBase<T2> &Xbeta,
                   MatrixBase<T3> &Sigma, Optimize &optim) {
    int K = zt.rows();
    int T = zt.cols();
    int df = 12;
    double w, num, den, alpha;
    VectorXd guess;
    MatrixXd mu(K, T);
    mu = zt - Xbeta;
    MatrixXd H;
    MatrixXd S = Sigma;
    VectorXd proposal;
    VectorXd proposalMean;
    vector<VectorXd> storeProposalMeans(K - 1);
    vector<MatrixXd> storeH(K - 1);
    for (int column = 0; column < (K - 1); ++column) {
      w = chi2rnd(df);
      w = sqrt(w / df);
      guess = Sigma.col(column).tail(K - (column + 1));
      proposalMean = guess;
      auto SLL = [&column, &mu, &Sigma, this](const VectorXd &x0) {
        return -SigmaLogLikelihood(x0, column, mu, Sigma, s0[column],
                                   S0[column]);
      };
      optim.BFGS(proposalMean, SLL, 0);
      if (optim.flag == 1) {
        optim.flag = 0;
        proposalMean.setZero();
        optim.BFGS(proposalMean, SLL, 0);
      }
      storeProposalMeans[column] = proposalMean;
      H = optim.ApproximateHessian(proposalMean, SLL);
      H = tune1 * H.llt().solve(MatrixXd::Identity(H.rows(), H.cols()));
      storeH[column] = (H.diagonal()).asDiagonal();
      proposal =
          proposalMean + (H.llt().matrixL() * normrnd(0, 1, H.rows(), 1)) / w;
      S.col(column).tail(proposal.size()) = proposal;
      S.row(column).tail(proposal.size()) = proposal.transpose();
    }
    VectorXd sigPrior = VectorXd::Zero(S.rows() * (S.rows() - 1) / 2);
    MatrixXd SigPrior = .5 * MatrixXd::Identity(S.rows() * (S.rows() - 1) / 2,
                                                S.rows() * (S.rows() - 1) / 2);
    if (isPD(S)) {
      proposal = vech(S);
      VectorXd guessvech = vech(Sigma);
      VectorXd pmeans = flattenVectorVector(storeProposalMeans);
      MatrixXd pcovars = flattenVectorMatrix(storeH);
      num = -SigmaLogLikelihood(proposal, mu, S, sigPrior, SigPrior) +
            logmvtpdf(guessvech.transpose(), pmeans.transpose(), pcovars, df);
      den = -SigmaLogLikelihood(guessvech, mu, Sigma, sigPrior, SigPrior) +
            logmvtpdf(proposal.transpose(), pmeans.transpose(), pcovars, df);
      alpha = min(0.0, num - den);
      if (log(unifrnd(0, 1)) < alpha) {
        sigmaAcceptance++;
        Sigma = S;
      }
    }
  }

  VectorXd flattenVectorVector(const std::vector<VectorXd> &Y) {
    int k = ((Y[0].size() + 1) * Y[0].size()) / 2;
    VectorXd flat(k);
    int h = 0;
    for (auto it = Y.begin(); it != Y.end(); ++it) {
      for (int i = 0; i < it->size(); ++i) {
        flat(h) = (*it)(i);
        ++h;
      }
    }
    return flat;
  }

  MatrixXd flattenVectorMatrix(const std::vector<MatrixXd> &Y) {
    int s = 0;
    for (auto it = Y.begin(); it != Y.end(); ++it) {
      s += it->rows();
    }
    MatrixXd flat = MatrixXd::Zero(s, s);
    int r = 0;
    int c = 0;
    for (auto it = Y.begin(); it != Y.end(); ++it) {
      flat.block(r, c, it->rows(), it->cols()) = *it;
      r += it->rows();
      c += it->cols();
    }
    return flat;
  }

  double SigmaLogLikelihood(const VectorXd &guess, const int column,
                            const MatrixXd &mu, const MatrixXd &Sigma,
                            const VectorXd &guesspriorMean,
                            const MatrixXd &guesspriorVar) {
    MatrixXd S = Sigma;
    S.col(column).tail(guess.size()) = guess;
    S.row(column).tail(guess.size()) = guess.transpose();
    MatrixXd S0inv = guesspriorVar.llt().solve(
        MatrixXd::Identity(guesspriorVar.rows(), guesspriorVar.cols()));
    int K = mu.rows();
    int T = mu.cols();
    MatrixXd Precision =
        S.llt().solve(MatrixXd::Identity(Sigma.rows(), Sigma.cols()));
    double tmu = -.5 * ((guess - guesspriorMean).transpose() * S0inv *
                        (guess - guesspriorMean))
                           .value();
    tmu += (-.5 * T) * logdet(S);
    if (isnan(tmu)) {
      return -1e14;
    } else {
      for (int t = 0; t < T; ++t) {
        tmu += -.5 * (mu.col(t).transpose() * Precision * mu.col(t)).value();
      }
      return tmu;
    }
  }

  double SigmaLogLikelihood(const VectorXd &guess, const MatrixXd &mu,
                            const MatrixXd &Sigma,
                            const VectorXd &guesspriorMean,
                            const MatrixXd &guesspriorVar) {
    MatrixXd S0inv = guesspriorVar.llt().solve(
        MatrixXd::Identity(guesspriorVar.rows(), guesspriorVar.cols()));
    int K = mu.rows();
    int T = mu.cols();
    MatrixXd Precision =
        Sigma.llt().solve(MatrixXd::Identity(Sigma.rows(), Sigma.cols()));
    double tmu = -.5 * ((guess - guesspriorMean).transpose() * S0inv *
                        (guess - guesspriorMean))
                           .value();
    tmu += (-.5 * T) * logdet(Sigma);
    if (isnan(tmu)) {
      return -1e14;
    } else {
      for (int t = 0; t < T; ++t) {
        tmu += -.5 * (mu.col(t).transpose() * Precision * mu.col(t)).value();
      }
      return tmu;
    }
  }

  double alphaG() {
    int K = yt.rows();
    int T = yt.cols();
    MatrixXd zt(K, T);
    zt.setZero();
    VectorXd gdraws((Sims - burnin) * (K - 1));
    int c = 0;
    MatrixXd SigmaStar = mean(SigmaPosterior);
    VectorXd BetaStar = mean(BetaPosterior);
    MatrixXd Xbeta = surX * BetaStar;
    Xbeta.resize(K, T);
    MatrixXd H;
    VectorXd proposal;
    MatrixXd Sigma;
    VectorXd guess;
    VectorXd proposalMean;
    MatrixXd mu(K, T);
    vector<VectorXd> storeProposalMeans(K - 1);
    vector<MatrixXd> storeH(K - 1);
    int df = 12;
    double w, num, den, alpha;
    for (int r = 0; r < (Sims - burnin); ++r) {
      cout << "G runs " << r + 1 << endl;
      Sigma = SigmaPosterior[r];
      mu = zt - Xbeta;
      for (int t = 0; t < T; ++t) {
        zt.col(t) = mvtnrnd(zt.col(t).transpose(), yt.col(t).transpose(),
                            Xbeta.col(t).transpose(), Sigma, 1, 0);
      }
      Xbeta = surX * BetaPosterior[r];
      Xbeta.resize(K, T);
      for (int column = 0; column < (K - 1); ++column) {
        w = chi2rnd(df);
        w = sqrt(w / df);
        guess = Sigma.col(column).tail(K - (column + 1));
        proposalMean = guess;
        proposal = SigmaStar.col(column).tail(K - (column + 1));
        auto SLL = [&column, &mu, &Sigma, this](const VectorXd &x0) {
          return -SigmaLogLikelihood(x0, column, mu, Sigma, s0[column],
                                     S0[column]);
        };
        optim.BFGS(proposalMean, SLL, 0);
        storeProposalMeans[column] = proposalMean;
        if (optim.flag == 1) {
          optim.flag = 0;
          proposalMean.setZero();
          optim.BFGS(proposalMean, SLL, 0);
        }
        H = optim.ApproximateHessian(proposalMean, SLL);
        H = H.llt().solve(MatrixXd::Identity(H.rows(), H.cols()));
        storeH[column] = (H.diagonal()).asDiagonal();
      }
      VectorXd sigPrior = VectorXd::Zero(Sigma.rows() * (Sigma.rows() - 1) / 2);
      MatrixXd SigPrior =
          .5 * MatrixXd::Identity(Sigma.rows() * (Sigma.rows() - 1) / 2,
                                  Sigma.rows() * (Sigma.rows() - 1) / 2);

      proposal = vech(SigmaStar);
      VectorXd guessvech = vech(Sigma);
      VectorXd pmeans = flattenVectorVector(storeProposalMeans);
      MatrixXd pcovars = flattenVectorMatrix(storeH);
      num = -SigmaLogLikelihood(proposal, mu, SigmaStar, sigPrior, SigPrior) +
            logmvtpdf(guessvech.transpose(), pmeans.transpose(), pcovars, df);
      den = -SigmaLogLikelihood(guessvech, mu, Sigma, sigPrior, SigPrior) +
            logmvtpdf(proposal.transpose(), pmeans.transpose(), pcovars, df);
      alpha = min(0.0, num - den);
      gdraws(c) = alpha + logmvtpdf(proposal.transpose(), pmeans.transpose(),
                                    pcovars, df);
      ++c;
    }
    return logavg(gdraws);
  }

  double alphaJ() {
    int K = yt.rows();
    int T = yt.cols();
    MatrixXd zt(K, T);
    zt.setZero();
    MatrixXd SigmaStar = mean(SigmaPosterior);
    VectorXd BetaStar = mean(BetaPosterior);
    MatrixXd Xbeta = surX * BetaStar;
    Xbeta.resize(K, T);
    int df = 12;
    double w, num, den, alpha;
    VectorXd sstar;
    MatrixXd mu(K, T);
    mu = zt - Xbeta;
    MatrixXd H;
    MatrixXd S;
    VectorXd proposal;
    MatrixXd Sigma = SigmaStar;
    VectorXd jdraws((Sims - burnin) * (K - 1));
    int c = 0;
    std::vector<VectorXd> sstarmean;
    std::vector<MatrixXd> Sstarvar;
    sstarmean.resize(K - 1);
    Sstarvar.resize(K - 1);
    for (int column = 0; column < K - 1; ++column) {
      sstar = SigmaStar.col(column).tail(K - (column + 1));
      proposal = sstar;
      auto SLL = [&column, &mu, &SigmaStar, this](const VectorXd &x0) {
        return -SigmaLogLikelihood(x0, column, mu, SigmaStar, s0[column],
                                   S0[column]);
      };
      optim.BFGS(proposal, SLL, 0);
      H = optim.ApproximateHessian(proposal, SLL);
      H = H.llt().solve(MatrixXd::Identity(H.rows(), H.cols()));
      sstarmean[column] = proposal;
      Sstarvar[column] = H;
    }
    for (int r = 0; r < (Sims - burnin); ++r) {
      cout << "J runs " << r + 1 << endl;
      for (int t = 0; t < T; ++t) {
        zt.col(t) = mvtnrnd(zt.col(t).transpose(), yt.col(t).transpose(),
                            Xbeta.col(t).transpose(), SigmaStar, 1, 0);
      }
      updateSurBeta(zt, surX, SigmaStar, b0, B0);
      BetaJ[r] = bnew.transpose();
      Xbeta = surX * BetaJ[r];
      Xbeta.resize(K, T);
      for (int column = 0; column < (K - 1); ++column) {
        w = chi2rnd(df);
        w = sqrt(w / df);
        S = SigmaStar;
        sstar = SigmaStar.col(column).tail(K - (column + 1));
        proposal =
            sstarmean[column] + (Sstarvar[column].llt().matrixL() *
                                 normrnd(0, 1, Sstarvar[column].rows()) / w);
        Sigma.col(column).tail(proposal.size()) = proposal;
        Sigma.row(column).tail(proposal.size()) = proposal.transpose();
      }
      sstar = vech(SigmaStar);
      proposal = vech(Sigma);
      VectorXd flatsstar = flattenVectorVector(sstarmean);
      MatrixXd flatSstar = flattenVectorMatrix(Sstarvar);
      VectorXd sigPrior = VectorXd::Zero(S.rows() * (S.rows() - 1) / 2);
      MatrixXd SigPrior =
          .5 * MatrixXd::Identity(S.rows() * (S.rows() - 1) / 2,
                                  S.rows() * (S.rows() - 1) / 2);
      num = -SigmaLogLikelihood(proposal, mu, Sigma, sigPrior, SigPrior) +
            logmvtpdf(sstar.transpose(), flatsstar.transpose(), flatSstar, df);
      den =
          -SigmaLogLikelihood(sstar, mu, SigmaStar, sigPrior, SigPrior) +
          logmvtpdf(proposal.transpose(), flatsstar.transpose(), flatSstar, df);
      jdraws(c) = min(0.0, num - den);
      ++c;
    }
    return logavg(jdraws);
  }

  double ml() {
    BetaJ.resize(Sims - burnin);
    int K = yt.rows();
    int T = yt.cols();
    MatrixXd Xbeta(K * T, 1);

    VectorXd betaStar = mean(BetaPosterior);
    MatrixXd SigmaStar = mean(SigmaPosterior);

    Xbeta = surX * betaStar;
    Xbeta.resize(K, T);
    MatrixXd zt(K, T);
    zt.setZero();
    double pstar = alphaG() - alphaJ();
    VectorXd pibeta(Sims - burnin);
    MatrixXd ztstar(K, T);
    for (int r = 0; r < (Sims - burnin); ++r) {
      for (int t = 0; t < T; ++t) {
        zt.col(t) = mvtnrnd(zt.col(t).transpose(), yt.col(t).transpose(),
                            Xbeta.col(t).transpose(), SigmaStar, 1, 0);
      }
      ztstar += zt;
      pibeta(r) = surBetaReducedRun(betaStar, zt, surX, SigmaStar, b0, B0);
    }
    pstar += logavg(pibeta);
    ztstar = ztstar.array() / (Sims - burnin);
    MatrixXd mu = ztstar - Xbeta;
    double like = surLikelihood(mu, SigmaStar);
    double betaprior = logmvnpdf(betaStar.transpose(), b0, B0);
    double sigmaprior = 0;
    VectorXd sstar;
    for (int column = 0; column < K - 1; ++column) {
      sstar = SigmaStar.col(column).tail(K - (column + 1));
      sigmaprior += logmvnpdf(sstar.transpose(), s0[column].transpose(),
                              S0[column].transpose());
    }
    cout << "Likelihood " << like << endl;
    cout << "betaprior " << betaprior << endl;
    cout << "sigmaprior " << sigmaprior << endl;
    cout << "pstar " << pstar << endl;
    double ml = like + betaprior + sigmaprior - pstar;
    cout << "Marginal Likelihood " << ml << endl;
    return ml;
  }
};

#endif
