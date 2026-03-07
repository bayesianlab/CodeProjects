#include <bits/stdc++.h>
#include "trie.hpp"
using namespace std;

int main()
{
    Dictionary D("collins_dictionary.txt");
    Trie *root = makeTrie(D.dict);
    // printTrie(root);
    string s = "SKEERY";
    cout << isWord(root,s) << endl;
    return 0;
}