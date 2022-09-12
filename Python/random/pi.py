
import math
from re import X
import numpy as np

N = 100000000

x = np.random.uniform(0,1,(1,N))
y = np.random.uniform(0,1,(1,N))

ratio = (np.sqrt((x*x)+(y*y)) < 1).sum()/N
print(4*ratio)




