clear;clc;
load('longt.mat')
rng(1001)
initBeta = betaSim;
initBeta = (ones(K,1+length(betaSim)).*[mu(1), betaSim])';
initBeta = initBeta(:);
initobsmod = ones(K,3).*[4,3,4];
initGamma = gamma;
v0 = 5;
r0 = 10;
Sims = 50;
burnin = floor(.1*Sims);
blocks = 6;

 [sumFt, sumFt2, storeBeta, storeObsVariance, storeObsModel,...
    storeStateTransitions, storeFt] = ...
    kowMultiLevelFactor(yt, Xt, RegionIndices,...
    CountriesThatStartRegions, Countries, SeriesPerCountry,...
    Sims, burnin, blocks, initBeta, initobsmod, initGamma, v0, r0);
Factor = Factor(:,2:end);

figure(1)
subplot(3,2,1);
hold on 
plot(Factor(1,:), 'Color', 'black')
plot(sumFt(1,:))
legend('True', 'Estimated')
hold off

subplot(3,2,2)
hold on 
plot(Factor(2,:), 'Color', 'black')
plot(sumFt(2,:))
legend('True', 'Estimated')
hold off

subplot(3,2,3)
hold on 
plot(Factor(3,:), 'Color', 'black')
plot(sumFt(3,:))
legend('True', 'Estimated')
hold off

figure(2)
subplot(3,2,1)
hold on 
plot(Factor(4,:), 'Color', 'black')
plot(sumFt(4,:))
legend('True', 'Estimated')
hold off

subplot(3,2,2)
hold on 
plot(Factor(5,:), 'Color', 'black')
plot(sumFt(5,:))
legend('True', 'Estimated')
hold off

subplot(3,2,3)
hold on 
plot(Factor(6,:), 'Color', 'black')
plot(sumFt(6,:))
legend('True', 'Estimated')
hold off

subplot(3,2,4)
hold on 
plot(Factor(7,:), 'Color', 'black')
plot(sumFt(7,:))
legend('True', 'Estimated')
hold off

subplot(3,2,5)
hold on 
plot(Factor(8,:), 'Color', 'black')
plot(sumFt(8,:))
legend('True', 'Estimated')
hold off

subplot(3,2,6)
hold on 
plot(Factor(9,:), 'Color', 'black')
plot(sumFt(9,:))
legend('True', 'Estimated')
hold off