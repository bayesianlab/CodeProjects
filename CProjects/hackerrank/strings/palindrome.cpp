#include <bits/stdc++.h>
using namespace std;

// } Driver Code Ends
class Solution
{
public:
    string longestPalin(string S)
    {
        string max_string = S.substr(0, 1);
        string x = longestPalinUtil(S, max_string);
        return x;
    }

private:
    string longestPalinUtil(string S, string &max_string)
    {
        if (S.size() == 0)
        {
            return max_string;
        }
        string first;
        for (int i = 0; i < S.size(); ++i)
        {
            first.push_back(S[i]);
            if (isPalindrome(first))
            {
                if (first.size() > max_string.size())
                {
                    max_string = first;
                }
            }
        }
        if (max_string.size() > S.size())
        {
            return max_string;
        }
        else
        {
            return longestPalinUtil(S.substr(1, S.size() - 1), max_string);
        }
    }

    bool isPalindrome(string first)
    {
        if (first.size() <= 1)
        {
            return true;
        }
        else
        {
            if (first[0] == first[first.size() - 1])
            {
                return isPalindrome(first.substr(1, first.size() - 2));
            }
            else
            {
                return false;
            }
        }
    }
};

int main()
{
    Solution s;
    string p = "qaabzbaaq";
    cout << s.longestPalin(p) << endl;
    return 0;
}
