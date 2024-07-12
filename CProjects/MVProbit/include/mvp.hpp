#ifndef MVP_H
#define MVP_H
#include <Eigen/Dense>

#include "Distributions.hpp"
#include "EigenTools.hpp"
#include "FullConditionals.hpp"
#include "IntegratedLikelihood.hpp"
#include "MultilevelModelFunctions.hpp"
#include "Optimization.hpp"
#include "TimeSeriesTools.hpp"


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

MatrixXd CorrelationMatrix(const MatrixXd &X) {
  VectorXd d = X.diagonal().array().pow(-.5);
  MatrixXd D = d.asDiagonal();
  return D * X * D;
}

pair<MatrixXd, MatrixXd> AstarLstar(MatrixXd &A, const MatrixXd &Sigma) {

  MatrixXd AAT = A * A.transpose();
  MatrixXd P = AAT + Sigma;
  VectorXd d = P.diagonal().array().pow(-.5);
  MatrixXd D = d.asDiagonal();
  MatrixXd L = Sigma.llt().matrixL();
  pair<MatrixXd, MatrixXd> M;
  M.first = D * A;
  M.second = D * L;
  return M;
}

class MVP : public BetaParameterTools,
            public SurBetaUpdater,
            public FullConditionalsNoAr {
public:
  std::vector<VectorXd> BetaPosterior;
  std::vector<MatrixXd> LoadingPosterior;
  std::vector<MatrixXd> SigmaPosterior;
  std::vector<MatrixXd> FactorPosterior;
  std::vector<VectorXd> gammaPosterior;
  std::vector<MatrixXd> CorrelationPosterior;
  std::vector<VectorXd> FactorVariancePosterior;
  std::vector<VectorXd> s0;
  std::vector<MatrixXd> S0;
  std::vector<VectorXd> BetaJ;

  RowVectorXd b0;
  MatrixXd B0;
  MatrixXd Ft;
  MatrixXd yt;
  MatrixXd zt;
  MatrixXd Xt;
  MatrixXd gammas;
  RowVectorXd g0;
  MatrixXd G0;
  VectorXd beta;
  int Sims;
  int burnin;
  Optimize optim;
  double tune1 = 1.;
  Matrix<int, Dynamic, 2> InfoMat;
  std::vector<MatrixXd> Xtk;
  int sigmaAcceptance = 0;
  string path_name; 

  pair<vector<VectorXd>, vector<MatrixXd>> setPriorBlocks(int K) {
    int blocks = K - 1;
    std::vector<VectorXd> s0;
    std::vector<MatrixXd> S0;
    s0.resize(blocks);
    S0.resize(blocks);
    int dim;
    for (int i = 0; i < K - 1; ++i) {
      dim = (K - 1) - i;
      s0[i] = VectorXd::Zero(dim);
      S0[i] = MatrixXd::Identity(dim, dim);
    }
    pair<vector<VectorXd>, vector<MatrixXd>> p;
    p.first = s0;
    p.second = S0;
    return p;
  }

  void setModel(const MatrixXd &yt, const MatrixXd &zt, const MatrixXd &Xt,
                const VectorXd &beta, const RowVectorXd &b0, const MatrixXd &B0,
                const std::vector<VectorXd> &s0,
                const std::vector<MatrixXd> &S0, Optimize &optim,
                double tune1) {
    int K = yt.rows();
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
                const MatrixXd _gammas, const RowVectorXd &b0,
                const MatrixXd &B0, const Matrix<int, Dynamic, 2> &InfoMat,
                string _path_name) {
    this->b0 = b0;
    this->B0 = B0;
    this->Ft = normrnd(0, 1, InfoMat.rows(), yt.cols());
    // this->Ft = Factors; 
    this->yt = yt;
    this->Xt = Xt;
    this->beta = beta;
    this->InfoMat = InfoMat;
    Xtk.resize(yt.rows());
    this->gammas = _gammas;
    g0 = RowVectorXd::Zero(_gammas.cols());
    G0 = createArPriorCovMat(1, _gammas.cols());
    path_name = _path_name;
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
    MatrixXd surX = surForm(Xt, K);
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
    savePosterior("test.csv", BetaPosterior);
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
    int KT = K * T;
    int nFactors = InfoMat.rows();
    int QK = nFactors * K;
    int nBetas = K * (Xt.cols() + nFactors);
    int levels = calcLevels(InfoMat, K);
    MatrixXd A = MatrixXd::Ones(K, nFactors);
    Identification2(A);
    MatrixXd Sigma = MatrixXd::Identity(K, K);
    VectorXd Ik = VectorXd::Ones(K);
    MatrixXd surX = surForm(Xt, K);
    MatrixXd Xbeta = surX * beta;
    Xbeta.resize(K, T);
    MatrixXd yhat = Xbeta + A * Ft;
    zt.resize(K, T);
    for (int t = 0; t < T; ++t) {
      zt.col(t) = mvtnrnd(yhat.col(t).transpose(), yt.col(t).transpose(),
                          yhat.col(t).transpose(), Sigma, 1, 0);
    }
    VectorXd factorVariance = VectorXd::Ones(nFactors);
    double d0 = 12;
    double D0 = 12;
    RowVectorXd OneK = RowVectorXd::Ones(K);
    RowVectorXd a0 = RowVectorXd::Ones(QK);
    MatrixXd A0 = MatrixXd::Identity(QK, QK);
    MatrixXd AF;
    for (int i = 0; i < Sims; ++i) {
      cout << "Sim " << i + 1 << endl;
      AF = A * Ft;
      yhat = Xbeta + AF;
      for (int t = 0; t < T; ++t) {
        zt.col(t) = mvtnrnd(zt.col(t).transpose(), yt.col(t).transpose(),
                            yhat.col(t).transpose(), Sigma, 1, 0);
      }
      zt = zt - AF;
      updateSurBeta(zt, surX, Sigma, b0, B0);
      beta = bnew.transpose();
      Xbeta = surX * beta;
      Xbeta.resize(K, T);
      MatrixXd Ftstacked = kroneckerProduct(Ft, OneK);
      MatrixXd surF = surForm(Ftstacked.transpose(), K);
      zt += AF;
      zt -= Xbeta;
      updateSurBeta(zt, surF, Sigma, a0, A0);
      A = bnew;
      A.transpose().resize(K, nFactors);
      A.transposeInPlace();
      Identification2(A);
      for (int n = 0; n < nFactors; ++n) {
        MatrixXd Acopy = A;
        Acopy.col(n) = VectorXd::Zero(K);
        MatrixXd resids = zt  - Acopy * Ft;
        MatrixXd Sinv = MakePrecision(gammas.row(n), factorVariance(n), T);
        resids.resize(KT, 1);
        Ft.row(n) = updateFactor(resids, A.col(n), Sinv, Sigma);
        // Factor dynamic multipliers update
        gammas.row(n) = updateArParameters(Ft.row(n), gammas.row(n),
                                           factorVariance(n), g0, G0);
        // MatrixXd H = ReturnH(gammas.row(n), T);
        // MatrixXd nu = (H * Ft.row(n).transpose()).transpose();
        // factor variance update
        // factorVariance(n) = updateSigma2(nu, d0, D0).value();
      }
          zt += Xbeta;
      if (i >= burnin) {
        BetaPosterior.push_back(beta);
        LoadingPosterior.push_back(A);
        FactorPosterior.push_back(Ft);
        gammaPosterior.push_back(gammas);
        FactorVariancePosterior.push_back(factorVariance);
        // CorrelationPosterior.push_back(Correlation);
      }
    }

    std::filesystem::create_directories(path_name);
    fname = path_name + "/main_MCMC_run"+ ".txt";
    std::ofstream file;
    file.open(fname);
    if (file.is_open()) {
      storePosterior(path_name + "/beta.csv", BetaPosterior);
      storePosterior(path_name + "/loadings.csv", LoadingPosterior);
      storePosterior(path_name + "/gammas.csv", gammaPosterior);
      storePosterior(path_name + "/factors.csv", FactorPosterior);
      storePosterior(path_name + "/factorVariance.csv", FactorVariancePosterior);
      file << "Full Conditional Version run with: " << Sims << " "
           << "burnin " << burnin << " " << T << " " << K << endl;
      file << "Beta avg" << endl;
      file << mean(BetaPosterior) << endl;
      cout << "Loading Avg" << endl; 
      file << mean(LoadingPosterior) << endl; 
      file << "Gamma avg" << endl;
      file << mean(gammaPosterior) << endl;
      file << "Factors avg" << endl;
      file << mean(FactorPosterior).transpose() << endl;
      file << "Factor variance avg" << endl; 
      file << mean(FactorVariancePosterior) << endl; 
      file.close();
    } else {
      cout << "Error, file not written" << endl;
    }
  }

  void ValidationRun(const MatrixXd &Xtest, const MatrixXd &ytest) {
    MVTNProbs mvtn;
    int K = ytest.rows();
    int T = ytest.cols();
    double acc = 0;
    double running_acc = 0;
    double running_ll = 0;
    double ll = 0;
    MatrixXd surX = surForm(Xtest, K);
    MatrixXd AvgZ(K,T);
    AvgZ.setZero(); 
    for (int i = 0; i < 1; ++i) {
      beta = BetaPosterior[i];
      MatrixXd Xbeta = surX * beta;
      Xbeta.resize(K, T);
      MatrixXd A = LoadingPosterior[i];
      MatrixXd Ft = FactorPosterior[i];
      MatrixXd AF = A * Ft;
      MatrixXd zt = Xbeta + AF;
      MatrixXd Pij = simple_probit_probs(zt);
      ll += log_loss(Pij, ytest);
      running_ll = ll / (i + 1);
      cout << "Log-loss " << running_ll << endl;
    }
    MatrixXi ypred = label_data(AvgZ);
    string ypred_fname = path_name + "/ypred.csv";
    writeCsv(ypred_fname, ypred); 
    string yactual_fname = path_name + "/ytest.csv";
    writeCsv(yactual_fname, ytest); 
    MatrixXi ytest_labeled = label_data(ytest); 
    double post_acc = accuracy(ypred, ytest_labeled); 
    MatrixXd Pij = simple_probit_probs(AvgZ); 
    double post_ll = log_loss(Pij, ytest); 
    cout << "Average accuracy " << running_acc << endl;
    cout << "Average log-loss " << running_ll << endl;
    std::filesystem::create_directories(path_name);
    std::ofstream file;
    string summary_fname = path_name + "/vaidation_summary" + ".txt";
    file.open(summary_fname);
    if (file.is_open()) {
      file << "Running log-loss (all posterior samples averaged) " << running_ll << endl;
      file << "Posterior mean accuracy " << post_acc << endl; 
      file << "Posterior mean log loss " << post_ll << endl; 
    }
    file.close();
  }

void ValidationRun(const MatrixXd &Xtest, const MatrixXd &ytest, int G, int bng, int batches) {
    MVTNProbs mvtn;
    int K = ytest.rows();
    int T = ytest.cols();
    double acc = 0;
    double running_acc = 0;
    double running_ll = 0;
    double ll = 0;
    MatrixXd surX = surForm(Xtest, K);
    MatrixXd AvgZ(K,T);
    AvgZ.setZero(); 
    for (int i = 0; i < 1; ++i) {
      beta = BetaPosterior[i];
      MatrixXd Xbeta = surX * beta;
      Xbeta.resize(K, T);
      MatrixXd A = LoadingPosterior[i];
      MatrixXd Ft = FactorPosterior[i];
      MatrixXd AF = A * Ft;
      MatrixXd zt = Xbeta + AF;
      AvgZ += zt;
      AvgZ = AvgZ/(i+1);  
      MatrixXd Pij = simple_probit_probs(zt);
      ll += log_loss(Pij, ytest);
      running_ll = ll / (i + 1);
      cout << "Log-loss " << running_ll << endl;
    }
    MatrixXi ypred = label_data(AvgZ);
    string ypred_fname = path_name + "/ypred.csv";
    writeCsv(ypred_fname, ypred); 
    string yactual_fname = path_name + "/ytest.csv";
    writeCsv(yactual_fname, ytest); 
    MatrixXi ytest_labeled = label_data(ytest); 
    double post_acc = accuracy(ypred, ytest_labeled); 
    MatrixXd Pij = simple_probit_probs(AvgZ); 
    double post_ll = log_loss(Pij, ytest); 
    cout << "Average log-loss " << running_ll << endl;
    std::filesystem::create_directories(path_name);
    std::ofstream file;
    string summary_fname = path_name + "/vaidation_summary" + ".txt";
    file.open(summary_fname);
    if (file.is_open()) {
      file << "Running log-loss (all posterior samples averaged) " << running_ll << endl;
      file << "Posterior mean accuracy " << post_acc << endl; 
      file << "Posterior mean log loss " << post_ll << endl; 
    }
    file.close();

    beta = mean(BetaPosterior);
    MatrixXd Xbeta = surX * beta;
    Xbeta.resize(K, T);
    MatrixXd A = mean(LoadingPosterior);
    MatrixXd Ft = mean(FactorPosterior);
    MatrixXd AF = A * Ft;
    MatrixXd zt = Xbeta + AF;
    vector<double> probs;
    vector<double> prob_var;
    MatrixXd Sigma = MatrixXd::Identity(K, K);
    MatrixXd OrthantProbs(batches, zt.cols());
    for (int j = 0; j < zt.cols(); ++j) {
      cout << "Orthant num " << j << endl;
      OrthantProbs.col(j) =
          mvtn.batch_crb(zt.col(j).transpose(), Sigma, ytest.col(j).transpose(),
                         G, bng, batches);
    }
    string orthant_fname = path_name + "/orthant_probs.csv"; 
    writeCsv(orthant_fname, OrthantProbs); 
  }

  MatrixXi label_data(const MatrixXd &latent_data) {
    int K = latent_data.rows();
    int T = latent_data.cols();
    MatrixXi LabeledData(K,T); 
    for (int t = 0; t < T; ++t) {
      for (int k = 0; k < K; ++k) {
        if(latent_data(k,t) > 0){
          LabeledData(k,t) = 1;
        }
        else{
          LabeledData(k,t) = 0; 
        }
      }
    }
    return LabeledData; 
  }

  void Forecast(const MatrixXd &Xfuture) {
    int K = LoadingPosterior[0].rows();
    int T = Xfuture.rows()/K; 
    if(not (Xfuture.rows()%K)){
      throw invalid_argument("Xfuture rows is not multiple of K (equations in yt).");
    }
    MatrixXd surX = surForm(Xfuture, K);
    MatrixXd AvgZ(K,T);
    AvgZ.setZero(); 
    for (int i = 0; i < 1; ++i) {
      beta = BetaPosterior[i];
      MatrixXd Xbeta = surX * beta;
      Xbeta.resize(K, T);
      MatrixXd A = LoadingPosterior[i];
      MatrixXd Ft = FactorPosterior[i];
      MatrixXd AF = A * Ft;
      MatrixXd zt = Xbeta + AF;
      AvgZ += zt;
      AvgZ = AvgZ/(i+1);  
    }
    cout << AvgZ << endl; 
  }

  void Identification1(MatrixXd &A) {
    for (int i = 0; i < A.cols(); ++i) {
      for (int j = 0; j < A.cols(); ++j) {
        if (j > i) {
          A(i, j) = 0.0;
        } else if (i == j) {
          A(i, j) = 1.0;
        }
      }
    }
  }

  void Identification2(MatrixXd &A) {
    for (int i = 0; i < A.cols(); ++i) {
      for (int j = 0; j < A.cols(); ++j) {
        if (j > i) {
          A(i, j) = 0.0;
        } 
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
    MatrixXd SigPrior = MatrixXd::Identity(S.rows() * (S.rows() - 1) / 2,
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
    MatrixXd surX = surForm(Xt, K);
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
    MatrixXd surX = surForm(Xt, K);
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
    MatrixXd surX = surForm(Xt, K);
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
