#include <bits/stdc++.h>

using namespace std;

string ltrim(const string &);
string rtrim(const string &);

/*
 * Complete the 'buildPalindrome' function below.
 *
 * The function is expected to return a STRING.
 * The function accepts following parameters:
 *  1. STRING a
 *  2. STRING b
 */
template <typename T>
void printvec(const vector<T> &x) {
  for (int i = 0; i < x.size(); ++i) {
    cout << x[i] << " ";
  }
  cout << endl;
}

vector<string> allStringPermutations(string s) {
  vector<string> T(tgamma(s.length() + 1));
  T[0] = s;
  int c = 1;
  while (next_permutation(s.begin(), s.end())) {
    T[c] = s;
    ++c;
  }
  return T;
}

map<int, vector<string>> allSubstrings(string s) {
  map<int, vector<string>> mp;
  mp[s.size()] = allStringPermutations(s);
  for (int i = 0; i < s.size(); ++i) {
    for (int j = 1; j < s.size(); ++j) {
      if (i + j > s.size()) {
        break;
      }
      string u = s.substr(i, j);
      mp[u.size()] = allStringPermutations(u);
    }
  }
  return mp;
}

bool isPalindrome(string x) {
  if (x.length() == 0 || x.length() == 1) {
    return true;
  } else if (x[0] != x.back()) {
    return false;
  } else {
    x = x.substr(1, x.size() - 2);
    return isPalindrome(x);
  }
}

pair<size_t, size_t> longestPalindrome(string X) {
  size_t beg = 0;
  int maxlen = 0;
  char last_char = '{';
  pair<size_t, size_t> indices;
  indices.first = string::npos;
  indices.second = string::npos;
  while (beg < X.length()) {
    char beg_char = X[beg];
    if (beg < X.length() - 1) {
      size_t is_end = beg;
      int searching = 1;
      while (searching) {
        is_end = X.find(beg_char, is_end + 1);
        if (is_end == string::npos) {
          searching = 0;
        } else {
          int plen = is_end - beg + 1;
          if ((plen >= maxlen) &&
              isPalindrome(X.substr(beg, is_end - beg + 1))) {
            char a = X[beg];
            if ((maxlen <= plen) && (a < last_char)) {
              maxlen = plen;
              last_char = a;
              indices.first = beg;
              indices.second = is_end;
            }
          }
        }
      }
    }
    ++beg;
  }
  return indices;
}

string findPalinSubStrings(string &a, string &b) {
  string X = a + b;
  int stringbreak = a.length() - 1;
  string longest;
  for (int loc = 0; loc < a.length(); ++loc) {
    size_t t = X.length();
    while (t != string::npos && t != loc) {
      t = X.find_last_of(X[loc], t - 1);
      if (t != string::npos && t > stringbreak) {
        int b = loc;
        int e = t;
        string st1;
        string st2;
        char reserve = '{';
        while (b <= e) {
          if (X[b] != X[e]) {
            if (e <= stringbreak) {
              reserve = X[b];
              break;
            }
            if (b > stringbreak) {
              reserve = X[e];
              break;
            } else if (X[b] < X[e]) {
              reserve = X[b];
              break;
            } else {
              reserve = X[e];
              break;
            }
          } else if (b == 3) {
            st1 += X[b];
          } else {
            st1 += X[b];
            st2 += X[e];
          }
          ++b;
          --e;
        }
        reverse(st2.begin(), st2.end());
        string palinkey;
        if (reserve != '{') {
          palinkey = st1 + reserve + st2;
          if (palinkey.length() > longest.length()) {
            longest = palinkey;
          } else if (palinkey.length() == longest.length()) {
            vector<string> q(2);
            q[0] = palinkey;
            q[1] = longest;
            sort(q.begin(), q.end());
            longest = q[0];
          }
        } else {
          palinkey = st1 + st2;
          if (palinkey.length() > longest.length()) {
            longest = palinkey;
          } else if (palinkey.length() == longest.length()) {
            vector<string> q(2);
            q[0] = palinkey;
            q[1] = longest;
            sort(q.begin(), q.end());
            longest = q[0];
          }
        }
      } else {
        break;
      }
    }
  }
  if (isalpha(longest[0])) {
    cout << longest << endl;
    return longest;
  } else {
    cout << "-1" << endl;
    return "-1";
  }
}

string bpalinUtil(string a, string b) {
  string g = findPalinSubStrings(a, b);
  return g;
}

multimap<char, pair<size_t, size_t>> makemm(const string &a, const string b) {
  size_t beg = 0;
  multimap<char, pair<size_t, size_t>> lettermap1;
  while (beg < a.length()) {
    size_t p2 = b.find(a[beg], beg);
    if (p2 != string::npos) {
      lettermap1.insert(make_pair(a[beg], make_pair(beg, p2)));
    }
    ++beg;
  }
  return lettermap1;
}

