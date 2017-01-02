function [ out ] = updateBetaPrior( betaMLE, iHess, sigSqd, X, yStar )
[r,c] = size(betaMLE);
if r<c
    betaMLE = betaMLE';
end

Bhat = inv( iHess+ ((X'*X)./sigSqd) );
betaHat = Bhat*( (iHess*betaMLE) + ((X'*yStar)./sigSqd) );
out = mvnrnd(betaHat, Bhat);


end

