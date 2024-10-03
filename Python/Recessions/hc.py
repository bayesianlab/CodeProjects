#%%
def getMinimumMoves(arr):
    N = len(arr)-1
    move = 0
    for c in range(N):
        prev = arr[c]
        for d in range(c, N+1):
            if prev > arr[d]:
                move += 1
                break
    return move

getMinimumMoves([1,0,1,0,1,0])
# %%
def findLowestStartingStair(jumps):
    stair_sum = 0
    m = 1
    cm = m 
    for i in range(len(jumps)):
        stair_sum += jumps[i]
        cm = abs(stair_sum)+1
        if cm > m:
            m = cm 
    return m

r = [1,-4,-2,3]
findLowestStartingStair(r)
# %%
def getMinCores(start, end):
    core = 1
    for i in range(len(start)):
        for j in range(i+1,len(end)):
            if end[i]==end[j]:
                core+=1
            if start[i]==start[j]:
                core+=1
            if end[i]==start[j]:
                core+=1


    return core
            
#%%    

a1 = [3,1,4, 7]
a2 = [3,2,4,10]


print(getMinCores(a1, a2))
#%%
a1 = [1,2,3]
a2 = [3,3,5]
print(getMinCores(a1, a2))
# %%

a1=[2,5,2,3,4]
a2=[3,7,4,6,10]


print(getMinCores(a1, a2))
# %%
