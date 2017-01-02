function [ btwoSLS ] = twoSLS( X,Z,y)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
projection = Z*inv(Z'*Z)'*Z';
btwoSLS = inv(X'*projection*X) * (X'*projection*y);

end

