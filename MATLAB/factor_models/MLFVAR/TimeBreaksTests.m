%% Time Breaks Tests
% Runs tests on a break in the middle and the 
% Full period
clear;clc;
% rng(3)
Sims = 200;
burnin = 10;
ReducedRuns = 100;
ML = zeros(1,2);
timeBreak = 100;
T = 200;
K =5;
identification = 2;
MLFtimebreaks(K, T, timeBreak, identification);
load('totaltime.mat')


yt = DataCell{1,1};
Xt = DataCell{1,2};
InfoCell = DataCell{1,3};
Factor = DataCell{1,4};
Gamma = DataCell{1,6};
Gt1 = DataCell{1,7};
Gt2 = DataCell{1,8};

[K,T] = size(yt);
[~, dimX] = size(Xt);
levels = size(InfoCell,2);
nFactors =  sum(cellfun(@(x)size(x,1), InfoCell));
v0=3;
r0 =5;
s0 = 3;
d0 = 5;
initBeta = ones(dimX,1);
obsPrecision = ones(K,1);
initStateTransitions = .3.*ones(nFactors,1);
[Identities, sectorInfo, factorInfo] = MakeObsModelIdentity( InfoCell);
initobsmodel = .01.*ones(K,1);
StateObsModel = makeStateObsModel(initobsmodel,Identities,0);
vecFt  =  kowUpdateLatent(yt(:),  StateObsModel, ...
    kowStatePrecision(diag(initStateTransitions),ones(nFactors,1),T), obsPrecision);
initFactor = reshape(vecFt, nFactors,T);
identification = 2;
estML = 1;


[sumFt, sumFt2, sumOM, sumOM2, sumST, sumST2,...
    sumBeta, sumBeta2, sumObsVariance, sumObsVariance2,...
    sumFactorVar, sumFactorVar2,sumVarianceDecomp,...
    sumVarianceDecomp2, ml] = Mdfvar_TimeBreaks(yt, Xt, InfoCell, Sims,burnin, ReducedRuns,...
    timeBreak, initFactor,  initobsmodel,initStateTransitions,...
    v0, r0, s0, d0, identification, estML);
sumOM
sumBeta
ml
ML(1) = ml;
[sumFt, sumFt2, sumOM, sumOM2, sumST, sumST2,...
    sumBeta, sumBeta2, sumObsVariance, sumObsVariance2,...
    sumFactorVar, sumFactorVar2,sumVarianceDecomp,...
    sumVarianceDecomp2, ml] = MultDyFacVar(yt, Xt,  InfoCell, Sims,...
    burnin, ReducedRuns, initFactor, initBeta, initobsmodel,...
    initStateTransitions, v0, r0, s0, d0, identification, estML);
sumOM
sumBeta
ml
ML(2) = ml;
ML(1) - ML(2)

%% Testing if two models estimated beats one
% yt1 = yt(:, 1:timeBreak);
% Xt1 = Xt(1:(timeBreak*K), :);
% [K,T] = size(yt1);
% [~, dimX] = size(Xt1);
% levels = size(InfoCell,2);
% nFactors =  sum(cellfun(@(x)size(x,1), InfoCell));
% v0=3;
% r0 =5;
% s0 = 3;
% d0 = 5;
% initBeta = ones(dimX,1);
% obsPrecision = ones(K,1);
% initStateTransitions = .3.*ones(nFactors,1);
% [Identities, sectorInfo, factorInfo] = MakeObsModelIdentity( InfoCell);
% initobsmodel = unifrnd(.1,.5,K,1);
% StateObsModel = makeStateObsModel(initobsmodel,Identities,0);
% vecFt  =  kowUpdateLatent(yt1(:),  StateObsModel, ...
%     kowStatePrecision(diag(initStateTransitions),ones(nFactors,1),T), obsPrecision);
% initFactor = reshape(vecFt, nFactors,T);
% identification = 2;
% estML = 1;
% 
% [sumFt, sumFt2, sumOM, sumOM2, sumST, sumST2,...
%     sumBeta, sumBeta2, sumObsVariance, sumObsVariance2,...
%     sumFactorVar, sumFactorVar2,sumVarianceDecomp,...
%     sumVarianceDecomp2, ml] = MultDyFacVar(yt1, Xt1,  InfoCell, Sims,...
%     burnin, ReducedRuns, initFactor, initBeta, initobsmodel,...
%     initStateTransitions, v0, r0, s0, d0, identification, estML);
% sumOM
% sumBeta
% ml
% 
% yt2 = yt(:, timeBreak+1 : end);
% Xt2 = Xt((timeBreak*K + 1): end, :);
% [K,T] = size(yt2);
% [~, dimX] = size(Xt2);
% levels = size(InfoCell,2);
% nFactors =  sum(cellfun(@(x)size(x,1), InfoCell));
% v0=3;
% r0 =5;
% s0 = 3;
% d0 = 5;
% initBeta = ones(dimX,1);
% obsPrecision = ones(K,1);
% initStateTransitions = .3.*ones(nFactors,1);
% [Identities, sectorInfo, factorInfo] = MakeObsModelIdentity( InfoCell);
% initobsmodel = unifrnd(.1,.5,K,1);
% StateObsModel = makeStateObsModel(initobsmodel,Identities,0);
% vecFt  =  kowUpdateLatent(yt2(:),  StateObsModel, ...
%     kowStatePrecision(diag(initStateTransitions),ones(nFactors,1),T), obsPrecision);
% initFactor = reshape(vecFt, nFactors,T);
% identification = 2;
% estML = 1;
% 
% [sumFt, sumFt2, sumOM, sumOM2, sumST, sumST2,...
%     sumBeta, sumBeta2, sumObsVariance, sumObsVariance2,...
%     sumFactorVar, sumFactorVar2,sumVarianceDecomp,...
%     sumVarianceDecomp2, ml] = MultDyFacVar(yt2, Xt2,  InfoCell, Sims,...
%     burnin, ReducedRuns, initFactor, initBeta, initobsmodel,...
%     initStateTransitions, v0, r0, s0, d0, identification, estML);
% sumOM
% sumBeta
% ml

