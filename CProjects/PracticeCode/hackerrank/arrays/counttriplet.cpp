#include <bits/stdc++.h>
using namespace std;
class Solution
{
public:
    bool binsearch(int sum, int b, int e, int arr[])
    {
        int m;
        while (b <= e)
        {
            m = (b + e) / 2;
            if (arr[m] == sum)
            {
                return true;
            }
            else if (arr[m] < sum)
            {
                b = m + 1;
            }
            else
            {
                e = m - 1;
            }
        }
        max()
        return false;
    }

    int countTriplet(int arr[], int n)
    {
        int sum = 0;
        int sol = 0;
        int c;
        sort(arr, arr + n);

        for (int i = 0; i < n; ++i)
        {
            sum = arr[i];
            for (int j = i + 1; j < n; ++j)
            {
                sum += arr[j];
                // cout << "i j " << i << " " << j << endl;
                if (binsearch(sum, j + 1, n - 1, arr))
                {
                    // cout << "i j " << i << " " << j << endl;
                    sol++;
                }
                sum -= arr[j];
            }
        }
        return sol;
    }
};

int main()
{
    int A[] = {1, 2, 3, 4};
    int n = 4;
    Solution s;
    cout << s.countTriplet(A, n) << endl;
}
