clear; clc;

rng(101)


N = 2000;
Sims = 1000;
batches = 15;
coefs = [.25; .45];
% importanceMLSimulation(N, coefs, Sims, batches)
% crtMLSimulations(N, coefs, Sims, batches)
crbMLSimulator(N, coefs, Sims, batches)
arkMLSimulator(N, coefs, Sims, batches)
askMLSimulator(N, coefs, Sims, batches)

% mu = [0,.5,1];
% sigma = createSigma(.7,3)
% ev = min(eig(sigma))
% sigma - eye(3)*ev



% newMethodSimulator(0,Inf,mu,sigma,10000,1000)
% crtSimulations(3, 1000,100)
% askSimulations(3, 1000,100)
% arkSimulations(3, 1000)