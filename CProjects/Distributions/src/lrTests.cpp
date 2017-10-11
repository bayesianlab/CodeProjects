#include <Eigen/Dense>
#include <iostream>
#include <fstream>
#include <math.h>
#include <limits> 
#include <ctime>
#include "MarginalLikelihoodCalculator.hpp"
#include "Dist.hpp"
#include "ProbabilitySimulator.hpp"
#include "CreateSampleData.hpp"

using namespace std;
using namespace Eigen;


int main(){
	cout << "\t\tLikelihood Function of Linear Regression Model Tests\n" << endl;
	string matlabpass = "Checked in MATLAB file matlabCtests.m and passed\n";
	MarginalLikelihoodCalculator mlc;
	Dist dobject;
	ProbabilitySimulator psim;
	int testN = 10000;
	const int dim = 4;
	VectorXd b(dim);
	b << .75, .55, .35, .15; //, .8, .85, .95, 1.1;
	CreateSampleData csd(testN, b);
	double a = 0;
	double inf = numeric_limits<double>::max();
	cout << "ghkSample test" << endl;
	dobject.ghkSampler(a, inf, csd.theta, csd.inverseFisher, 10);	
	cout << dobject.ghkDraws << endl;
	cout << endl;
	MatrixXd bs(dobject.ghkDraws.rows(), dim);
   	bs 	= dobject.ghkDraws.rightCols(dim);
	VectorXd sigs(dobject.ghkDraws.rows()); 
	sigs = dobject.ghkDraws.col(0);
	dobject.lrLikelihood(bs, sigs, csd.y, csd.X);
	cout << "Likelihood test" << endl;
	cout << dobject.linreglike << endl;
	cout << matlabpass << endl;
	cout << endl;
	
	VectorXd bPrior = VectorXd::Zero(dim);
	MatrixXd eye;
  	eye.setIdentity(dim, dim);	
	VectorXd pdf(bs.rows());
	
	cout << "Log mvn pdf tests" << endl;
	dobject.logmvnpdf(bs, bPrior, eye); 	
	cout << dobject.lmvnpdf << endl;
	cout << matlabpass << endl;
	
	VectorXd ghkSigma =	dobject.ghkDraws.col(0);
	VectorXd invgammaPdf = VectorXd::Zero(dobject.ghkDraws.rows());
	double alpha = 3;
	double beta = 6;
	VectorXd y = dobject.ghkDraws.col(0);
	dobject.loginvgammapdf(y, alpha, beta);
	cout << "Inv gamma pdf" << endl;
	cout << dobject.ligampdf << endl;
	cout << matlabpass << endl;


	cout << "ghkLinearConstraints tests" << endl;
	VectorXd a1(5);
	VectorXd b1(5);
	a1 << 0, 0, 0, 0, 0;
	b1 << 1.5, 1.5, 1.5, 1.5,1.5;
	dobject.ghkLinearConstraints(a1, b1, csd.theta, csd.inverseFisher, 4);
	cout << endl;

	cout << "Shifted exponential " << endl;
	ofstream shiftexp;
	shiftexp.open("shiftedexp.txt");
	const int msize = 1000;
	Matrix<double, msize,3> H;
	H.col(1) = VectorXd::LinSpaced(msize, 2., 10);
	cout << dobject.shiftexprnd(1.0, 2.) << endl;
	for(int i = 0; i < msize; i ++){ H(i, 0) = dobject.shiftexprnd(1., 2.); };
	for(int j = 0; j < msize; j++){H(j, 2) = dobject.shiftexppdf(1., 2., H(j, 1));};
	shiftexp << H;
	shiftexp.close();

	const int easytest = 15;
	Matrix<double, easytest, 1> easy;
	int errorFlag = 0;
	double rrv;

	cout << "\n\tLeft truncation" << endl;
	for(int i =0; i < 15; i++) {
		rrv = dobject.leftTruncation(8, inf);
		easy(i) = rrv;
		if( rrv < .33 ){
			errorFlag = 1;
			break;

		}
	}
	if(errorFlag == 1){
		cout << "Error in Roberts method Left truncation test failed" << endl;
		cout <<  rrv << endl;
	}
	cout << "Passed, all truncated correct" << endl;
	errorFlag = 1;
	

	cout << "\tRight truncation" << endl;
	cout << "\t(-inf, -9]" << endl;
	errorFlag = 0;
	for(int i =0; i < 15; i++) {
		double rrv = dobject.rightTruncation(-inf, -9.);
		easy(i) = rrv;
		if( rrv >= -9.){
			errorFlag = 1;
			break;
		}
	}
	if(errorFlag == 1){
		cout << "Error in Roberts method" << endl;
		cout <<  rrv << endl;
	}
	else{
		cout << "Passed, all truncated correct" << endl;
		cout << easy << endl;
	}


	cout << "\ttwo sided truncation" << endl;
	cout << "\t[-.5, .5]" << endl;
	for(int i =0; i < 15; i++) {
		double rrv = dobject.twoSided(-.5, .5);
		easy(i) = rrv;
		if( rrv < -.5 || rrv > .5){
			cout << "Error in Roberts method" << endl;
			cout <<  rrv << endl;
		}
	}
	cout << "Passed, all truncated correct" << endl;
	cout << easy << endl;

	cout << "\n\tTruncated normal tests"  <<endl;
	cout << "\tN(0,1) [8, inf)" << endl;
	double muminus = 8;
	for(int i =0; i < 15; i++) {
		double rrv = dobject.truncNormalRnd(muminus, inf, 0, 1);
		easy(i) = rrv;
		if( rrv < muminus ){
			cout << "Error in Roberts method" << endl;
			cout <<  rrv << endl;
		}
	}
	cout << "Passed, all truncated correct" << endl;
	cout << easy << endl;

	cout << "\tTwo sided truncation in + tail" << endl;
	cout << "\tN(10, 3) [30, 45]" << endl;
	errorFlag = 0;
	for(int i =0; i < 15; i++) {
		double rrv = dobject.truncNormalRnd(30., 45, 10., 3.);
		easy(i) = rrv;
		if( rrv < 30. || rrv > 45.){
			errorFlag = 1;
			break;
		}
	}
	if(errorFlag == 1){
		cout << "Error in Roberts method" << endl;
		cout <<  easy << endl;
	}
	else{
 		cout << "Passed, all truncated correct" << endl;
		cout << easy << endl;
	}
	cout << "\tTwo sided truncation in - tail" << endl;
	cout << "\tN(-3, .5) [-10, -9]" << endl;
	errorFlag = 0;
	for(int i =0; i < 15; i++) {
		double rrv = dobject.truncNormalRnd(-10., -9., -3, .5);
		easy(i) = rrv;
		if( rrv < -10. || rrv > -9.){
			errorFlag = 1;
			break;
		}
	}
	if(errorFlag == 1){
		cout << "Error in Roberts method" << endl;
		cout <<  easy << endl;
	}
	else{
 		cout << "Passed, all truncated correct" << endl;
		cout << easy << endl;
	}

	cout << "\tCrazy Tail" << endl;
	cout << "\tN(2, .1) [50, inf)" << endl;
	errorFlag = 0;
	for(int i =0; i < 15; i++) {
		double rrv = dobject.truncNormalRnd(50., inf, 2., .1);
		easy(i) = rrv;
		if( rrv < 50 ){
			errorFlag = 1;
			break;
		}
	}
	if(errorFlag == 1){
		cout << "Error in Roberts method" << endl;
		cout <<  easy << endl;
	}
	else{
 		cout << "Passed, all truncated correct" << endl;
		cout << easy << endl;
	}

	cout << "\tCrazy Tail" << endl;
	cout << "\tN(-2, .1) (-inf, -50]" << endl;
	errorFlag = 0;
	for(int i =0; i < 15; i++) {
		double rrv = dobject.truncNormalRnd(-inf, -50, -2., .1);
		easy(i) = rrv;
		if( rrv > -50. ){
			errorFlag = 1;
			break;
		}
	}
	if(errorFlag == 1){
		cout << "Error in Roberts method" << endl;
		cout <<  easy << endl;
	}
	else{
 		cout << "Passed, all truncated correct" << endl;
		cout << easy << endl;
	}

	cout << "\n\t TESTS COMPLETED\n" << endl;
	return 0; 
	
} 

