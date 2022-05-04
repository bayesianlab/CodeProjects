// { Driver Code Starts
// driver code

#include <iostream>
using namespace std;

struct Node
{
    int data;
    Node *next;

    Node(int val)
    {
        data = val;
        next = NULL;
    }
};

void loopHere(Node *head, Node *tail, int position)
{
    if (position == 0)
        return;

    Node *walk = head;
    for (int i = 1; i < position; i++)
        walk = walk->next;
    tail->next = walk;
}

bool isLoop(Node *head)
{
    if (!head)
        return false;

    Node *fast = head->next;
    Node *slow = head;

    while (fast != slow)
    {
        if (!fast || !fast->next)
            return false;
        fast = fast->next->next;
        slow = slow->next;
    }

    return true;
}

int length(Node *head)
{
    int ret = 0;
    while (head)
    {
        ret++;
        head = head->next;
    }
    return ret;
}

// } Driver Code Ends
/*
structure of linked list node:

struct Node
{
    int data;
    Node* next;

    Node(int val)
    {
        data = val;
        next = NULL;
    }
};

*/

class Solution
{
public:
    // Function to remove a loop in the linked list.
    void removeLoop(Node *head)
    {
        int arr[10000];
        Node *h = head;
        Node *runner = head;
        Node *prev;
        int distance, prev_distance, c = 0, has_loop = 0;
        prev_distance = 0;
        while (runner != NULL)
        {
            arr[c] = runner->data;
            runner->data = -1;
            if ((runner->next != NULL) && (runner->next->data == -1))
            {
                runner->next = NULL;
                ++c; 
                break; 
            }
            runner = runner->next;
            ++c;
        }
        runner = head; 
        for(int i = 0; i < c; ++i)
        {
            runner->data = *(arr +i);
            runner = runner->next; 
        }
        return;
    }
};

void printList(Node *Node)
{
    int c = 0;
    while (Node != NULL)
    {
        ++c;
        printf("%d ", Node->data);
        Node = Node->next;
    }
    printf("\n");
    printf("nodes %d\n", c);
}

int main()
{
    Node *one = new Node(1);
    Node *two = new Node(2);
    Node *three = new Node(3);

    one->next = two;
    two->next = three;
    three->next = two;
    Solution s;
    s.removeLoop(one);
    printList(one);
}