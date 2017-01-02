function [ igam ] = invertedGamma( beta, X, yStar)
[r,c] = size(beta);
if r<c
    beta = beta';
end
v0 = 5;
del0 = 5;
[n,c] = size(X);
param1 = (v0 + n) / 2;
xTimesBeta = X*beta;
resids = yStar - xTimesBeta;
param2 = (del0 + (resids'*resids))/2;
gam = gamrnd(param1, 1./param2);
igam = 1./gam;


end

