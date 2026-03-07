// { Driver Code Starts
// Initial template for C++

#include <bits/stdc++.h>
using namespace std;

// } Driver Code Ends
// User function template for C++

class Solution
{
public:
    int romanToDecimal(string &str)
    {
        unordered_map<char, int> roman;
        roman.insert({{'I', 1},
                      {'V', 5},
                      {'X', 10},
                      {'L', 50},
                      {'C', 100},
                      {'D', 500},
                      {'M', 1000}});
        int pm = 0;
        int total = 0;
        int cur;
        int next;
        int i = 0;
        while (i < str.length())
        {
            cur = roman[str[i]];
            next = roman[str[i + 1]];
            if (cur != next)
            {
                if (cur < next)
                {
                    pm += cur;
                    total += next - pm;
                    i += 2;
                    pm = 0;
                }
                else if (cur > next)
                {
                    pm += cur;
                    total += pm;
                    pm = 0;
                    ++i;
                }
            }
            else
            {
                pm += cur;
                ++i;
            }
        }
        total += pm;
        return total;
    }
};

int main()
{
    Solution s;
    string t = "MMMDCCXCIV";
    cout << s.romanToDecimal(t) << endl;
}