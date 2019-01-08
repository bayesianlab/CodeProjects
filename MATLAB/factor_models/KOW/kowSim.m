function [  ] = kowSim(Sims,burnin, ReducedRuns, blocks, dataset )
if ischar(Sims)
    Sims = str2num(Sims);
end
if ischar(burnin)
    burnin = str2num(burnin);
end
if ischar(blocks)
    blocks = str2num(blocks);
end
if ischar(ReducedRuns)
    ReducedRuns = str2num(ReducedRuns);
end
load(dataset)
[K,T] = size(yt);
initobsmodel = .1.*ones(K,3);
initgamma = .3;
[f,f2, beta, sigma2, G, Gamma, storef, ml] = ...
    kowDynFac(yt, Xt, RegionIndices, CountriesThatStartRegions, Countries,...
        SeriesPerCountry,  initobsmodel, initgamma, blocks, Sims,burnin, ReducedRuns);

fname = strcat(createDateString('run_date_'), '_',dataset);
save(fname)
end

