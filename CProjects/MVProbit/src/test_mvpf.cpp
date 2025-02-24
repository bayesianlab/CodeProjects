
#include <iostream>
#include "mvp.hpp"
#include "GenerateFactorData.hpp"
#include "Plotter.hpp"


using namespace std;
using namespace Eigen;
int main() {
	cout << " Test mvp" << endl;
	int T = 150;
	int K = 8;

	GenerateFactorData gfp;
	Matrix<int, Dynamic, 2> InfoMat(2, 2);
	InfoMat << 0, K - 1, 0, K-1;
	VectorXd phi(2);
	phi << .10, .10;
	gfp.genProbitData(K, T, 1, 1, InfoMat);
	MatrixXd yt(K, T);
	for (int i = 0; i < T; ++i) {
		for (int j = 0; j < K; ++j) {
			if (gfp.yt(j, i) > 0) {
				yt(j, i) = 1;
			}
			else {
				yt(j, i) = 0;
			}
		}
	}

	// int p = 2;
	// MatrixXd B0 = MatrixXd::Identity((p + 1) * K, (p + 1) * K);
	// RowVectorXd b0((p + 1) * K);
	// b0.setZero();
	// MatrixXd xt = normrnd(0, 1, T * K, p);
	// MatrixXd Xt(K * T, p + 1);
	// Xt << VectorXd::Ones(K * T), xt;
	// VectorXd beta = VectorXd::Ones(p + 1);
	// MatrixXd S = CreateSigma(.5, K);
	// cout << vech(S) << endl;
	// MatrixXd Lower = S.llt().matrixL();
	// MatrixXd eps = Lower * normrnd(0, 1, K, T);
	// eps.resize(K * T, 1);
	// MatrixXd zt = Xt * beta + eps;
	// zt.resize(K, T);
	// MatrixXd yt(K, T);
	// for (int i = 0; i < T; ++i) {
	// 	for (int j = 0; j < K; ++j) {
	// 		if (zt(j, i) > 0) {
	// 			yt(j, i) = 1;
	// 		}
	// 		else {
	// 			yt(j, i) = 0;
	// 		}
	// 	}
	// }

	MVP mv;
	string date = dateString();
	string path_name = "mvprobit_factor_" + date;
	VectorXd b = unifrnd(0,1, K);
	MatrixXd ytrain = yt.block(0,0,K, 100); 
	MatrixXd Xtrain = gfp.Xt.block(0,0, K*100, gfp.Xt.cols()); 
	MatrixXd ytest = yt.block(0, 100, K, yt.cols()- 100); 
	MatrixXd Xtest = gfp.Xt.block(K*100, 0, gfp.Xt.rows() - (K*100), gfp.Xt.cols()); 
	mv.setModel(ytrain, Xtrain, b, phi, gfp.b0, 10*gfp.B0, 
	            InfoMat, path_name);
	mv.runFactorModel(100, 10);

	MatrixXd Fbar = mean(mv.FactorPosterior);
	MatrixXd Betabar = mean(mv.BetaPosterior);
	
	mv.BayesianPrediction(Xtest, ytest);
	// mv.Forecast(Xtest, K); 

	// Betabar.resize(K, gfp.Xt.cols() + InfoMat.rows());
	// MatrixXd A = Betabar.rightCols(Fbar.rows());
	// MatrixXd AF = A*Fbar;

	// plotter("af1.csv", Fbar.row(0), gfp.Factors.row(0));
	// plotter("af2.csv", Fbar.row(1), gfp.Factors.row(1));

	// vector<MatrixXd> z; 
	// vector<MatrixXd> f; 
	// z.push_back(gfp.Factors); 
	// f.push_back(Fbar); 
	// mv.storePosterior("true.csv", z);
	// mv.storePosterior("factors.csv", f);

}
