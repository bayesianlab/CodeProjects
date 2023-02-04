#include <bits/stdc++.h>
using namespace std;

// } Driver Code Ends
// User function template for C++

class Solution
{
public:
    string rremove(string s)
    {
        if (s.length() == 0)
        {
            return s;
        }
        int d = 0;
        int eflag = 0;
        int xflag = 0;
        while (d < s.size())
        {
            int j = d + 1;
            while (s[d] == s[j] && j < s.size())
            {
                eflag = 1;
                xflag = 1;
                ++j;
            }
            if (eflag)
            {
                s.erase(d, j - d);
                eflag = 0;
            }
            else
            {
                ++d;
            }
        }
        if (xflag == 0)
        {
            return s;
        }
        else
        {
            return rremove(s);
        }
    }
};

int main()
{
    Solution s;
    // string x = "aaaahhsrrtts";
    string x = "acaaabbbacdddd";
    cout << s.rremove(x) << endl;
    return 0;
}