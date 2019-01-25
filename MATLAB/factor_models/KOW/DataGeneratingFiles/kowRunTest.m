clear;clc;

kowGenTestData
load('sdtest.mat')
Sims = 100;
burnin = floor(.1*Sims);
Beta = Beta';
Beta = Beta(:);
v0 = 5; 
r0 = 10;
[sumFt, sumFt2, storeBeta, storeObsVariance, storeObsModel,...
    storeStateTransitions, storeFt] = kowTest(yt,Xt,Sims, burnin,...
    Beta,  Gsim, .1 , zeros(1,T), v0, r0);

figure(1)
hold on
plot(Factor(1,:))
plot(sumFt(1,:))