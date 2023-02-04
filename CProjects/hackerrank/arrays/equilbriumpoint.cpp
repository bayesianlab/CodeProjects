// { Driver Code Starts
#include <iostream>
using namespace std;

// } Driver Code Ends
class Solution
{
public:
    // Function to find equilibrium point in the array.
    // a: input array
    // n: size of array
    int equilibriumPoint(long long a[], int n)
    {
        if(n == 1)
        {
            return 1; 
        }
        int mid = n / 2 - 1;
        int midlast = mid;
        int endarr, begarr, sumbeg, sumend, maxit, c;
        endarr = n - 1;
        begarr = 0;
        while ((mid < endarr) && (mid > begarr))
        {

            sumbeg = 0;
            sumend = 0;
            c = 0;
            maxit = max(mid, endarr - mid);
            while (c < maxit)
            {
                ++c;
                if (begarr < mid)
                {
                    sumbeg += *(a + begarr);
                    ++begarr;
                }
                if (endarr > mid)
                {
                    sumend += *(a + endarr);
                    --endarr;
                }
            }
            // cout << "mid " << mid << " sumbeg " << sumbeg << " sumend " << sumend << endl;
            if (sumend < sumbeg)
            {
                if (mid - 1 == midlast)
                {
                    break;
                }
                midlast = mid;
                --mid;
            }
            else if (sumend > sumbeg)
            {
                if (mid + 1 == midlast)
                {
                    break;
                }
                midlast = mid;
                ++mid;
            }
            else
            {
                return mid + 1;
            }
            endarr = n - 1;
            begarr = 0;
        }
        return -1;
    }
};

int main()
{
    Solution s;
    int n = 2;
    long long arr[] = {1,3};
    cout << s.equilibriumPoint(arr, n) << endl;
}