clear;clc;

kowGenTestData
load('longt.mat')
rng(1001)
Sims = 100;
burnin = floor(.1*Sims);
Beta = [0,0,0]
v0 = 5; 
r0 = 10;
[sumFt, sumFt2, storeBeta, storeObsVariance, storeObsModel,...
    storeStateTransitions, storeFt] = kowTest(yt,Xt,Sims, burnin,...
    Beta,  Gsim(1).*ones(K,1), .1 , zeros(1,T), v0, r0);
mean(storeBeta,2)
figure(1)
hold on
plot(Factor(1,:))
plot(sumFt(1,:))