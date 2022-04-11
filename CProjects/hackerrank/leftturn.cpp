#include <bits/stdc++.h>

using namespace std;

string ltrim(const string &);
string rtrim(const string &);
vector<string> split(const string &);

void printv(vector<int> b)
{
    for(int i = 0; i < b.size(); ++i)
    {
        cout << b[i] << " ";
    }
    cout << endl; 
}

vector<int> rotLeft(vector<int> a, int d) {
    vector<int> b = a; 
    int c = 0;
    for(int j = a.size() - d; j < a.size(); ++j)
    {
        b[j]= a[c];
        ++c;
    }
    c = a.size()-1;
    for(int j = a.size() - d - 1; j >=0; --j)
    {
        b[j] = a[c];
        --c;
    }
    return b;
}


int main()
{
    int d = 4;
    vector<int> a{1,2,3,4,5};
    vector<int> b = rotLeft(a, d);
    printv(b);
    
}