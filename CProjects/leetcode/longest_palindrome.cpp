#include <bits/stdc++.h>

using namespace std;
class Solution {
 public:
  int longestPalindrome(string s) {
    map<char, int> mymap;
    for (int i = 0; i < s.length(); ++i) {
      mymap[s[i]] += 1;
    }
    multimap<int, char> reversemymap;
    vector<int> mapkeys;
    int c = 0;

    for (auto it = mymap.begin(); it != mymap.end(); ++it) {
      reversemymap.insert(make_pair(it->second, it->first));
      mapkeys.push_back(it->second);
      ++c;
    }

    c = 0;
    int length = 0;
    for (auto it = reversemymap.begin(); it != reversemymap.end(); ++it) {
      int k = times(it->first);
      if (k) {
        // Even
        length += k;
        auto jt = find(mapkeys.begin(), mapkeys.end(), it->first);
        if (jt != mapkeys.end()) {
          mapkeys[jt - mapkeys.begin()] -=k;
        }
      }
      ++c;
    }

    sort(mapkeys.begin(), mapkeys.end(), [](int &i, int &j) {
      if (i > j)
        return true;
      else
        return false;
    });

    for (int i = 0; i < mapkeys.size(); ++i) {
      if (mapkeys[i] != 0) {
        length++;
        break;
      }
    }
    return length;
  }

  int times(int A) {
    if ((A / 2) > 0) {
      return 2 * (A / 2);
    } else {
      return 0;
    }
  }
};

int main() {
  Solution s;
  //   cout << s.longestPalindrome("ddccccab") << endl;
//   cout << s.longestPalindrome("ccc") << endl;
  cout << s.longestPalindrome("aabbc") << endl;

  return 0;
}