function [ newa, amean,ApproxCov ] = mhStepForA(y,mu, FullSigma,...
    Sdiag,derivll, guess, b0,B0, nu)
K = length(guess) ;
[amean, ApproxCov] = bhhh(guess, derivll, 10, 1e-2, .5);
acan = amean + (chol(ApproxCov, 'lower')*normrnd(0,1,K,1))...
    ./sqrt(chi2rnd(nu,1)/nu);
Num = log(mvnpdf(acan, b0, B0)) + ...
    marginalLogLikelihood(y,mu,[1;acan],FullSigma, Sdiag) +...
    MVstudenttpdf(guess,amean,ApproxCov,nu);
Den = log(mvnpdf(guess, b0, B0)) + ...
    marginalLogLikelihood(y,mu,[1;guess],FullSigma, Sdiag) +...
    MVstudenttpdf(acan,amean,ApproxCov,nu);
mhprob = min(0, Num - Den);
if log(unifrnd(0,1,1,1)) < mhprob
    newa = acan;
else
    newa = guess;
end
end

