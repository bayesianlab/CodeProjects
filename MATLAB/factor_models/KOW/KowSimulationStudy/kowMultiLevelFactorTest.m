clear;clc;
load('smallt.mat')
initBeta = betaSim;
initBeta = (ones(K,1+length(betaSim)).*[mu(1), betaSim])';
initBeta = initBeta(:);
initobsmod = ones(K,3).*Gsim;
initGamma = gamma;
v0 = 5;
r0 = 10;
Sims = 200;
burnin = floor(.1*Sims);
blocks = 6;

 [sumFt, sumFt2, storeBeta, storeObsVariance, storeObsModel,...
    storeStateTransitions, storeFt] = ...
    kowMultiLevelFactor(yt, Xt, RegionIndices,...
    CountriesThatStartRegions, Countries, SeriesPerCountry,...
    Sims, burnin, blocks, initBeta, initobsmod, initGamma, v0, r0);
hold on 
Factor = Factor(:,2:end);
plot(Factor(1,:), 'Color', 'black')
plot(sumFt(1,:))
legend('True', 'Estimated')