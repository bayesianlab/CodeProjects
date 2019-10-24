%% Sample data single factor model
clear;clc;
% rng(12)
K = 1;
T = 10;
nFactors = 1;
beta = .33;
lags = 2;

deltas = initializeARparams(K,lags);
gammas = initializeARparams(nFactors,lags);


[ip, stateSpaceDeltas]= initCovar(deltas);
[S,H]=FactorPrecision(stateSpaceDeltas,ip, ones(K,1), T);

gammas = [.1, .3];
ip = initCovar(gammas);
[P,~]=FactorPrecision(gammas,ip, [1], T);
F = mvnrnd(zeros(1,T), P\eye(T));
cons = ones(T,1);
u = reshape(mvnrnd(zeros(1,K*T), eye(K*T)), K,T);

indices = 1:K;
xi = [cons,F'];
Beta = ones(size(xi,2),1);
xi = kron(xi,ones(K,1));
X = surForm(xi,K);
[KT, dimX] = size(X);




yt = zeros(K,T);

et = zeros(K,T+ lags);
et(:,1:lags) = normrnd(0,1,K,lags);

lagvec = 1:lags;
ind = lags;
for t = 1:T
    select = indices + (t-1)*K; 
    lagGet = t:ind;
    ind = ind + lags-1;
    yt(:,t) = X(select,:)*Beta + stateSpaceDeltas * et(:, lagGet)' + normrnd(0,1,K,1);
    et(:, t+lags)=  yt(:,t)-X(select,:)*Beta;
       
end



Sims = 1;
bn = 1;
initgamma = [.5,.2,.1];
initfactor = normrnd(0,1,1,T);

[storeBeta] = Baseline(yt,xi, F, Beta, deltas, gammas, Sims, bn);

mean(storeBeta,2)
% ylim = [0,20];
% hold on 
% histogram(storeBeta(1,:))
% vline(Beta(1))