#include "trie.hpp"

Trie *makeTrie(vector<string> words)
{
    Trie *t;
    Trie *home;
    Trie *root = newTrie('a');
    string alpha = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    int i = 0;
    char last = 'a';
    for (const string &w : words)
    {
        int j = 1;
        if (last != w[0])
        {
            last = w[0];
            t = newTrie(w[0]);
            root->next[i] = t;
            home = t;
            ++i;
        }
        for (j; j < w.length(); ++j)
        {
            t = insertLetter(t, w[j]);
            if (j == w.length() - 1)
            {
                t->endsword = 1;
            }
        }
        t = home;
    }
    return root;
}

Trie *insertLetter(Trie *root, char a)
{

    for (int i = 0; i < 26; ++i)
    {
        if (root->next[i] != NULL)
        {
            if (root->next[i]->data == a)
            {
                return root->next[i];
            }
        }
    }
    int i = 0;
    while (root->next[i] != NULL)
    {
        ++i;
    }
    root->next[i] = newTrie(a);
    return root->next[i];
}

void printTrieUtil(Trie *root, string str)
{
    if (root->data == 'a')
    {
        int i = 0;

        for (int i = 0; i < 26; ++i)
        {
            if (root->next[i] != NULL)
            {
                printTrieUtil(root->next[i], str);
            }
        }
    }
    else
    {
        str += root->data;
        if (root->endsword == 1 || root->isBarren())
        {
            cout << str << endl;
        }
        for (int i = 0; i < 26; ++i)
        {
            if (root->next[i] != NULL)
            {
                printTrieUtil(root->next[i], str);
            }
        }
    }
}

void printTrie(Trie *root)
{
    string str = "";
    printTrieUtil(root, str);
}

Trie *newTrie(char d)
{
    Trie *t = (Trie *)malloc(sizeof(Trie));
    t->data = d;
    for (int i = 0; i < 26; ++i)
    {
        t->next[i] = NULL;
    }
    return t;
}

bool findSubWord(Trie *root, int nextroot, string sub)
{
    if (sub.empty())
    {
        return true;
    }
    if (nextroot >= 26)
    {
        return false;
    }
    if (root->data == sub[0])
    {
        if (findSubWord(root->next[nextroot], nextroot + 1, sub.substr(1, sub.length() - 1)))
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    else
    {
        return false;
    }
}