#include <bits/stdc++.h>
#include <iostream>
using namespace std;

class Dictionary
{
public:
    vector<string> dict;

    Dictionary(string fname)
    {
        string word;
        ifstream F(fname);
        if (F.is_open())
        {
            while (getline(F, word))
            {
                word.erase(remove(word.begin(), word.end(), '\"'), word.end());
                dict.push_back(word);
            }
            cout << "success" << endl;
        }
        else
        {
            cout << "Error" << endl;
        }
    }
};

class Trie
{
public:
    char data;

    bool endsword;

    

    Trie *next[26];
};

Trie *newTrie(char);

Trie *insertLetter(Trie *root, char a);

void printTrie(Trie *);

void pritnTrieUtil(Trie *, string str);

Trie *makeTrie(vector<string> words);

bool findSubWord(Trie *root, string sub);