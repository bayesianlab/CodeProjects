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
print(arr)