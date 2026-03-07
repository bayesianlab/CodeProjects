// { Driver Code Starts
// Initial template for C++

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
        if (node->next != NULL)
        {
            cout << node->data << " ";
        }
        node = node->next;
    }
    cout << "\n";
}

// } Driver Code Ends
/*Link list Node */
/*struct Node {
    int data;
    Node* next;

    Node(int x){
        data = x;
        next = NULL;
    }

};*/

class Solution
{
public:
    /* Should return data of middle node. If linked list is empty, then  -1*/
    int getMiddle(Node *head)
    {
        Node *temp = new Node(head->data);
        temp = head;
        int c = 0;
        while (head != NULL)
        {
            head = head->next;
            // if (head != NULL)
            // {
                ++c;

            // }
        }
        if (c > 0)
        {
            c -= 1;
        }
        int x = 0;
        if (c % 2)
        {
            c = c / 2 + 1;
            while (x < c)
            {
                temp = temp->next;
                ++x;
            }
            return temp->data;
        }
        else
        {
            c = c / 2;
            while (x < c)
            {
                temp = temp->next;
                ++x;
            }
            return temp->data;
        }
    }
};

int main()
{
    Solution s;
    int t;
    cin >> t;
    Node *x = new Node(1);
    int d;
    Node *head = new Node(d);
    head = x;
    int arr[] = {6, 49,30 ,11};
    for (int i = 0; i < t -1; ++i)
    {
        x->data = arr[i];
        Node *n = new Node(d);
        x->next = n;
        x = x->next;
    }
    printList(head);
    cout << s.getMiddle(head) << endl;
}