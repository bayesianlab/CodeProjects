clear;clc;
X= normrnd(0,1,10000,10000);
b = ones(10000,1);
y = X*b;
XpX = X'*X;
Xpy = X'*y;
tic
inv(XpX)*Xpy;
toc
tic
linSysSolve(chol(XpX,'lower'), Xpy);
toc