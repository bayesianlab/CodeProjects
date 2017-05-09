function [ ml ] = arkSimulator(a, b, mu, sigma, sims, bd, lim)
J = length(mu);
precision = inv(sigma);   
conditionalVars = diag(precision);
sample = zeros(sims, 3, J);
sample(:,1,:) = drawNTruncatedMVNs(sims, bd, mu, sigma, lim);
notj = notJindxs(J);
xnot1 = squeeze(sample(:,1,2:J));
munot1 = mu(2:J);
Hxx1 = conditionalVars(1);
Hyx1 = precision(1, notj(1,:));
sigmaxx1 = sqrt((1/Hxx1));
sample(:,2,1) = conditionalMeanMVN(mu(1), Hxx1, Hyx1, xnot1, munot1);
sample(:,3,1) = repmat(sigmaxx1, sims,1);
zStar = squeeze(mean(sample(:,1,:)))';
kernel = arkTransitionKernel(a,b,zStar, sample, mu, precision, conditionalVars);
ml = log(mvnpdf(zStar, mu, sigma)/mean(prod(kernel,2)));
end

