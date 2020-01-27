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

v0=mean(mean(yt,2));
r0 =v0;
s0 = v0;
d0 = v0;
initStateTransitions = .1.*ones(nFactors,1);
[Identities, ~, ~] = MakeObsModelIdentity( InfoCell);
initobsmodel = .01.*ones(K,levels);
StateObsModel = makeStateObsModel(initobsmodel,Identities,0);
PriorBeta = .01.*ones(dimX, K);
ydemut = yt - reshape(surForm(Xt,K)*PriorBeta(:), K,T);  
initObsPrecision = 1./var(yt,[],2);
vecFt  =  kowUpdateLatent(ydemut(:),  StateObsModel, ...
    kowStatePrecision(diag(initStateTransitions), ones(nFactors,1),T), initObsPrecision);
initFactor = reshape(vecFt, nFactors,T);
identification = 2;
%%%%%%%%%%%%
%%%%%%%%%%%%
%DONT FORGET TO TURN THIS ON!!!!!!!!!
%%%%%%%%%%%%
%%%%%%%%%%%%
estML = 1; %%%%%%
%%%%%%%%%%%%
%%%%%%%%%%%%

[storeFt, storeVAR, storeOM, storeStateTransitions,...
    storeObsPrecision, storeFactorVar,varianceDecomp, ml] = Hdfvar(yt, Xt,  InfoCell, Sims,...
    burnin, initFactor,  initobsmodel, initStateTransitions, initObsPrecision, v0, r0, s0, d0,...
    identification, estML, DotMatFile);
muvar = mean(storeVAR,3);
SX = surForm(Xt,K);
Xbeta = reshape(SX*muvar(:),K,T);
Som = makeStateObsModel(mean(storeOM,3), Identities,0);
Ft = mean(storeFt,3);
GFt = Som*Ft;
yhat = Xbeta+GFt;
period = strfind(DotMatFile, '.');
fname = join(['Result_', DotMatFile(1:period-1),]);
if OutputDirFullPath(end) ~= '/'
    OutputDirFullPath = join([OutputDirFullPath, '/']);
end
savedfile = join([OutputDirFullPath, fname,'_',createDateString('')]);
fprintf('Saving file %s \n', savedfile)
save(savedfile)
end
