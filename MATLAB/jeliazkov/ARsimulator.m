function [ pHat] = ARsimulator(X,beta, eps)
% something like this for multinomial probit
% pHat = normcdf(X*beta);
u =  X*beta + eps;
simProb =  u > 0;
pHat = mean(simProb,2);
end

