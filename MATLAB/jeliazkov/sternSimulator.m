function [ lp ] = sternSimulator(sims, mu, sigma )
[~, J] = size(sigma);
[~, vals] = eig(sigma);
smallestEigen = min(diag(vals));
varianceMat = sigma - (smallestEigen.*eye(J));
z = mvnrnd(mu, varianceMat, sims)./sqrt(smallestEigen);
vals = normcdf(z);
simResults = prod(vals,2);
lp = logProbability(sims, simResults);
end

