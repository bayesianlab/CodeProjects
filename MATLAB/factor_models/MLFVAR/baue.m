function [] = baue()
clear;clc;
load('baue.mat');
rng(3)
yt = DataCell{1,1};
Xt = DataCell{1,2};
InfoCell = DataCell{1,3};
Factor = DataCell{1,4};
Gamma = DataCell{1,6};
Gt = DataCell{1,7};

[K,T] = size(yt);
[~, dimX] = size(Xt);
sectorInfo = cellfun(@(x)size(x,1), InfoCell);
Regions = sectorInfo(2);

levels = size(InfoCell,2);
 
nFactors =  sum(cellfun(@(x)size(x,1), InfoCell));
v0=3;
r0 =5;
s0 = 3;
d0 = 5;
Sims = 5000;
burnin = 1000;
ReducedRuns = 10;
initBeta = ones(dimX,1);
obsPrecision = ones(K,1);
initStateTransitions = .3.*ones(nFactors,1);

[Identities, sectorInfo, factorInfo] = MakeObsModelIdentity( InfoCell);

initobsmodel = unifrnd(0,1,K,3);
StateObsModel = makeStateObsModel(initobsmodel,Identities,0);
vecFt  =  kowUpdateLatent(yt(:),  StateObsModel, ...
    kowStatePrecision(diag(initStateTransitions),ones(nFactors,1),T), obsPrecision);
initFactor = reshape(vecFt, nFactors,T);
size(initFactor)
identification = 2;
estML = 0;

t = 1:59;

[sumFt, sumFt2, sumOM, sumOM2, sumST, sumST2,...
    sumBeta, sumBeta2, sumObsVariance, sumObsVariance2,...
    sumFactorVar, sumFactorVar2,sumVarianceDecomp,...
   sumVarianceDecomp2] = Mldfvar(yt, Xt,  InfoCell, Sims,...
    burnin, ReducedRuns, initFactor, initBeta, initobsmodel,...
    initStateTransitions, v0, r0, s0, d0, identification, estML)
f = 'baue_';
f=createDateString(f)
save(f)
end

