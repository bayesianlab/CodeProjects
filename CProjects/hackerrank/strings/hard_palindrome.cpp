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
void maxPalin(const string &a, const string &b, string &cur) {
  int candlen = a.length() + b.length();
  if (cur.length() < candlen) {
    cur = a + b;
  } else if (cur.length() == candlen) {
    cur = sortPalindromes(a, b, cur);
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
  for (auto it = a.begin(); it != a.end(); ++it) {
    mp[*it].push_back(t);
    ++t;
  }
  set<char> sb(b.begin(), b.end());
  int stopflag = 1;
  for (auto it = sb.begin(); it != sb.end(); ++it) {
    if (mp.find(*it) != mp.end()) {
      stopflag = 0;
      break;
    }
  }
  if (stopflag == 1) {
    cout << "-1" << endl;
    return "-1";
  } else {
    for (auto it = b.begin(); it != b.end(); ++it) {
      mp[*it].push_back(t);
      ++t;
    }
  }

  map<size_t, vector<size_t>> mp2;
  for (auto it = mp.begin(); it != mp.end(); ++it) {
    mp2[(it->second).size()] = it->second;
  }

  // for (const auto &i : mp2) {
  //   cout << i.first << " ";
  //   printvec(i.second);
  // }

  string curLongestPalin = "";
  vector<int> begEndIndices(2);
  int itcount = 0;
  // beginning and ending indexes of all possible palindromes in this
  // map
  for (auto it = mp2.rbegin(); it != mp2.rend(); ++it) {
    // ++itcount;
    vector<size_t> indexVector = it->second;
    // printvec(indexVector);
    if (indexVector.size() >= 2) {
      int indexVectorCounter = 0;
      // break out of all loops if found a palindrome, because all other
      // palindromes inside this palindrome must be of less length
      bool found = false;
      for (auto palinBegIndex = indexVector.begin();
           palinBegIndex != indexVector.end() && found == false;
           ++palinBegIndex) {
        ++itcount;
        if (*palinBegIndex > a.length() - 1) {
          break;
        }
        for (auto palinEndIndex = indexVector.rbegin();
             palinEndIndex != indexVector.rend() && found == false;
             ++palinEndIndex) {
          if (*palinEndIndex <= (int)a.length() - 1) {
            break;
          }
          ++itcount;
          if (isSubstringABigger(*palinEndIndex, *palinBegIndex, a)) {
            string substrA =
                a.substr(*palinBegIndex, a.length() - *palinBegIndex);
            for (int p = 0;
                 p < *palinEndIndex + 1 - a.length() && found == false; ++p) {
              ++itcount;
              string substrB = b.substr(p, *palinEndIndex + 1 - a.length() - p);
              string ssbcpy = substrB;
              reverse(ssbcpy.begin(), ssbcpy.end());
              size_t begPalindromeIndex = substrA.find(ssbcpy);
              int largestPossiblePalin = substrA.length() + substrB.length();
              if (begPalindromeIndex != string::npos) {
                if (largestPossiblePalin >= curLongestPalin.length()) {
                  int palindromeLenCounter;
                  if ((int)curLongestPalin.length() - 2 * (int)ssbcpy.length() >
                      0) {
                    palindromeLenCounter =
                        (int)curLongestPalin.length() - (int)ssbcpy.length();
                  } else {
                    palindromeLenCounter = ssbcpy.length();
                  }
                  string candidateA = "";
                  int check = curLongestPalin.length();
                  while (palindromeLenCounter <= a.length() && found == false) {
                    itcount++;
                    string ca = substrA.substr(begPalindromeIndex,
                                               palindromeLenCounter);
                    // cout << "A " << ca << " " << substrB << " "
                    //      << curLongestPalin.length() << endl;
                    if (ca.length() + substrB.length() >=
                            curLongestPalin.length() &&
                        isPalindrome2(ca, substrB)) {
                      maxPalin(ca, substrB, curLongestPalin);
                      if (p > 0) {
                        string other = b.substr(
                            p - 1, *palinEndIndex - a.length() - p + 2);
                        if (isPalindrome2(ca, other)) {
                          maxPalin(ca, other, curLongestPalin);
                        }
                      }
                    }
                    palindromeLenCounter++;
                  }
                  if (check < curLongestPalin.length()) {
                    found = true;
                  }
                }
              }
            }
          } else {
            // B is bigger
            string substrB = b.substr(0, *palinEndIndex - a.length() + 1);
            for (int p = a.length() - *palinBegIndex; p > 0 && found == false;
                 --p) {
              ++itcount;
              string substrA = a.substr(*palinBegIndex, p);
              string ssacpy = substrA;
              reverse(ssacpy.begin(), ssacpy.end());
              int endPalinIndex = substrB.rfind(ssacpy);
              int largestPossiblePalin =
                  endPalinIndex + ssacpy.length() + substrA.length();
              if (endPalinIndex != string::npos) {
                if (largestPossiblePalin >= curLongestPalin.length()) {
                  string candidateB = "";
                  int charCount;
                  if ((int)curLongestPalin.length() - 2 * (int)ssacpy.length() >
                      0) {
                    int diff = (int)curLongestPalin.length() -
                               2 * (int)ssacpy.length();
                    endPalinIndex -= diff;
                    charCount = ssacpy.length() + diff;
                  } else {
                    charCount = ssacpy.length();
                  }
                  int check = curLongestPalin.length();
                  while (endPalinIndex >= 0 && found == false) {
                    itcount++;
                    string cb = substrB.substr(endPalinIndex, charCount);
                    // cout << "B " << substrA << " " << cb << " "
                    //      << curLongestPalin.length() << endl;
                    // cout << *palinBegIndex << " " << endPalinIndex +
                    // charCount + a.length() - 1<< endl;
                    if (cb.length() + substrA.length() >=
                            curLongestPalin.length() &&
                        isPalindrome2(substrA, cb)) {
                      maxPalin(substrA, cb, curLongestPalin);
                      if (p <= a.length()) {
                        string other = a.substr(*palinBegIndex, p + 1);
                        if (isPalindrome2(other, cb)) {
                          maxPalin(other, cb, curLongestPalin);
                        }
                      }
                    }
                    --endPalinIndex;
                    ++charCount;
                  }
                  if (check < curLongestPalin.length()) {
                    found = true;
                  }
                }
              }
            }
          }
        }
      }
    }
  }
  cout << itcount << endl;
  cout << curLongestPalin << endl;
  if (curLongestPalin.empty()) {
    curLongestPalin = -1;
  }
  return curLongestPalin;
}

int main() {
  // string a14 = "aeyoozlty";
  // string b14 = "pzoo";
  // buildPalindrome(a14, b14);

  // string aa = "o";
  // string bb = "ozalzoo";
  // cout << isPalindrome2(aa, bb) << endl;

  // string a = "jdfh";
  // string b = "fds";
  // buildPalindrome(a, b);

  // string at1 =
  //     "ottloictodtdtloloollllyocidyiodttoacoctcdcidcdttyoiilocltacdlydaailaiylc"
  //     "ttilld";
  // string bt1 =
  //     "jevgfsuujwrunvgvgwpfbknkruvwzgxxgksmexqvxbghfffseuugxkwexhzfbpu";
  // buildPalindrome(at1, bt1);
  // -1

  // string at2 =
  //     "qquhuwqhdswxxrxuzzfhkplwunfagppcoildagktgdarveusjuqfistulgbglwmfgzrnyxry"
  //     "etwzhlnfewczmnoozlqatugmd";
  // string bt2 =
  //     "jwgzcfabbkoxyjxkatjmpprswkdkobdagwdwxsufeesrvncbszcepigpbzuzoootorzfskcw"
  //     "bqorvw";
  // buildPalindrome(at2, bt2);
  // oozlzoo

  // string at3 = "dczatfarqdkelalxzxillkfdvpfpxabqlngdscrentzamztvvcvrtcm";
  // string bt3 =
  //     "bqlizijdwtuyfrxolsysxlfebpolcmqsppmrfkyunydtmwbexsngxhwvroandfqjamzkptts"
  //     "lildlrkjoyrpxugiceahgiakev";
  // buildPalindrome(at3, bt3);
  // lxsysxl

  string at3 = "alxzxillk";
  string bt3 = "lilsysxlf";
  buildPalindrome(at3, bt3);

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