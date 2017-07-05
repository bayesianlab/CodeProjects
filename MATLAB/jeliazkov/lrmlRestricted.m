function [ importance  ] = lrmlRestricted( a,b, y, X, a0, d0, mle, hess, draws, burnin )
format long
[J, ~] = size(hess);
variances = diag(hess);
Chol = chol(hess, 'lower');
z = askGibbs(0,Inf, mle, hess, draws, burnin);
theta = mle + Chol*z';
sampLength = draws - burnin;
univariateDensities = zeros(sampLength, J);
for j = 1:J
    univariateDensities(:,j) = tnormpdf(a, b, mle(j), sqrt(variances(j)),...
        theta(j, :)')';
end
hTheta = prod(univariateDensities,2);
likelihoods = lrLikelihood(y,X, theta(2:J, :), theta(1,:))...
    + log(mvnpdf(theta(2:J, :)', zeros(1,J-1), eye(J-1)))...
    + log(invgampdf(theta(1,:), a0, d0))...
    - log(hTheta);
[likelihoods, lrLikelihood(y,X, theta(2:J, :), theta(1,:)), log(mvnpdf(theta(2:J, :)', zeros(1,J-1), eye(J-1))), log(invgampdf(theta(1,:), a0, d0)), log(hTheta), theta(1,:)']
importance = mean(likelihoods);
end

