#include <bits/stdc++.h>

using namespace std;

class Matches {
 public:
  vector<int> m1;
  vector<int> m2;

  void findMatchH(vector<string> s1, vector<string> s2, vector<int> rowid,
                  vector<pair<int, int>> &save) {
    if (s2.size() == 0) {
      return;
    }
    auto it = s1.begin();
    int loc = 0;
    int notmatch = 1;
    while (1) {
      it = find(s1.begin() + loc + 1, s1.end(), s2[0]);
      loc = it - s1.begin();
      if (it == s1.end()) {
        s1.erase(s1.begin() + 0);
        s2.erase(s2.begin() + 0);
        rowid.erase(rowid.begin() + 0);
        findMatchH(s1, s2, rowid, save);
        break;
      }
      if (s1[0] == s2[loc]) {
        auto p = make_pair(rowid[0], rowid[loc]);
        save.push_back(p);
        s1.erase(s1.begin() + 0);
        s2.erase(s2.begin() + 0);
        s1.erase(s1.begin() + loc - 1);
        s2.erase(s2.begin() + loc - 1);
        rowid.erase(rowid.begin() + 0);
        rowid.erase(rowid.begin() + loc - 1);
        findMatchH(s1, s2, rowid, save);
        break;
      }
    }
  }

  void findMatch(vector<string> s1, vector<string> s2, vector<int> rowid) {
    vector<pair<int, int>> save;
    findMatchH(s1, s2, rowid, save);

    for (auto it = save.begin(); it != save.end(); ++it) {
      m1.push_back(it->first);
      m2.push_back(it->second);
    }
  }
};

class Flight {
 public:
  vector<string> origin;
  vector<string> dest;
  vector<int> rowid;

  void insert(vector<string> s1, vector<string> s2, vector<int> r) {
    for (int i = 0; i < s1.size(); ++i) {
      addData(s1[i], s2[i], r[i]);
    }
  }

  void addData(string s1, string de, int r) {
    origin.push_back(s1);
    dest.push_back(de);
    rowid.push_back(r);
  }

  void printData() {
    for (int i = 0; i < origin.size(); ++i) {
      cout << origin[i] << " " << dest[i] << " " << rowid[i] << endl;
    }
  }
};

void findMatch(vector<string> s1, vector<string> s2, vector<int> rowid);

void findMatchH(vector<string> s1, vector<string> s2, vector<int> rowid,
                vector<pair<int, int>> &save);

Flight parseCsv(string file, int ocol, int dcol, int id);
