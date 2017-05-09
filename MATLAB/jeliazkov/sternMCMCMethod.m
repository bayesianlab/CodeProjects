clear;clc;
s= createSigma(-.7,3);
mu=[0,.5,1];
sims = 11000;
burnin  = 1000;
a=0;
b=Inf;
sternSimulations(3,sims, burnin)
sternSimulations(6,sims, burnin)
sternSimulations(9,sims, burnin)
sternSimulations(12,sims, burnin)