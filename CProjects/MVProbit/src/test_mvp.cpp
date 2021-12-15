
#include <iostream>
#include "mvp.hpp"

int main()
{
    cout << " Test mvp" << endl;
    MatrixXd zt = normrnd(0, 1, 3, 100);
    MatrixXd yt(3, 100);
    for (int i = 0; i < 100; ++i)
    {
        for (int j = 0; j < 3; ++j)
        {
            if (zt(i, j) > .5)
            {
                yt(i, j) = 1;
            }
            else
            {
                yt(i, j) = 0;
            }
        }
    }
    MatrixXd mut = normrnd(0, 1, 3, 100);

    drawLatentData(zt,yt,mut);
    cout << zt << endl; 

    return 1;
}