#include <bits/stdc++.h>
#include "useful.cpp"
using namespace std;

bool fpt(pair<int, int>, pair<int, int>);

void mysort(vector<int> &y);

pair<int, int> makepp(int a, int b);

typedef bool (*compfun)(pair<int, int>, pair<int, int>);

class Node
{
public:
    int data;
    Node *left;
    Node *right;
};

Node *maketree(vector<int> data)
{
    vector<int>::iterator it;
    vector<Node *> nodes;
    for (it = data.begin(); it != data.end(); ++it)
    {
        Node *n = new Node;
        n->data = *it;
        nodes.push_back(n);
    }
    vector<Node *>::iterator nodeit;
    queue<Node *> Q;
    Node *root = new Node;
    root = nodes[0];
    Q.push(nodes[0]);
    Node *n = NULL;
    int c = 0;
    for (nodeit = nodes.begin() + 1; nodeit != nodes.end(); ++nodeit)
    {
        n = Q.front();
        Q.pop();
        n->left = *nodeit;
        Q.push(*nodeit);
        nodeit++;
        if (nodeit != nodes.end())
        {
            n->right = *nodeit;
            Q.push(*nodeit);
        }
    }
    return root;
}

void printTreeDepthFirst(Node *root)
{
    if (root == NULL)
    {
        return;
    }
    cout << root->data << endl;
    printTreeDepthFirst(root->left);
    printTreeDepthFirst(root->right);
}

void printTree2(Node *root)
{
    queue<Node *> Q; 
    Q.push(root); 
    while(!Q.empty())
    {
        Node *n = Q.front(); 
        cout << n->data << endl; 
        Q.pop(); 
        if(n->left)
        {
            Q.push(n->left);
        }
        if(n->right)
        {
            Q.push(n->right); 
        }
    }
}

int main()
{
    multimap<pair<int, int>, int, compfun> m(fpt);
    pair<int, int> x1 = makepp(2, 4);
    pair<int, int> x2 = makepp(4, 3);
    pair<int, int> x3 = makepp(58, 78);
    pair<int, int> x4 = makepp(0, 78);
    m.insert(pair<pair<int, int>, int>(x1, 2));
    m.insert(pair<pair<int, int>, int>(x2, 0));
    m.insert(pair<pair<int, int>, int>(x3, 389));
    m.insert(pair<pair<int, int>, int>(x4, 28));

    multimap<pair<int, int>, int>::iterator j = m.begin();

    for (j; j != m.end(); ++j)
    {
        cout << (*j).first.first << " " << (*j).first.second << " " << (*j).second << endl;
    }

    cout << endl;
    vector<int> Y = {1, 4, 3, 6, 7, 2, 0, 6, 9};
    mysort(Y);
    printvec(Y);

    map<int, string> amap = {{1, "topgun"}, {2, "maverick"}, {3, "wolf"}};

    map<int, string>::const_iterator it;
    for (it = amap.begin(); it != amap.end(); ++it)
    {
        cout << it->first << " " << it->second << endl;
    }

    for (const auto &it : amap)
    {
        cout << it.first << " " << it.second << endl;
    }

    vector<int> treevals{1, 3, 6, 3, 2, 9, 10};
    Node *root = maketree(treevals);
    printTreeDepthFirst(root);
    printTree2(root);

    return 0;
}

bool fpt(pair<int, int> x, pair<int, int> y)
{
    return x.second > y.second;
}

pair<int, int> makepp(int a, int b)
{
    pair<int, int> p1(a, b);
    return p1;
}

void mysort(vector<int> &y)
{
    for (int i = 0; i < y.size() - 1; ++i)
    {
        if (y[i] > y[i + 1])
        {
            int t = y[i];
            y[i] = y[i + 1];
            y[i + 1] = t;
            int j = i;
            while (j >= 1)
            {
                if (y[j] < y[j - 1])
                {
                    int t = y[j - 1];
                    y[j - 1] = y[j];
                    y[j] = t;
                }
                --j;
            }
        }
    }
}
