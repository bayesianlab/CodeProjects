#include <bits/stdc++.h>

using namespace std;

class SinglyLinkedListNode
{
public:
    int data;
    SinglyLinkedListNode *next;
};

SinglyLinkedListNode *insertNodeAtPosition(SinglyLinkedListNode *llist, int data, int position)
{
    SinglyLinkedListNode *x = new SinglyLinkedListNode;
    if (position == 0)
    {
        x->data = data;
        x->next = llist;
        return x;
    }
    else
    {
        SinglyLinkedListNode *head = llist;
        SinglyLinkedListNode *y = new SinglyLinkedListNode;
        for (int i = 0; i < position - 1; ++i)
        {
            llist = llist->next;
        }
        y = llist->next;
        x->data = data;
        llist->next = x;
        x->next = y;
        return head;
    }
}

void printList(SinglyLinkedListNode *list)
{
    int c = 0;
    while (NULL != list)
    {
        cout << list->data << endl;
        list = list->next;
        ++c;
        if (c == 10)
        {
            break;
        }
    }
}

bool has_cycle(SinglyLinkedListNode *head)
{
    SinglyLinkedListNode *x;
    SinglyLinkedListNode *z;
    z = head;
    x = head->next;
    if (x == NULL)
    {
        return false;
    }
    else if (x == head)
    {
        return true;
    }
    else
    {
        while (x->next != NULL)
        {
            if (x->next == x)
            {
                return true;
            }
            while (x != head)
            {
                if (x->next == head)
                {
                    return true;
                }
                head = head->next;
            }
            x = x->next;
            head = z;
        }
        return false;
    }
}

bool has_cycle2(SinglyLinkedListNode *head)
{
    if(head == NULL)
    {
        return false;
    }
    if(head == head->next)
    {
        return true; 
    }
    if(head->next == NULL)
    {
        return false; 
    }
    SinglyLinkedListNode *np = new SinglyLinkedListNode;
    SinglyLinkedListNode *nnode = new SinglyLinkedListNode; 
    while(head != NULL)
    {
        if(head->next == np)
        {
            return true; 
        }
        nnode = head->next; 
        head->next = np;
        head = nnode; 
    }
    return false; 
}

int main()
{
    SinglyLinkedListNode *list = new SinglyLinkedListNode;
    SinglyLinkedListNode *p2 = new SinglyLinkedListNode;
    SinglyLinkedListNode *p3 = new SinglyLinkedListNode;
    list->data = 1;
    list->next = p2;
    p2->data = 16;
    p3->data = 7;
    p2->next = p3;
    // printList(list);
    SinglyLinkedListNode *y = insertNodeAtPosition(list, 5, 0);

    // printList(y);
    SinglyLinkedListNode *p4 = new SinglyLinkedListNode;
    p4->data = 10;
    p4->next = p2;
    p3->next = p4;
    SinglyLinkedListNode *z1 = new SinglyLinkedListNode;
    SinglyLinkedListNode *z2 = new SinglyLinkedListNode;
    SinglyLinkedListNode *z3 = new SinglyLinkedListNode;

    z1->data = 1;
    z1->next = z2; 
    z2->data = 0;
    z2->next = z3; 
    z3->data = -1;
    // z1->next = z2;
    // z2->next = z2;
    z3->next = z1;
    cout << has_cycle2(z2) << endl;
}