#include "fib.hpp"

template <typename T>
void printvec(const vector<T> &x)
{
    for(int i = 0; i < x.size(); ++i)
    {
        cout << x[i] << " ";
    }
    cout << endl; 
}

int fibUtil(int n)
{
    if (n == 0)
    {
        return 0;
    }
    else if (n == 1)
    {
        return 1;
    }
    else
    {
        return fibUtil(n - 1) + fibUtil(n - 2);
        
    }
}

vector<int> fib(vector<int> n)
{
    vector<future<int>> X(n.size());
    for (int i = 0; i < n.size(); ++i)
    {
        X[i] = async(fibUtil, n[i]);
    }
    vector<int> y(n.size()); 
    for(int i = 0; i < X.size(); ++i)
    {
       y[i]= X[i].get(); 
    }
    return y;
}

