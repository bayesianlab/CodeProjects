#include <bits/stdc++.h> 

using namespace std; 

class Solution {
public:
    void merge(vector<int>& nums1, int m, vector<int>& nums2, int n) {
        int c = 0;
        int d = 0;
        int y = -1; 
        for(int i = 0; i < nums1.size(); ++i){
            if(i>=m){
                nums1[i] = nums2[c]; 
                ++c;
            }
            else if(i < m){
                if(nums1[i] > nums2[d]){
                    int x = nums1[i]; 
                    nums1[i] = nums2[d];
                    if(y==-1)
                    {
                        while(x > nums2[d+1] && (d+1)<n){
                            ++d; 
                        }
                        if(d+1 == n && x > nums2[d+1]){
                            nums2[d] = x;
                            y=d;
                            --d;
                        }
                    }
                    else{
                        nums2[d] = x; 
                        --d; 
                    }

                }
            }    
        }
        for(int i = 0; i < nums1.size(); ++i){
            cout << nums1[i] << endl; 
        }
        cout << endl; 
        for(int i = 0; i < nums2.size(); ++i){
            cout << nums2[i] << endl; 
        }      
    }
};

int main()
{
    Solution s; 
    // vector<int> nums1a = {1,0}; 
    // vector<int> nums2a = {2};
    // s.merge(nums1a, 1, nums2a, 1); 
    vector<int> nums1b = {1,2,3,5,0,0,0}; 
    vector<int> nums2b = {2,3,4};
    s.merge(nums1b, 7, nums2b, 3); 
    vector<int> nums1c = {1,1,1,1,1,0,0,0,0,0}; 
    vector<int> nums2c = {0,0,0,0,0};
    s.merge(nums1c, 5, nums2c, 5); 
    return 0;
}