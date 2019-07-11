% MUST FIX TWO SIDED TRUNCATED NORMAL

clear;clc;
% rng(121)
SeriesPerCountry=10;
CountriesInRegion =1;
Regions = 1;
Countries = CountriesInRegion*Regions;
T = 10;
identification = 2;
beta = ones(1,SeriesPerCountry+1).*.4;
K = SeriesPerCountry*CountriesInRegion*Regions;
[DataCell] = ...
    MLFdata(T, Regions, CountriesInRegion,SeriesPerCountry,beta, identification);

% load('StandardizedRealData.mat')
yt = DataCell{1,1};
Xt = DataCell{1,2};
InfoCell = DataCell{1,3};

InfoCell = InfoCell(1,1);
levels = size(InfoCell,2);

Factor = DataCell{1,4};
Gamma = DataCell{1,6};
Gt = DataCell{1,7};
[K,T] = size(yt);
[~, dimX] = size(Xt);
levels = size(InfoCell,2);

nFactors =  sum(cellfun(@(x)size(x,1), InfoCell));
v0=3;
r0 =5;
s0 = 3;
d0 = 5;
Sims = 60;
burnin = 6;
ReducedRuns = 10;
initBeta = ones(dimX,1);
obsPrecision = ones(K,1);
initStateTransitions = .3.*ones(nFactors,1).*.1;
[Identities, sectorInfo, factorInfo] = MakeObsModelIdentity( InfoCell);

% Simulation Version
% initobsmodel = unifrnd(0,1,K,levels);
initobsmodel = zeros(K,1);
StateObsModel = makeStateObsModel(initobsmodel,Identities,0);
vecFt  =  kowUpdateLatent(yt(:),  StateObsModel, ...
    kowStatePrecision(diag(initStateTransitions),ones(nFactors,1),T), obsPrecision);
Ft = reshape(vecFt, nFactors,T);
initFactor = Ft;
identification = 2;
estML = 0;
[sumFt, sumFt2, sumOM, sumOM2, sumST, sumST2,...
    sumObsVariance, sumObsVariance2, sumVarianceDecomp,...
    sumVarianceDecomp2, sumFactorVar, sumFactorVar2, ml]= MultDyFacVarSimVersion(yt,...
      InfoCell, Sims, burnin, ReducedRuns,  initFactor, initobsmodel,...
      initStateTransitions,v0,r0, s0,d0, identification,estML);

 plot(yt(1,:))
 hold on
 plot(sumFt(1,:))
 sumOM
 Gt
% plotFt(Factor, sumFt, sumFt2, InfoCell)
% ml
% [sumOM,Gt]
% mean([sumOM,Gt])
% hold on
% plot(Factor(1,:))
% plot(sumFt(1,:))
% A = makeStateObsModel(sumOM, Identities, 0);
% yhat = A*sumFt;
% figure
% hold on
% plot(yt(1,:))
% plot(yhat(1,:))
% AvgDevs = T^(-1).*(yt - yhat).^2;
% rmse = mean(sqrt(sum( AvgDevs,2)))




% Real Data Version
% [sumFt, sumFt2, sumOM, sumOM2, sumST, sumST2,...
%     sumBeta, sumBeta2, sumObsVariance, sumObsVariance2,...
%     sumFactorVar, sumFactorVar2,sumVarianceDecomp,...
%    sumVarianceDecomp2] = ...
%     MultDyFacVar(yt, Xt, InfoCell, Sims, burnin,...
%     ReducedRuns,  initFactor, initBeta, initobsmodel, initStateTransitions,v0,r0, s0,d0, identification);
% xaxis = 1962:2014;

% plotSectorFactor(sumFt(1,:), sumFt2(1,:), xaxis)
% plotSectorFactor(sumFt(2,:), sumFt2(2,:), xaxis)
% plotSectorFactor(sumFt(3,:), sumFt2(3,:), xaxis)
% plotSectorFactor(sumFt(9,:), sumFt2(9,:), xaxis)
% plotSectorFactor(sumFt(10,:), sumFt2(10,:), xaxis)
% plotSectorFactor(sumFt(11,:), sumFt2(11,:), xaxis)
%



