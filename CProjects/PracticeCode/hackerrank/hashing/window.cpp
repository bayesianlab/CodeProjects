#include <bits/stdc++.h>
using namespace std;

// } Driver Code Ends

class Solution
{
public:
    vector<int> countDistinct(int A[], int n, int k)
    {
        unordered_map<int, int> um;
        vector<int> sol;
        int distinct = 0;
        for (int i = 0; i < k; ++i)
        {
            if (um[*(A + i)] == 0)
            {
                distinct++;
            }
            um[*(A + i)]++;
        }
        sol.push_back(distinct);
        for (int i = k; i < n; ++i)
        {
            if (um[A[i - k]] == 1)
            {
                distinct--;
            }
            um[A[i - k]]--;

            if (um[*(A + i)] == 0)
            {
                distinct++;
            }

            um[*(A + i)]++;
            sol.push_back(distinct);
        }
        return sol;
    }
};

// { Driver Code Starts.
int main()
{

    int n = 7, k = 4;

    int a[n] = {1, 2, 1, 3, 4, 2, 3};

    Solution obj;
    vector<int> result = obj.countDistinct(a, n, k);
    for (int i : result)
        cout << i << " ";
    cout << endl;

    return 0;
}