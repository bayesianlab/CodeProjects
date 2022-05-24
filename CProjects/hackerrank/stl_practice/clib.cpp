#include <map>
#include <iostream>
#include <ostream>
#include <vector>
#include "useful.cpp"
using namespace std;

bool fpt(pair<int, int>, pair<int, int>);

void mysort(vector<int> &y);

pair<int, int> makepp(int a, int b);

typedef bool (*compfun)(pair<int, int>, pair<int, int>);

int main()
{
    multimap<pair<int, int>, int, compfun> m(fpt);
    pair<int, int> x1 = makepp(2, 4);
    pair<int, int> x2 = makepp(4, 3);
    pair<int, int> x3 = makepp(58, 78);
    pair<int, int> x4 = makepp(0, 78);
    m.insert(pair<pair<int, int>, int>(x1, 2));
    m.insert(pair<pair<int, int>, int>(x2, 0));
    m.insert(pair<pair<int, int>, int>(x3, 389));
    m.insert(pair<pair<int, int>, int>(x4, 28));

    multimap<pair<int, int>, int>::iterator j = m.begin();

    for (j; j != m.end(); ++j)
    {
        cout << (*j).first.first << " " << (*j).first.second << " " << (*j).second << endl;
    }

    cout << endl; 
    vector<int> Y = {1, 4, 3, 6, 7 , 2, 0 , 6, 9};
    mysort(Y);
    printvec(Y);

    return 0;
}

bool fpt(pair<int, int> x, pair<int, int> y)
{
    return x.second > y.second;
}

pair<int, int> makepp(int a, int b)
{
    pair<int, int> p1(a, b);
    return p1;
}

void mysort(vector<int> &y)
{
    for (int i = 0; i < y.size() - 1; ++i)
    {
        if (y[i] > y[i + 1])
        {
            int t = y[i];
            y[i] = y[i + 1];
            y[i + 1] = t;
            int j = i;
            while (j >= 1)
            {
                if (y[j] < y[j - 1])
                {
                    int t = y[j - 1];
                    y[j - 1] = y[j];
                    y[j] = t;
                }
                --j;
            }
        }
    }
}
