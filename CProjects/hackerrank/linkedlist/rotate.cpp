#include <bits/stdc++.h>
using namespace std;

struct Node
{
    int data;
    struct Node *next;
    Node(int x)
    {
        data = x;
        next = NULL;
    }
};

void printList(Node *node)
{
    while (node != NULL)
    {
        // if (node->next != NULL)
        // {
        cout << node->data << " ";
        // }
        node = node->next;
    }
    cout << "\n";
}

class Solution
{
public:
    // Function to rotate a linked list.
    Node *rotateRight(Node *head, int k)
    {

        int c = 0;
        int y = 0;
        struct Node *temp;
        struct Node *temp2;
        struct Node *newhead;
        temp = head;
        while (temp != NULL)
        {
            temp = temp->next;
            ++c;
        }

        if (k == c)
        {
            return head;
        }

        temp = head;
        int x = 0;
        while (x <= c - 1 - k)
        {
            if (x == c - 1 - k)
            {
                temp2 = temp->next;
                newhead = temp2;
                temp->next = NULL;
                while (temp2->next != NULL)
                {
                    temp2 = temp2->next;
                }
                temp2->next = head;
                break;
            }
            temp = temp->next;
            ++x;
        }
        return newhead;
    }

    Node *rotate(Node *head, int k)
    {
        int c = 0;
        Node *temphead = head;
        Node *beg = temphead;
        while (c < k - 1 && (temphead->next != NULL))
        {
            temphead = temphead->next;
            ++c;
        }
        if (temphead->next == NULL)
        {
            return head;
        }
        Node *x = temphead->next;
        Node *newhead = x; 
        while(x->next != NULL)
        {
            x = x->next;
        }
        x->next = head; 
        temphead->next = NULL; 
        return newhead;
    }
};

int main()
{
    Solution s;
    int t = 4;
    Node *x = new Node(1);
    Node *head = x;
    for (int i = 1; i < t; ++i)
    {
        Node *y = new Node(i + 1);
        x->next = y;
        x = x->next;
    }
    printList(head);
    head = s.rotate(head, 4);
    printList(head);
}