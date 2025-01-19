#%%

def pivot(arr, l, h):
     
    px = (l + h) // 2
    left = l 
    right = h - 1
    p = arr[px]
    while 1:
        while arr[left] < p:
            left += 1
        while arr[right] > p:
            right -= 1
        if left >= right:
            return right 
        
        t = arr[left]
        arr[left] = arr[right]
        arr[right] = t
     
        

def quicksort(arr, l, h):
    if len(arr) == 2:
        pivot(arr, l, h)
     
    if l < h:
        px = pivot(arr, l, h)

        print(px)
        print(arr[px])


        quicksort(arr, l, px)

        quicksort(arr, px+1, h)
    

    

arr = [1,2,5,6, 7, 3, 4]
quicksort(arr, 0, len(arr))
print(arr)


# %%
