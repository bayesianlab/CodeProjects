#include <iostream> 
#include <vector> 
using namespace std; 
template <typename T>
void printvec(const vector<T> &x)
{
    for(int i = 0; i < x.size(); ++i)
    {
        cout << x[i] << " ";
    }
    cout << endl; 
}