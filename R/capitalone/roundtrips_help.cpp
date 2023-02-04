#include "roundtrips_help.hpp"

using namespace std;




Flight parseCsv(string file, int ocol, int dcol, int id);

Flight parseCsv(string file, int orgcol, int descol, int rowid) {
  ifstream fin;
  fin.open(file);
  vector<string> data(2);
  Flight F;
  if (fin.is_open()) {
    string field;
    string newfield;
    string line;
    fin.close();
    fin.open(file);
    int colCount;
    int rowCount = 0;
    vector<int> setCols;
    while (getline(fin, line, '\n')) {
      colCount = -1;
      istringstream buf(line);
      if (rowCount != 0) {
        while (getline(buf, field, ',')) {
          colCount++;
          if (orgcol == colCount) {
            F.origin.push_back(field);
          }
          if (descol == colCount) {
            F.dest.push_back(field);
          }
          if (rowid == colCount) {
            F.rowid.push_back(stoi(field));
          }
        }
      }
      rowCount++;
    }
    return F;
    fin.close();
  } else {
    cout << "error" << endl;
    return F;
  }
  return F;
}
