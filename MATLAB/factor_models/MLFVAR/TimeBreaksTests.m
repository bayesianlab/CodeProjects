%% Time Breaks Tests
% Runs tests on a break in the middle and the 
% Full period
clear;clc;
rng(3)
Sims = 100;
burnin = 50;
ReducedRuns = 100;
ML = zeros(1,3);
% timeBreak = 50;
T = 70;
% K =6;
% identification = 2;
DataCell=SimDataMLF(T, 2, 3, 5, .55);
% load('totaltime.mat')
yt = DataCell{1,1};
Xt = DataCell{1,2};
InfoCell = DataCell{1,3};
Factor = DataCell{1,4};
Gamma = DataCell{1,6};
Gt1 = DataCell{1,7};
% Gt2 = DataCell{1,8};
% yt = yt(:, 1:timeBreak);
% Xt = Xt(1:K*timeBreak, :);

[K,T] = size(yt);
[~, dimX] = size(Xt);
levels = size(InfoCell,2);
nFactors =  sum(cellfun(@(x)size(x,1), InfoCell));
v0=6;
r0 =10;
s0 = 6;
d0 = 10;
initBeta = ones(dimX,1);
obsPrecision = ones(K,1);
initStateTransitions = .3.*ones(nFactors,1);
[Identities, sectorInfo, factorInfo] = MakeObsModelIdentity( InfoCell);
initobsmodel = .01.*ones(K,levels);
for q = 1:size(InfoCell,2)
    h = InfoCell{q};
    for r = 1:size(h,1)
        initobsmodel(h(r,1),q) = 1;
    end
end
StateObsModel = makeStateObsModel(initobsmodel,Identities,0);
vecFt  =  kowUpdateLatent(yt(:),  StateObsModel, ...
    kowStatePrecision(diag(initStateTransitions),ones(nFactors,1),T), obsPrecision);
initFactor = reshape(vecFt, nFactors,T);
identification = 2;
estML = 0;


[sumFt, sumFt2, sumOM, sumOM2, sumST, sumST2,...
    sumBeta, sumBeta2, sumObsVariance, sumObsVariance2,...
    sumFactorVar, sumFactorVar2, varianceDecomp, ml] = Mldfvar(yt, Xt,  InfoCell, Sims,...
    burnin, ReducedRuns, initFactor, initobsmodel,...
    initStateTransitions, v0, r0, s0, d0, identification, estML, 'totaltime.mat');

variance = sumFt2 - sumFt.^2;
sig = sqrt(variance);
upper = sumFt + 1.5.*sig;
lower = sumFt - 1.5.*sig;
LW = .75;
COLOR = [1,0,0];
facealpha = .3;
fillX = [1:length(sumFt(1,:)), fliplr(1:length(sumFt(1,:)))];
fillY = [upper, fliplr(lower)];
fs =1;
mut = reshape(Xt*sumBeta,K,T);
figure
h = fill(fillX(1,:), fillY(fs,:), COLOR);
set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none');
hold on
world = plot(sumFt(fs,:), 'black');
% plot(Factor(fs,:), 'blue')

% sumOM
% sumBeta
% ml
% ML(1) = ml;
% [sumFt, sumFt2, sumOM, sumOM2, sumST, sumST2,...
%     sumBeta, sumBeta2, sumObsVariance, sumObsVariance2,...
%     sumFactorVar, sumFactorVar2,sumVarianceDecomp,...
%     sumVarianceDecomp2, ml] = Mldfvar(yt, Xt,  InfoCell, Sims,...
%     burnin, ReducedRuns, initFactor, initBeta, initobsmodel,...
%     initStateTransitions, v0, r0, s0, d0, identification, estML);
% ML(1) = ml;
% 
% yt = DataCell{1,1};
% Xt = DataCell{1,2};
% InfoCell = DataCell{1,3};
% Factor = DataCell{1,4};
% Gamma = DataCell{1,6};
% Gt1 = DataCell{1,7};
% Gt2 = DataCell{1,8};
% yt = yt(:, timeBreak+1:end);
% 
% Xt = Xt((K*timeBreak)+1:end, :);
% 
% [K,T] = size(yt);
% [~, dimX] = size(Xt);
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
% initobsmodel = .01.*ones(K,1);
% StateObsModel = makeStateObsModel(initobsmodel,Identities,0);
% vecFt  =  kowUpdateLatent(yt(:),  StateObsModel, ...
%     kowStatePrecision(diag(initStateTransitions),ones(nFactors,1),T), obsPrecision);
% initFactor = reshape(vecFt, nFactors,T);
% identification = 2;
% estML = 1;
% [sumFt, sumFt2, sumOM, sumOM2, sumST, sumST2,...
%     sumBeta, sumBeta2, sumObsVariance, sumObsVariance2,...
%     sumFactorVar, sumFactorVar2,sumVarianceDecomp,...
%     sumVarianceDecomp2, ml] = Mldfvar(yt, Xt,  InfoCell, Sims,...
%     burnin, ReducedRuns, initFactor, initBeta, initobsmodel,...
%     initStateTransitions, v0, r0, s0, d0, identification, estML);
% ML(2) = ml;
% 
% yt = DataCell{1,1};
% Xt = DataCell{1,2};
% InfoCell = DataCell{1,3};
% Factor = DataCell{1,4};
% Gamma = DataCell{1,6};
% Gt1 = DataCell{1,7};
% Gt2 = DataCell{1,8};
% 
% [K,T] = size(yt);
% [~, dimX] = size(Xt);
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
% initobsmodel = .01.*ones(K,1);
% StateObsModel = makeStateObsModel(initobsmodel,Identities,0);
% vecFt  =  kowUpdateLatent(yt(:),  StateObsModel, ...
%     kowStatePrecision(diag(initStateTransitions),ones(nFactors,1),T), obsPrecision);
% initFactor = reshape(vecFt, nFactors,T);
% identification = 2;
% estML = 1;
% [sumFt, sumFt2, sumOM, sumOM2, sumST, sumST2,...
%     sumBeta, sumBeta2, sumObsVariance, sumObsVariance2,...
%     sumFactorVar, sumFactorVar2,sumVarianceDecomp,...
%     sumVarianceDecomp2, ml] = Mldfvar(yt, Xt,  InfoCell, Sims,...
%     burnin, ReducedRuns, initFactor, initBeta, initobsmodel,...
%     initStateTransitions, v0, r0, s0, d0, identification, estML);
% ML(3) = ml;
% ML(1) + ML(2) - ML(3)