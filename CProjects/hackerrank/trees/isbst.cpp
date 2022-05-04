#include <bits/stdc++.h>
using namespace std;
#define MAX_HEIGHT 100000

// Tree Node
struct Node
{
    int data;
    Node *left;
    Node *right;

    Node(int val)
    {
        data = val;
        left = right = NULL;
    }
};

// } Driver Code Ends
class Solution
{
public:
    // Function to check whether a Binary Tree is BST or not.

    bool isBSThelp(Node *root, int min, int max)
    {
        if (root == NULL)
        {
            return true;
        }
        // cout << root->data << " " << min << " " << max << endl; 
        if ((root->data > max) || (root->data < min))
        {

            return false;
        }
        if ((root->left != NULL) && (root->left->data > root->data))
        {
            return false;
        }
        if ((root->right != NULL) && (root->right->data < root->data))
        {
            return false;
        }
        if (!isBSThelp(root->left, min, root->data) || !isBSThelp(root->right, root->data, max))
        {
            return false;
        }
        else
        {
            return true;
        }
    }
    
    bool isBST(Node *root)
    {
        int b = numeric_limits<int>::max();
        int a = numeric_limits<int>::min();
        if(isBSThelp(root, a, b))
        {
            return true;
        }
        else{
            return false; 
        }
    }
};

int main()
{
    Solution s;

    Node *center = new Node(2);
    Node *left = new Node(1);
    Node *right = new Node(3);
    center->left = left;
    center->right = right;

    cout << s.isBST(center) << endl;

    Node *a = new Node(10);
    Node *b = new Node(5);
    Node *c = new Node(18);
    Node *d = new Node(2);
    Node *e = new Node(9);
    Node *f = new Node(15);
    Node *g = new Node(19);
    Node *h = new Node(4);
    Node *i = new Node(8);
    Node *j = new Node(11);
    a->left = b;
    a->right = c;
    b->left = d;
    b->right = e;
    c->left = f;
    c->right = g;
    d->left = NULL;
    d->right = h;
    e->left = i;
    e->right = NULL;
    f->left = j;
    f->right = NULL;
    g->left = NULL;
    g->right = NULL;
    int inf = numeric_limits<int>::max();
    cout << s.isBST(a) << endl; 
}