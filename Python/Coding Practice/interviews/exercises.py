#%% 
"""
Find when 2 nums of a sorted array sum to a target. Return the indexes
Exercise page 10 Coding Interview Patterns
"""
arr = [-5,-2,3,4,6]

def pair_two_pointer(arr, t):
    l = 0 
    r = len(arr) -1
    while l < r:
        if arr[l] + arr[r] == t:
            return (l,r)
        if arr[l] + arr[r] < t:
            l += 1
        if arr[l] + arr[r] > t:
            r -= 1
    return (None, None)

pair_two_pointer(arr, 7)
# %%
"""
Triplet sum
"""
arr = [0,-1,2,-3,1,1]
def triplet_sum(arr):
    arr.sort()
    print(arr)
    res = []
    k = None 
    j = None 
    prev = None 
    for i in range(1,len(arr)):
        if arr[i] != arr[i-1]:
            k,j = pair_two_pointer(arr[i:], -arr[i-1])
        if (k and j) and (arr[k] != prev):
            res.append((arr[i-1], arr[k+i], arr[j+i]))
            prev = arr[k]
    return res 
triplet_sum(arr)

# %%
