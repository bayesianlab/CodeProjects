function [] = RunHdfvar(Sims, burnin, DataLocationFullPath,DotMatFile, OutputDirFullPath)
if ischar(Sims)
    Sims = str2num(Sims);
end
if ischar(burnin)
    burnin = str2num(burnin);
end

fprintf('Current Working Directory\n')
pwd
if (DataLocationFullPath == "")
    load(DotMatFile)
    disp(DotMatFile)
else
    datalocation = join([DataLocationFullPath,'/', DotMatFile]);
    disp(DotMatFile)
    load(datalocation, 'DataCell')
end
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
[Identities, sectorInfo, factorInfo] = MakeObsModelIdentity( InfoCell);
initobsmodel = ones(K,levels);
StateObsModel = makeStateObsModel(initobsmodel,Identities,0);
vecFt  =  kowUpdateLatent(yt(:),  StateObsModel, ...
    kowStatePrecision(diag(initStateTransitions), ones(nFactors,1),T), obsPrecision);
initFactor = reshape(vecFt, nFactors,T);
identification = 2;
%%%%%%%%%%%%
%%%%%%%%%%%%
%DONT FORGET TO TURN THIS ON!!!!!!!!!
%%%%%%%%%%%%
%%%%%%%%%%%%
estML = 0; %%%%%%
%%%%%%%%%%%%
%%%%%%%%%%%%

[storeFt, storeVAR, storeOM, storeStateTransitions,...
    storeObsPrecision, storeFactorVar,varianceDecomp, ml] = Hdfvar(yt, Xt,  InfoCell, Sims,...
    burnin, initFactor,  initobsmodel, initStateTransitions, v0, r0, s0, d0, identification, estML, DotMatFile);
period = strfind(DotMatFile, '.');
fname = join(['Result_', DotMatFile(1:period-1),]);
if OutputDirFullPath(end) ~= '/'
    OutputDirFullPath = join([OutputDirFullPath, '/']);
end
savedfile = join([OutputDirFullPath, fname,'_',createDateString('')]);
fprintf('Saving file %s \n', savedfile)
save(savedfile)
end
