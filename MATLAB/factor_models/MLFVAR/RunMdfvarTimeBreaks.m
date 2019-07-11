function [] = RunMdfvarTimeBreaks(DotMatFile)
load(DotMatFile,  'DataCell')
yt = DataCell{1,1};
Xt = DataCell{1,2};
InfoCell = DataCell{1,3};
[K,T] = size(yt);
[~, dimX] = size(Xt);
Sims = 10000;
burnin = 2000;
ReducedRuns = 2000;
nFactors =  sum(cellfun(@(x)size(x,1), InfoCell));
v0=3;
r0 =5;
s0 = 3;
d0 = 5;
initBeta = ones(dimX,1);
obsPrecision = ones(K,1);
initStateTransitions = .3.*ones(nFactors,1);
[Identities, sectorInfo, factorInfo] = MakeObsModelIdentity( InfoCell);
initobsmodel = unifrnd(.1,.5,K,1);
StateObsModel = makeStateObsModel(initobsmodel,Identities,0);
vecFt  =  kowUpdateLatent(yt(:),  StateObsModel, ...
    kowStatePrecision(diag(initStateTransitions),ones(nFactors,1),T), obsPrecision);
initFactor = reshape(vecFt, nFactors,T);
identification = 2;
estML = 1;
timeBreak = 100;
[sumFt, sumFt2, sumOM1, sumOM12, sumOM2, sumOM22, sumST, sumST2,...
    sumBeta, sumBeta2, sumObsVariance, sumObsVariance2,...
    sumFactorVar, sumFactorVar2,sumVarianceDecomp,...
    sumVarianceDecomp2, ml] = Mdfvar_TimeBreaks(yt, Xt, InfoCell, Sims,burnin, ReducedRuns,...
    timeBreak, initFactor,  initobsmodel,initStateTransitions,...
    v0, r0, s0, d0, identification, estML);
ml
fname = createDateString('timebreaks_');
save(fname)
end
