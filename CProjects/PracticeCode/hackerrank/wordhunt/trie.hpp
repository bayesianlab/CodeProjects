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
            cout << "Loaded Dictionary successfully." << endl;
        }
        else
        {
            cout << "Error dictionary not loaded!" << endl;
        }
    }
};

class Trie
{
public:
    char data;

    bool endsword;

    bool isBarren()
    {
        for(int i =0; i < 26; ++i)
        {
            if(next)
            {
                return false; 
            }
        }
        return true; 
    }

    Trie *next[26];

    ~Trie()
    {
    };
};

Trie *newTrie(char);

Trie *insertLetter(Trie *root, char a);

void printTrie(Trie *);

void pritnTrieUtil(Trie *, string str);

Trie *makeTrie(vector<string> words);

bool isSubWord(Trie *root,  string sub);

bool isWord(Trie *, string sub); 