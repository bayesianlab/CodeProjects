clear; clc;
rng(101)


N = 20;
Sims = 200;
batches = 15;
importanceMLSimulation(N, Sims, batches)
% crtMLSimulations(N, Sims, batches)
% crbMLSimulator(N, Sims, batches)
arkMLSimulator(N, Sims, batches)
askMLSimulator(N, Sims, batches)