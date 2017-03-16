function [ pHat] = ARsimulator(X,beta, eps)
u =  X*beta + eps;
simProb = binornd(1, normcdf(u));
pHat = mean(simProb,2);
end

