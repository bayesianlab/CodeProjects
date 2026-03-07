#include <bits/stdc++.h>

#include <cstdio>

using namespace std;
typedef struct Node {
  int value;
  Node* next;
  Node(int val) {
    value = val;
    next = NULL;
  }
} Node;

Node* SplitList(Node** inList) {
  // TODO
  Node* even = NULL;
  Node* it = *inList;
  if (!(it->value % 2)) {
    even = it;
    it = it->next;
    *inList = it;
  }
  Node* prev = NULL;
  int c = 0;

  while (it != NULL) {
    if (!(it->value % 2) && even == NULL) {
      even = it;
      even->next = NULL;
      it = it->next;
    }
    else if(!(it->value % 2){
      even->next = it;
      
      it = it->next;  
    }
  }
  *inList = head;
  return even;
}

void PrintList(const char* prefix, Node* head) {
  if (!head) {
    printf("%s : Empty\n", prefix);
    return;
  }

  Node* curr = head;
  printf("%s : ", prefix);
  while (curr != NULL) {
    printf("%d", curr->value);
    curr = curr->next;
    if (curr != NULL) {
      printf(", ");
    }
  }
  printf("\n");
}

#ifndef RunTests
int main() {
  Node* head = new Node(1);
  Node* b = new Node(2);
  head->next = b;
  PrintList("Initial", head);

  Node* evenList = SplitList(&head);
  PrintList("Odd ", head);
  PrintList("Even", evenList);

  return 0;
}
#endif