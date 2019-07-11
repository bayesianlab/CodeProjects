function [Matrix] = TransformMatrix(Vector, RowsMatrix)
K = length(Vector);
Matrix = zeros(RowsMatrix*RowsMatrix, K);
leftPaddingCounter = 0;
rightPaddingCounter = K;
upperPaddingCounter = 0;
nonzeroSize = RowsMatrix;
t = 1:RowsMatrix;
for k = 1:RowsMatrix
    select = t + (k-1)*RowsMatrix;
    nonzeroSize = nonzeroSize -1;
    rightPaddingCounter = rightPaddingCounter - nonzeroSize;
    rightPadding = zeros(nonzeroSize, rightPaddingCounter);
    I = eye(nonzeroSize);
    leftPadding = zeros(nonzeroSize, leftPaddingCounter);
    leftPaddingCounter = leftPaddingCounter + nonzeroSize;
    upperPaddingCounter = upperPaddingCounter + 1;
    upperPadding = zeros(upperPaddingCounter,K);
    Matrix( select, :) = [upperPadding; [leftPadding, I, rightPadding] ];
end
end

