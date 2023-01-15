#include <algorithm>
#include <bitset>
#include <climits>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <ctime>
#include <deque>
#include <fstream>
#include <iostream>
#include <limits>
#include <list>
#include <map>
#include <numeric>
#include <queue>
#include <set>
#include <sstream>
#include <stack>
#include <string>
#include <unordered_map>
#include <vector>

using namespace std;

class Chains {
 public:
  map<string, vector<double>> DailyChain;
  vector<int> job1;
  vector<int> jobend;
  vector<int> njobs;
  vector<int> trun;
  vector<int> avgrun;

  void makeLL() {
    map<int, int> jobid_to_index;
    int i = 0;
    for (auto it = DailyChain["job_id"].begin();
         it != DailyChain["job_id"].end(); ++it) {
      jobid_to_index[*it] = i;
      ++i;
    }
    int rowindex = 0;
    vector<double> jobids = DailyChain["job_id"];
    vector<double> nextjobs = DailyChain["next_job_id"];
    while (!jobid_to_index.empty()) {
      int time = DailyChain["runtime_in_seconds"][rowindex];
      int jobs = 1;
      job1.push_back(jobids[rowindex]);
      jobid_to_index.erase(jobids[rowindex]);
      while (nextjobs[rowindex] != 0) {
        rowindex = jobid_to_index[nextjobs[rowindex]];
        time += DailyChain["runtime_in_seconds"][rowindex];
        jobs++;
        jobid_to_index.erase(jobids[rowindex]);
        if (jobid_to_index.empty()) {
          jobend.push_back(jobids[rowindex]);
          njobs.push_back(jobs);
          trun.push_back(time);
          avgrun.push_back(time / jobs);
          return ;
        }
      }
      jobend.push_back(jobids[rowindex]);
      njobs.push_back(jobs);
      trun.push_back(time);
      avgrun.push_back(time / jobs);
      rowindex = jobid_to_index.begin()->second; 
    }
  }

  void initialize() {
    DailyChain["job_id"];
    DailyChain["runtime_in_seconds"];
    DailyChain["next_job_id"];
  }

  void get_summary() {
    for (int i = 0; i < job1.size(); ++i) {
      cout << "start_job: " << job1[i] << endl;
      cout << "last_job: " << jobend[i] << endl;
      cout << "number_of_jobs: " << njobs[i] << endl;
      cout << "job_chain_runtime: " << trun[i] << endl;
      cout << "avgerage_job_time: " << avgrun[i] << endl;
      cout << endl;
    }
  }

  void printChain() {
    vector<string> keys = {"job_id", "runtime_in_seconds", "next_job_id"};
    int row = 0;
    int max_row = DailyChain["job_id"].size();
    cout << "job_id "
         << "runtime_in_seconds "
         << "next_job_id" << endl;
    while (row < max_row) {
      for (int i = 0; i < 3; ++i) {
        cout << DailyChain[keys[i]][row] << " ";
      }
      cout << endl;
      ++row;
    }
  }
};

int main() {
  /* Enter your code here. Read input from STDIN. Print output to STDOUT */
  Chains chain;
  int r = 0;
  ifstream fin("headlands.csv");
  for (string line; getline(fin, line);) {
    istringstream buf(line);
    string field;
    map<int, string> column_names;
    column_names[0] = "job_id";
    column_names[1] = "runtime_in_seconds";
    column_names[2] = "next_job_id";
    if (r >= 1) {
      int c = 0;
      while (getline(buf, field, ',')) {
        try {
          double x = stod(field);
          if (c >= 3) {
            cout << "Malformed Input" << endl;
            return -1;
          }
          chain.DailyChain[column_names[c]].push_back(x);
          ++c;
        } catch (const char* msg) {
          cout << "Malformed Input" << endl;
          return -1;
        }
      }
    } else {
      int c = 0;
      while (getline(buf, field, ',')) {
        if (c >= 3) {
          cout << "Malformed Input" << endl;
          return -1;
        }
        if (c == 0 && field != "#job_id") {
          cout << "Malformed Input" << endl;
        } else if (c == 1 && field != "runtime_in_seconds") {
          cout << "Malformed Input" << endl;
        } else if (c == 2 && field != "next_job_id") {
          cout << "Malformed Input" << endl;
        }
        ++c;
      }
      chain.initialize();
    }
    ++r;
  }
  chain.printChain();
  chain.makeLL();
  chain.get_summary();
  return 0;
}