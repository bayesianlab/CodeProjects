#%%
#

def getMinCores(start, end):
    # Write your code here
    start_core = {}
    end_core = {} 
    n = 1
    for i in range(len(start)):
        if start[i] in start_core:   
            n += 1
            start_core.clear()
            end_core.clear()
            start_core[start[i]] = 1
        else:
            start_core[start[i]] = 1
        
        if end[i] != start[i] and end[i] in end_core:
            n += 1
            end_core.clear()
            start_core.clear() 
            end_core[end[i]] = 1
        else:
            end_core[end[i]] = 1
         
    return n 
         
# %%
s = [1,2,3]
e = [3,3,5]
getMinCores(s, e)

# %%
5
s = [2,5,2,3,4]
e = [3,7,4,6,10]
getMinCores(s,e)
# %%

s = [1,4,7]
e = [2,4,10]
getMinCores(s,e)
# %%
