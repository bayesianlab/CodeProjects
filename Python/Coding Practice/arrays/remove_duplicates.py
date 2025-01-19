#%%

class Solution(object):
    def removeDuplicates(self, nums):
        """
        :type nums: List[int]
        :rtype: int
        """
        if len(nums) > 1:
            i,j, c,k  = 1, 0, 0, 0
            N = len(nums)

            while i < N:
                if nums[j] == nums[i]:
                    c += 1
                    if c >= 2:
                        nums[i] = None                     
                        k += 1
                else:
                    c = 0
                    j = i 
                i += 1
            i,j = 0,0
            first_none = True 
            while i < N:
                while i < N and nums[i] is not None:
                    if not first_none:
                        nums[j] = nums[i] 
                        nums[i] = None
                        j += 1  
                    i += 1
                if first_none:
                    j = i
                first_none = False 

                while i < N and nums[i] is None:
                    i += 1
            return N - k 
                

        
                        

nums = [1,1,1,1,2,2,2,3,3,3,4,4,4,4]
s = Solution() 
print(s.removeDuplicates(nums))
nums = [1,1,1,2,2,3]
print( s.removeDuplicates(nums) )
nums = [0,0,1,1,1,1,2,3,3]
print( s.removeDuplicates(nums))                    



# %%
