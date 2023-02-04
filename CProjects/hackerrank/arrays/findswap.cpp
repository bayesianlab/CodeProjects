// { Driver Code Starts
#include <bits/stdc++.h>
using namespace std;

// } Driver Code Ends
class Solution
{

public:
    int findSwapValues(int A[], int n, int B[], int m)
    {
        set<int> setA;
        set<int> setB;
        int sumA = 0, sumB = 0, tsumA, tsumB;
        int biggest = max(n, m);
        int i = 0;
        while (i < biggest)
        {
            if (i < n)
            {
                setA.insert(*(A + i));
                sumA += *(A + i);
            }
            if (i < m)
            {
                setB.insert(*(B + i));
                sumB += *(B + i);
            }
            ++i;
        }
        tsumA = sumA;
        tsumB = sumB;
        for (int i : setA)
        {
            for (int j : setB)
            {
                tsumA = sumA - i + j;
                tsumB = sumB - j + i;
                if(tsumA == tsumB)
                {
                    return 1;
                }
            }
        }
        return -1; 
    }
};

// { Driver Code Starts.

int main()
{

    int n = 6, m = 4;
    int a[n] = {4, 1, 2, 1, 1, 2};
    int b[m]{3, 6, 3, 3};

    Solution ob;
    cout << ob.findSwapValues(a, n, b, m);
    cout << "\n";

    return 0;
}