#include <stdio.h>
#include <stdlib.h>

struct Node
{
    int data;
    struct Node *next;

} * start;

int getNthFromLast(struct Node *head, int n)
{
    int c = 0;
    struct Node *nth = head;
    struct Node *otherhead = head;
    while (head != NULL)
    {
        ++c;
        if (c > n)
        {
            nth = nth->next;
        }

        head = head->next;
    }
    if (n > c)
    {
        return -1;
    }
    else if (nth != otherhead)
    {
        return nth->data;
    }
    else
    {
        return otherhead->data;
    }
}

int main()
{
    Node *one = (Node *)malloc(sizeof(Node *));
    Node *two = (Node *)malloc(sizeof(Node *));
    Node *three = (Node *)malloc(sizeof(Node *));
    Node *four = (Node *)malloc(sizeof(Node *));
    Node *five = (Node *)malloc(sizeof(Node *));
    one->data = 1;
    two->data = 2;
    three->data = 3;
    four->data = 4;
    five->data = 5;
    one->next = two;
    two->next = three;
    three->next = four;
    four->next = five;
    five->next = NULL;
    printf("%d\n", getNthFromLast(one, 6));
}