#include <bits/stdc++.h>
using namespace std;

// Tree Node
struct Node
{
    int data;
    Node *left;
    Node *right;
};

Node *newNode(int val)
{
    Node *temp = new Node;
    temp->data = val;
    temp->left = NULL;
    temp->right = NULL;

    return temp;
}

vector<int> leftprint(Node *root)
{
    stack<Node *> prev;
    Node *temp;
    prev.push(root);
    vector<int> ans;
    while (!prev.empty())
    {
        for (int i = 0; i < prev.size(); ++i)
        {
            temp = prev.top();
            prev.pop();
            if (i == 0)
            {
                ans.push_back(temp->data);
            }
            if (temp->left)
            {
                prev.push(temp->left);
            }
            if (temp->right)
            {
                prev.push(temp->right);
            }
        }
    }
    return ans;
}

int main()
{
    Node *one = newNode(1);
    Node *two = newNode(2);
    Node *three = newNode(3);
    one->left = two;
    one->right = three;
    vector<int> x;
    int z = 0;
    x = leftprint(one);
    for (int i = 0; i < x.size(); ++i)
    {
        cout << x[i] << endl;
    }
}