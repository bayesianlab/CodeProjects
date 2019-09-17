clear;clc;
filename = 'BigKow/kowz.mat', 'DataCell';
load(filename)
Sims=10;
burnin =2;
ReducedRuns=10;
yt = DataCell{1,1};
csvwrite('yt.csv', yt)
Xt = DataCell{1,2};
InfoCell = DataCell{1,3};
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
initStateTransitions = .01.*ones(nFactors,1);
[Identities, sectorInfo, factorInfo] = MakeObsModelIdentity( InfoCell);
initobsmodel = .01.*ones(K,levels);
StateObsModel = makeStateObsModel(initobsmodel,Identities,0);
% vecFt  =  kowUpdateLatent(yt(:) - (Xt*initBeta),  StateObsModel, ...
%     kowStatePrecision(diag(initStateTransitions),ones(nFactors,1),T), obsPrecision);
vecFt = .01.*ones(nFactors*T, 1);
initFactor = reshape(vecFt, nFactors,T);
identification = 2;
estML = 1;
[sumFt, sumFt2, sumOM, sumOM2, sumST, sumST2,...
    sumBeta, sumBeta2, sumObsVariance, sumObsVariance2,...
    sumFactorVar, sumFactorVar2, varianceDecomp, ml] = Mldfvar(yt, Xt,  InfoCell, Sims,...
    burnin, ReducedRuns, initFactor, initBeta, initobsmodel,...
    initStateTransitions, v0, r0, s0, d0, identification, estML, filename);
save('experimental.mat')