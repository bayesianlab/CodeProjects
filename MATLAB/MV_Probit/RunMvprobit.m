function [] = RunMvprobit(filename, K)


T = 100;
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
% F2 = mvnrnd(zeros(1,T), FP,1);
Factors = [F1] ;
nFactors = size(Factors,1);
beta = ones(Q,1);
zt = reshape(X*beta,K,T) + Astar*Factors+ normrnd(0,1/sqrt(2),K,T);
yt = double(zt > 0);

Sims=10000;
bn = 1000;
cg = 0;
initFt = normrnd(0,1,nFactors,T);
lags = 1;
g0 = zeros(1,lags);
G0=diag(fliplr(.5.^(0:lags-1)));
b0= 0;
B0 =1;
a0 = .5;
A0= 10;

InfoCell{1} = [1,K];
[Output] =GeneralMvProbit(yt, X, Sims, bn, cg, estml, b0, B0, g0, G0, a0, A0,...
    initFt, InfoCell);

save(filename, Output)

end

