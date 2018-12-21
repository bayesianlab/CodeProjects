clear;clc;
% Dimension and setup
rng(1.6)
T = 100;
G = [-.5, -.3, .25];
gamma = .3;
SeriesPerCountry = 3;
beta = [.3, -.5, .25];
Regions = 2;
CountriesInRegion = 3;
Countries = Regions*CountriesInRegion;
mu = ones(Countries*SeriesPerCountry, 1).* -.5;
[yt, Xt, Factor, RegionIndices,CountriesThatStartRegions ] = ...
    kowGenSimData(T, Regions, CountriesInRegion, SeriesPerCountry, mu, beta, G, gamma);

[K,T] = size(yt);
initobsmodel = .1.*ones(K,3);
initgamma = .3;
blocks = 6;
[f,f2, beta, sigma2, G, Gamma, sf] = ...
    kowDynFac(yt, Xt, RegionIndices, CountriesThatStartRegions, Countries,...
        SeriesPerCountry,  initobsmodel, initgamma, blocks, 10,1);

