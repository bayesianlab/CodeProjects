__author__ = 'dillonflannery-valadez'
import math, random, pylab
import wx

total = 0.0
for i in range(1, 8):
    total  += (-1.0/6)** i
print total

total = 0.0
for i in range(1, 11):
    total += 8 * (8** (i-1))
    # print i, total
    # raw_input()
print total

total = 0.0
for i in range(1,11):
    total += 3**(i-1)
print total