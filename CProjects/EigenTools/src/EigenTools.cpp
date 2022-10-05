#include "EigenTools.hpp"

high_resolution_clock::time_point timeit() {
  high_resolution_clock::time_point start = high_resolution_clock::now();
  return start;
}

double timeit(high_resolution_clock::time_point &start) {
  high_resolution_clock::time_point end = high_resolution_clock::now();
  duration<double> d = duration_cast<duration<double>>(end - start);
  double sec = d.count();
  return sec;
}

VectorXi sequence(int b, int e) {
  if (e < b) {
    throw invalid_argument("Error in sequence, end point less than beginning.");
  }
  VectorXi c(e - b + 1);
  int h = 0;
  for (int i = b; i <= e; ++i) {
    c(h) = b + h;
    ++h;
  }
  return c;
}

VectorXi sequence(int b, int e, int skip) {
  if (e < b) {
    throw invalid_argument("Error in sequence, end point less than beginning.");
  }
  int N = (e - b + skip) / skip;
  VectorXi c(N);
  int h = 0;
  for (int i = b; i <= e; i += skip) {
    c(h) = b + h * skip;
    ++h;
  }
  return c;
}

VectorXd variance(const Ref<const MatrixXd> &A, int dim) {
    // verified with R
  if (dim == 0) {
    /// @brief dim = 0 variance across the rows, 1 down the columns
    /// @param A - matrix
    /// @param dim - the dimension
    /// @return variance across rows or down columns
    MatrixXd centered = (A.colwise() - A.rowwise().mean()).array().pow(2);
    return (1. / (A.cols() - 1)) * centered.rowwise().sum();
  } else {
    MatrixXd centered = (A.rowwise() - A.colwise().mean()).array().pow(2);
    return (1. / (A.rows() - 1)) * centered.colwise().sum();
  }
}

MatrixXd readCSV(std::string file) {
  MatrixXd X;
  int rows, cols;
  ifstream fin;
  fin.open(file);
  string line;
  int rowCount = -1;
  int colCount;
  if (fin.is_open()) {
    string field;
    string newfield;
    while (getline(fin, line, '\n')) {
      rowCount++;
      colCount = -1;
      istringstream buf(line);
      if (rowCount == 0) {
        while (getline(buf, field, ',')) {
          ++colCount;
        }
        cols = colCount;
      }
    }
    rows = rowCount;
    X.resize(rows + 1, cols + 1);
    rowCount = -1;
    fin.close();
    fin.open(file);
    while (getline(fin, line, '\n') && rowCount < rows) {
      rowCount++;
      colCount = -1;
      istringstream buf(line);

      while (getline(buf, field, ',')) {
        colCount++;
        if (colCount > cols) {
          throw invalid_argument("Columns not set correctly in readCSV");
        }
        X(rowCount, colCount) = stod(field);
      }
      if (rowCount > rows) {
        throw invalid_argument("Rows not set correctly in readCSV");
      }
    }
    fin.close();
    return X;
  } else {
    cout << "File " << file << " not opened." << endl;
    X.resize(1, 1);
    return X;
  }
}

Matrix<int, Dynamic, 2> castToInfoMat(const MatrixXd &I) {
  Matrix<int, Dynamic, 2> InfoMat(I.rows(), 2);
  for (int i = 0; i < I.rows(); ++i) {
    for (int j = 0; j < 2; ++j) {
      InfoMat(i, j) = (int)I(i, j);
    }
  }
  return InfoMat;
}

VectorXd vech(const MatrixXd &X) {
  size_t r = X.rows();
  VectorXd vh(r * (r - 1) / 2);
  int k = 0;
  for (int c = 0; c < X.cols(); ++c) {
    for (int x = c + 1; x < r; ++x) {
      vh[k] = X(x, c);
      ++k;
    }
  }
  return vh;
}
