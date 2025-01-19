#%%
import pandas as pd 
import numpy as np 

#%%

word = 'recrudescence'

stack = [] 

for i in word:
    stack.append(i)
print(stack)
while len(stack) > 0:
    print(stack.pop()) 
# %%

class Node:

    def __init__(self, val):
        self.next = None 
        self.value = val 


class LinkedList:

    def __init__(self):
        self.head = None 
        self.tail = None 

    def push(self, val):
        if not self.head:
            self.head = Node(val)
            self.tail = self.head 
        else:
            self.head.next = Node(val)
            self.head = self.head.next 
        
    def print(self):
        tmp = self.tail 
        while tmp is not None:
            print(tmp.value)
            tmp = tmp.next 


class Stack:

    def __init__(self):
        self.head = None 
    
    def push(self, v):
        n = Node(v)
        if self.head is None:
            self.head = n 
        else:
            n.next = self.head 
            self.head = n 
    
    def pop(self):
        if self.head is not None:
            v = self.head.value 
            self.head = self.head.next 
            return v 
        else:
            return None 

class Queue:

    def __init__(self):
        self.head = None
        self.tail = None  

    def push(self, v):
        n = Node(v)
        if self.head is None:
            self.head = n 
            self.tail = self.head 
        else:
            self.head.next = n 
            self.head = self.head.next 

    def pop(self):
        v = self.tail.value 
        self.tail = self.tail.next 
        return v 



q = Queue()
q.push(1)
q.push(2)
q.push(3)
print(q.pop())
print(q.pop())
print(q.pop())
# %%
