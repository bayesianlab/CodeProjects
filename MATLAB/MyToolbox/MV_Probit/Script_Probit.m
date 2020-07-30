clear;clc;
cg = 1;
% rng(11)

T = 100;
K=20;
Q = 1;
X = [ones(T*K,1), normrnd(0,1,T*K, Q-1)];
A = zeros(K,1);
A(1:end,1) = .3.*ones(K,1);
% A(2:end, 2) = .3.*ones(K-1,1)

C = A*A' + eye(K);
D = diag(C).^(-.5);
Astar = diag(D)*A;
SigmaStar = diag(D)*eye(K);
Astar*Astar' + SigmaStar*SigmaStar'

gamma = .3;
P0= initCovar(gamma, 1);
FP = FactorPrecision(gamma,P0, 1, T)\eye(T) ;
F1 = mvnrnd(zeros(1,T), FP,1);
F2 = mvnrnd(zeros(1,T), FP,1);
Factors = [F1] ;
nFactors = size(Factors,1);
beta = ones(Q,1);
zt = reshape(X*beta,K,T) + Astar*Factors+ normrnd(0,1/sqrt(2),K,T);
yt = double(zt > 0);
Sims=100;
bn = 10;


%     T = 100;
%     K=10;
%     Q = 3;
%     X = [ones(T*K,1), normrnd(0,1,T*K, Q-1)];
%     beta = ones(Q,K);
%     surX = surForm(X, K);
% R = createSigma(.5,K);
%     epsilon = mvnrnd(zeros(1,K), R, T)';
%     zt=reshape(surX*beta(:) + epsilon(:), K,T);
%     yt = double(zt > 0);


% b0= 0;
% B0 =100;

% tau0 = 0;
% T0 = .5;
% s0 = 0;
% S0 = 2;
% R0 = eye(K);
% tau = [1, .9, .9, .5, .1, .1, .1, .1, .1]
% estml =1 ;
% [Output]=GeneralMvProbit(yt, X,Sims, bn, cg, estml, b0, B0,  s0, S0, R0, tau);
% storeBeta = Output{1};
% storeSigma = Output{2};
% summary1 = Output{7};
% sum(table2array(summary1(:,2)))
% mubeta = mean(storeBeta,2);
% table(mubeta, ones(Q*K,1))


cg = 0;
initFt = normrnd(0,1,nFactors,T);
lags = 1;
R0 = ones(K,1);
g0 = zeros(1,lags);
G0=diag(fliplr(.5.^(0:lags-1)));
b0= 0;
B0 =1;
a0 = .5;
A0= 10;
s0 = 6;
S0 = 6;
v0 = 6;
r0 = 6;
InfoCell{1} = [1,K];
% InfoCell{2} = [2,K];

estml = 1;
[Output] =GeneralMvProbit(yt, X, Sims, bn, cg, estml, b0, B0, g0, G0, a0, A0,...
    initFt, InfoCell);

storeBeta = Output{1};
storeFt= Output{2};
storeSt= Output{3};
storeOm = Output{4};
summary2 = Output{6};
mubeta = round(mean(storeBeta,2),3);
table(mubeta,repmat(beta(:), K,1) )


Fhat = mean(storeFt,3);
meanst = mean(storeSt,3);
table( meanst, repmat(gamma,nFactors,1))

ombar = round(mean(storeOm,3),3);
table(ombar, Astar)


for f = 1:nFactors
    figure
    plot(Factors(f,:))
    hold on
    plot(Fhat(f,:))
end