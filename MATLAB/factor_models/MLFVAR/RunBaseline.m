function [] = RunBaseline(Sims, burnin, DataPath,DotMatFile, OutputDirFullPath)
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
yt=yt./std(yt,[],2);
levels = size(InfoCell,2);
nFactors =  sum(cellfun(@(x)size(x,1), InfoCell));
lagOm = 3;
lagFac = 3;
b0 = zeros(1,dimX + levels);
B0 =100.*eye(dimX + levels);
v0=6;
r0 =4;
s0 = 6;
d0 = 4;
g0 = zeros(1,lagFac);
G0 = diag([.25, .5,1])*eye(lagFac);
obsPrecision = ones(K,1);
initStateTransitions = .1.*ones(nFactors,1);
iBeta = [ones(K,dimX), unifrnd(0,1,K,levels)];
idelta = .1.*ones(K,lagOm);
igamma=.1.*ones(nFactors, lagFac);
[Identities, sectorInfo, factorInfo] = MakeObsModelIdentity(InfoCell);
initobsmodel = .1.*ones(K,levels);
StateObsModel = makeStateObsModel(initobsmodel,Identities,0);
% vecFt  =  kowUpdateLatent(yt(:),  StateObsModel, ...
%     kowStatePrecision(diag(initStateTransitions), ones(nFactors,1),T), obsPrecision);
% iFt = reshape(vecFt, nFactors,T);
iFt = ones(nFactors,T).*.01;

%%%%%%%
calcML=1;  %
%%%%%%%
%%%%%%%%%%%%%%
autoregressiveErrors=0;%
%%%%%%%%%%%%%%

[storeMean, storeLoadings, storeOmArTerms, storeStateArTerms,...
    storeFt, storeObsV, storeFactorVariance, varianceDecomp] =...
    Baseline(InfoCell, yt,Xt, iFt, iBeta, idelta, igamma,...
    b0, B0, v0,r0, g0, G0, Sims, burnin, autoregressiveErrors, calcML);


StateObsModel = makeStateObsModel(mean(storeLoadings,3),Identities,0);

beta=mean(storeMean,3)';
beta = beta(:); 
mu1 = surForm(Xt, K)*beta;
Ft = mean(storeFt,3);
mu2=StateObsModel*Ft;
yhat=reshape(mu1,K,T)+mu2;

% SX = surForm(Xt,K);
% Xbeta = reshape(SX*muvar(:),K,T);
% Som = makeStateObsModel(mean(storeOM,3), Identities,0);
% Ft = mean(storeFt,3);
% GFt = Som*Ft;
% yhat = Xbeta+GFt;

period = strfind(DotMatFile, '.');
fname = join(['Result_', DotMatFile(1:period-1),]);
if OutputDirFullPath(end) ~= '/'
    OutputDirFullPath = join([OutputDirFullPath, '/']);
end
savedfile = join([OutputDirFullPath, fname,'_',createDateString('')]);
fprintf('Saving file %s \n', savedfile)
save(savedfile)

end
