#include <bits/stdc++.h>

using namespace std;

vector<pair<string,string>> routes(vector<pair<string, string>> init, vector<string> stage1,
            vector<string> stage2) {
  vector<pair<string, string>> m;
  m.push_back(init[0]);
  set<string> x;
  for (auto it = m.begin(); it != m.end(); ++it) {
    x.insert(it->first);
    x.insert(it->second);
  }
    vector<string> y(x.begin(), x.end()); 
  for (int i = 0; i < y.size(); ++i) {
    for (int k = 0; k < stage1.size(); ++k) {
      m.push_back(make_pair(y[i], stage1[k]));
    }
  }

  set<string> teams;
  for (auto it = m.begin(); it != m.end(); ++it) {
    teams.insert(it->first);
    teams.insert(it->second);
  }
  vector<string> t(teams.begin(), teams.end());
  for (int i = 0; i < t.size(); ++i) {
    for (int k = 0; k < stage2.size(); ++k) {
      m.push_back(make_pair(t[i], stage2[k]));
    }
  }

  return m; 
}

void path(vector<pair<string, string>> m){
    
}

int main() {
  string tb = "TB";
  string cle = "Cle";
  string ny = "NY";
  string sea = "Sea";
  string tor = "Tor";
  string hou = "Hou";
  vector<pair<string, string>> matchups({make_pair(tb, cle)});

  vector<string> stage1({ny});
  vector<string> stage2({sea, tor, hou});

  vector<pair<string, string>> m = routes(matchups, stage1, stage2);

//   m.push_back(make_pair(sea,tor));
//   m.push_back(make_pair(sea, hou));
//   m.push_back(make_pair(tor,hou));

//   for (auto it = m.begin(); it != m.end(); ++it) {
//     cout << it->first << " " << it->second << endl;
//   }


//   for (auto it = matchups.begin(); it != matchups.end(); ++it) {
//     cout << it->first << " " << it->second << endl;
//   }
  return 0;
}