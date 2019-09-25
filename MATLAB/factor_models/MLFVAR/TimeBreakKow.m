function [] = TimeBreakKow(Sims, burnin, ReducedRuns, DataLocation, DotMatFile, OutputDir)
if ischar(Sims)
    Sims = str2num(Sims);
end
if ischar(burnin)
    burnin = str2num(burnin);
end
if ischar(ReducedRuns)
    ReducedRuns = str2num(ReducedRuns);
end
fprintf('Current Working Directory\n')
pwd
datalocation = join([DataLocation,'/', DotMatFile]);
disp(DotMatFile)
if ~exist('~/Checkpoints')
    mkdir('~/Checkpoints')
end
load(datalocation, 'DataCell')
yt = DataCell{1,1};
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
initBeta = .1.*ones(dimX,1);
obsPrecision = ones(K,1);
initStateTransitions = .1.*ones(nFactors,1);
[Identities, sectorInfo, factorInfo] = MakeObsModelIdentity( InfoCell);
initobsmodel = .1.*ones(K,levels);
StateObsModel = makeStateObsModel(initobsmodel,Identities,0);
vecFt  =  kowUpdateLatent(yt(:),  StateObsModel, ...
    kowStatePrecision(diag(initStateTransitions),ones(nFactors,1),T), obsPrecision);
% vecFt = .5.*ones(nFactors*T, 1);
initFactor = reshape(vecFt, nFactors,T);
identification = 2;
estML = 1;
[sumFt, sumFt2, sumOM, sumOM2, sumST, sumST2,...
    sumBeta, sumBeta2, sumObsVariance, sumObsVariance2,...
    sumFactorVar, sumFactorVar2,sumVarianceDecomp,...
    sumVarianceDecomp2, storeVarDecomp, ml] = Mldfvar(yt, Xt,  InfoCell, Sims,...
    burnin, ReducedRuns, initFactor, initBeta, initobsmodel,...
    initStateTransitions, v0, r0, s0, d0, identification, estML, DotMatFile);
period = strfind(DotMatFile, '.');

fname = join(['Result_', DotMatFile(1:period-1)]);
dirname = join(['~/CodeProjects/MATLAB/factor_models/MLFVAR/',OutputDir]);
if ~exist(dirname, 'dir')
    mkdir(dirname)
end
periodloc = strfind(DotMatFile, '.') ;
checkpointdir = join( [ '~/CodeProjects/MATLAB/factor_models/MLFVAR/Checkpoints/',...
    DotMatFile(1:periodloc-1), 'Checkpoints/'] );
filename = join([dirname,'/',fname]);
fprintf('Saving file %s \n', filename)
save(filename)
fprintf('Removing checkpoint dir\n')
rmdir(checkpointdir, 's')
end

