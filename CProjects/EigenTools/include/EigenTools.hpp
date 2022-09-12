#pragma once
#ifndef EIGENTOOLS_H
#define EIGENTOOLS_H
#include <math.h>

#include <Eigen/Dense>
#include <Eigen/Sparse>
#include <chrono>
#include <eigen3/unsupported/Eigen/KroneckerProduct>
#include <fstream>
#include <iostream>
#include <stdexcept>
using namespace std;
using namespace chrono;
using namespace Eigen;

high_resolution_clock::time_point timeit();
typedef SparseMatrix<double> SparseDouble;

double timeit(high_resolution_clock::time_point &start);

template <typename D>
void dim(const EigenBase<D> &M) {
  cout << M.rows() << " x " << M.cols() << endl;
}

VectorXd var(const Ref<const MatrixXd> &A);

VectorXi sequence(int b, int e);

VectorXi sequence(int b, int e, int skip);

template <typename Derived1>
MatrixXd CreateDiag(const MatrixBase<Derived1> &diagonalMat,
                    const ArrayXi &diagonalVector, int k, int c) {
  /* Puts elements of diagonalMat along the diagonals in diagonalVector */
  MatrixXd D = MatrixXd::Zero(k, c);
  if (k > c) {
    if (min(k - diagonalVector.cwiseAbs().minCoeff(), c) > diagonalMat.rows()) {
      throw invalid_argument(
          "di rows must be greater than number of elements in longest "
          "diagonal.");
    }
  } else {
    if (min(c - diagonalVector.cwiseAbs().minCoeff(), k) > diagonalMat.rows()) {
      throw invalid_argument(
          "di rows must be greater than number of elements in longest "
          "diagonal.");
    }
  }

  if (diagonalMat.cols() < diagonalVector.rows()) {
    throw invalid_argument("Not enough diagonals supplied.");
  }
  int w = 0;
  int lastcol = 0;
  int curdiagonal;
  int abscurdiag;
  for (int t = 0; t < diagonalVector.size(); ++t) {
    curdiagonal = diagonalVector(t);
    if (curdiagonal < 0) {
      abscurdiag = abs(diagonalVector(t));
      lastcol = min(k - abscurdiag, c);
      for (int h = 0; h < lastcol; ++h) {
        w = h + abscurdiag;
        D(w, h) = diagonalMat(h, t);
      }
    } else {
      lastcol = min(c - abs(diagonalVector(t)), k);
      for (int h = 0; h < lastcol; ++h) {
        w = h + diagonalVector(t);
        D(h, w) = diagonalMat(h, t);
      }
    }
  }
  return D;
}

template <typename Derived1>
SparseDouble CreateBigDiag(const MatrixBase<Derived1> &diagonalMat,
                           const ArrayXi &diagonalVector, int k, int c) {
  SparseMatrix<double> EmptyD(k, c);
  if (k > c) {
    if (min(k - diagonalVector.cwiseAbs().minCoeff(), c) > diagonalMat.rows()) {
      throw invalid_argument(
          "di rows must be greater than number of elements in longest "
          "diagonal.");
    }
  } else {
    if (min(c - diagonalVector.cwiseAbs().minCoeff(), k) > diagonalMat.rows()) {
      throw invalid_argument(
          "di rows must be greater than number of elements in longest "
          "diagonal.");
    }
  }

  if (diagonalMat.cols() < diagonalVector.rows()) {
    throw invalid_argument("Not enough diagonals supplied.");
  }
  int w = 0;
  int lastcol = 0;
  int curdiagonal;
  int abscurdiag;
  for (int t = 0; t < diagonalVector.size(); ++t) {
    curdiagonal = diagonalVector(t);
    if (curdiagonal < 0) {
      abscurdiag = abs(diagonalVector(t));
      lastcol = min(k - abscurdiag, c);
      for (int h = 0; h < lastcol; ++h) {
        w = h + abscurdiag;
        EmptyD.insert(w, h) = diagonalMat(h, t);
      }
    } else {
      lastcol = min(c - abs(diagonalVector(t)), k);
      for (int h = 0; h < lastcol; ++h) {
        w = h + diagonalVector(t);
        EmptyD.insert(h, w) = diagonalMat(h, t);
      }
    }
  }
  return EmptyD;
}

