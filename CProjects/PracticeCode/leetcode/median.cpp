#include <bits/stdc++.h>
using namespace std;
/*
Given two sorted arrays nums1 and nums2 of size m and n respectively,
return the median of the two sorted arrays.
*/

class Solution {
 public:
  double findMedianSortedArrays(vector<int>& nums1, vector<int>& nums2) {
    int l1 = nums1.size();
    int l2 = nums2.size();
    int m = (l1 + l2) / 2;
    vector<int> L(l1 + l2);
    {
      int i = 0;
      int c = 0;
      int j = 0;
      while (j < l1+l2) {
        if(nums1[i] < nums2[c]){
            L[j] = nums1[i]; 
            ++j; 
            ++i;
        }
        else{
            L[j] = nums2[c]; 
            ++c;
            ++j; 
        }
        
      }
    }
    if ((l1 + l2) % 2) {
      return L[m];
    } else {
      return (L[m - 1] + L[m]) / 2.0;
    }
  }
};

int main() {
  Solution s;

  vector<int> n1 = {1, 3};

  vector<int> n2 = {2};

  cout << s.findMedianSortedArrays(n1, n2) << endl;
}

