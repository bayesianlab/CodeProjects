function [] = kowMLF(Sims, burnin, ReducedRuns, dataset)
if ischar(Sims)
    Sims = str2num(Sims);
end
if ischar(burnin)
    burnin = str2num(burnin);
end
if ischar(ReducedRuns)
    ReducedRuns = str2num(ReducedRuns);
end
pwd

load(dataset);
rng(1001)
initobsmod = ones(K,3).*[1,1,1];
initGamma = g';
v0 = 5;
r0 = 10;
Sims = 10;
ReducedRuns = 5;
burnin = 1;
blocks = 1;
[sumFt, sumFt2, storeBeta, storeObsVariance, storeObsModel,...
    storeStateTransitions, ml] = ...
    kowMultiLevelFactor(yt, Xt, RegionIndices,...
      CountriesThatStartRegions, Countries, SeriesPerCountry,...
      Sims, burnin, blocks, Regions, K/Regions, betaTrue, initobsmod, initGamma, v0, r0, ...
      ReducedRuns);
fname = createDateString('simstudy_')
save(fname)

end

