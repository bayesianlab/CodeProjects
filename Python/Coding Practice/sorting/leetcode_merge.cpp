#include <bits/stdc++.h>
using namespace std;

class Solution {
public:
    void merge(vector<int>& nums1, int m, vector<int>& nums2, int n) {
        int i = 0;
        int j = 0;
        
        while((i < m) && (j < n)){
            if(nums1[i] > nums2[j]){
                int k = 0; 
                while((nums1[i] > nums2[k]) && (k < n)){
                    int t = nums1[i];
                    nums1[i] = nums2[k];
                    nums2[k] = t;
                    ++k;
                }
            }
            ++i

            

        }
        for(int k = 0; k < nums2.size(); ++k){
            nums1[k+m] = nums2[k];
        }

    }
};

int main(){
    cout << "merging" << endl; 
    Solution s; 
    int n = 3;
    int m = 4;
    vector<int> nums1(n+m); 
    vector<int> nums2(m); 
    nums1={1,2,4, 10};
    nums2={1,3,10};
    s.merge(nums1, m, nums2, n); 
    for(int i = 0; i < m+n; ++i){
        cout << nums1[i] << endl; 
    }
}