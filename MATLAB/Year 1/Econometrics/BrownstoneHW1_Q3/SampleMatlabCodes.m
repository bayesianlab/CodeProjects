function SampleMatlabCodes
clear
clc
nobs = 8000;
X = [ones(nobs,1),randn(nobs,3)];
Y = X*[1 2 3 4]' + randn(nobs,1);
Y(Y>0) = 1;
Y(Y<=0) = 0;
estimator = PROBIT(Y,X);
end