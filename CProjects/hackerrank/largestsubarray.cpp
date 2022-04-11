#include <bits/stdc++.h>
using namespace std;

class Solution
{
public:
    int maxLen(vector<int> &A, int n)
    {
        int sum = 0;
        map<int, vector<int>> X;
        vector<int> sums(n);
        if (A.size() < 2)
        {
            return n;
        }

        for (int i = 0; i < n; ++i)
        {
            sum += A[i];
            sums[i] = sum;
        }
        if (sum == 0)
        {
            return n;
        }
        for (int i = 0; i < n; ++i)
        {
            X[sums[i]].push_back(i);
        }

        int cur_max = 0;
        int prev_dist = 0;
        int dist = 0;

        for (auto const &p : X)
        {
            if (p.second.size() > 1)
            {
                if (p.first == 0 && p.second.size() >= 1)
                {
                    dist = p.second[p.second.size() - 1] + 1;
                    if (dist > prev_dist)
                    {
                        cur_max = dist;
                        prev_dist = dist;
                    }
                }
                else
                {
                    dist = p.second[p.second.size() - 1] - p.second[0];
                    if (dist > prev_dist)
                    {
                        cur_max = dist;
                        prev_dist = dist;
                    }
                }
            }
        }
        return cur_max;
    }
};

int main()
{
    int N = 8;
    vector<int> A = {15, -2, 2, -8, 1, 7, 10, 23};
    Solution s;
    cout << s.maxLen(A, N) << endl;
}