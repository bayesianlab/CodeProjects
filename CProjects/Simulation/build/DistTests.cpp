#include <iostream>
#include <fstream>
#include <math.h>
#include <limits> 
#include "Dist.hpp"
#include "ProbabilitySimulator.hpp"
using namespace std;
using namespace Eigen;

#define N 10

int main()
{
	ofstream testfile;
	testfile.open("testfile.txt");
	
	Dist d;
	MatrixXd normalMat(N,3); 
	d.normrnd(0,1,normalMat);
	cout << "Normal random variable test" << endl;
	cout << normalMat << endl;
	testfile << normalMat;	
	testfile.close();
	cout << endl;	
	
	VectorXd mu(3);
	mu << 10,10,10;
	MatrixXd sig(3,3);
	sig << .7, .3, .3, 
		.3, .7, .45, 
		.45, .3, .7;
	MatrixXd mvn(N,3); 
	cout << "Multivariate normal test" << endl;
	d.mvnrnd(mu, sig, mvn);
	cout << endl << mvn << endl<<endl;
	testfile.open("mvn.txt");
	testfile << mvn;
	testfile.close();


	cout << endl << "Inverse gamma tests " <<endl;
	VectorXd v(N);
	d.igammarnd(1,1,v);
	cout << v << endl;
	testfile.open("igamma.txt");
	testfile << v;
	testfile.close();
	
    double inf = numeric_limits<double>::max();
	cout << "Trunc normal test" << endl;
    VectorXd tvars(10000);
	d.tnormrndTEST(0.0, inf, 0, 1, tvars);
	cout << tvars.mean() << endl;
	cout << d.standardDev(tvars) << endl;
	cout << "Standard Dev test " << endl;
	VectorXd u(10);
	u << 1,2,3,4,5,6,7,8,9,10;
	cout << d.standardDev(u) << " Should be 3.0277" << endl;

    MatrixXd s(3,3);
    mu << 1,1,1;
    s << 1, .7, .49, 
     .7, 1, .7,
     .49, .7 , 1;
	
	cout << "Univariate version test of trunc normal" << endl;
	cout << d.tnormrnd(0, inf, 0,1) << endl;

	cout << "Inversion TMVN function test" << endl;	
	
	int testN = 2000;
	int dim = 4;
	int a = 0;
	// Creating regression sample data // 
	VectorXd b(dim);
	VectorXd epsilon(testN);
	MatrixXd noise(testN, 1);
	MatrixXd X(testN, dim);	
	b << .75, .55, .35, .15; //, .8, .85, .95, 1.1;
	d.normrnd(0,1 , X);
	d.normrnd(0,1, noise);
	VectorXd y = X*b + noise;
	MatrixXd XpX = X.transpose() * X;	
	MatrixXd Xpy = X.transpose() * y;
	MatrixXd XpXinv = XpX.inverse();
	VectorXd bMle = XpXinv*Xpy; 
	VectorXd e = y - X*bMle;
	VectorXd esqd  = e.transpose()*e / (testN - dim);
	VectorXd empty = VectorXd::Zero(dim);
	MatrixXd iFish(dim+1, dim+1);
	iFish(0,0) = 2*pow(esqd(0),2)/2;
	iFish.block(1,1, dim, dim) = esqd(0)*XpXinv;
	cout << " Inverse Hessian Matrix " << endl;
	cout << iFish << endl;
	
	VectorXd thetaMle(dim+1);
	thetaMle(0) = esqd(0);
	thetaMle.segment(1, dim) = bMle;
	cout << " Means for mvn " << endl;
	cout << thetaMle << endl;
	int testSims = 1000;
	MatrixXd testSample(testSims, 2*(dim+1));
	VectorXd sigv(dim+1);
	d.inversionTMVN(a,inf, thetaMle, iFish, testSample, sigv);
	cout << " Test sample, after burnin " << endl;
	MatrixXd sample = testSample.bottomRows(100);
	cout << sample << endl;
	cout << " Conditional variances " << endl;
	cout << sigv << endl;

	ProbabilitySimulator p;
	/*VectorXd zStar(dim+1);
	VectorXd fzStar(dim+1);
	cout << "TN PDF Test " << endl;
	cout << d.tnormpdf(a,inf,0,1, 1.3) << endl;
	cout << "CRB tests"<< endl;
	MatrixXd redRunSample(10, dim);
	p.chibRaoBlackwell(a, inf, thetaMle, iFish, zStar, fzStar, 200, 20, 200, 20);
	cout << zStar.transpose() << endl;
	cout << fzStar.transpose() << endl;*/
	
	VectorXd crbmu(3);
    crbmu << 0, .5, 1.;
	MatrixXd crbsigma(3,3);
    crbsigma << 1, -.7, .49,
		 		-.7, 1, -.7,
				 .49, -.7, 1;		
	VectorXd x(3);
	x << .33, .33, .33;
	cout << "MVN Normal PDF Tests "<< endl;
	cout << d.mvnpdf(crbmu, crbsigma, x) << endl;
	VectorXd zs(3);	
	VectorXd fzs(3);
	cout << "CHIB" << endl;
	cout << endl;
	p.chibRaoBlackwell(a, inf, crbmu, crbsigma, zs, fzs, 10, 1, 10, 1);
	cout << zs.transpose() << endl;
	cout << fzs.transpose() << endl;
	cout << " Prob. " << endl;
	cout << log(d.mvnpdf(crbmu,crbsigma, zs)) << endl;
 	cout << log(fzs.prod()) << endl;
	cout << log(d.mvnpdf(crbmu, crbsigma, zs)/fzs.prod()) << endl;
	cout << "\n\t\tTESTS COMPLETE" << endl;
	
	return 0;
}
