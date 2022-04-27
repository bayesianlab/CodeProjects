#include <bits/stdc++.h>
using namespace std;

 // } Driver Code Ends
//User function template for C++

class Solution{
public:
    string rremove(string s){
        stack<char> t; 
        t.push(s[0]); 
        int c = 1; 
        while(c < s.size())
        {
            if(t.top() == s[c])
            {
                t.pop(); 
                ++c; 
            }
            else
            {
                t.push(s[c]); 
            }
        }
    }
};