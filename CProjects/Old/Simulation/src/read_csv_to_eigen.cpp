#include "read_csv_to_eigen.hpp"
#include <Eigen/Dense>
#include <fstream>
#include <iostream>
#include <sstream>
#include <stdio.h>
#include <stdlib.h>
#include <string>

using namespace std;
using namespace Eigen;

Eigen::MatrixXd readCSV(std::string file, int rows, int cols) {

  MatrixXd X = MatrixXd::Zero(rows, cols);
  ifstream fin;
  fin.open(file);
  string line;
  int rowCount = -1;
  if (fin.is_open()) {
    while (getline(fin, line, '\r') && rowCount < rows-1) {
      rowCount++;
      int colCount = -1;
      istringstream buf(line);
      string field;
      while (getline(buf, field, ',')) {
        colCount++;
        string number;
        X(rowCount, colCount) = stod(field);
      }
    }
    fin.close();
    return X;
  } else {
    cout << "File " << file << " not opened." << endl;
    return X;
  }
}
