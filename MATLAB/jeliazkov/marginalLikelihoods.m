clear; clc;

rng(101)


N = 2000;
Sims = 50;
batches = 5;
% importanceMLSimulation(N, Sims, batches)
% crtMLSimulations(N, Sims, batches)
crbMLSimulator(N, Sims, batches)
% arkMLSimulator(N, Sims, batches)
% askMLSimulator(N, Sims, batches)

% mu = [0,.5,1];
% sigma = createSigma(.7,3)
% ev = min(eig(sigma))
% sigma - eye(3)*ev



% newMethodSimulator(0,Inf,mu,sigma,10000,1000)
% crtSimulations(3, 1000,100)
% askSimulations(3, 1000,100)
% arkSimulations(3, 1000)