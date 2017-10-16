#include "ProbabilitySimulator.hpp"
#include <Eigen/Dense>
#include "Dist.hpp"
#include <iostream>
#include <math.h>

using namespace Eigen;
using namespace std;

ProbabilitySimulator::ProbabilitySimulator(){
	cout << "Started prob sim" << endl;
}

int ProbabilitySimulator::getReducedRunSampleColumnDimension(int Jminus1){
	int rrSampleDim = 0;
	for(int j = 2; j <= Jminus1; j++){
		rrSampleDim = rrSampleDim + j;
	} 
	return rrSampleDim;
} 

void ProbabilitySimulator::fillSigmaVect(VectorXd& sv, VectorXd& Hxx){
	for(int j = 0; j < sv.size(); j++){
		sv(j) = sqrt(1/Hxx(j));
	} 
} 

double ProbabilitySimulator::getfzStarMeanAtCol(double a, double b, MatrixXd& sample, int col,
	   	double sigma, double zStar){
	VectorXd temp(sample.rows());
	for(int i = 0; i < sample.rows(); i++){
		temp(i) = distributionObject.tnormpdf(a,b,sample(i,col), sigma, zStar);
	} 
	return temp.mean();
} 

void ProbabilitySimulator::fillfzStar(VectorXd& fzStar, int redRuns, VectorXd& a, VectorXd& b, MatrixXd& sample,
	   	VectorXd& sigma, VectorXd& zStar){
	int condMeanIndex = 0;
	int JdimReductionIndex = zStar.size() - 1;
	for(int k = 0; k < redRuns; k++){
		fzStar(k+1) = getfzStarMeanAtCol(a(k+1),b(k+1), sample, condMeanIndex + JdimReductionIndex, 
				sigma(k+1), zStar(k+1));
		condMeanIndex = condMeanIndex + JdimReductionIndex*2;
		JdimReductionIndex--;
	} 
} 
void ProbabilitySimulator::chibRaoBlackwell(VectorXd& a, VectorXd& b, VectorXd& mu, MatrixXd& sigma, 
		 VectorXd& zStar, VectorXd& fzStar, int sims, int burnin, int rrSims, int rrburnin){
	/* 
	 * zStar5 unneeded. J - 2 Reduced Runs because 1 was just calculated and the last will be given
	 */ 
	int J = sigma.cols();
	int Jminus1 = J-1;
	MatrixXd tmvnsample(sims, 2*J);
	VectorXd sigv(J);	
	distributionObject.tmvnrand(a, b, mu, sigma, tmvnsample, sigv);
	tmvnsample = tmvnsample.bottomRows(sims-burnin);
	cout << "Created truncated sample" << endl;
	cout << "Size " << tmvnsample.rows() << "x" <<tmvnsample.cols() << endl;

	int redRuns = J - 2;
	int rrSampleDim = 2*getReducedRunSampleColumnDimension(Jminus1);
	MatrixXd redRunSample(rrSims, rrSampleDim);
	int sampleSize = sims-burnin;
	int rrSampleSize = rrSims- rrburnin;

	MatrixXd precision = sigma.inverse();
	VectorXd Hxx = precision.diagonal();
	VectorXd sigmaVect(J);
	fillSigmaVect(sigmaVect, Hxx);
    
	VectorXd Hxy(J-1);
    VectorXd xNotJ(J-1);
    VectorXd muNotJ(J-1);
	
	zStar(0) = tmvnsample.col(0).mean();
	VectorXd temp(sampleSize);
	fzStar(0) = getfzStarMeanAtCol(a(0), b(0), tmvnsample, J, sigv(0), zStar(0));
	double muj;
	int condMeanIndex; 
	int JdimensionReductionIndex = Jminus1;
	int drawIndex=0;
	int drawIndexStartValue = 0;
	int currentDim = Jminus1;
	cout << "Starting " << redRuns << " reduced runs\n" << endl;
	// Counters: 
	// rr = {0, 1, 2, ..., reducedRuns} 
	// sim = {1, 2, 3, ..., reducedRunSimulations}
	// decrement = {J,...,2,1,0} Counts down to take less elements becaue the redRunsample dimensions changes
	// drawIndex points to the element of redRunSample where random variates should be put
	// condMeanIndex points  to the element of redRunSample where the conditional mean is put
	// countj = {0,1,2,...,J-1} counts upwards, depends on dimension
	// currentDim = {J-1,...,2}
	for(int rr = 0; rr < redRuns; rr++){
		for(int sim = 1; sim < rrSims; sim ++){
			int decrement = 0;
			int countj =0;
			drawIndex = drawIndexStartValue;
	 		for(int j = rr+1; j < J; j++){
				decrement = J - (j+1);
				muNotJ << mu.head(j), mu.tail(decrement);
			    xNotJ.head(rr+1) = zStar.head(rr+1);
				xNotJ.tail(currentDim - 1) << redRunSample.row(sim-1).segment(drawIndex-countj, countj).transpose(),
				  redRunSample.row(sim-1).segment(drawIndex+1, decrement).transpose();
				countj++;
				Hxy << precision.row(j).head(countj + rr).transpose(), 
					precision.row(j).tail(decrement).transpose(); 
				condMeanIndex = drawIndex + JdimensionReductionIndex;
				muj = distributionObject.conditionalMean(Hxx(j), Hxy, muNotJ, xNotJ, mu(j));
				redRunSample(sim, drawIndex) = distributionObject.truncNormalRnd(a(j), b(j), muj, sigmaVect(j));
				redRunSample(sim,  condMeanIndex) = muj;
				drawIndex++;
		   	}
		}
		if(rr == redRuns-1){
			zStar.tail(2) << redRunSample.col(drawIndex - JdimensionReductionIndex).tail(rrSampleSize).mean(),
				redRunSample.col(drawIndex- JdimensionReductionIndex + 1).tail(rrSampleSize).mean();

		}else{
			zStar(rr+1) = redRunSample.col(drawIndex - JdimensionReductionIndex).tail(rrSampleSize).mean();
			drawIndexStartValue = condMeanIndex + 1;
			drawIndex = drawIndexStartValue;
			JdimensionReductionIndex--;
		}
		currentDim--;	
	}
	redRunSample = redRunSample.bottomRows(rrSampleSize);
	fillfzStar(fzStar, redRuns, a,b, redRunSample, sigmaVect, zStar);
	Hxy = precision.row(Jminus1).head(Jminus1);
	muNotJ = mu.head(Jminus1);
	xNotJ = zStar.head(Jminus1);
	muj = distributionObject.conditionalMean(Hxx(Jminus1), Hxy , muNotJ, xNotJ, mu(Jminus1));
	fzStar(Jminus1) = distributionObject.tnormpdf(a(Jminus1), b(Jminus1), muj, sigmaVect(Jminus1), zStar(Jminus1));
	cout << "Finished\n" << endl;
} 
 

