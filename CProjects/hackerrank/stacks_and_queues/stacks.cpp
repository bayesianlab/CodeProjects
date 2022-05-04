
#include <iostream>

using namespace std; 

struct Stack
{
    int data;
    Stack *next;
};

Stack *pushon(Stack *head, int data)
{
    Stack *t = (Stack*)malloc(sizeof(Stack));
    t->data = data; 
    t->next = head; 
    return t;  
}

Stack *popoff(Stack *head)
{
    head = head->next; 
    return head; 
}

void printstack(Stack* head)
{
    while(head != NULL)
    {
        cout << head->data << " " << endl; 
        head = head->next; 
    }
}


int main()
{
    Stack* s1 = (Stack*)malloc(sizeof(Stack));
    s1->data = 1;
    s1 = pushon(s1, 2);
    s1 = pushon(s1, 7);
    s1 = pushon(s1, 8);
    printstack(s1);
    s1 = popoff(s1);
    printstack(s1);


}