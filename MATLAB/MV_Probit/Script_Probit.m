clear;clc;

N = 250;
K=3;
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
B0 = 10.*eye(Q);
Sims=100;
bn = 10;
tau0 = 0;
T0 = .5;

s0 = vech(R, -1);
S0 = .5;
R0 = eye(K);



[storeSigma0, storeBeta]=GeneralMvProbit(yt, X, R0, b0, B0, tau0, T0, s0, S0, Sims, bn, zt);

musig = mean(storeSigma0,2);
Q = unVechMatrixMaker(K, -1);
Qmu = reshape(Q*musig,K,K);

Rest = round(Qmu + Qmu' + eye(K),3);
table(Rest,R )
mubeta = round(mean(storeBeta,2),3);
table(mubeta,beta(:) )
