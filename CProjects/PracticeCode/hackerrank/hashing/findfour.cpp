// { Driver Code Starts
#include <bits/stdc++.h>
using namespace std;

// } Driver Code Ends
// User function template for C++

class Solution
{
public:
    // arr[] : int input array of integers
    // k : the quadruple sum required

    void makecomb(vector<vector<int>> &combs, vector<int> indices, int n, int k, int start = 0)
    {
        if (indices.size() == k)
        {
            combs.push_back(indices);
            return;
        }
        for (int i = start; i < n; ++i)
        {
            indices.push_back(i);
            makecomb(combs, indices, n, k, i + 1);
            indices.pop_back();
        }
    }

    vector<vector<int>> fourSum(vector<int> &arr, int k)
    {
        sort(arr.begin(), arr.end());
        int left, right;
        vector<vector<int>> x;
        vector<int> tmpsol(4);
        int n = arr.size();
        for (int i = 0; i < arr.size(); ++i)
        {
            cout << arr[i] << " ";
        }
        cout << endl;
        for (int i = 0; i < n - 4; ++i)
        {
            for (int j = i + 1; j <= n - 3; ++j)
            {
                left = j + 1;
                right = n - 1;
                while (left < right)
                {
                    if ((arr[i] + arr[j] + arr[left] + arr[right]) == k)
                    {
                        tmpsol[0] = arr[i];
                        tmpsol[1] = arr[j];
                        tmpsol[2] = arr[left];
                        tmpsol[3] = arr[right];
                        x.push_back(tmpsol);
                    }
                    if ((arr[i] + arr[j] + arr[left] + arr[right]) < k)
                    {
                        left++;
                    }
                    else
                    {
                        right--;
                    }
                }
            }
        }
        set<vector<int>> unique(x.begin(), x.end());
        x.resize(unique.size());
        copy(unique.begin(), unique.end(), x.begin());
        return x;
    }

    void printsol(vector<vector<int>> &sol)
    {
        for (int i = 0; i < sol.size(); ++i)
        {
            for (int j = 0; j < sol[i].size(); ++j)
            {
                cout << sol[i][j] << " ";
            }
            cout << endl;
        }
    }
};

int main()
{
    vector<int> arr = {43, 70, 83, 90, 99, 72, 25, 44, 90, 5, 39, 54, 86, 69,
                       82, 42, 64, 97, 7, 55, 4, 48, 11, 22, 28, 99, 43, 46, 68, 40,
                       22, 11, 10, 5, 1, 61, 30, 78, 5, 20, 36, 44, 26, 22, 65, 8, 16};
    Solution s;
    vector<vector<int>> ans = s.fourSum(arr, 325);
    s.printsol(ans);

    return 0;
}
