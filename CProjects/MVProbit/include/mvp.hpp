#ifndef MVP_H
#define MVP_H
#include <Eigen/Dense>

#include "Distributions.hpp"
#include "EigenTools.hpp"
#include "FullConditionals.hpp"
#include "IntegratedLikelihood.hpp"
#include "Optimization.hpp"
#include "MultilevelModelFunctions.hpp"
#include "TimeSeriesTools.hpp"

using namespace Eigen;
using namespace std;

template <typename Tz, typename Ty, typename Tm>
void drawLatentData(MatrixBase<Tz>& zt, const MatrixBase<Ty>& yt,
	const MatrixBase<Tm>& mut) {
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
			}
			else {
				zt(k, t) = -NormalTruncatedPositive(-mutt(k), 1, 1).value();
			}
		}
	}
}

MatrixXd CorrelationMatrix(const MatrixXd& X)
{
	VectorXd d = X.diagonal().array().pow(-.5); 
	MatrixXd D = d.asDiagonal(); 
	return D * X * D; 
}

pair<MatrixXd, MatrixXd> AstarLstar(const MatrixXd &A, const MatrixXd &Sigma){
		MatrixXd AAT = A * A.transpose();		 
		MatrixXd P = AAT + Sigma; 
		VectorXd d = P.diagonal().array().pow(-.5); 
		MatrixXd D = d.asDiagonal(); 
		MatrixXd L = Sigma.llt().matrixL();
		pair<MatrixXd, MatrixXd> M;  
		M.first = D*A; 
		M.second = D*L; 
		return M; 
}

