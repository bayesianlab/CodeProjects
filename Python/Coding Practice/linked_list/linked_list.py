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