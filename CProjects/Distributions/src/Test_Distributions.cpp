#include <chrono>
#include <iostream>
#include <Plotter.hpp>
#include <Eigen/Dense>
#include <boost/random/mersenne_twister.hpp>

#include "Distributions.hpp"

using namespace std;

int main(int argc, char *argv[])
{

    int on = 0;
    int shiftedexponential = 0;
    int truncnorm = 1;
    if (on)
    {
        int n = 3;
        // cout << logdet(sig) << endl;
        // VectorXd y = x.transpose();
        // VectorXd m = mu.transpose();
        MatrixXd sig = MatrixXd::Identity(n, n);
        sig = .5 * sig;
        VectorXd x(n);
        x << 0, 0, 0;
        VectorXd mu(n);
        mu << .5, .5, 1;
        cout << logmvnpdf(x.transpose(), mu.transpose(), sig) << endl;
        cout << "Correct solution "
             << "-3.21709" << endl;

        double alpha;
        double beta;
        int N = 10000;
        alpha = 50.0;
        beta = 50.0;
        VectorXd G = igammarnd(alpha, 1.0 / beta, N);
        cout << G.mean() << endl;
        cout << "Analytical solution: mean -> " << beta / (alpha - 1) << " as n -> infty" << endl;

        VectorXd c = G.array() - G.mean();
        cout << (1.0 / N) * (c.transpose() * c) << endl;
        cout << "Variance: Analytical solution is " << pow(beta, 2) / (pow(alpha - 1, 2) * (alpha - 2)) << endl;

        MatrixXd H(10000, 100);
        for (int j = 0; j < 100; ++j)
        {

            for (int i = 0; i < 10000; ++i)
            {
                H(i, j) = gammarnd(6, 5);
            }
        }
        cout << H.colwise().mean() << endl;
        cout << "Should appoximately = 30" << endl;
        cout << sig << endl;
        cout << normrnd(0, 1) << endl;
        cout << "\n";
        cout << mu << endl;
        cout << "mvnrnd" << endl;
        cout << mvnrnd(mu.transpose(), sig, 5) << endl;
        cout << "Uniform" << endl;
        cout << unifrnd(0, 1, 10, 10) << endl;
        cout << "Chi squared" << endl;
        cout << chi2rnd(1, 10) << endl;
        cout << chi2rnd(1, 5, 5) << endl;
        cout << "Wishart" << endl;
        cout << wishrnd(MatrixXd::Identity(10, 10), 10) << endl;
        mu.setZero(3);
        x.setOnes(3);

        sig = CreateSigma(.5, 3);
        cout << logmvtpdf(x, mu, sig, 15) << endl;
        cout << "Correct answer"
             << " -3.3695" << endl;

        VectorXd RandVals = unifrnd(1, 10, 10);
        cout << "Correct Answer:" << endl;
        cout << log(RandVals.mean()) << endl;
        RandVals = RandVals.array().log();
        cout << "Should be equal to:" << endl;
        cout << logavg(RandVals) << endl;
        RandVals = unifrnd(1, 100, 1000);
        cout << "Correct Answer:" << endl;
        cout << log(RandVals.mean()) << endl;
        RandVals = RandVals.array().log();
        cout << "Should be equal to:" << endl;
        cout << logavg(RandVals) << endl;
    }

    if(shiftedexponential)
    {
        VectorXd V = shiftedExponential(-2, 1, 1000);
        writeToCSVfile("V.csv", V);
        cout << normalCDF(0) << endl;
        cout << normalCDF(1) << endl; 
        cout << normalCDF(-1) << endl; 
    }

    if(truncnorm)
    {
        VectorXd Y = NormalTruncatedPositive(1,1,10000);
        writeToCSVfile("Y.csv", Y);
    }

    return 0;
}