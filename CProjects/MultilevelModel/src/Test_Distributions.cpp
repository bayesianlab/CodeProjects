#include <chrono>
#include <iostream>

#include <eigen-3.3.9/Eigen/Dense>
#include <boost/random/mersenne_twister.hpp>

#include "Distributions.hpp"

using namespace std;

int main(int argc, char *argv[])
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
    int on = 0;
    if (on)
    {
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
        RowVectorXd mu = RowVectorXd::Zero(3);
        RowVectorXd x = RowVectorXd::Ones(3);
        sig = CreateSigma(.5, 3);
        cout << logmvtpdf(x, mu, sig, 15) << endl;
        cout << "Correct answer"
             << " -3.3695" << endl;
 
    }

    return 0;
}