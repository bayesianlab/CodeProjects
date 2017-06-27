function [ marginalLikelihood, se ] = crbSimulator(a, b, mu, sigma,...
    sims, burnin, varargin)
sample = tmvnGibbsSampler(a, b, mu, sigma, sims, burnin, varargin{1});
precision = inv(sigma);
[zStar, fzStar] = crbMarginalLikelihood(a,b, mu, precision, sample, sims);
marginalLikelihood = logProbMCMC(zStar, fzStar, mu,sigma);
se = lpVarCRB(sample, 25,a,b,mu, sigma, precision);
end

