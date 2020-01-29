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
lagState=1;
% yt=yt-mean(yt,2);
yt=yt./std(yt,[],2);
v0= 6;
r0 = 4;
s0 = 6;
d0 = 6;
[Ey, Vy]=invGammaMoments(.5*v0, .5*r0)
[Ey, Vy] =invGammaMoments(.5*s0, .5*d0)
a0=1;
A0inv = 1;
g0 = zeros(1,lagState);
G0 = eye(lagState);
beta0 = [mean(yt,2)'; zeros(dimX-1, K)];
B0inv = .01.*eye(dimX);

initStateTransitions = zeros(nFactors,lagState);
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
estML = 1; %%%%%%
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
figure
plot(yt(1,:))
hold on
plot(yhat(1,:))
pA = sprintf('v0=%d r0=%.3f, s0=%d d0=%.3f,', v0,r0,s0,d0);
pB = sprintf('a0=%d, A0inv=%.3f,g0=%d, G0=%d', a0,A0inv,g0,G0);
title({pA; pB})

period = strfind(DotMatFile, '.');
fname = join(['Result_', DotMatFile(1:period-1),]);
if OutputDirFullPath(end) ~= '/'
    OutputDirFullPath = join([OutputDirFullPath, '/']);
end
savedfile = join([OutputDirFullPath, fname,'_',createDateString('')]);
fprintf('Saving file %s \n', savedfile)
save(savedfile)
end
