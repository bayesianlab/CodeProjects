function [ marginalLikelihood ] = crbSimulator(a, b, mu, sigma,...
    sims, burnin, varargin)
sample = tmvnGibbsSampler(a, b, mu, sigma, sims, burnin, varargin{1});
precision = inv(sigma);
[zStar, fzStar] = crbMarginalLikelihood(a,b, mu, precision, sample, sims, burnin);
marginalLikelihood = log(mvnpdf(zStar,mu,sigma)/prod(fzStar));
end

