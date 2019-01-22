clear;clc;

kowGenTestData
load('sdtest.mat')
Sims = 1000;
burnin = floor(.1*Sims);
Beta = Beta';
Beta = Beta(:);
v0 = 0; 
r0 = 0;
[sumFt, sumFt2, storeBeta, storeObsVariance, storeObsModel,...
    storeStateTransitions, storeFt] = kowTest(yt,Xt,Sims, burnin,...
    Beta, Gsim, gammaSim, Factor, v0, r0);
figure(1)
hold on
plot(Factor(1,101:200), 'Color', 'black')
plot(sumFt(1,101:200))
legend('True', 'Estimated')
figure(2)
hold on
plot(Factor(1,301:499), 'Color', 'black')
plot(sumFt(1,301:499))
legend('True', 'Estimated')
figure(3)
hold on
plot(Factor(1,:), 'Color', 'black')
plot(sumFt(1,:))
legend('True', 'Estimated')
% 
% figure(2)
% sst = squeeze(storeStateTransitions);
% hold on 
% plot(sst(1,:))
% plot(sst(2,:))
% plot(sst(3,:))
% plot(sst(4,:))
% yline(gammaSim);
% msst = mean(sst(1,:))
% yline(msst);