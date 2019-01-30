clear;clc;
load('longt.mat')
rng(1001)

initobsmod = ones(K,3).*[.3,1,1];
initGamma = gamma';
v0 = 5;
r0 = 10;
Sims = 50;
burnin = 5;
blocks = 1;


[sumFt, sumFt2, storeBeta, storeObsVariance, storeObsModel,...
    storeStateTransitions, storeFt] = ...
    kowMultiLevelFactor(yt, Xt, RegionIndices,...
      CountriesThatStartRegions, Countries, SeriesPerCountry,...
      Sims, burnin, blocks, 2, 2, betaTrue, initobsmod, gamma, v0, r0);

variance = sumFt2 - sumFt.^2;
sig = sqrt(variance);
upper = sumFt + 2.*sig;
lower = sumFt - 2.*sig;


mean(storeObsModel,3)
mean(storeStateTransitions,3)'
mean(reshape(mean(storeBeta,2), SeriesPerCountry+1, K),2)'



subplot(5,2,[1,2])
hold on 
plot(Factor(1,:), 'Color', 'black')
plot(sumFt(1,:))
legend('True', 'Estimated')
title('World')
hold off

subplot(5,2,3)
hold on 
plot(Factor(2,:), 'Color', 'black')
plot(sumFt(2,:))
legend('True', 'Estimated')
title('Region 1')
hold off

subplot(5,2,5)
hold on 
plot(Factor(3,:), 'Color', 'black')
plot(sumFt(3,:))
legend('True', 'Estimated')
title('Region 2')
hold off


subplot(5,2,4)
hold on 
plot(Factor(4,:), 'Color', 'black')
plot(sumFt(4,:))
legend('True', 'Estimated')
title('Country 1')
hold off

subplot(5,2,6)
hold on 
plot(Factor(5,:), 'Color', 'black')
plot(sumFt(5,:))
legend('True', 'Estimated')
title('Country 2')
hold off


subplot(5,2,7)
hold on 
plot(Factor(6,:), 'Color', 'black')
plot(sumFt(6,:))
legend('True', 'Estimated')
title('Country 3')
hold off


subplot(5,2,8)
hold on 
plot(Factor(7,:), 'Color', 'black')
plot(sumFt(7,:))
legend('True', 'Estimated')
title('Country 4')
hold off

