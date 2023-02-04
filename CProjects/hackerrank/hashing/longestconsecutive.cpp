// { Driver Code Starts
#include <bits/stdc++.h>
using namespace std;

// } Driver Code Ends
class Solution
{
public:
    // arr[] : the input array
    // N : size of the array arr[]

    // Function to return length of longest subsequence of consecutive integers.
    int findLongestConseqSubseq(int arr[], int N)
    {
        map<int, int> freq;
        for (int i = 0; i < N; ++i)
        {
            freq[*(arr + i)]++;
        }
        int seq=1;
        int seq_last = 1; 
        map<int, int>::iterator it = freq.begin(); 
        int last = it->first; 
        it++; 
        for (it; it != freq.end(); ++it)
        {
            // cout << "(" << it->first << ", " << it->second << ")" << endl;
            if (!it->first)
            {
                seq = 1;
            }
            else if (last + 1 != it->first)
            {
                seq = 1;
            }
            else
            {
                seq++;
            }
            if(seq > seq_last)
            {
                seq_last = seq; 
            }
            last = it->first; 
        }
        return seq_last;
    }
};

// { Driver Code Starts.

// Driver program
int main()
{

    int a[] = {2, 6, 1, 9, 4, 5, 3};
    int n = 7;
    Solution obj;
    cout << obj.findLongestConseqSubseq(a, n) << endl;

    return 0;
}