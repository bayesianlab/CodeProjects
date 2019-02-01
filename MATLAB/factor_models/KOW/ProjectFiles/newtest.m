clear;clc;
rng(145)
CountriesInRegion = 1;
SeriesPerCountry = 4;
Regions = 1;
T = 200;
beta = [-.2, .2, -.2,.2, -.2];
G = [.3, .4, .5]';
gamma = [.3, .3, .3]';
K = SeriesPerCountry*CountriesInRegion*Regions;
[yt, Xt, Factor, RegionRestrictionIndices, CountriesThatStartRegions, beta] = ...
    kowGenSimData(T, Regions, CountriesInRegion,SeriesPerCountry,beta, G, gamma);


InfoMat = [1, 1];
v0=5;
r0 =10;
Sims = 1;
burnin =1;
initobsmodel = [1,1,1].*ones(K,3);
initStateTransitions = [.5;.5;.5];
 MultDyFacVar(yt, Xt,InfoMat, SeriesPerCountry, Sims, burnin, initobsmodel, initStateTransitions,v0,r0)