function [] = RunHdfvar(Sims, burnin, estML, DataPath,DotMatFile, Job_Name_In_Queue, OutputDirFullPath)
if ischar(Sims)
    Sims = str2num(Sims);
end
if ischar(burnin)
    burnin = str2num(burnin);
end
if ischar(estML)
    estML = str2num(estML);
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
r0 = 4
s0 = 6
d0 = 4
[Ey, Vy]=invGammaMoments(.5*v0, .5*r0)
[Ey, Vy] =invGammaMoments(.5*s0, .5*d0)
a0=1
A0inv = 1
g0 = zeros(1,lagState)
G0 = eye(lagState)
yt
beta0 = [mean(yt,2)'; zeros(dimX-1, K)]
B0inv = 1.*eye(dimX)

initStateTransitions = zeros(nFactors,lagState);
[Identities, ~, ~] = MakeObsModelIdentity( InfoCell);
initobsmodel = ones(K,levels);
initObsPrecision = 1./var(yt,[],2);
initFactorVar = ones(nFactors,1);
initFactor = normrnd(0,1,nFactors,T);
identification = 2;


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
