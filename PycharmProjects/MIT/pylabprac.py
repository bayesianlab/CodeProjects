__author__ = 'dillonflannery-valadez'
import pylab
import random
x = []
for i in range(0,10):
    x.append(random.randint(0,10))
pylab.hist(x)
pylab.show()