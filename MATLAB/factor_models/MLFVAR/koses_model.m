%% Sample data single factor model
clear;clc;
% rng(1)
K = 25;
subGroup = 5;
subSubGroup = 2;
T = 200;
KT = K*T;
beta = .33;
lags = 3;
InfoCell{1} = [1,K];
% InfoCell{2} = [(1:subGroup:K)', (subGroup:subGroup:K)'];
% InfoCell{3} = [(1:subSubGroup:K)',(subSubGroup:subSubGroup:K)'];
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
    ip = initCovar(gamma(q,:),1);
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


Sims = 1000;
bn = 100;
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
dimX=size(consAndMean,2);
b0 = ones(1,dimX + levels);
b0(1) = 1;

B0 =10.*eye(dimX + levels);
B0(1,1) = 1;
B0
v0=6
r0 = 4
s0 = 6
d0 = 4
autoregressiveErrors=1;
calcML =0;
g0 = zeros(1,lags);
if lags == 3
    G0 = diag([.25, .5,1])*eye(lags);
else
    G0 = 1;
end
[storeMean, storeLoadings, storeOmArTerms, storeStateArTerms,...
    storeFt, storeObsV, storeFactorVariance] =...
    Baseline(InfoCell, yt,consAndMean, iFt, iBeta, idelta, igamma,...
    b0, B0, v0,r0, s0, d0, g0, G0, Sims, bn, autoregressiveErrors, calcML);
mFt = mean(storeFt,3);
plot(Ft)
hold on
plot(mFt)
mean(mean(storeMean,3))
(Ft - mFt)*(Ft-mFt)'