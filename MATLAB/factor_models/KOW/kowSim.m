function [  ] = kowSim(Sims,burnin,dataset )
load(dataset)
[K,T] = size(yt);
initobsmodel = .1.*ones(K,3);
initgamma = .3;
blocks = 6;
[f,f2, beta, sigma2, G, Gamma, sf] = ...
    kowDynFac(yt, Xt, RegionIndices, CountriesThatStartRegions, Countries,...
        SeriesPerCountry,  initobsmodel, initgamma, blocks, Sims,burnin);

fname = createDateString('run_date_');
save(fname)
end

