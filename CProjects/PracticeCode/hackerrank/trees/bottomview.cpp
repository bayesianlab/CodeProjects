#include <bits/stdc++.h>
using namespace std;
#define MAX_HEIGHT 100000

// Tree Node
struct Node
{
    int data;
    Node *left;
    Node *right;
};

// Utility function to create a new Tree Node
Node *newNode(int val)
{
    Node *temp = new Node;
    temp->data = val;
    temp->left = NULL;
    temp->right = NULL;

    return temp;
}

class Solution
{
public:
    void bottomViewUtil(Node *root, unordered_map<int, int> &mp, int &pos)
    {
        if (root)
        {
            cout << root->data << " " << pos << endl; 
            mp[pos] = root->data;
        }
        if (root->right)
        {
            ++pos;
            root = root->right; 
            cout << root->data << " " << pos << endl; 
            mp[pos] = root->data; 
            if (root->left)
            {
                bottomViewUtil(root->left, mp, --pos);
            }
            bottomViewUtil(root, mp, pos); 
        }
    }

    vector<int> bottomView(Node *root)
    {
        unordered_map<int, int> mp;
        stack<Node *> old;
        int depth = 0; 
        while (root)
        {
            old.push(root);
            ++depth; 
            root = root->left;
        }
        cout << depth << endl; 
        int pos = -1;
        while (!old.empty())
        {
            Node *t = old.top();
            old.pop(); 
            bottomViewUtil(t, mp, ++pos); 
            cout << endl; 
        }
        cout << endl; 
        for(const auto &p : mp)
        {
            cout << p.first << " " << p.second << endl; 
        }
    }
};

int main()
{
    Node *a = newNode(20);
    Node *b = newNode(8);
    Node *c = newNode(22);
    Node *d = newNode(5);
    Node *e = newNode(3);
    Node *f = newNode(4);
    Node *g = newNode(25);
    Node *h = newNode(10);
    Node *i = newNode(14);
    a->left = b;
    a->right = c;
    b->left = d;
    b->right = e;
    c->left = f;
    c->right = g;
    e->left = h;
    f->right = i; 
    Solution s;
    s.bottomView(a);
}