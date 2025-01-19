#%%
class Solution(object):
    def merge(self, nums1, m, nums2, n):
        """
        :type nums1: List[int]
        :type m: int
        :type nums2: List[int]
        :type n: int
        :rtype: None Do not return anything, modify nums1 in-place instead.
        """
        if n == 0:
            return 
        i = 0
        merging = True 
        while merging:
            while (i < m) and (nums1[i] <= nums2[0]):
                i+=1
            t = nums1[i]
            nums1[i] = nums2[0]
            nums2[0] = t 
            j = 1
            while j < n:
                if nums2[j-1] > nums2[j]:
                    t = nums2[j-1]
                    nums2[j-1] = nums2[j]
                    nums2[j] = t 
                j += 1
            nums1[m+j] = nums2[j]
                
            if i >= m:
                merging = False 
        j = 0
        i = m
        while i + j < m + n:
            nums1[i+j] = nums2[j]
            j+=1

nums1 = [1,2,3,0,0,0]
m = 3
nums2 = [2,5,6]
n = 3
s = Solution()
s.merge(nums1, m, nums2, n)
print(nums1)
# %%
nums1 = [2,0]
m = 1
nums2 = [1]
n = 1
s = Solution()
s.merge(nums1, m, nums2, n)
print(nums1)
# %%
nums1 = [1,2,3,10, None, None, None]
m =  4
nums2 = [4,5,6]
n = 3
s = Solution()
s.merge(nums1, m, nums2, n)
print(nums1)
# %%
