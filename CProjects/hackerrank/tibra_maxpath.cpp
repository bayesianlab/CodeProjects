#include <bits/stdc++.h>

using namespace std;

string ltrim(const string &);
string rtrim(const string &);

/*
 * Complete the 'maximum_path' function below.
 *
 * The function is expected to return an INTEGER.
 * The function accepts INTEGER_ARRAY node_values as parameter.
 */

template <typename T>
void printvec(const vector<T> &x)
{
    for (int i = 0; i < x.size(); ++i)
    {
        cout << x[i] << " ";
    }
    cout << endl;
}

class Node
{
public:
    int data;
    Node *left;
    Node *right;
};

void printTree(Node *root)
{
    if (root == NULL)
    {
        return;
    }
    cout << root->data << endl;
    printTree(root->left);
    printTree(root->right);
}

void printTree2(Node *root)
{
    queue<Node *> Q;
    Q.push(root);
    while (!Q.empty())
    {
        Node *n = Q.front();
        cout << n->data << endl;
        Q.pop();
        if (n->left)
        {
            Q.push(n->left);
        }
        if (n->right)
        {
            Q.push(n->right);
        }
    }
}

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
    nodeit = nodes.begin();
    while (!Q.empty())
    {
        Node *t = Q.front();
        Q.pop();
        if (nodeit != nodes.end())
        {
            t->left = *nodeit;
            Q.push(t->left);
            ++nodeit;
            if (nodeit != nodes.end())
            {
                t->right = *nodeit;
                Q.push(t->right);
            }
            else
            {
                t->right = NULL;
            }
        }
        else
        {
            t->left = NULL;
            t->right = NULL;
        }
    }
    return root;
}

void takePath(Node *root, string &path, map<string, int> &pathmemo)
{
    if (root == NULL)
    {
        path.pop_back();
        return;
    }
    else
    {
        if (*path.rbegin() == '1')
        {
            pathmemo[path] = pathmemo[path.substr(0, path.size() - 1)] + root->data;
        }
        else if (*path.rbegin() == '0')
        {
            pathmemo[path] = pathmemo[path.substr(0, path.size() - 1)] + root->data;
        }
        path += '1';
        takePath(root->left, path, pathmemo);
        path += '0';
        takePath(root->right, path, pathmemo);
    }
    path.pop_back();
}

void takePath2(Node *root, int &cur_max, int &cand_max)
{
    if (root == NULL)
    {
        return;
    }
    else
    {
        cand_max += root->data;
        if (cand_max > cur_max)
        {
            cur_max = cand_max;
        }
        takePath2(root->left, cur_max, cand_max);
        takePath2(root->right, cur_max, cand_max);
    }
    cand_max -= root->data;
}
int maxPathSum(Node *root, int &ma)
{
    if (!root)
        return 0;
    int left = maxPathSum(root->left, ma);
    int right = maxPathSum(root->right, ma);
    ma = max(ma, root->data + left + right);
    return max(max(0, max(left, right)) + root->data, 0);
}
int maximum_path(vector<int> node_values)
{
    Node *root = maketree(node_values);
    map<string, int> pathmap;
    int starting_sum = root->data;
    string path = "2";
    pathmap[path] = root->data;
    // takePath(root, path, pathmap);
    // auto elem = max_element(pathmap.begin(), pathmap.end(), [](const auto &x, const auto &y)
    //                         { return x.second < y.second; });

    // for(const auto &i:pathmap)
    // {
    //     cout << i.first << " " << i.second << endl;
    // }
    // return elem->second;

    int cm = 0;
    int cand = 0;
    takePath2(root, cm, cand);
    cout << cm << endl; 
    int y ;
    maxPathSum(root, y);
    return cm;
}

int main()
{
    vector<int> tree = {1, 3, -1, 3, 1, 5};
    cout << maximum_path(tree) << endl;

    vector<int> tree2 = {770, 964, -720, 5, -360, -54, -987, -54, 948, 33, 47, -557, -461, -509, 846, 963, 423, 75, 236, -19, -284, -702, -396, -890, 189, 330, -991, 717, -453, -59, 267, 795, 838, -967, 417, -473, 363, 548, 796, -182, 8, 602, 370, 577, -343, -112, -405, -191, 148, -970, -312, -576, -706, 133, -456, -497, 750, 567, 88, -580, -434, 378, 376, -905, 169, 819, 68, -322, 48, -980, -92, -427, -135, -932, -143, 826, 547, -46, 408, 309, 706, -358, 937, -248, -290, 958, -883, -980, 214, 960, -737,
                         328, -188, -100, 697, -945, -402, 994, -812, -379, -757, 426, 185, 159, 685, -544, -551, 845, 767, 274, -152, 982, -119, -174, 855, -465, -571, -108, 657, -368};
    cout << maximum_path(tree2) << endl;
};
