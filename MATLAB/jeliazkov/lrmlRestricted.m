function [ importance  ] = lrmlRestricted( a,b, y, X, a0, d0, mle, hess, draws, burnin )
[J, ~] = size(hess);
variances = diag(hess);
Chol = chol(hess, 'lower');
z = askGibbs(0,Inf, mle, hess, draws, burnin);
theta = mle + Chol*z';

univariateDensities = zeros(draws - burnin, J);
for j = 1:J
    univariateDensities(:,j) = tnormpdf(0,Inf, mle(j), sqrt(variances(j)),...
        theta(j, :)')';
end
hTheta = prod(univariateDensities,2);

importance = mean(lrLikelihood(y,X, theta(2:J, :), theta(1,:)) +...
    log(mvnpdf(theta(2:J, :)', zeros(1,J-1), eye(J-1))) +...
    log(invgampdf(theta(1,:), a0, d0)) -...
    log(hTheta));
end

