clear;clc;
% rng(1001)
N = 150;
K=4;
Q = 3;
X = [ones(N*K,1), normrnd(0,1,N*K, Q-1)];
beta = ones(Q,K);
surX = surForm(X, K);
R = createSigma(.5,K);
epsilon = mvnrnd(zeros(1,K), R, N)';
zt=reshape(surX*beta(:) + epsilon(:), K,N);
yt = double(zt > 0);

mean(zt,2)


b0= ones(Q,1);
B0 = 100.*eye(Q);
Sims=100;
bn = 10;
tau0 = 0;
T0 = .5;
[storeSigma0, storeBeta]=GeneralMvProbit(yt, X, R,Sims, bn, b0, B0, tau0, T0);

mean(storeSigma0,3)
mean(storeBeta,2)
