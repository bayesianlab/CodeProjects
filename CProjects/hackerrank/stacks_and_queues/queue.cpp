#include <stdio.h>
#include <stdlib.h>

// A linked list (LL) node to store a queue entry
struct QNode
{
    int key;
    struct QNode *next;
};

// The queue, front stores the front node of LL and rear stores the
// last node of LL
struct Queue
{
    struct QNode *front, *rear;
};

// A utility function to create a new linked list node.
struct QNode *newNode(int k)
{
    struct QNode *temp = (struct QNode *)malloc(sizeof(struct QNode));
    temp->key = k;
    temp->next = NULL;
    return temp;
}

// A utility function to create an empty queue
struct Queue *createQueue()
{
    struct Queue *q = (struct Queue *)malloc(sizeof(struct Queue));
    q->front = q->rear = NULL;
    return q;
}

// The function to add a key k to q
void push(struct Queue *q, int k);

// Function to remove a key from given queue q
void pop(struct Queue *q);

void printq(struct Queue *q)
{
    struct QNode *t = q->rear;
    while (t != NULL)
    {
        printf("%d ", t->key);
        t = t->next;
    }
    printf("\n");
}

// Driver Program to test anove functions
int main()
{
    struct Queue *q = createQueue();
    struct QNode *one = (QNode *)malloc(sizeof(QNode));
    struct QNode *two = (QNode *)malloc(sizeof(QNode));
    struct QNode *three = (QNode *)malloc(sizeof(QNode));
    struct QNode *othertwo = (QNode *)malloc(sizeof(QNode));
    push(q, 2);
    push(q, 3);
    printq(q);
    pop(q);
    printq(q); 
    push(q, 4); 
    printq(q);
    pop(q);
    printq(q); 


    return 0;
}

// } Driver Code Ends

// User function Template for C

// The function to add a key k to q
void push(struct Queue *q, int k)
{
    struct QNode *u = (QNode *)malloc(sizeof(QNode *));
    u->key = k;
    if ((q->rear == NULL) && (q->front == NULL))
    {
        q->rear = u;
        q->front = u;
    }
    else
    {
        struct QNode *x = q->rear;
        u->next = x;
        q->rear = u;
    }
}

// Function to remove a key from given queue q
void pop(struct Queue *q)
{
    if (q->rear == NULL)
    {
        return;
    }
    else if (q->rear == q->front)
    {
        printf("%d\n", q->rear->key); 
        q->rear = NULL;
        q->front = q->rear;
        return;
    }
    else
    {
        struct QNode *t = q->rear;
        while (t->next != q->front)
        {
            t = t->next;
        }
        q->front = t;
        printf("%d\n", t->next->key);
        t->next = NULL;
    }
}