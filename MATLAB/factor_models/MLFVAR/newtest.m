clear;clc;
rng(1101)
SeriesPerCountry =8;
CountriesInRegion = 4;
Regions = 2;
Countries = CountriesInRegion*Regions;


T = 100;
beta = ones(1,SeriesPerCountry+1).*.4;
G = [.4, .4, .7]';
gamma = ones(1, 1+Regions+Countries).*.7;
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
Sims = 50;
burnin =10;
initobsmodel = [.01,.01,.01].*ones(K,3);
initStateTransitions = ones(nFactors,1).*.1;
initBeta = ones(size(Xt,2),1);
wb = 1;
ReducedRuns = 3;

[sumFt, sumFt2,sumOM, sumOM2, sumST, sumST2,...
    sumBeta, sumBeta2, sumObsVariance, sumObsVariance2] = ...
    MultDyFacVarSimVersion(yt, Xt,InfoCell, Sims, burnin, ReducedRuns, initBeta, initobsmodel, ...
     initStateTransitions,v0,r0, wb, Factor);


disp('Mean Obs. Model') 
disp(mean(mean(sumOM,3),1))

disp('Mean State Trans. l') 
disp(sumST')

 plotFt(Factor, sumFt, sumFt2, InfoCell)
 
 
 
 
 
 
 
 
 

% clear;clc;
% rng(1101)
% SeriesPerCountry =3;
% CountriesInRegion = 2;
% Regions = 2;
% Countries = CountriesInRegion*Regions;
% T = 50;
% beta = ones(1,SeriesPerCountry+1).*.4;
% G = [.2, .3, .1]';
% % gamma = linspace(.1, .2, 1+Regions+Countries);
% gamma = ones(1, 1+Regions+Countries).*.7;
% DataCell = SimDataMLF(T, Regions, CountriesInRegion,SeriesPerCountry,beta, G, gamma);
% 
% yt = DataCell{1,1};
% Xt = DataCell{1,2};
% InfoCell = DataCell{1,3};
% Factor = DataCell{1,4};
% nFactors =  sum(cellfun(@(x)size(x,1), InfoCell));
% [K,T] = size(yt);
% 
% Sims = 50;
% burnin =10;
% ReducedRuns = 3;
% initBeta = ones(size(Xt,2),1);
% initobsmodel = [.2,.1,.4].*ones(K,3);
% initStateTransitions = ones(nFactors,1).*.1;
% initBeta = ones(size(Xt,2),1);
% v0=3;
% r0 =5;
% [sumFt, sumFt2,sumOM, sumOM2, sumST, sumST2,...
%     sumBeta, sumBeta2, sumObsVariance, sumObsVariance2] = ...
%     MDFM(yt, Xt,InfoCell, Sims, burnin, ReducedRuns, initBeta, initobsmodel, ...
%      initStateTransitions,v0,r0);

