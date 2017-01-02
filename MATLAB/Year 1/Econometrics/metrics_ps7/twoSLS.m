function [ btwoSLS] = twoSLS( X_Mat,exogeneous_instruments,y)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
projection = exogeneous_instruments*inv(exogeneous_instruments'...
    *exogeneous_instruments)*exogeneous_instruments';

btwoSLS = inv(X_Mat'*projection*X_Mat) * (X_Mat'...
    *projection*y);

end

