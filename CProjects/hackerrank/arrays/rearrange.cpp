#include <bits/stdc++.h>
using namespace std;

class Solution
{
public:
    // This function wants you to modify the given input
    // array and no need to return anything
    // arr: input array
    // n: size of array
    // Function to rearrange  the array elements alternately.
    void rearrange(long long *arr, int n)
    {
        int i, even, odd, endlist, temp;
        queue<int> X;
        stack<int> Y;
        i = 0;
        endlist = n - 1;
        even = 0;
        odd = 1;
        temp = arr[n / 2];

        int half = (n / 2);

        if (n == 2)
        {
            long long t = arr[0];
            arr[0] = arr[1];
            arr[1] = t;
        }
        else if (n > 2)
        {

            while (even <= endlist)
            {
                if (odd < (n / 2))
                {
                    X.push(arr[even]);
                    X.push(arr[odd]);
                    arr[even] = arr[endlist];
                    arr[odd] = X.front();
                    X.pop();
                }
                else if (even == (n / 2) - 1)
                {
                    X.push(arr[even]);
                    Y.push(arr[odd]);
                    arr[even] = arr[endlist];
                    arr[odd] = X.front();
                    X.pop();
                }
                else if (endlist <= odd)
                {
                    if (endlist == even)
                    {
                        arr[even] = arr[endlist];
                        arr[odd] = X.front();
                        X.pop();
                    }
                    else
                    {
                        Y.push(arr[even]);
                        arr[even] = arr[endlist];
                        arr[odd] = X.front();
                        X.pop();
                    }
                }
                else
                {
                    Y.push(arr[even]);
                    Y.push(arr[odd]);
                    arr[even] = arr[endlist];
                    arr[odd] = X.front();
                    X.pop();
                }
                // for (int i = 0; i < n; ++i)
                // {
                //     cout << *(arr + i) << " ";
                // }
                cout << endl;
                ++i;
                even = 2 * i;
                odd = 2 * i + 1;
                endlist -= 1;
            }
            X.push(temp);
            int even2 = even - 1;
            for (int j = i; j < (n / 2); ++j)
            {
                even = 2 * j;
                odd = 2 * j + 1;
                arr[even] = Y.top();
                arr[odd] = X.front();
                X.pop();
                Y.pop();
            }
            if (n % 2)
            {
                if (half % 2)
                {
                    arr[n - 1] = X.front();
                    Y.pop();
                }
                else
                {
                    arr[n - 1] = X.front();
                    X.pop();
                }
            }
        }
    }
};

int main()
{
    Solution s;
    int n = 1;
    long long x[] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17};
    s.rearrange(x, n);
    for (int i = 0; i < n; ++i)
    {
        cout << *(x + i) << " ";
    }
    cout << endl;
    
    cout << 9%10*10 << endl; 
}