class MVP : public BetaParameterTools,
	public SurBetaUpdater,
	public FullConditionalsNoAr {
public:
	std::vector<VectorXd> BetaPosterior;
	std::vector<MatrixXd> SigmaPosterior;
	std::vector<MatrixXd> FactorPosterior;
	std::vector<VectorXd> gammaPosterior; 
	std::vector<MatrixXd> CorrelationPosterior; 
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
	string file_name; 

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

	void setModel(const MatrixXd& yt, const MatrixXd& zt, const MatrixXd& Xt,
		const VectorXd& beta, const RowVectorXd& b0, const MatrixXd& B0,
		const std::vector<VectorXd>& s0,
		const std::vector<MatrixXd>& S0, Optimize& optim,
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

	void setModel(const MatrixXd& yt, const MatrixXd& Xt, const VectorXd& beta,
		const MatrixXd _gammas, const RowVectorXd& b0,
		const MatrixXd& B0, const Matrix<int, Dynamic, 2>& InfoMat,
		string _file_name) {
		this->b0 = b0;
		this->B0 = B0;
		this->Ft = normrnd(0, 1, InfoMat.rows(), yt.cols());
		this->yt = yt;
		this->Xt = Xt;
		this->beta = beta;
		this->InfoMat = InfoMat;
		Xtk.resize(yt.rows());
		this->gammas = _gammas; 
		g0 = RowVectorXd::Zero(_gammas.cols());
		G0 = createArPriorCovMat(1, _gammas.cols());
		file_name = _file_name; 
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
		int nFactors = InfoMat.rows();
		int levels = calcLevels(InfoMat, K);
		MatrixXd A = MatrixXd::Ones(K, nFactors);
		MatrixXd Sigma = MatrixXd::Identity(K,K);
		VectorXd Ik = VectorXd::Ones(K);
		for (int i = 0; i < A.cols(); ++i) {
			for (int j = i; j < A.cols(); ++j){
				if (i == j){
					A(i, j) = 1.0;
				}
				else {
					A(i, j) = 0;
				}
			}
		}
		auto AL = AstarLstar(A, Sigma); 
		MatrixXd Astar = AL.first; 
		MatrixXd SigmaStar = AL.second*AL.second.transpose(); 
		MatrixXd Correlation = AL.first*AL.first.transpose() + AL.second*AL.second.transpose(); 
		MatrixXd surX = surForm(Xt, K);
		MatrixXd Xbeta = surX * beta;
		Xbeta.resize(K, T); 
		MatrixXd yhat = Xbeta + Astar * Ft;
		VectorXd factorVariance = VectorXd::Ones(nFactors); 
		zt.resize(K, T); 
		for (int i = 0; i < Sims; ++i) {
			cout << "Sim " << i + 1 << endl;
			for (int t = 0; t < T; ++t) {
				zt.col(t) = mvtnrnd(yhat.col(t).transpose(), yt.col(t).transpose(),
					yhat.col(t).transpose(), Correlation, 1, 0);
			}
			updateSurBeta(zt, surX, Correlation, b0, B0);
			MatrixXd btemp = bnew; 
			btemp.resize(K, Xt.cols()); 
			MatrixXd Beta(K, Xt.cols() + nFactors); 
			Beta << btemp, Astar;
			Xtk = groupByTime(Xt, K);
			updateLoadingsFullConditionals(Beta, zt, SigmaStar.diagonal(), InfoMat, Xtk, Ft, b0, B0);
			A = Beta.rightCols(nFactors); 
			for (int i = 0; i < A.rows(); ++i) {
				for (int j = i; j < A.cols(); ++j) {
					if (i == j) {
						A(i, j) = 1.;
					}
					else {
						A(i, j) = 0;
					}
				}
			}
			auto AL = AstarLstar(A, Sigma);
			MatrixXd Astar = AL.first; 
			MatrixXd SigmaStar = AL.second*AL.second.transpose(); 
			Correlation = Astar*Astar.transpose() + SigmaStar; 
			Beta.rightCols(nFactors) = Astar; 
			Xbeta = surX * bnew.transpose();
			Xbeta.resize(K, T);
			updateFactor2(Ft, zt, Xtk, InfoMat, Beta, SigmaStar.diagonal(), factorVariance, gammas);
			for (int n = 0; n < nFactors; ++n) {
				// Factor dynamic multipliers update
				gammas.row(n) = updateArParameters(Ft.row(n), gammas.row(n),
					factorVariance(n), g0, G0);
			}
			if (i >= burnin) {
				Beta.resize(K * (Xt.cols()+nFactors), 1); 
				BetaPosterior.push_back(Beta); 
				FactorPosterior.push_back(Ft); 
				gammaPosterior.push_back(gammas); 
				CorrelationPosterior.push_back(Correlation); 
			}
			zt = Xbeta + Astar * Ft; 
		}
		cout << mean(CorrelationPosterior) << endl; 
		cout << mean(BetaPosterior) << endl; 

		string date = dateString();
		string ext = ".txt";
		string path = "mvprobit_" + file_name + "_" + date + "/";
		std::filesystem::create_directories(path);
		fname = path + file_name + ext;
		std::ofstream file;
		file.open(fname);
		if (file.is_open()) {
			storePosterior(path + "beta.csv", BetaPosterior);
			storePosterior(path + "gammas.csv", gammaPosterior);
			storePosterior(path + "factors.csv", FactorPosterior);
			file << "Full Conditional Version run with: " << Sims << " " << "burnin "
				<< burnin << endl;
			file << "Beta avg" << endl;
			file << mean(BetaPosterior) << endl;
			file << "Gamma avg" << endl;
			file << mean(gammaPosterior) << endl;
			file << "Factor Variance" << endl;
			file << mean(FactorPosterior).transpose() << endl;
			file.close();
		}
		else {
			cout << "Error, file not written" << endl;
		}
	}

	template <typename T1, typename T2, typename T3>
	void updateSigma(const MatrixBase<T1>& zt, const MatrixBase<T2>& Xbeta,
		MatrixBase<T3>& Sigma, Optimize& optim) {
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
			auto SLL = [&column, &mu, &Sigma, this](const VectorXd& x0) {
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

	VectorXd flattenVectorVector(const std::vector<VectorXd>& Y) {
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

	MatrixXd flattenVectorMatrix(const std::vector<MatrixXd>& Y) {
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

	double SigmaLogLikelihood(const VectorXd& guess, const int column,
		const MatrixXd& mu, const MatrixXd& Sigma,
		const VectorXd& guesspriorMean,
		const MatrixXd& guesspriorVar) {
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
		}
		else {
			for (int t = 0; t < T; ++t) {
				tmu += -.5 * (mu.col(t).transpose() * Precision * mu.col(t)).value();
			}
			return tmu;
		}
	}

	double SigmaLogLikelihood(const VectorXd& guess, const MatrixXd& mu,
		const MatrixXd& Sigma,
		const VectorXd& guesspriorMean,
		const MatrixXd& guesspriorVar) {
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
		}
		else {
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
				auto SLL = [&column, &mu, &Sigma, this](const VectorXd& x0) {
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
			auto SLL = [&column, &mu, &SigmaStar, this](const VectorXd& x0) {
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
