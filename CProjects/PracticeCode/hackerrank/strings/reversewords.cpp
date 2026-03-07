// { Driver Code Starts
#include <bits/stdc++.h>
using namespace std;

// } Driver Code Ends

class Solution
{
public:
    // Function to reverse words in a given string.
    string reverseWords(string S)
    {
        S = reverseWordsUtil(S);
        size_t b = 0;
        size_t p = 0;
        while (p != string::npos)
        {
            p = S.find_first_of('.', b);
            string t = reverseWordsUtil(S.substr(b, p-b));
            S.replace(b, p-b, t); 
            b = p+1; 
        }
        return S;
    }

private:
    string reverseWordsUtil(string S)
    {
        int beg = 0;
        int end = S.size() - 1;
        char c;
        while (beg <= end)
        {
            c = S[beg];
            S[beg] = S[end];
            S[end] = c;
            beg++;
            end--;
        }
        return S;
    }
};

int main()
{
    Solution s;
    string x = "pqr.mno.qxyz";
    cout << s.reverseWords(x) << endl;
    return 0;
}