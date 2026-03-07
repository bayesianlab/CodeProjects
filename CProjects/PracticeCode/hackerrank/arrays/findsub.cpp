#include <bits/stdc++.h>
using namespace std;
#define ll long long

// } Driver Code Ends
// User function template for C++

class Solution
{
public:
    // Function to count subarrays with sum equal to 0.
    ll findSubarray(vector<ll> arr, int n)
    {
        int sum = 0;
        int indx = 0;
        map<int, vector<int>> indxmap; // stores where the sum became the orignal number again, these indexes
                                       // will sum to zero

        for (int i = 0; i < n; ++i)
        {
            sum += arr[i];
            if (indxmap.find(sum) != indxmap.end())
            {
                indxmap[sum].push_back(i);
            }
            else
            {
                indxmap[sum].push_back(i);
            }
        }
        ll sol = 0;
        for (const auto &p : indxmap)
        {

            cout << p.first << " ";
            if (p.second.size() >= 1)
            {
                for (int i = 0; i < p.second.size(); ++i)
                {
                    cout << p.second[i] << " ";
                }
                cout << endl;
            }
            else
            {
                cout << endl;
            }

            if (p.first == 0)
            {
                sol += ((p.second.size() + 1) * p.second.size()) / 2;
            }
            else if (p.second.size() >= 2)
            {
                sol += ((p.second.size() - 1) * p.second.size()) / 2;
            }

            // if (p.second.size() >= 2)
            // {
            //     if (((p.first == arr[0]) && (p.second[0] != 0)) || (p.first == 0))
            //     {
            //         sol += ((p.second.size() + 1) * p.second.size()) / 2;
            //     }
            //     else
            //     {
            //         sol += ((p.second.size() - 1) * p.second.size()) / 2;
            //     }
            // }
        }
        return sol;
    }
};

// { Driver Code Starts.
int main()
{

    vector<ll> arr = {0, -19, 20, -19, 6, -13, 3, -9, 6, 15, -16, 6, -3, -16, -3, -3, -4, 11, -12, 16, -10, 8, 6, 15, 14, 11, 7, 3, 8, 6};
    Solution ob;
    int n = arr.size();
    cout << ob.findSubarray(arr, n) << "\n";

    return 0;
}