map<char, string> makem2(
    const string &a, const string &b,
    const multimap<char, pair<size_t, size_t>> &lettermap1) {
  map<char, string> lettermap2;
  for (size_t t = 0; t < max(a.length(), b.length()); ++t) {
    auto ait = lettermap1.find(a[t]);
    if (ait != lettermap1.end()) {
      if (ait->second.first != t) {
        lettermap2[a[t]].push_back(a[t]);
      }
    } else {
      lettermap2[a[t]].push_back(a[t]);
    }
    auto bit = lettermap1.find(b[t]);
    if (bit != lettermap1.end()) {
      if (bit->second.second != t) {
        lettermap2[b[t]].push_back(b[t]);
      }
    } else {
      lettermap2[b[t]].push_back(b[t]);
    }
  }
  return lettermap2;
}

string bp(string a, string b) {
  auto lettermap1 = makemm(a, b);
  map<char, string> lettermap2 = makem2(a, b, lettermap1);
  queue<char> left;
  stack<char> right;
  for (auto it = lettermap1.begin(); it != lettermap1.end(); ++it) {
    left.push(a[(*it).second.first]);
    right.push(b[(*it).second.second]);
  }

  for (map<char, string>::iterator it = lettermap2.begin();
       it != lettermap2.end(); ++it) {
    while (it->second.length() >= 2) {
      char t1 = it->second.front();
      it->second.erase(0, 1);
      char t2 = it->second.front();
      it->second.erase(0, 1);
      left.push(t1);
      right.push(t2);
    }
  }

  for (auto it = lettermap2.begin(); it != lettermap2.end(); ++it) {
    if (isalpha(it->second[0])) {
      left.push(it->second.front());
      it->second.erase(0, 1);
      break;
    }
  }

  string P;
  while (!left.empty()) {
    P += left.front();
    left.pop();
  }
  while (!right.empty()) {
    P += right.top();
    right.pop();
  }
  if (isalpha(P[0]))

  {
    cout << P << endl;
    return P;
  } else {
    cout << "-1" << endl;
    ;
    return "-1";
  }
}

// vector<string> generateSubstrings(const string &a,
//                                   const int &palindromeBegPoint) {
//   vector<string> vecta;
//   for (int i = a.length() - 1; i >= palindromeBegPoint; --i) {
//     size_t asize = i - palindromeBegPoint + 1;
//     string substrA = a.substr(palindromeBegPoint, asize);
//     vecta.push_back(substrA);
//   }
//   return vecta;
// }

// void palindromeSearchRight(const string &substrB, const vector<string>
// &vecta,
//                            int endMatchIndx, string &curLongestPalin,
//                            int curIt) {
//   int addCharCntr = 0;
//   while (endMatchIndx >= 0) {
//     string candidateB =
//         substrB.substr(endMatchIndx, vecta[curIt].length() + addCharCntr);
//     if (!isPalindrome2(vecta[curIt], candidateB)) {
//       break;
//     } else {
//       int candlen = vecta[curIt].length() + candidateB.length();
//       if (candlen < curLongestPalin.length()) {
//         break;
//       }
//       maxPalin(vecta[curIt], candidateB, curLongestPalin);
//       int reverseIt = curIt - 1;
//       while (reverseIt >= 0) {
//         if (!isPalindrome2(vecta[reverseIt], candidateB)) {
//           break;
//         } else {
//           int candlen = vecta[reverseIt].length() + candidateB.length();
//           if (candlen < curLongestPalin.length()) {
//             break;
//           }
//           maxPalin(vecta[reverseIt], candidateB, curLongestPalin);
//         }
//         --reverseIt;
//       }
//     }
//     --endMatchIndx;
//     ++addCharCntr;
//   }
// }

// void palindromeSearchLeft() {}

bool isSubstringABigger(const int end, const int beg, const string &a) {
  if (end + 1 - (int)a.length() < (int)a.length() - beg) {
    return true;
  } else {
    return false;
  }
}
string sortPalindromes(string a, string b, string cur) {
  vector<string> last2Palins(2);
  last2Palins[0] = a + b;
  last2Palins[1] = cur;
  sort(last2Palins.begin(), last2Palins.end());
  return last2Palins.front();
}

int maxPalin(const string &a, const string &b, string &cur) {
  int candlen = a.length() + b.length();
  if (cur.length() < candlen) {
    cur = a + b;
    return 1;
  } else if (cur.length() == candlen) {
    string old = cur;
    cur = sortPalindromes(a, b, cur);
    if (cur != old) {
      return 1;
    } else {
      return 0;
    }
  } else {
    return 0;
  }
}
bool isPalindrome2(const string &a, const string &b) {
  int i, j, k, m, q;
  char beg, end;
  i = 0;
  j = a.length() + b.length() - 1;
  q = a.length() - 1;

  while (i <= j) {
    if (i > a.length() - 1) {
      k = i - a.length();
      beg = b[k];
    } else {
      k = i;
      beg = a[k];
    }
    if (i > b.length() - 1) {
      m = q;
      end = a[m];
      --q;
    } else {
      m = b.length() - i - 1;
      end = b[m];
    }
    if (beg != end) {
      return false;
    }
    ++i;
    --j;
  }
  return true;
}