template <typename D>
MatrixXd surForm(const MatrixBase<D> &stackedx, int K) {
  int KT = stackedx.rows();
  int cols = stackedx.cols();
  int T = KT / K;
  MatrixXd KronIone =
      kroneckerProduct(MatrixXd::Identity(K, K), MatrixXd::Ones(1, cols))
          .replicate(T, 1);
  return KronIone.array() * stackedx.replicate(1, K).array();
}

template <typename D>
bool isPD(const MatrixBase<D> &x) {
  if (x.llt().info() == NumericalIssue) {
    return false;
  } else {
    return true;
  }
}

MatrixXd readCSV(std::string file);

Matrix<int, Dynamic, 2> castToInfoMat(const MatrixXd &I);

template <typename Q>
MatrixXd blockDiag(const MatrixBase<Q> &Blocks, const int &blocksizerows) {
  const int blocksizecols = Blocks.cols();
  const int finalMatRows = Blocks.rows();
  if (finalMatRows % blocksizerows) {
    throw(invalid_argument(
        "Error in blockDiag, blocksizerows is not multiple of Blocks.rows()."));
  }
  const int T = finalMatRows / blocksizerows;
  const int finalMatCols = blocksizecols * T;
  int startRow, startCol, endRow, endCol, r, c;

  MatrixXd BlockDiag(finalMatRows, finalMatCols);
  startRow = 0;
  startCol = 0;
  r = 0;
  for (int t = 0; t < T; ++t) {
    startRow = t * blocksizerows;
    startCol = t * blocksizecols;
    endRow = (t + 1) * blocksizerows;
    endCol = (t + 1) * blocksizecols;
    for (int i = startRow; i < endRow; ++i) {
      c = 0;
      for (int j = startCol; j < endCol; ++j) {
        BlockDiag(i, j) = Blocks(r, c);
        ++c;
      }
      ++r;
    }
  }
  return BlockDiag;
}

template <typename T>
MatrixXd makeBlockDiagonal(const MatrixBase<T> &Block, const int &reptimes) {
  const int r = Block.rows();
  MatrixXd B = Block.replicate(reptimes, 1);
  return blockDiag(B, r);
}

template <typename T>
MatrixXd makeBlockDiagonal(const MatrixBase<T> &Block, const int &reptimes,
                           const ArrayXi &diag) {
  /* Makes a block diagonal of Block along diagonal diag */
  VectorXd v = VectorXd::Ones(reptimes);
  MatrixXd M = CreateDiag(v, diag, reptimes, reptimes);
  MatrixXd X = kroneckerProduct(M, Block);
  return X;
}

template <typename D, typename Y>
void bigBlockDiag(SparseMatrix<D> &BigSparseBlock,
                  const MatrixBase<Y> &StackedBlock, const int &blocksizerows) {
  if (StackedBlock.rows() % blocksizerows) {
    throw(invalid_argument("Error in bigBlockDiag."));
  }
  const int T = StackedBlock.rows() / blocksizerows;
  const int blocksizecols = StackedBlock.cols();
  int startRow, startCol, endRow, endCol, r, c;
  startRow = 0;
  startCol = 0;
  r = 0;
  for (int t = 0; t < T; ++t) {
    startRow = t * blocksizerows;
    startCol = t * blocksizecols;
    endRow = (t + 1) * blocksizerows;
    endCol = (t + 1) * blocksizecols;
    for (int i = startRow; i < endRow; ++i) {
      c = 0;
      for (int j = startCol; j < endCol; ++j) {
        BigSparseBlock.insert(i, j) = StackedBlock(r, c);
        ++c;
      }
      ++r;
    }
  }
}

template <typename T>
MatrixXd mean(const std::vector<T> &X) {
  MatrixXd avg;
  avg.setZero(X[0].rows(), X[0].cols());
  for (T i : X) {
    avg += i;
  }
  return avg.array() / X.size();
}

template <typename T, typename D>
void makeBigBlockDiag(SparseMatrix<T> &BigSparseBlock,
                      const MatrixBase<D> &Block, const int &reptimes) {
  if ((long int)BigSparseBlock.rows() != (long int)reptimes * Block.rows()) {
    throw(
        invalid_argument("Error in makeBigBlockDiag, BigSparseBlock.rows() is "
                         "not a multiple of reptimes x Block."));
  }
  int r = Block.rows();
  MatrixXd B = Block.replicate(reptimes, 1);
  return bigBlockDiag(BigSparseBlock, B, r);
}

VectorXd vech(const MatrixXd &X);

#endif