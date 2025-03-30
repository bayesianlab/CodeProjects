#%%
class Solution:
    def rotate(self, nums, k) :
        """
        Do not return anything, modify nums in-place instead.
        """
        sh = k % len(nums)
        i = 0 
        j = k - 1
        while i < j:
        
            t = nums[i]
            nums[i] = nums[j]
            nums[j] = t 

            j -= 1
            i += 1
        
        j = len(nums) - 1
        i = k
        while i < j:
            t = nums[i] 
            nums[i] = nums[j] 
            nums[j] = t

            j -= 1
            i += 1
        
        i = 0
        j = len(nums) - 1
        while i < j:
            t= nums[i] 
            nums[i] = nums[j] 
            nums[j] = t 

            j -= 1
            i += 1

        print(nums)


                        
s = Solution()
nums = [1,2,3,4,5,6,7,8]
k = 5
s.rotate(nums, k)




          
          
                  
                
                
                

# %%
