#include <bits/stdc++.h>
#include "trie.hpp"
using namespace std;

int main()
{
    Dictionary D("mini.txt");
    Trie *root = makeTrie(D.dict);
    printTrie(root);
    return 0;
}