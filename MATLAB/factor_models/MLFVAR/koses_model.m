%% Sample data single factor model
clear;clc;
% rng(1)
K = 3;
T = 100;
KT = K*T;
nFactors = 1;
beta = .33;
lags = 2;
InfoCell{1} = [1,K];

delta = initializeARparams(K,lags);
gamma = initializeARparams(nFactors,lags);


[ip, stateSpaceDeltas]= initCovar(delta);
[S,H]=FactorPrecision(stateSpaceDeltas,ip, ones(K,1), T);
gamma = [.1, .3];
ip = initCovar(gamma);
[Lambda,H]=FactorPrecision(gamma,ip, [1], T);
Ft = mvnrnd(zeros(1,T), Lambda\eye(T));

consAndMean = ones(KT,1);
dimx = size(consAndMean,2);
SurX = surForm(consAndMean,K);
u = reshape(mvnrnd(zeros(1,K*T), eye(K*T)), K,T);
indices = 1:K;




Beta = kron(ones(K,1),ones(size(consAndMean,2),1))
Gh =setGt(InfoCell);
[Identities,~,~] =MakeObsModelIdentity( InfoCell);
Gt = makeStateObsModel(Gh, Identities,0);
yt = zeros(K,T);

et = zeros(K,T+ lags);
et(:,1:lags) = normrnd(0,1,K,lags);

lagvec = 1:lags;
ind = lags;
for t = 1:T
    select = indices + (t-1)*K; 
    yt(:,t) = SurX(select,:)*Beta + Gt*Ft(:,t) + sum(delta .* et(:, lagvec),2) + normrnd(0,1,K,1);
    et(:, t+lags)=  yt(:,t)-SurX(select,:)*Beta;
    lagvec = lagvec+1;
end


Sims = 6000;
bn = 600;
igamma = gamma;
iFt = Ft;
idelta = delta;
iBeta = reshape(Beta, K,dimx);




[storeMean, storeLoadings, storePhi, storeFt, storeObsV] =...
    Baseline(InfoCell, yt,consAndMean, iFt, iBeta, idelta, igamma, Sims, bn);
% mean(storeMean,2)
% mean(storeLoadings,3)
delta
mean(storePhi,3)
% sumFt = mean(storeFt,3);
% obv=mean(storeObsV,2)
% plot(F)
% hold on 
% sig =2.*std(storeFt,[],3);
% fup = sumFt + sig;
% fdown = sumFt - sig;
% plot(sumFt, 'red')
% plot(fup,  'b--')
% plot(fdown, 'b--')
% ylim = [0,20];
% hold on 
% histogram(storePhi(1,:))
% vline(deltas(1))
% ylim = [0,20];
% hold on 
% histogram(storeBeta(1,:))
% vline(Beta(1))