clear;clc;
rng(1101)
SeriesPerCountry =5;
CountriesInRegion = 10;
Regions = 2;
Countries = CountriesInRegion*Regions;


T = 50;
beta = ones(1,SeriesPerCountry+1).*.4;
G = [.99, .7, .5]';
gamma = linspace(.5, .8, 1+Regions+Countries);
K = SeriesPerCountry*CountriesInRegion*Regions;
[DataCell] = ...
    MLFdata(T, Regions, CountriesInRegion,SeriesPerCountry,beta, G, gamma);

yt = DataCell{1,1};
Xt = DataCell{1,2};
Factor = DataCell{1,3};
InfoCell = DataCell{1,4};
SeriesPerCountry = InfoCell{1,3};


Countries = length(InfoCell{1,1});
Regions = size(InfoCell{1,2},1);
nFactors = 1 + Regions + Countries;
v0=3;
r0 =5;
Sims = 10;
burnin =1;
initobsmodel = [.2,.2,.2].*ones(K,3);
initStateTransitions = ones(nFactors,1).*.5;
initBeta = ones(size(Xt,2),1);
wb = 1;
ReducedRuns = 3;


[sumFt, sumFt2,sumOM, sumOM2, sumST, sumST2,...
    sumBeta, sumBeta2, sumObsVariance, sumObsVariance2] = ...
    MultDyFacVarSimVersion(yt, Xt,InfoCell, Sims, burnin, ReducedRuns, initBeta, initobsmodel, ...
     initStateTransitions,v0,r0, wb);


disp('Mean Obs. Model') 
disp(mean(mean(sumOM,3),1))


 plotFt(Factor, sumFt, sumFt2, InfoCell)
