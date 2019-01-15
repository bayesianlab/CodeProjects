rng(5)
load('sdtest.mat')
Sims = 1000;
burnin = floor(.1*Sims);
[sumFt, sumFt2, storeBeta, storeObsVariance, storeObsModel,...
    storeStateTransitions, storeFt] = kowTest(yt,Xt,Sims, burnin, [muSim;betaSim], Gsim, gammaSim, Factor);
% figure(1)
% hold on
% plot(Factor(1,101:200), 'Color', 'black')
% plot(sumFt(1,101:200))
% legend('True', 'Factor')
% figure(2)
% hold on
% plot(Factor(1,301:500), 'Color', 'black')
% plot(sumFt(1,301:500))
% legend('True', 'Factor')
% figure(3)
% hold on
% plot(Factor(1,:), 'Color', 'black')
% plot(sumFt(1,:))
% legend('True', 'Factor')

figure(2)
sst = squeeze(storeStateTransitions);
hold on 
plot(sst(1,:))
plot(sst(2,:))
plot(sst(3,:))
plot(sst(4,:))
yline(.8);
yline(mean(sst(1,:)));