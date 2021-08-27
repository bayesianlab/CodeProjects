#include <stdio.h>
#include "GenerateAutoRegressiveData.hpp"
int main()
{
    int T = 10;
    MatrixXd p(1, 3);
    p << .1, .15, .3;
    MatrixXd params = p.replicate(1, 1);

    GenerateAutoRegressiveData gar(T, params, .5);
    cout << gar.yt << endl;

    return 0;
}
