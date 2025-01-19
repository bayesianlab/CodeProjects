class Node:
    def __init__(self, data) -> None:
        self.value = data
        self.Next = None


class linked_list:
    def __init__(self) -> None:
        self.head = None

    def addLast(self, data):
        if(self.head is None):
            self.head = Node(data)
        else:
            root = self.head
            while(root.Next is not None):
                root = root.Next
            root.Next = Node(data)

    def insert(self, data):
        if(self.head == None):
            print("is none ")
            self.head = Node(data)
        else:
            h = self.head
            while(h.Next is not None):
                h = h.Next
            h.Next = Node(data)

    def reverse(self):
        last = None
        cur = self.head
        while(cur is not None):
            temp = cur.Next
            cur.Next = last
            last = cur
            cur = temp
        self.head = last

    def printList(self):
        root = self.head
        while(root is not None):
            print(root.value)
            root = root.Next

#%%

class Node:
    def __init__(self, val, Node):
        self.val = val 
        self.next = Node


X0 = Node(1, None)
C = Node(10, X0)
B = Node(8, C)
A = Node(4, B)



def reverse(head):
    prev = None 

    while head is not None:
        tmp = head.next 
        head.next = prev 
        prev = head 
        head = tmp 
    return prev 
#%%
def recur_reverse(head, prev):
    if head.next is None:
        head.next = prev 
        return head 
    else:
        t = head.next 
        head.next = prev 
        return recur_reverse(t, head)



def disp(head):               
    while head is not None:
        print(head.val)
        head = head.next 

X0 = Node(1, None)
C = Node(10, X0)
B = Node(8, C)
A = Node(4, B)
# A = reverse(A)
h = recur_reverse(A, None)

disp(h)
# %%


D = Node('D', None)
C = Node('C', D)
B = Node('B', C)
D.next = B 
A = Node('A', B)

def cycledisp(head):
    its = 10
    t = 0
    while t < its:
        print(head.val)
        head = head.next 
        t+= 1
cycledisp(A)
# %%

def cycle_detect(head):
    i = head 
    j = head  
 
    m = 0
    while (j is not None) and (j.next is not None) and m<100:
        i = i.next 
        j = j.next.next 
        print(i.val, j.val)
        if i == j:
            return 1 
    return 0 

print(cycle_detect(A))
# %%
def maxArea(height):
    i = 0
    j = len(height) - 1
    m = 0
    
    while i < j:
        if height[i] < height[j]:
            a = height[i]*(j-i)
            i += 1 
        else:
            a = height[j]*(j-i)
            j -= 1
        if a > m:
            m = a 
            store = (i,j)
    return m

height = [1,8,6,2,5,4,8,3,7]
print(maxArea(height))
print(maxArea([1,1]))
# %%
class Solution:

    def lengthOfLongestSubstring(self, s):
        """
        :type s: str
        :rtype: int
        """
        if s == '':
            return 0
        if len(s)==1:
            return 1 
        m = 0 
        i = 0
        j = 0
        prior = {} 

        while i < len(s) and j < len(s):
            if (s[j] in prior) and prior[s[j]] >= i:
                i = prior[s[j]] + 1
            else:
                prior[s[j]] = j
                m = max(m, j - i + 1)  
                j += 1
              
            
            
        return m 







x = Solution()
s = "abcabcbb"
x.lengthOfLongestSubstring(s)
# s = 'bbbbbbbb'
# x.lengthOfLongestSubstring(s)
# s = 'aab'
# x.lengthOfLongestSubstring(s)
# s = "dvdf"
# x.lengthOfLongestSubstring(s)
# %%
