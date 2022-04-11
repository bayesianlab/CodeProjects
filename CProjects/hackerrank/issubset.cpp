// { Driver Code Starts
#include <bits/stdc++.h>
using namespace std;

string isSubset(int a1[], int a2[], int n, int m);

int main()
{
    int n = 6;
    int m = 4;
    int a1[n] = {11, 1, 13, 21, 3, 7};
    int a2[m] = {11, 3, 7, 1};

    cout << isSubset(a1, a2, n, m) << endl;

    return 0;
}
// } Driver Code Ends

string isSubset(int a1[], int a2[], int n, int m)
{
    unordered_map<int, int> x;
    for (int i = 0; i < n; ++i)
    {
        x[*(a1 + i)]++;
    }
    // for(const auto &p:x)
    // {
    //     cout << p.first << " " << p.second  << endl;
    // }
    for (int i = 0; i < m; ++i)
    {
        if (x.find(a2[i]) == x.end())
        {
            return "No";
        }
    }

    return "Yes";
}