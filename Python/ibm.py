#%%
import pandas as pd 
import numpy as np

#%%
e = [1,-20,3,-2]
def maxMeetings(effectiveness):
    # Write your code here
    effectiveness.sort(reverse=True)
    
    max = 0
    msum = 0 
    neg = 0
    i = 0 
    while i < len(effectiveness):
        if effectiveness[i] > 0:
            max += 1
            msum += effectiveness[i] 
        else:
            msum += effectiveness[i] 
            if msum > 0:
                max+= 1 
        i+= 1
    print(max)


    

maxMeetings(e)


# %%
d = [")))()()((("]

    
def myConvert(ithstr, calls):
    if calls <= 1:
        stack = []
        substr = []  
        i = 0 
        if len(ithstr) % 2:
            return 0 
        if len(ithstr) <= 1:
            return 0
        while i < len(ithstr):
            if ithstr[i] == '(':
                stack.append('(') 
            elif ithstr[i] == ')' and len(stack) > 0:
                stack.pop() 
            else:
                substr.append(ithstr[i])
            i += 1

        x = ''.join(stack)
        y = ''.join(substr)
        
        calls += 1
        myConvert(x+y, calls)
        if len(stack) == 0:
            return 1 
        else:
            return 0
    else:
        return 0

def isConvertibleData(dataset):
    # Write your code here
    retArray = [] 
    for i in dataset:
        print(myConvert(i, 0))

isConvertibleData(d)
# %%