% load('mpy.mat')
% yt = DataCell{1,1};
% Xt = DataCell{1,2};
% InfoCell = DataCell{1,3};
% Factor = DataCell{1,4};
% Gamma = DataCell{1,6};
% Gt = DataCell{1,7};
%
% [K,T] = size(yt);
% [~, dimX] = size(Xt);
% sectorInfo = cellfun(@(x)size(x,1), InfoCell);
% Regions = sectorInfo(2);
%
% levels = size(InfoCell,2);
%
% nFactors =  sum(cellfun(@(x)size(x,1), InfoCell));
% v0=3;
% r0 =5;
% s0 = 3;
% d0 = 5;
% Sims = 10;
% burnin = 0;
% ReducedRuns = 10;
% initBeta = ones(dimX,1);
% obsPrecision = ones(K,1);
% initStateTransitions = .3.*ones(nFactors,1);
%
% [Identities, sectorInfo, factorInfo] = MakeObsModelIdentity( InfoCell);
%
% initobsmodel = unifrnd(0,1,K,3);
% StateObsModel = makeStateObsModel(initobsmodel,Identities,0);
% vecFt  =  kowUpdateLatent(yt(:),  StateObsModel, ...
%     kowStatePrecision(diag(initStateTransitions),ones(nFactors,1),T), obsPrecision);
% initFactor = reshape(vecFt, nFactors,T);
% identification = 2;
% estML = 0;
%
% [sumFt, sumFt2, sumOM, sumOM2, sumST, sumST2,...
%     sumBeta, sumBeta2, sumObsVariance, sumObsVariance2,...
%     sumFactorVar, sumFactorVar2,sumVarianceDecomp,...
%    sumVarianceDecomp2] = MultDyFacVar(yt, Xt,  InfoCell, Sims,...
%     burnin, ReducedRuns, initFactor, initBeta, initobsmodel,...
%     initStateTransitions, v0, r0, s0, d0, identification, estML)
%
% clear;clc;
% load('ue.mat');
% rng(3)
% yt = DataCell{1,1};
% Xt = DataCell{1,2};
% InfoCell = DataCell{1,3};
% Factor = DataCell{1,4};
% Gamma = DataCell{1,6};
% Gt = DataCell{1,7};
%
% [K,T] = size(yt);
% [~, dimX] = size(Xt);
% sectorInfo = cellfun(@(x)size(x,1), InfoCell);
% Regions = sectorInfo(2);
%
% levels = size(InfoCell,2);
%
% nFactors =  sum(cellfun(@(x)size(x,1), InfoCell));
% v0=3;
% r0 =5;
% s0 = 3;
% d0 = 5;
% Sims = 10;
% burnin = 1;
% ReducedRuns = 10;
% initBeta = ones(dimX,1);
% obsPrecision = ones(K,1);
% initStateTransitions = .3.*ones(nFactors,1);
%
% [Identities, sectorInfo, factorInfo] = MakeObsModelIdentity( InfoCell);
%
% initobsmodel = unifrnd(0,1,K,3);
% StateObsModel = makeStateObsModel(initobsmodel,Identities,0);
% vecFt  =  kowUpdateLatent(yt(:),  StateObsModel, ...
%     kowStatePrecision(diag(initStateTransitions),ones(nFactors,1),T), obsPrecision);
% initFactor = reshape(vecFt, nFactors,T);
% size(initFactor)
% identification = 2;
% estML = 0;
%
% t = 1:59;
%
% [sumFt, sumFt2, sumOM, sumOM2, sumST, sumST2,...
%     sumBeta, sumBeta2, sumObsVariance, sumObsVariance2,...
%     sumFactorVar, sumFactorVar2,sumVarianceDecomp,...
%    sumVarianceDecomp2] = MultDyFacVar(yt, Xt,  InfoCell, Sims,...
%     burnin, ReducedRuns, initFactor, initBeta, initobsmodel,...
%     initStateTransitions, v0, r0, s0, d0, identification, estML)
%
% importdates
% dates = statesbusapp.Date;
%
% plot(dates(2:end-1), sumFt(1,:))


