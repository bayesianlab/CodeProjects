#include <bits/stdc++.h>
using namespace std;
class Solution
{
public:
    //Function to find a continuous sub-array which adds up to a given number.
    vector<int> subarraySum(int arr[], int n, long long s)
    {

        int c = 0;
        int ts;
        int tc = 0;
        vector<int> sol(1, -1);
        while (c < n)
        {
            tc = c;
            ts = 0;
            for (int i = c; i < n; ++i)
            {
                ts += arr[i];
                if (ts > s)
                {
                    break;
                }
                if (ts == s)
                {
                    sol[0] = tc + 1;
                    sol.push_back(i+1);
                    return sol;
                }
            }
            ++c;
        }
        return sol;
    }
};

int main()
{
    Solution s;
    int A[] = {1, 2, 3, 7, 5};
    int n = 5;
    int sum = 12;
    vector<int> x = s.subarraySum(A, n, sum);
    cout << x[0] << " " << x[1] << endl;

    int B[] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
    n = 10;
    sum = 15;
    x = s.subarraySum(B, n, sum);
    cout << x[0] << " " << x[1] << endl;

    return 0;
}