clear;clc;
load('longt.mat')
rng(1001)

initobsmod = ones(K,3).*[.5,.5,.5];
initGamma = g';
v0 = 5;
r0 = 10;
Sims = 10;
ReducedRuns = 5;
burnin = 1;
blocks = 1;


[sumFt, sumFt2, storeBeta, storeObsVariance, storeObsModel,...
    storeStateTransitions,  ml] = ...
    kowMultiLevelFactor(yt, Xt, RegionIndices,...
      CountriesThatStartRegions, Countries, SeriesPerCountry,...
      Sims, burnin, blocks, 2, 10, betaTrue, initobsmod, initGamma, v0, r0, ...
      ReducedRuns);

variance = sumFt2 - sumFt.^2;
sig = sqrt(variance);
upper = sumFt + 2.*sig;
lower = sumFt - 2.*sig;
xaxis = 1:T;
fillX = [xaxis, fliplr(xaxis)];
fillY = [upper, fliplr(lower)];
mean(storeObsModel,3)
mean(storeStateTransitions,3)'
mean(reshape(mean(storeBeta,2), SeriesPerCountry+1, K),2)'

facealpha = .5;

subplot(5,2,[1,2])
h = fill(fillX(1,:), fillY(1,:), [1,0,0]);
set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
hold on 
p1 = plot(Factor(1,:), 'Color', 'black', 'LineWidth', 1);
title('World')
hold off

subplot(5,2,3)
h = fill(fillX(1,:), fillY(1,:), [1,0,0]);
set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
hold on 
p1 = plot(Factor(2,:), 'Color', 'black');
title('Region 1')
hold off

subplot(5,2,5)
h = fill(fillX(1,:), fillY(1,:), [1,0,0]);
set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
hold on 
p1 = plot(Factor(3,:), 'Color', 'black');
title('Region 2')
hold off

subplot(5,2,4)
hold on 
h = fill(fillX(1,:), fillY(1,:), [1,0,0]);
set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
p1 = plot(Factor(4,:), 'Color', 'black');
title('Country 1')
hold off

subplot(5,2,6)
h = fill(fillX(1,:), fillY(1,:), [1,0,0]);
set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
hold on 
p1 = plot(Factor(5,:), 'Color', 'black');
title('Country 2')
hold off


subplot(5,2,7)
h = fill(fillX(1,:), fillY(1,:), [1,0,0]);
set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
hold on 
p1 = plot(Factor(6,:), 'Color', 'black');
title('Country 3')
hold off


subplot(5,2,8)
h = fill(fillX(1,:), fillY(1,:), [1,0,0]);
set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
hold on 
p1 = plot(Factor(7,:), 'Color', 'black');
title('Country 4')
hold off

