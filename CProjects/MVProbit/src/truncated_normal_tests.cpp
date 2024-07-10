#include "Distributions.hpp"
#include "EigenTools.hpp"
#include <Eigen/Dense>

using namespace Eigen;
using namespace std;

int main(){
    cout << "truncated normal tests" << endl; 
    if (abs(normalpdf(1,0,1) - 0.2419707) > 1e-7){
        cout << "Test failed" << endl; 
    }
    else{
        cout << "Test normalpdf, m 0, v 1, passed" << endl; 
    }

    if ( abs(normalpdf(1,1,1) - 0.3989423) > 1e-7){
        cout << "Test failed" << endl; 
    }
    else{
        cout << "Test normalpdf, mean 1, v 1, passed" << endl; 
    }

    if (normalpdf(.5,-1,1) - 0.2419707 > 1e-7){
        cout << "Test failed" << endl; 
    }
    else{
        cout << "Test normalpdf, mean -1, v 1, passed" << endl; 
    }

    if (abs(normalpdf(1,-1,2) -  0.1037769) > 1e-7){
        cout << "Test failed" << endl; 
    }
    else{
        cout << "Test normalpdf, mean -1, v 2 passed" << endl; 
    }

    if(abs(lognormalpdf(1,0,2) - (-1.515512)) > 1e-6){
        cout << "Test failed" << endl; 
    }
    else{
        cout << "Test lognormalpdf, m 0, v 2 passed" << endl; 
    }  

    if(abs(tnormpdf_onesided(1, 0, .5, 1) - 0.5091604) > 1e-7){
        cout << "Test failed" << endl; 
    }else{
        cout << "Test, truncated left 0, m .5, v 1, passed" << endl; 
    }

    if(abs(tnormpdf_onesided(.5, 0, -.5, 1) - 0.7842505) > 1e-7){
        cout << "Test failed" << endl; 
    }else{
        cout << "Test, truncated right 0, m .5, v 1, passed" << endl; 
    }

    if(abs(tnormpdf_onesided(.5, 0, .5, 4) - 0.3331703) > 1e-7){
        cout << "Test failed" << endl; 
    }else{
        cout << "Test, truncated left 0, m .5, v 4, passed" << endl; 
    }


    if(abs(logtnormpdf_onesided(.5, 0, .5, 4) - (-1.099102)) > 1e-6){
        cout << "Test failed" << endl; 
        cout << logtnormpdf_onesided(.5, 0, .5, 4) << endl; 
    }else{
        cout << "Test, log truncated left 0, m .5, v 4, passed" << endl; 
    }

    RowVectorXd x = RowVectorXd::Ones(3); 
    MatrixXd Sig = CreateSigma(-.3, 3); 
    RowVectorXd mu = RowVectorXd::Ones(3).array() - .5; 

    if(abs(logmvnpdf(x, mu, Sig) - (-3.251791)) > 1e-6){
        cout << "Test failed" << endl; 
    }
    else{
        cout << "Test MVN passed" << endl; 
    }

    if(abs(tnormcdf_onesided(1, 0, 0, 1) - 0.6826895)>1e-7){
        cout << "Test failed" << endl; 
    }
    else{
        cout << "Test tnormcdf x=1, m=0, v=1, left = 0 passed. " << endl; 
    }

    if(abs(tnormcdf_onesided(1, 0, 1, 1) - 0.4057133)>1e-7){
        cout << "Test failed" << endl; 
        cout << tnormcdf_onesided(1, 0, 1, 1) << endl; 
    }
    else{
        cout << "Test tnormcdf x=-1, m=1, v=1, left = 0 passed. " << endl; 
    }

    double prob = 1-tnormcdf_onesided(1, 0, .5, 1);
    if(abs(prob - 0.4462101)>1e-7){
        cout << "Test failed" << endl; 
        cout << prob << endl; 
    }
    else{
        cout << "Test tnormcdf x=-1, m=.5, v=1, right = 0 passed. " << endl; 
    }

    
}


