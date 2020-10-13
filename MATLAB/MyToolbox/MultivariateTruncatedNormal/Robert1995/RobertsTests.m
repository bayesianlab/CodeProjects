clear;clc;
% hist(shiftedExponentialDist(100,-10,10000), 100)
X=NormalTruncatedPositive(-100,1,10000);
hist(X, 100)

mean(X)
mode(X)