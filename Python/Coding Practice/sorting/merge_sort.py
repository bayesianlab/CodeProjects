#%%
import numpy as np 

def merge(A, s, m, e):
    L1 = [] 
    L2 = [] 
    for i in range(s, m + 1):
        L1.append(A[i])
    for j in range(m + 1, e + 1):
        L2.append(A[j])
    L1.append(np.inf)
    L2.append(np.inf)
    print(L1)
    print(L2)

    i = 0
    j = 0
    for k in range(s,e+1):
        if L1[i] < L2[j]:
            A[k] = L1[i]
            i += 1
        else:
            A[k] = L2[j]
            j += 1

def mergesort(A, s,e):
    if s < e:
        q = (s + e)//2
        mergesort(A, s, q)
        mergesort(A, q+1,e)
        merge(A, s,q,e)

# %%
A = [5,4,3,2,1]
mergesort(A, 0, len(A)-1)
# %%
A
# %%
