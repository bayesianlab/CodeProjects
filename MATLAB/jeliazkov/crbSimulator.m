function [ marginalLikelihood, se ] = crbSimulator(a, b, mu, sigma,...
    sims, burnin, init)
sample = tmvnGibbsSampler(a, b, mu, sigma, sims, burnin, init);
precision = inv(sigma);
[zStar, fzStar] = crbMarginalLikelihood(a,b, mu, precision, sample, sims, burnin);
marginalLikelihood = logProbMCMC(zStar, fzStar, mu,sigma);
% se = lpVarCRB(sample, 25,a,b,mu, sigma, precision);
se=1
end

