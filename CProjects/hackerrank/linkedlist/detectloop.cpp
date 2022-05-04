// { Driver Code Starts
// Initial template code for C++

#include <bits/stdc++.h>
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

bool detectLoop(Node *head)
{
    queue<int> Q;
    int truth = 0;
    struct Node *H = head;
    while (head->next != NULL)
    {
        Q.push(head->data);
        head->data = -1;
        if (head->next->data == -1)
        {
            truth = 1;
            break;
        }
        head = head->next;
    }
    head = H;
    while (!Q.empty())
    {
        head->data = Q.front();
        Q.pop(); 
    }
    if (truth == 1)
    {
        return true;
    }
    return false;
}

int main()
{
    Node *one = new Node(1);
    Node *two = new Node(2);
    Node *three = new Node(3);

    one->next = two;
    two->next = three;
    three->next = two;
    cout << detectLoop(one) << endl;
}