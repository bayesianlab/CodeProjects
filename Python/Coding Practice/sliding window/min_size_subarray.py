#%%
class Solution(object):
    def minSubArrayLen(self, target, nums):
        """
        :type target: int
        :type nums: List[int]
        :rtype: int
        """
        N = len(nums)
        s,j,i = 0,-1,-1
        m = N + 1
         
        while (j <= i) and (j < N-1):

            if (i < N-1) and (s < target):
                i += 1
                s += nums[i]
            elif s >= target:
                j += 1
                m = min(m, i - j + 1)
                s -= nums[j]
            else:
                break 
        if m == N + 1:
            return 0 
        else:
            return m 
            

        
         


        
                
        

        
# arr = [2,3,1,2,4,3]
# target = 7
s = Solution()
# print(s.minSubArrayLen(target, arr))
# arr = [1,4,4]
# target = 4
# print(s.minSubArrayLen(target, arr))
# arr = [12,28,83,4,25,26,25,2,25,25,25,12]
# target = 213
# print(s.minSubArrayLen(target, arr))
# arr = [5,1,3,5,10,7,4,9,2,8]
# target = 15
# print(s.minSubArrayLen(target, arr))
# %%
# nums = [1,1,1,1,1,1,1,1]
# target = 11
# print(s.minSubArrayLen(target, nums))

#%%
nums = [8]
target = 7
print(s.minSubArrayLen(target, nums))