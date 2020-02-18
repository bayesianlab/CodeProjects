function [] = RunHdfvar(Sims, burnin, DataPath,DotMatFile, Job_Name_In_Queue, OutputDirFullPath)
if ischar(Sims)
    Sims = str2num(Sims);
end
if ischar(burnin)
    burnin = str2num(burnin);
end

fprintf('Current Working Directory\n')
pwd
if (DataPath == "")
    load(DotMatFile)
    disp(DotMatFile)
else
    datalocation = join([DataPath,'/', DotMatFile]);
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
lagState=1;

v0= 6
r0 = 10
s0 = 6
d0 = 10
[Ey, Vy]=invGammaMoments(.5*v0, .5*r0)
[Ey, Vy] =invGammaMoments(.5*s0, .5*d0)
a0=1
A0inv = .2
g0 = zeros(1,lagState)
G0 = eye(lagState)
beta0 = [mean(yt,2)'; zeros(dimX-1, K)]
B0inv = .1.*eye(dimX)

initStateTransitions = .5.*ones(nFactors,lagState);
[Identities, ~, ~] = MakeObsModelIdentity( InfoCell);
initobsmodel = .25.*ones(K,levels);
StateObsModel = makeStateObsModel(initobsmodel,Identities,0);
PriorBeta = .25.*ones(dimX, K);
ydemut = yt - reshape(surForm(Xt,K)*PriorBeta(:), K,T);  
initObsPrecision = 1./var(yt,[],2);
initFactorVar = ones(nFactors,1);
vecFt  =  kowUpdateLatent(ydemut(:),  StateObsModel, ...
    kowStatePrecision(diag(initStateTransitions), initFactorVar, T), initObsPrecision);
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
    burnin, initFactor,  initobsmodel, initStateTransitions, initObsPrecision, initFactorVar,...
    beta0, B0inv, v0, r0, s0, d0, a0,A0inv, g0, G0, identification, estML, DotMatFile);
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
savedfile = join([OutputDirFullPath, fname,'_', Job_Name_In_Queue, '_', createDateString('')]);
fprintf('Saving file %s \n', savedfile)
save(savedfile)
end
