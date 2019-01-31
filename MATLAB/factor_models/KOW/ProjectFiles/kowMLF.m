function [] = kowMLF(Sims, burnin, ReducedRuns, dataset, varargin)
if ischar(Sims)
    Sims = str2num(Sims);
end
if ischar(burnin)
    burnin = str2num(burnin);
end
if ischar(ReducedRuns)
    ReducedRuns = str2num(ReducedRuns);
end
rng(1001)
load(dataset);
if nargin == 5
    fname = createDateString(varargin{1})
else
    fname = createDateString('simulation_study_')
end
[sumFt, sumFt2, storeBeta, storeObsVariance, storeObsModel,...
    storeStateTransitions, ml] = ...
    kowMultiLevelFactor(yt, Xt, RegionIndices,...
      CountriesThatStartRegions, Countries, SeriesPerCountry,...
      Sims, burnin, blocks,  RegionBlocks, K/RegionBlocks, initBeta, initobsmod, initGamma, v0, r0, ...
      ReducedRuns);

save(fname)

end

