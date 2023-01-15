#include <iostream> 
#include <bits/stdc++.h>

using namespace std; 

class Solution {
public:
    int numIdenticalPairs(vector<int>& nums) {
        map<int, vector<int>> goodpairs; 
        for(int i = 0; i < nums.size(); ++i){
            
            if(goodpairs.find(nums[i]) != goodpairs.end()){
                goodpairs[nums[i]].push_back(i);
            }else{
                goodpairs[nums[i]].push_back(i);
            }
        }
        int p = 0; 
        for(auto it = goodpairs.begin(); it != goodpairs.end(); ++it){
            int n = (it->second.size()-1);
            p += n*(n+1)/2; 

            for(auto jt = it->second.begin(); jt != it->second.end(); ++jt){
                cout << *jt << " ";
            }
            cout << endl; 
        }
        return p; 
    }
};

int main(){
    Solution s; 
    vector<int> nums = {1,2,3,1,1,3};
    cout << s.numIdenticalPairs(nums) << endl;
    return 0; 
}