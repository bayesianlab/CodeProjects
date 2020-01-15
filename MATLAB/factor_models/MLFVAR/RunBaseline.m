function [] = RunBaseline(Sims, burnin, DotMatFile, OutputDir)
if ischar(Sims)
    Sims = str2num(Sims);
end
if ischar(burnin)
    burnin = str2num(burnin);
end

fprintf('Current Working Directory\n')
pwd
load(DotMatFile)
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
obsPrecision = ones(K,1);
initStateTransitions = .1.*ones(nFactors,1);
iBeta = [ones(K,dimX), unifrnd(0,1,K,levels)];
lagOm = 1;
lagFac = 1;
idelta = unifrnd(0,.1,K,lagOm);
igamma=unifrnd(0,.1,nFactors, lagFac);
[Identities, sectorInfo, factorInfo] = MakeObsModelIdentity(InfoCell);
initobsmodel = .1.*ones(K,levels);
StateObsModel = makeStateObsModel(initobsmodel,Identities,0);
vecFt  =  kowUpdateLatent(yt(:),  StateObsModel, ...
    kowStatePrecision(diag(initStateTransitions), ones(nFactors,1),T), obsPrecision);
% vecFt = .5.*ones(nFactors*T, 1);
iFt = reshape(vecFt, nFactors,T);


[storeMean, storeLoadings, storeOmArTerms, storeStateArTerms,...
    storeFt, storeObsV, storeFactorVariance, varianceDecomp] =...
    Baseline(InfoCell, yt,Xt, iFt, iBeta, idelta, igamma,...
    v0,d0, Sims, burnin,1);

period = strfind(DotMatFile, '.');
string = DotMatFile(1:period-1);
splits = strsplit(string, '/');
name = splits{end} ;
dateCreated = createDateString('');
fname = join(['Result_', name, '_', dateCreated]);
if ~exist(OutputDir, 'dir')
    mkdir(OutputDir)
end
fname=join([OutputDir, '/',fname]);
fprintf('Saving file: %s \n',fname)
save(fname)

end
