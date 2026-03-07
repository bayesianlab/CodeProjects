#include <stdio.h>
#include <stdlib.h>

struct Node
{
    int data;
    struct Node *next;

} * start;

void insert();
void display(struct Node *head);

// } Driver Code Ends
// User function Template for C

struct Node *reverseList(struct Node *head)
{
    int c = 0;
    struct Node *x;
    struct Node *tail;
    struct Node *temp;
    tail = head; 
    temp = NULL;
    x = NULL; 
    while (tail != NULL)
    {
        x = tail->next;
        tail->next = temp; 
        temp = tail; 
        tail = x; 
    }
    return temp;
}

int main()
{
    int t;
    scanf("%d", &t);
    struct Node *n;
    struct Node *x = (struct Node *)malloc(sizeof(struct Node));
    struct Node *head = (struct Node *)malloc(sizeof(struct Node));
    head = x;
    for (int i = 0; i < t; ++i)
    {
        n = (struct Node *)malloc(sizeof(struct Node));
        n->next = NULL;
        x->data = i;
        x->next = n;
        x = x->next;
    }

    display(head);
    struct Node *tail = reverseList(head);
    display(tail);
}

void display(struct Node *head)
{
    while (head != NULL)
    {
        printf("%d ", head->data);
        head = head->next;
    }
    printf("\n");
}