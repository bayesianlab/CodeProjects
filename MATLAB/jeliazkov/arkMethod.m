% Accept Reject Kernal Estimator
clear;clc;
sims = 10000;
burnin = floor(.1*sims);
arkSimulations(3,sims,burnin)
% arkSimulations(6,sims,burnin)
% arkSimulations(9,sims,burnin)
% arkSimulations(12,sims,burnin)
