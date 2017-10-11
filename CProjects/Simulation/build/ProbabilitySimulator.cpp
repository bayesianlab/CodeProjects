//#include "Dist.hpp"
#include "ProbabilitySimulator.hpp"
#include <Eigen/Dense>
#include "Dist.hpp"
#include <iostream>
#include <math.h>

using namespace Eigen;
using namespace std;



void ProbabilitySimulator::chibRaoBlackwell(double a, double b, VectorXd& mu, MatrixXd& sigma, 
		 VectorXd& zStar, VectorXd& fzStar, int sims, int burnin, int rrSims, int rrburnin){
	/* 
	 * zStar5 unneeded
	 */
	// Generate sample
	Dist d;	
	int J = sigma.cols();
	int Jminus1 = J-1;
	MatrixXd tmvnsample(sims, 2*J);
	VectorXd sigv(J);	
	d.inversionTMVN(a, b, mu, sigma, tmvnsample, sigv);
	tmvnsample = tmvnsample.bottomRows(sims-burnin);
	cout << "Created truncated sample" << endl;
	cout << "Size " << tmvnsample.rows() << "x" <<tmvnsample.cols() << endl;
	int redRuns = J - 2;
	int rrSampleDim=0;
	for(int j = 2; j <= Jminus1; j++){
		rrSampleDim = rrSampleDim + j;	
	} 
	rrSampleDim = 2*rrSampleDim;
	MatrixXd redRunSample(rrSims, rrSampleDim);
	int sampleSize = sims-burnin;
	int rrSampleSize = rrSims- rrburnin;
	MatrixXd precision = sigma.inverse();
	VectorXd Hxx = precision.diagonal();
	VectorXd sigmaVect(J);
	for(int j = 0; j<J;j++){
		sigmaVect(j) = sqrt(1/Hxx(j));
	} 
    VectorXd Hxy(J-1);
    VectorXd xNotJ(J-1);
    VectorXd muNotJ(J-1);

	zStar(0) = tmvnsample.col(0).mean();
	VectorXd temp(sampleSize);
	// Calc fzstar 0 //
	for(int i = 0; i < sampleSize; i++){
		temp(i) = d.tnormpdf(a, b, tmvnsample(i,J), sigv(0), zStar(0));
	}
	fzStar(0) = temp.mean();
	VectorXd tempfzStarVector(rrSims-rrburnin);
	// J - 2 Reduced Runs because 1 was just calculated and the last will be given
	double muj;
	int condMeanIndex; 
	int JdimensionReductionIndex = Jminus1;
	int drawIndex=0;
	int drawIndexStartValue = 0;
	cout << "Starting " << redRuns << " reduced runs\n" << endl;
	for(int rr = 0; rr < redRuns; rr++){
		for(int sim = 1; sim < rrSims; sim ++){
			int decrement = 0;
			int countj =0;
			drawIndex = drawIndexStartValue;
	 		for(int j = rr+1; j < J; j++){
				countj++;
				decrement = J - (j+1);
				muNotJ << mu.head(j), mu.tail(decrement);
			    xNotJ.head(rr+1) = zStar.head(rr+1);
				xNotJ.tail(Jminus1-1) << redRunSample.row(sim-1).segment(drawIndex, j-1).transpose(),
				  redRunSample.row(sim-1).segment(drawIndex+1, decrement).transpose();
				Hxy << precision.row(j).head(countj + rr).transpose(), 
					precision.row(j).tail(decrement).transpose(); 
				// save means variances and sample draws
				condMeanIndex = drawIndex + JdimensionReductionIndex;
				muj = d.conditionalMean(Hxx(j), Hxy, muNotJ, xNotJ, mu(j));
				redRunSample(sim, drawIndex) = d.tnormrnd(a, b, muj, sigmaVect(j));
				redRunSample(sim,  condMeanIndex) = muj;
				drawIndex++;
		   	}
		}
		if(rr == redRuns-1){
			zStar.tail(2) << redRunSample.col(drawIndex - JdimensionReductionIndex).tail(rrSampleSize).mean(),
				redRunSample.col(drawIndex- JdimensionReductionIndex + 1).tail(rrSampleSize).mean();
		}else{
			zStar(rr+1) = redRunSample.col(drawIndex - JdimensionReductionIndex).mean();
			drawIndexStartValue = condMeanIndex + 1;
			drawIndex = drawIndexStartValue;
			JdimensionReductionIndex--;
		} 	
	}
	JdimensionReductionIndex = Jminus1;
	condMeanIndex = 0;
	cout << "Calc fzstar\n" << endl;
    for(int k = 0; k < redRuns; k++){
		for(int t = rrburnin; t < rrSims; t++){
			tempfzStarVector(t-rrburnin) = d.tnormpdf(a,b,redRunSample(t,condMeanIndex+JdimensionReductionIndex),
				   	sigmaVect(k+1),
					zStar(k+1));
		}
		fzStar(k+1) = tempfzStarVector.mean();
		condMeanIndex = condMeanIndex + JdimensionReductionIndex*2;
		JdimensionReductionIndex--;
	} 
	Hxy = precision.row(Jminus1).head(Jminus1);
	muNotJ = mu.head(Jminus1);
	muj = d.conditionalMean(Hxx(Jminus1), Hxy , muNotJ, xNotJ, mu(Jminus1));
	fzStar(Jminus1) = d.tnormpdf(a, b, muj, sigmaVect(Jminus1), zStar(Jminus1));
	cout << "Finished running\n" << endl;
} 
 

