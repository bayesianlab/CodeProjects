function [ matrix ] = createMatrixG( transitionMat, diagonalMat, beta)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
 
matrix = eye(length(transitionMat)) - ...
    transitionMat * (beta.*diagonalMat);
matrix = inv(matrix)* [1;1];

end

