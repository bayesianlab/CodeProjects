// { Driver Code Starts
#include <bits/stdc++.h>
using namespace std;

// } Driver Code Ends
class Solution
{
public:
    vector<string> find_permutation(string S)
    {
        int perms = S.size();
        vector<string> X = permutations(S); 
        sort(X.begin(), X.end());
        return X; 
    }

private:
    vector<string> permutations(string S)
    {
        vector<string> X;
        sort(S.begin(), S.end()); 
        X.push_back(S);
        while(next_permutation(S.begin(), S.end()))
        {
            X.push_back(S); 
        }
        return X;
    }
};

int main()
{
    Solution s;
    string U = "ljr";
    vector<string> sol = s.find_permutation(U);
    for(auto const b:sol)
    {
        cout << b << endl; 
    }
    return 1;
}
