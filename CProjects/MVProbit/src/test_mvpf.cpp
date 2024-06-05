
#include <iostream>
#include "mvp.hpp"
#include "GenerateFactorData.hpp"
#include "Plotter.hpp"

using namespace std;
using namespace Eigen;
int main() {
	cout << " Test mvp" << endl;
	int T = 100;
	int K = 8;

	GenerateFactorData gfp;
	Matrix<int, Dynamic, 2> InfoMat(2, 2);
	InfoMat << 0, K - 1, 1, K-1;
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
	VectorXd phi(1);
	phi << .25;
	MatrixXd B0 = MatrixXd::Identity(gfp.b0.rows(),gfp.b0.rows());
	cout << gfp.b0 << endl; 
	mv.setModel(yt, gfp.Xt, gfp.betas.replicate(K, 1), phi, RowVectorXd::Ones(gfp.b0.cols()), gfp.B0, InfoMat, "factor", gfp.Factors);
	mv.runFactorModel(100, 10);

	MatrixXd Fbar = mean(mv.FactorPosterior);
	MatrixXd Betabar = mean(mv.BetaPosterior);
	Betabar.resize(K, gfp.Xt.cols() + InfoMat.rows());
	MatrixXd A = Betabar.rightCols(Fbar.rows());
	MatrixXd AF = A*Fbar;

	plotter("af.csv", Fbar.row(1), gfp.Factors.row(1));
	plotter("af.csv", Fbar.row(0), gfp.Factors.row(0));
}