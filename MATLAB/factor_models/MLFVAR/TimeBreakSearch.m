function [] = TimeBreakSearch(Sims, burnin, ReducedRuns, DotMatFile)
if ischar(Sims)
    Sims = str2num(Sims);
end
if ischar(burnin)
    burnin = str2num(burnin);
end
if ischar(ReducedRuns)
    ReducedRuns = str2num(ReducedRuns);
end

load(DotMatFile)
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
initBeta = ones(dimX,1);
obsPrecision = ones(K,1);
initStateTransitions = .3.*ones(nFactors,1);
[Identities, sectorInfo, factorInfo] = MakeObsModelIdentity( InfoCell);
initobsmodel = unifrnd(.1,.5,K,levels);
StateObsModel = makeStateObsModel(initobsmodel,Identities,0);
vecFt  =  kowUpdateLatent(yt(:),  StateObsModel, ...
    kowStatePrecision(diag(initStateTransitions),ones(nFactors,1),T), obsPrecision);
initFactor = reshape(vecFt, nFactors,T);
identification = 2;
estML = 1;

timeBreaks = 2:T-1;
mls = zeros(length(timeBreaks),1);
c = 0;
for g = timeBreaks
    fprintf('Time break: %i\n', g)
    c = c + 1;
    [sumFt, sumFt2, sumOM, sumOM2, sumST, sumST2,...
        sumBeta, sumBeta2, sumObsVariance, sumObsVariance2,...
        sumFactorVar, sumFactorVar2,sumVarianceDecomp,...
        sumVarianceDecomp2, ml] = Mdfvar_TimeBreaks(yt, Xt, InfoCell, Sims,burnin, ReducedRuns,...
        timeBreaks(c), initFactor,  initobsmodel,initStateTransitions,...
        v0, r0, s0, d0, identification, estML);
    mls(c) = ml;
end
[~, order] = sort(mls);
[mls(order), timeBreaks(order)]
fname = createDateString(join(DotMatFile, '_'));
save(fname)
end

