
/*Christy is interning at HackerRank. One day she has to distribute some
chocolates to her colleagues. She is biased towards her friends and plans to
give them more than the others. One of the program managers hears of this and
tells her to make sure everyone gets the same number.

To make things difficult, she must equalize the number of chocolates in a series
of operations. For each operation, she can give  pieces to all but one
colleague. Everyone who gets a piece in a round receives the same number of
pieces.

Given a starting distribution, calculate the minimum number of operations needed
so that every colleague has the same number of pieces.

Example

 represents the starting numbers of pieces for each colleague. She can give
pieces to the first two and the distribution is then . On the next round, she
gives the same two  pieces each, and everyone has the same number: . Return the
number of rounds, .

Function Description

Complete the equal function in the editor below.

equal has the following parameter(s):

int arr[n]: the integers to equalize
Returns

int: the minimum number of operations required
*/
#include <bits/stdc++.h>
using namespace std;

int equal(vector<int> arr) {
  vector<int> diffs(arr.size() - 1);
  int notequal = 1;
  int minelem = min_element(arr.begin(), arr.end()) - arr.begin();
  int maxelem = max_element(arr.begin(), arr.end()) - arr.begin();
  int diff = arr[maxelem] - arr[minelem];
  int c = 0;
  vector<int> tmp;
  while (c <= 4) {
    int m = 0;
    for (auto it = arr.begin(); it != arr.end(); ++it) {
      if (*it != arr[minelem]) {
        int diff = *it - (arr[minelem] - c);
        m += (diff / 5) + ((diff % 5) / 2) + (diff % 5) % 2;
      }
    }
    int extra = c/2 + (c%2)%2;
    tmp.push_back(m+extra);
    ++c;
  }
  return *min_element(tmp.begin(), tmp.end());
}

int main() {
  vector<int> A = {1,5,5};
  cout << equal(A) << endl;
}