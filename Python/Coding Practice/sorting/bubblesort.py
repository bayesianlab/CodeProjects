#%%

def bubblesort(arr):

    N = len(arr)
    while 1:
        swap = False 
        i = 1
        j = i
        while i < N:
            if arr[i-1] > arr[i]:
                t = arr[i-1]
                arr[i-1] = arr[i]
                arr[i] = t
                j = i 
                swap = True  
            i += 1
        N = j
        if not swap:
            break 
arr = [5,4,3,2,1]
bubblesort(arr)
print(arr)
# %%
[set() for _ in range(9)]
# %%
r = [[1,2,3], [4,5,6]]
# %%
