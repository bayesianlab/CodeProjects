#include <bits/stdc++.h>
using namespace std;

class qn
{
public:
    int key;
    qn *next;
};

class Queue
{
public:
    qn *front, *back;
    Queue()
    {
        front = NULL;
        back = NULL;
    }
    void push(int k)
    {
        qn *newback = (qn *)malloc(sizeof(qn ));
        newback->key = k;
        if (front == NULL)
        {
            front = newback;
            back = front;
        }
        else
        {
            back->next = newback;
            back = newback; 
        }
    }
    void pop()
    {
        if (back == NULL)
        {
            return;
        }
        else
        {
            qn *u = front->next;
            front = u; 
        }
    }
    void printq()
    {
        qn *x = front;
        while (x != NULL)
        {
            cout << x->key << " ";
            x = x->next;
        }
        cout << endl;
    }
};

int main()
{
    Queue Q;
    Q.push(1);
    Q.push(2);
    Q.push(-1);
    Q.push(10);
    Q.printq();
    Q.pop();
    Q.printq();
}