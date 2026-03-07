#include <bits/stdc++.h>
using namespace std;

struct Node {
  int val;
  Node* left = NULL;
  Node* right = NULL;
};

void addNode(Node* head, int value) {
  Node* N = new Node;
  N->val = value;
  Node* H = head;
  while (head != NULL) {
    if (value < head->val) {
      if (head->left == NULL) {
        head->left = N;
        return;
      } else {
        head = head->left;
      }
    } else {
      if (head->right == NULL) {
        head->right = N;
        return;
      } else {
        head = head->right;
      }
    }
  }
}

void printTreeDepthFirst(Node* head) {
  if (head == NULL) {
    return;
  }
  cout << head->val << endl;
  printTreeDepthFirst(head->left);
  printTreeDepthFirst(head->right);
}

void printTreeBreadthFirst(Node* head) {
    cout <<"Breadth First " << endl; 
  queue<Node*> Q;
  Q.push(head);
  while (!Q.empty()) {
    Node* T = Q.front();
    cout << T->val << endl;
    Q.pop();
    if (T->left) {
      Q.push(T->left);
    }
    if (T->right) {
      Q.push(T->right);
    }
  }
}

int main() {
  Node* head = new Node;
  head->val = 0;
  addNode(head, 1);
  addNode(head, -1);
  addNode(head, 2);
  addNode(head, -4);
  addNode(head, 0);

  printTreeDepthFirst(head);
  printTreeBreadthFirst(head);

  return 0;
}