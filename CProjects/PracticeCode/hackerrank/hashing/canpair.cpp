// { Driver Code Starts
#include <bits/stdc++.h>
using namespace std;

// } Driver Code Ends
class Solution
{
public:
    bool canPair(vector<int> nums, int k)
    {
        if ((nums.size() % 2))
        {
            return false;
        }
        else
        {
            unordered_map<int, int> mmap;
            int pair = 0;
            int pairs = nums.size() / 2;
            for (const auto &c : nums)
            {
                int rem = c % k;
                mmap[rem]++;
            }
            unordered_map<int, int>::iterator mapit;
            // for (const auto &p : mmap)
            // {
            //     cout << p.first << " " << p.second << endl;
            // }
            if(mmap[0]%2)
            {
                return false; 
            }
            else
            {
                mmap.erase(0);
            }
            for (mapit = mmap.begin(); mapit != mmap.end(); mapit++)
            {

                if (mmap.find(k - mapit->first) != mmap.end())
                {
                    if (mmap[k - mapit->first] != mmap[mapit->first])
                    {
                        return false;
                    }

                }
                else
                {
                    return false;
                }
            }
            // for (const auto &p : mmap)
            // {
            //     cout << p.first << " " << p.second << endl;
            // }
            return true;
        }
    }
};

int main()
{

    vector<int> nums = {13, 11, 9, 3, 7, 1};
    int k = 4;
    Solution ob;
    bool ans = ob.canPair(nums, k);
    if (ans)
        cout << "True\n";
    else
        cout << "False\n";

    return 0;
}