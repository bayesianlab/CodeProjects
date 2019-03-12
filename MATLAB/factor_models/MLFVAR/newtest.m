
clear;clc;
% rng(121)
SeriesPerCountry=6;
CountriesInRegion = 2;
Regions = 2;
Countries = CountriesInRegion*Regions;
T = 50;
beta = ones(1,SeriesPerCountry+1).*.4;
gamma = unifrnd(0,.8, 1, 1+Regions+Countries,1);
K = SeriesPerCountry*CountriesInRegion*Regions;
[DataCell] = ...
    MLFdata(T, Regions, CountriesInRegion,SeriesPerCountry,beta, gamma);

yt = DataCell{1,1};
Xt = DataCell{1,2};
InfoCell = DataCell{1,3};
Factor = DataCell{1,4};
Gamma = DataCell{1,6};
Gt = DataCell{1,7};




sectorInfo = cellfun(@(x)size(x,1), InfoCell);
Regions = sectorInfo(2);
Countries = sectorInfo(3);

nFactors = 1 + Regions + Countries;
v0=3;
r0 =5;
Sims = 40;
burnin =20;


% initobsmodel = Gt;
% initobsmodel = .1.*ones(K,3);
% initobsmodel = zeros(K,3);
initobsmodel = [.5.*ones(K,1), .5.*ones(K,1), .5.*ones(K,1)];
% initobsmodel = [zeros(K,1), zeros(K,1), .5.*ones(K,1)];

initStateTransitions = ones(nFactors,1).*.5;
% initStateTransitions = DataCell{1,6}';

obsPrecision = ones(K,1);
[Identities, sectorInfo, factorInfo] = MakeObsModelIdentity( InfoCell);
StateObsModel = makeStateObsModel(initobsmodel,Identities,0);
vecFt  =  kowUpdateLatent(yt(:),  StateObsModel, kowStatePrecision(diag(initStateTransitions),1,T), obsPrecision);
Ft = reshape(vecFt, nFactors,T);
initFactor = Ft;
ReducedRuns = 3;
[sumFt, sumFt2,sumOM, sumOM2, sumST, sumST2,...
    sumObsVariance, sumObsVariance2] = ...
    MultDyFacVarSimVersion(yt, InfoCell, Sims, burnin, ReducedRuns,  initFactor, initobsmodel, ...
    initStateTransitions,v0,r0);



% fitted =  (1./sum(sumFt.^2,2)).*sum((sumFt.*Factor),2).* sumFt;
% SST = sum((Factor - mean(Factor,2)).^2,2);
% SSR = sum((Factor - fitted).^2,2) ;
% R2 = (1-(SSR./SST))'
% disp('Mean Obs. Model')
% disp(mean(mean(sumOM,3),1))
% disp('Mean State Trans. l')
% disp(sumST')
plotFt(Factor, sumFt, sumFt2, InfoCell)

Gt
sumOM

Gamma
sumST


