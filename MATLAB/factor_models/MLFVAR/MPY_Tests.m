clear;clc;
filename = 'mpy.mat', 'DataCell';
load(filename)
Sims=10;
burnin =5;
ReducedRuns=10;
yt = DataCell{1,1};
Xt = DataCell{1,2};
InfoCell = DataCell{1,3};
[K,T] = size(yt);
[~, dimX] = size(Xt);
levels = size(InfoCell,2);
nFactors =  sum(cellfun(@(x)size(x,1), InfoCell));
v0=3;
r0 =5;
s0 = 3;
d0 = 5;
initBeta = .1.*ones(dimX,1);
obsPrecision = ones(K,1);
initStateTransitions = .1.*ones(nFactors,1);
[Identities, sectorInfo, factorInfo] = MakeObsModelIdentity( InfoCell);
initobsmodel = .1.*ones(K,levels);
% initobsmodel = zeros(K,levels);
StateObsModel = makeStateObsModel(initobsmodel,Identities,0);
vecFt  =  kowUpdateLatent(yt(:) - (Xt*initBeta),  StateObsModel, ...
    kowStatePrecision(diag(initStateTransitions),ones(nFactors,1),T), obsPrecision);
initFactor = reshape(vecFt,nFactors,T);
% initFactor = normrnd(0,1,nFactors,T);
identification = 2;
estML = 1;
[sumFt, sumFt2, sumOM, sumOM2, sumOtherOM, sumOtherOM2,...
    sumST, sumST2,sumBeta, sumBeta2, sumObsVariance, sumObsVariance2,...
    sumFactorVar, sumFactorVar2, varianceDecomp, ml] = Mldfvar(yt, Xt,  InfoCell, Sims,...
    burnin, ReducedRuns, initFactor, initBeta, initobsmodel,...
    initStateTransitions, v0, r0, s0, d0, identification, estML, filename);
save('experimental.mat')