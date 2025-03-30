# Quicksort
#%%
def partition(arr, b, e):
    N = e- b 
    pivot = arr[e-1]
    j = 0 
    for i in range(0, e):
        if arr[i] < pivot:
            t = arr[i]
            arr[i] = arr[j]
            arr[j] = t
            j += 1
    t = arr[j]
    arr[j] = arr[e-1]
    arr[e-1] = t
    return j 


arr = [8,1,2,0,7, 11]


# %%
def quicksort(arr, b ,e):
    if e - b > 1:
        j = partition(arr, b, e)
        quicksort(arr, b, j-1)
        quicksort(arr, j + 1, e)
    
# %%
quicksort(arr,0, len(arr))

# %%

def merge(arr, p, q, r):
    L = [] 
    R = [] 
    for i in range(p, q):
        L.append(arr[i])
    for j in range(q, r+1):
        R.append(arr[j])
    L.append(max(arr)*100)
    R.append(max(arr)*100)
    i,j = 0,0
    for k in range(p,r+1):
        if L[i] <= R[j]:
            arr[k] = L[i]
            i += 1
        else:
            arr[k] = R[j]
            j += 1

# %%

def mergesort(arr, p,r):

    if p < r:
        mid = (r+p+1)//2
        print(arr[p:mid])
        print(arr[mid:r+1])
        mergesort(arr, p, mid-1)
        mergesort(arr, mid, r)
        merge(arr, p, mid, r)
# %%
arr = [1,2,4,3, 0]

mergesort(arr, 0, len(arr)-1)
# %%


def insertion_sort(arr):
    for i in range(1, len(arr)):
        k = arr[i] 
        j = i - 1
        while j > -1 and arr[j] > k:
            arr[j+1] = arr[j]
            j -= 1 
        arr[j+1] = k 

arr = [1,2,4,3, 0]

insertion_sort(arr)
arr
#%%

def shift(nums, k):
    shifts = k % len(nums)
    
    j = len(nums) - shifts - 1 
    i = 0
    while i < j:
        t = nums[i] 
        nums[i] = nums[j]
        nums[j] = t
        i+=1
        j -= 1

    i = len(nums) - shifts  
    j = len(nums) - 1
    while i < j:
        t = nums[i]
        nums[i] = nums[j]
        nums[j] = t
        i += 1
        j -= 1

    i = 0
    j = len(nums) -1 
    while i < j:
        t = nums[i] 
        nums[i] = nums[j] 
        nums[j] = t 
        i += 1 
        j -= 1


nums = [1,2,3,4,5,6,7]
shift(nums, 3)
nums 
# %%
def maxProfit(prices):
    i = 0
    j = i + 1
    mp = 0 
    while j < len(prices):
        p = prices[j] - prices[i]
        print(i,j, p) 
        if p > 0:
            mp += p
        i = j 
        j += 1
          
    return mp 

prices = [7,1,5,3,6,4]

maxProfit(prices)

#%%
# nums = [2,0,6,9,8,4,5,0,8,9,1,2,9,6
# ,8,8,0,6,3,1,2,2,1,2,6,5,3,1,2,2,6,4,2,4,3,0,0,
# 0,3,8,2,4,0,1,2,0,1,4,6,5,8,0,7,9,3,4,6,6,5,8,9,3,
# 4,3,7,0,4,9,0,9,8,4,3,0,7,7,1,9,1,9,4,9,0,1,9,5,7,
# 7,1,5,8,2,8,2,6,8,2,2,7,5,1,7,9,6]
# nums = [2,3,1,1,4]



nums = [7,0,9,6,9,6,1,7,9,0,1,2,9,0,3]

def canJump(nums):
    idx = 0 
    jumper(nums, idx) 




        
    
    
    
        

#%%

nums = [2,3,1,1,1,4]

    
# nums = [0]
# nums = [1, 0]
# nums = [1,1,1,0]
# nums = [3,2,1,0,4]
# nums = [1,2,1,1,1]
# nums = [7,0,9,6,9,6,1,7,9,0,1,2,9,0,3]

def jump(nums):
    
    for i in range(1, len(nums)):
        nums[i] = max(nums[i] + i, nums[i-1])

    j = 0
    r = 0
    
    while j < len(nums) - 1:
        r += 1 
        j = nums[j] 
        

    return r


        
print(jump(nums))
        


# %%
citations =[3,0,6,1,5]
def hIndex(citations):
    citations.sort()
    gt = [len(citations)]
    k = 0
    for i in range(1, len(citations)):
        if citations[i]==citations[i-1]:
            gt.append(len(citations) - k) 
        else:
            k = i
            gt.append(len(citations) - k) 

    c = 0
    hidx = 0
    for i in range(len(citations)):
        if hidx < min(citations[i], gt[i]):
            hidx = min(citations[i], gt[i])
    return hidx

hIndex(citations)
# %%
gas = [5,1,2,3,4]
cost =[4,4,1,5,1]
def canCompleteCircuit(gas, cost):
    diff = []
    starts = [] 
    for i in range(len(gas)):
        if gas[i] - cost[i] >= 0:
            starts.append(i)
        diff.append(gas[i] - cost[i])
    l = max(diff) 
    while len(starts) > 0:
        m = max(diff)
        if m < l:
            break  
        j = diff.index(m)
        
        acc = 0
        while 1:
            acc += diff[j]
            if acc < 0:
                break 
            j += 1 

            if j > len(gas) - 1:
                j = 0
            if j == i:
                return i 
        
    return -1

# canCompleteCircuit(gas, cost)
gas = [2]
cost = [2]
canCompleteCircuit(gas, cost)
# %%
