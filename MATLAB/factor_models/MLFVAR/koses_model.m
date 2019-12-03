%% Sample data single factor model
clear;clc;
% rng(1)
K = 10;
subGroup = 5;
subSubGroup = 2;
T = 100;
KT = K*T;
beta = .33;
lags = 2;
InfoCell{1} = [1,K];
InfoCell{2} = [(1:subGroup:K)', (subGroup:subGroup:K)'];
InfoCell{3} = [(1:subSubGroup:K)',(subSubGroup:subSubGroup:K)'];
levels=length(InfoCell);
nFactors =0;
for i = 1:levels
    J = InfoCell{i};
    Rows = size(J,1);
    nFactors = nFactors + Rows;
end
delta = zeros(K,lags);
gamma = zeros(nFactors,lags);
for k = 1:K
    delta(k,:) = initializeARparams(1,lags);
end
Ft = zeros(nFactors,T);
for q = 1:nFactors
    gamma(q,:) = initializeARparams(1,lags);
    ip = initCovar(gamma(q,:));
    [Lambda,~]=FactorPrecision(gamma(q,:),ip, 1, T);
    Linv = chol(Lambda, 'lower')\eye(T);
    Ft(q,:) = reshape(Linv'*normrnd(0,1,T,1),1,T);
end

consAndMean = ones(KT,1);
dimx = size(consAndMean,2);
SurX = surForm(consAndMean,K);
u = reshape(mvnrnd(zeros(1,K*T), eye(K*T)), K,T);
Beta = kron(ones(K,1),ones(size(consAndMean,2),1));
Gh =setGt(InfoCell);
[Identities,~,~] =MakeObsModelIdentity( InfoCell);
Gt = makeStateObsModel(Gh, Identities,0);
yt = zeros(K,T);
et = zeros(K,T+ lags);
et(:,1:lags) = normrnd(0,1,K,lags);
indices = 1:K;
lagvec = 1:lags;
ind = lags;
for t = 1:T
    select = indices + (t-1)*K;
    yt(:,t) = SurX(select,:)*Beta + Gt*Ft(:,t) + sum(delta .* et(:, lagvec),2) + normrnd(0,1,K,1);
    et(:, t+lags)=  yt(:,t)-SurX(select,:)*Beta - Gt*Ft(:,t);
    lagvec = lagvec+1;
end


Sims = 60;
bn = 10;
%% True values
igamma = gamma;
iFt = Ft;
iGh = Gh;
idelta = delta;
iBeta = reshape(Beta, K,dimx);
iBeta = [iBeta,Gh];

%% Random values
% iFt = normrnd(0,1,nFactors,T);
% igamma = normrnd(0,1,nFactors,lags);
% idelta = normrnd(0,1,K,lags);
% iBeta = normrnd(0,1,K,dimx);
% iGh = unifrnd(0,1,K,levels)
% iBeta = [iBeta,Gh];
% 
v0 = 3;
d0 = 6;
[storeMean, storeLoadings, storeOmArTerms, storeStateArTerms,...
    storeFt, storeObsV, storeFactorVariance] =...
    Baseline(InfoCell, yt,consAndMean, iFt, iBeta, idelta, igamma,...
    v0,d0, Sims, bn,1);
