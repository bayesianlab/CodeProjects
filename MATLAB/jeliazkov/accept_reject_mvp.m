clear; clc;
simulation_data_mvp
sims = 10000;
simResultsAR = zeros(N,sims);
for s = 1:sims
    zi = mvnrnd(mu1, sigma, N);
    simResultsAR(:,s) = sum(zi > 0,2)==3;
end
mean(simResultsAR)
mean(log((1/sims)*sum(simResultsAR,2)))