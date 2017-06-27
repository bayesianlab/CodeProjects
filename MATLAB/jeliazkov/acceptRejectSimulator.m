function [ lp, v ] = acceptRejectSimulator(sims, N, mu, sigma)
[J,~] = size(sigma);
simResultsAR = zeros(N,sims);
zi = mvnrnd(mu,sigma,sims);
simResultsAR(:,:) = (sum(zi > 0,2) == J)';
v = lpVarAR(simResultsAR, 25);
lp = logProbability(sims, simResultsAR);
end

