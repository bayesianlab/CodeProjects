#include <iostream>
#include <eigen3/Eigen/Dense>
#include <boost/random/mersenne_twister.hpp>
#include "MultilevelModel.hpp"

using namespace std;

int main(int argc, char *argv[])
{
    int n = 2;
    VectorXd gammas(n);
    gammas << .2, .2;
    VectorXd vars = VectorXd::Ones(1);
    MatrixXd r = MatrixXd::Ones(9, 3);
    VectorXd d(3);
    d << 1, 2, -4;
    int on = 1;
    if (on)
    {
        CreateDiag(r, d, 10, 10);
        try
        {
            sequence(-1, -3);
        }
        catch (invalid_argument)
        {
            cout << "invalid arg" << endl;
        }
        cout << "1-10" << endl;
        cout << sequence(1, 10).transpose() << endl;
        cout << "-3 - -1" << endl;
        cout << sequence(-3, -1).transpose() << endl;
        cout << "-10 10 by 2" << endl;
        cout << sequence(-10, 10, 2).transpose() << endl;
        cout << "-3 3 by 3" << endl;
        cout << sequence(-3, 3, 3).transpose() << endl;
        cout << "-5 to 10 by 3" << endl;
        cout << sequence(-5, 10, 3).transpose() << endl;
        cout << "make state space" << endl;
        cout << makeStateSpace(gammas.transpose()) << endl;
        VectorXd gammas2(4);
        gammas2 << .2, .2, .2, .2;
        cout << "amke state sapce 2" << endl;
        cout << makeStateSpace(gammas2.transpose()) << endl;
        MatrixXd gammas3(2, 1);
        gammas3 << .2, .2;
        VectorXd vars3(2);
        vars3 << 1,1;
        cout << "make state space 3" << endl;
        cout << makeStateSpace(gammas3) << endl;
        MatrixXd gammas4(2, 2);
        gammas4 << .2, .2, .3, .3;
        cout << "make state space 4" << endl;
        cout << makeStateSpace(gammas4) << endl;
        cout << "set covariance" << endl;
        cout << setCovar(gammas.transpose(), vars) << endl;
        cout << " set covariance 2" << endl;
        VectorXd vars2 = VectorXd::Ones(1);
        cout << setCovar(gammas2.transpose(), vars2) << endl;
        cout << "Create Diagonal" << endl;
        VectorXd gammas5(4);
        gammas5 << -.1, -.2, -.3, 1;
        MatrixXd G5;
        G5 = gammas5.transpose().replicate(10, 1);
        cout << G5 << endl;
        cout << CreateDiag(G5, sequence(-4, -1), 10, 10) << endl;
        cout << "Make Precision" << endl; 
        cout << MakePrecision(gammas.transpose(), vars, setCovar(gammas.transpose(), vars), 10) << endl;
        cout << "Make Precision 2" << endl; 
        cout << MakePrecision(gammas2.transpose(), vars2, setCovar(gammas2.transpose(), vars2), 10) << endl; 
        cout << "Make Precision 3" << endl; 
        cout << MakePrecision(gammas3, vars3, setCovar(gammas3, vars3), 10) << endl; 
        cout <<" Make Precision 4" << endl; 
        cout << MakePrecision(gammas4, vars3, setCovar(gammas4, vars3), 10) << endl; 

    }

    return 0;
}