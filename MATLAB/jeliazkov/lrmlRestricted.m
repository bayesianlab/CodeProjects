function [ importance  ] = lrmlRestricted( a,b, y, X, a0, d0, mle, hess, draws, burnin )
format long
[J, ~] = size(hess);
variances = diag(hess);
theta = ghkGibbsSampler(0, Inf, mle, hess, draws);
theta = theta(burnin+1:draws,:);
sampLength = draws - burnin;
univariateDensities = zeros(sampLength, J);

for j = 1:J
    univariateDensities(:,j) = tnormpdf(a, b, mle(j), sqrt(variances(j)),...
        theta(:,j)')';
end
hTheta = prod(univariateDensities,2);

likelihoods = lrLikelihood(y,X, theta(:, 2:J)', theta(:,1)')...
    + logmvnpdf(theta(:,2:J), zeros(1,J-1), eye(J-1))...
    + loginvgampdf(theta(:,1), a0, d0)'...
    - log(hTheta);
importance = mean(likelihoods);
end

