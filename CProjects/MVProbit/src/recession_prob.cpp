#include <iostream>
#include "mvp.hpp"
#include "GenerateFactorData.hpp"
#include "Plotter.hpp"
#include "EigenTools.hpp"


using namespace std;
using namespace Eigen;

int main(){
    MatrixXd yt = readCSV("/home/dillon/CodeProjects/CProjects/build/RecessionIndicatorY.csv");
    MatrixXd Xt = readCSV("/home/dillon/CodeProjects/CProjects/build/RecessionIndicatorX.csv");
    MatrixXd Xt_Outsample = readCSV("/home/dillon/CodeProjects/CProjects/build/RecessionIndicatorX_Outsample.csv");
    yt.transposeInPlace(); 
    int K = yt.rows();
    int T = yt.cols(); 

	MVP mv;
    Matrix<int, Dynamic, 2> InfoMat(1, 2);
	InfoMat << 0, K - 1;
	VectorXd phi(1);
	phi << unifrnd(.1,.2);
	string date = dateString();
	string path_name = "identification_" + date;
    VectorXd b = unifrnd(0,1, Xt.cols()*K);	
    RowVectorXd b0 = VectorXd::Zero(Xt.cols()*K);
    MatrixXd  B0 = 10*MatrixXd::Identity(Xt.cols()*K,Xt.cols()*K);
	mv.setModel(yt, Xt, b, phi, b0, B0, 
	            InfoMat, path_name);
	mv.runFactorModel(10000, 1000);
    mv.InSampleValidation(Xt, yt, 100, 10, 25);
    mv.BayesianPrediction(Xt_Outsample, K, 100, 10, 25);
}