'''
Given a sorted array of distinct integers and a target value, 
return the index if the target is found. 
If not, return the index where it would be if it were inserted in order.
'''
#%%
class Solution(object):
    def searchInsert(self, nums, target):
        """
        :type nums: List[int]
        :type target: int
        :rtype: int
        """
        i, j = 0, len(nums)
        while i < j:
            m = (i + j) // 2 
            if nums[m] >= target:
                j = m 
            else:
                i = m + 1
        return i

nums = [1,3,5,6]

s = Solution()
print(s.searchInsert(nums, 5))


# %%
