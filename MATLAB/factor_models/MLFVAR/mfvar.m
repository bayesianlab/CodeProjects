function [] = mfvar(Sims, burnin, ReducedRuns, SimVersion, DotMatFile)
if ischar(Sims)
    Sims = str2num(Sims);
end
if ischar(burnin)
    burnin = str2num(burnin);
end
if ischar(ReducedRuns)
    ReducedRuns = str2num(ReducedRuns);
end
if ischar(SimVersion)
    SimVersion = str2num(SimVersion);
end

load(DotMatFile,  'DataCell')
yt = DataCell{1,1};
Xt = DataCell{1,2};
InfoCell = DataCell{1,3};
Factor = DataCell{1,4};


[Identities, sectorInfo, factorInfo] = MakeObsModelIdentity( InfoCell);
levels = length(sectorInfo);
Countries = sectorInfo(3);
Regions = sectorInfo(2);
[K,T] = size(yt);
nFactors = 1 + Regions + Countries;
v0=3;
r0 =5;
s0=v0;
d0 = r0;
initobsmodel = unifrnd(.05,.5, K,3);
initStateTransitions = ones(nFactors,1).*.2;
initBeta = ones(size(Xt,2),1);
obsPrecision = ones(K,1);
StateObsModel = makeStateObsModel(initobsmodel,Identities,0);
vecFt  =  kowUpdateLatent(yt(:),  StateObsModel,...
    kowStatePrecision(diag(initStateTransitions),1,T), obsPrecision);
Ft = reshape(vecFt, nFactors,T);
initFactor = Ft;
if SimVersion == 1
    fprintf('Running sim version\n')
    [sumFt, sumFt2,sumOM, sumOM2, sumST, sumST2,...
        sumObsVariance, sumObsVariance2, sumFactorVar, sumFactorVar2] = ...
        MultDyFacVarSimVersion(yt, InfoCell, Sims, burnin,...
        ReducedRuns,  initFactor, initobsmodel, initStateTransitions,v0,r0, s0,d0, identification);
    
    deletext = strfind(DotMatFile, '.');
    leadname = DotMatFile(1:deletext-1);
    fname = createDateString(leadname);
    save(fname)
    fprintf(['Saved results as  ', fname, '\n'])
    
else
    for id = 2:2
        identification = id;
        fprintf('<strong> Running version with mean </strong>\n')
        [sumFt, sumFt2,sumOM, sumOM2, sumST, sumST2 sumBeta, sumBeta2,...
            sumObsVariance, sumObsVariance2, sumFactorVar, sumFactorVar2, sumVarianceDecomp,...
   sumVarianceDecomp2] = ...
            MultDyFacVar(yt, Xt, InfoCell, Sims, burnin,...
            ReducedRuns,  initFactor, initBeta, initobsmodel, initStateTransitions,v0,r0, s0,d0, identification);
        fname = createDateString('id2_realdata_');
        save(fname)
    end
    fprintf('\n\t\t SIMULATION ENDED \n')
end

