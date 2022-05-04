#include <bits/stdc++.h>
using namespace std;

template <typename T>
class node
{
public:
    T key;
    node<T> *next;
};

template <typename T>
class Stack
{
public:
    node<T> *top;

    Stack()
    {
        top = NULL;
    }

    void push(T data)
    {
        node<T> *newtop = (node<T> *)malloc(sizeof(node<T>));
        newtop->key = data;
        if (top == NULL)
        {
            top = newtop;
            top->next = NULL;
            return;
        }
        newtop->next = top;
        top = newtop;
    }

    void pop()
    {
        if (top == NULL)
        {
            throw runtime_error("error");
        }
        top = top->next;
    }

    T peek()
    {
        if (top != NULL)
        {
            return top->key;
        }
        throw runtime_error("error");
    }

    void printstack()
    {
        if (top == NULL)
        {
            return;
        }
        node<T> *x = top;
        while (x != NULL)
        {
            cout << x->key << " ";
            x = x->next;
        }
        printf("\n");
    }
};

int main()
{
    Stack<string> S;
    S.push("top");
    S.push("cracking");
    S.push("coding");
    S.push("interview");
    S.printstack();
    S.pop();
    S.pop();
    S.push("inside");
    S.pop();
    S.printstack();
    S.pop();
    S.pop();
    S.push("gayle");
    string x = S.peek(); 
    S.printstack();
    cout << x << endl; 

    return 0;
}