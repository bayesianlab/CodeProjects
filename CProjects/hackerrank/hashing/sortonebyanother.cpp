// { Driver Code Starts
// Initial template for C++

#include <bits/stdc++.h>
using namespace std;

// } Driver Code Ends
// User function template in C++

class Solution
{
public:
    // A1[] : the input array-1
    // N : size of the array A1[]
    // A2[] : the input array-2
    // M : size of the array A2[]

    // Function to sort an array according to the other array.
    vector<int> sortA1ByA2(vector<int> A1, int N, vector<int> A2, int M)
    {
        map<int, int> order;
        vector<int> other; 
        int total = 0;
        for (int i = 0; i < M; ++i)
        {
            order[A2[i]];
        }

        for (int i = 0; i < N; ++i)
        {
            if (order.find(A1[i]) != order.end())
            {
                order[A1[i]]++;
                ++total;
            }
            else
            {
                other.push_back(A1[i]); 
            }
        }
        sort(other.begin(), other.end()); 
        map<int, int>::iterator p;
        int c = 0; 
        for(int i = 0; i < M; ++i)
        {
            int x = order[A2[i]];
            for(int j = 0; j < x; ++j)
            {
                A1[c] = A2[i]; 
                ++c;
            }
        }
        for(int i = 0; i < other.size(); ++i)
        {
            A1[c+i] = other[i]; 
        }
        return A1;
    }
};

// { Driver Code Starts.

int main(int argc, char *argv[])
{
    int n = 11;
    int m = 4;
    vector<int> a1 = {2, 1, 2, 5, 7, 1, 9, 3, 6, 8, 8};
    vector<int> a2 = {2, 1, 8, 3};

    Solution ob;
    a1 = ob.sortA1ByA2(a1, n, a2, m);

    for (int i = 0; i < n; i++)
        cout << a1[i] << " ";

    cout << endl;

    return 0;
}