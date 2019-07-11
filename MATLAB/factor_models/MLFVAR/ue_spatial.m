function [] = ue_spatial()
load('ue_spatial.mat')

yt = DataCell{1,1};
Xt = DataCell{1,2};
InfoCell = DataCell{1,3};
LocationCorrelation = DataCell{1,4};
p = size(LocationCorrelation,1);
zp = zeros(1,p);
zpp = zp;
zp(1) = 1;
zpp(end) = 1;
cutpoints = 1./([zp;zpp]*eig(LocationCorrelation));

[K,T] = size(yt);
[~, dimX] = size(Xt);
sectorInfo = cellfun(@(x)size(x,1), InfoCell);
levels = size(InfoCell,2);
nFactors =  sum(cellfun(@(x)size(x,1), InfoCell));
v0=3;
r0 =5;
s0 = 3;
d0 = 5;
Sims = 10000;
burnin = 1000;
ReducedRuns = 9000;
initBeta = ones(dimX,1);
obsPrecision = ones(K,1);
initobsmodel = unifrnd(0,1,K, levels);
initStateTransitions = .3.*ones(nFactors,1).*.1;
Identities{1,1} = ones(K,1);
StateObsModel = makeStateObsModel(initobsmodel, Identities,0);

vecFt  =  kowUpdateLatent(yt(:),  StateObsModel, ...
    kowStatePrecision(diag(initStateTransitions), ones(nFactors,1),T), obsPrecision);
Ft = reshape(vecFt, nFactors,T);
initFactor = Ft;
identification = 2;
CorrType = 2;
initparama = 1;
[sumFt, sumFt2, sumOM, sumOM2, sumST, sumST2,...
    sumObsVariance, sumObsVariance2,...
    sumFactorVar, sumFactorVar2,sumVarianceDecomp,...
    sumVarianceDecomp2, parama] = ...
    Smdfvar(yt, Xt, InfoCell, CorrType,...
    LocationCorrelation, cutpoints, Sims, burnin,ReducedRuns,...
    initFactor, initobsmodel, initStateTransitions,v0,r0, s0,d0, initparama, identification);
f = 'ue_spatial_';
f=createDateString(f)
save(f)
end

