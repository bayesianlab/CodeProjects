#include <bits/stdc++.h>
using namespace std;

struct node
{
    int data;
    struct node *next;

    node(int x)
    {
        data = x;
        next = NULL;
    }
};

/* Function to print linked list */
void printList(struct node *node)
{
    int c = 0;
    while (node != NULL)
    {
        printf("%d ", node->data);
        node = node->next;
        ++c;
    }
    printf("\n");
}

class Solution
{
public:
    struct node *reverse(struct node *head, int k)
    {
        struct node *templast;
        struct node *newnext;
        struct node *other;
        struct node *otherlast;
        struct node *newhead;
        int c = 1;
        int nodecount = 1;
        if (head->next == NULL)
        {
            return head;
        }
        else if (k == 1)
        {
            return head;
        }
        else
        {
            while (head != NULL)
            {
                newnext = head->next;
                if (c == 1)
                {
                    other = head;
                    ++c;
                }
                else if (c == k)
                {
                    if (nodecount == k)
                    {
                        newhead = head;
                        newhead->next = templast;
                    }
                    else if (nodecount > k)
                    {
                        otherlast->next = head;
                        head->next = templast;
                    }
                    else
                    {
                        head->next = templast;
                    }
                    c = 1;
                    otherlast = other;
                }
                else
                {
                    head->next = templast;
                    ++c;
                }
                templast = head;
                head = newnext;
                nodecount++;
            }
            if (c != 1)
            {
                if (nodecount < k)
                {
                    newhead = templast;
                    struct node *copy;
                    copy = templast;
                    while (copy != templast->next)
                    {
                        templast = templast->next;
                    }
                    templast->next = NULL;
                    return newhead;
                }
                else
                {
                    otherlast->next = templast;
                    if (templast->next == NULL)
                    {
                        return newhead;
                    }
                    else
                    {
                        struct node *copy;
                        copy = templast;
                        while (copy != templast->next)
                        {
                            templast = templast->next;
                        }
                        templast->next = NULL;
                        return newhead;
                    }
                }
            }
            else
            {
                otherlast->next = NULL;
                return newhead;
            }
        }
        return newhead;
    }
};

int main()
{
    Solution s;
    int t = 10000;
    node *x = new node(1);
    node *head = x;
    for (int i = 1; i < t; ++i)
    {
        node *y = new node(i + 1);
        x->next = y;
        x = x->next;
    }
    printList(head);
    head = s.reverse(head, 100);
    printList(head);

    // struct node *z = new node(1);
    // struct node *u = new node(2);
    // struct node *r = new node(3);
    // struct node *p, *m;
    // z->next = u;
    // u->next = NULL;
    // r->next = z;
    // p = z;
    // cout << p->next->data << endl;
    // cout << p << endl;
    // cout << z << endl;
    // cout << r->next << endl;
}