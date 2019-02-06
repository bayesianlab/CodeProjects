clear;clc;
rng(1101)
SeriesPerCountry =6;
CountriesInRegion = 5;
Regions = 4;
Countries = CountriesInRegion*Regions;


T = 100;
beta = ones(1,SeriesPerCountry+1).*.4;
G = [.7, .7, .6]';
gamma = linspace(.1, .3, 1+Regions+Countries);
K = SeriesPerCountry*CountriesInRegion*Regions;
[yt, Xt, Factor,InfoCell, beta] = ...
    MLFdata(T, Regions, CountriesInRegion,SeriesPerCountry,beta, G, gamma);


Countries = CountriesInRegion*Regions;

nFactors = 1 + Regions + Countries;
v0=3;
r0 =5;
Sims = 50;
burnin =10;
initobsmodel = [.2,.2,.2].*ones(K,3);
initStateTransitions = ones(nFactors,1).*.5;
initBeta = beta;
wb = 2;


[sumFt, sumFt2,som] = MultDyFacVar(yt, Xt,InfoCell, SeriesPerCountry, Sims, burnin, initBeta, initobsmodel, ...
     initStateTransitions,v0,r0, wb);


disp('Mean Obs. Model') 
disp(mean(mean(som,3),1))


 plotFt(Factor, sumFt, sumFt2, InfoCell)