string buildPalindrome(string a, string b) {
  map<char, vector<size_t>> mp;
  size_t t = 0;
  string x = a + b;
  for (auto it = x.begin(); it != x.end(); ++it) {
    mp[*it].push_back(t);
    ++t;
  }

  // for (const auto &i : mp) {
  //   cout << i.first << " ";
  //   printvec(i.second);
  // }

  string curLongestPalin = "";
  vector<int> begEndIndices(2);
  int itcount = 0;
  vector<string> tsubs;
  // beginning and ending indexes of all possible palindromes in this
  // map
  for (auto it = mp.begin(); it != mp.end(); ++it) {
    ++itcount;
    vector<size_t> indexVector = it->second;
    if (indexVector.size() >= 2) {
      for (auto palinBegIndex = indexVector.begin();
           palinBegIndex != indexVector.end(); ++palinBegIndex) {
        ++itcount;
        if (*palinBegIndex <= a.length() - 1) {
          int m = a.length() - *palinBegIndex;
          int first = 0;
          while (m >= 1) {
            string atemp = a.substr(*palinBegIndex, m);
            --m;
            for (auto palinEndIndex = indexVector.rbegin();
                 palinEndIndex != indexVector.rend(); ++palinEndIndex) {
              if (*palinEndIndex > (int)a.length() - 1) {
                int j = 0;
                int n = *palinEndIndex - a.length() + 1;
                while (n >= 1) {
                  itcount++;
                  string btemp = b.substr(j, n);
                  if (btemp.length() + atemp.length() <
                      curLongestPalin.length()) {
                    break;
                  }
                  cout << atemp << " " << btemp << endl;
                  if (isPalindrome2(atemp, btemp)) {
                    if (maxPalin(atemp, btemp, curLongestPalin)) {
                      break;
                    }
                  }
                  ++j;
                  --n;
                }
              }
            }
          }
        }
      }
    }
  }
  cout << itcount << endl;
  if (curLongestPalin.length() == 0) {
    curLongestPalin = "-1";
  }

  return curLongestPalin;
}

int main() {
  // string at3 = "ab";
  // string bt3 = "ntba";
  // buildPalindrome(at3, bt3);
  string a14 = "noozlqat";
  string b14 = "zoootor";
  cout << buildPalindrome(a14, b14) << endl;
  cout << "oozlzoo" << endl;

  // string a = "jdfh";
  // string b = "fds";
  // buildPalindrome(a, b);
  // cout << "dfhfd" << endl;

  // string at1 =
  //     "ottloictodtdtloloollllyocidyiodttoacoctcdcidcdttyoiilocltacdlydaailaiylc"
  //     "ttilld";
  // string bt1 =
  //     "jevgfsuujwrunvgvgwpfbknkruvwzgxxgksmexqvxbghfffseuugxkwexhzfbpu";
  // cout << buildPalindrome(at1, bt1) << endl;
  // cout << "-1" << endl;

  // string at2 =
  //     "qquhuwqhdswxxrxuzzfhkplwunfagppcoildagktgdarveusjuqfistulgbglwmfgzrnyxry"
  //     "etwzhlnfewczmnoozlqatugmd";
  // string bt2 =
  //     "jwgzcfabbkoxyjxkatjmpprswkdkobdagwdwxsufeesrvncbszcepigpbzuzoootorzfskcw"
  //     "bqorvw";
  // cout <<buildPalindrome(at2, bt2) << endl;
  // oozlzoo

  // string at3 = "dczatfarqdkelalxzxillkfdvpfpxabqlngdscrentzamztvvcvrtcm";
  // string bt3 =
  //     "bqlizijdwtuyfrxolsysxlfebpolcmqsppmrfkyunydtmwbexsngxhwvroandfqjamzkptts"
  //     "lildlrkjoyrpxugiceahgiakev";
  // buildPalindrome(at3, bt3);
  // lxsysxl

  // string at3 = "alxzxillk";
  // string bt3 = "lilsysxlf";

  // folpcfblpncetyhtrwxkbosccskxbuvcrosavnpxzoeoyyghbbqkflslfkqbbhgyyoeozxpnvasorcvubxksccsobkxwrthytecnplbfcplof

  // rvngnvr

  // bkkb

  // "kfnfolpcfblpncetyhtrwxkbosccskxbuvcrosavnpxzoeoyyghbbqkflslfkqbbhgyyjj"
  // "qrxpxnloeozxpnvasorcvubxksccsobkxwrthytecnplbfcplofx"
  // "mlfcpidlqrvngnvttaifcbopnwezesomkxhaiafmvkbjaisyr"
  // "btultpnxbcrmornqumatserhieqggrivouwfnbnghdfall"
  // pb
  // kkb
  // rfq
  // xzj
  // zlc
  // zdw
  // s
  // k
  // w
  // d
}