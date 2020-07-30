clear;clc;
T = 100;
K=10;
Q = 3;
X = [ones(T*K,1), normrnd(0,1,T*K, Q-1)];
beta = ones(Q,K);
surX = surForm(X, K);
R = createSigma(.7,K);
epsilon = mvnrnd(zeros(1,K), R, T)';
zt=reshape(surX*beta(:) + epsilon(:), K,T);
yt = double(zt > 0);
DataCell{1} = yt;
DataCell{2} = X;
save('MVPData/simdata_toeplitz_d10', 'DataCell')

T = 100;
K=50;
Q = 3;
X = [ones(T*K,1), normrnd(0,1,T*K, Q-1)];
beta = ones(Q,K);
surX = surForm(X, K);
R = createSigma(.7,K);
epsilon = mvnrnd(zeros(1,K), R, T)';
zt=reshape(surX*beta(:) + epsilon(:), K,T);
yt = double(zt > 0);
DataCell{1} = yt;
DataCell{2} = X;
save('MVPData/simdata_toeplitz_d50', 'DataCell')

T = 100;
K=100;
Q = 3;
X = [ones(T*K,1), normrnd(0,1,T*K, Q-1)];
beta = ones(Q,K);
surX = surForm(X, K);
R = createSigma(.7,K);
epsilon = mvnrnd(zeros(1,K), R, T)';
zt=reshape(surX*beta(:) + epsilon(:), K,T);
yt = double(zt > 0);
DataCell{1} = yt;
DataCell{2} = X;
save('MVPData/simdata_toeplitz_d100', 'DataCell')

T = 100;
K=10;
Q = 3;
X = [ones(T*K,1), normrnd(0,1,T*K, Q-1)];
A = ones(K,1);
A(2:end,1) = (K-1:-1:1)'./10;
C = A*A' + diag(ones(K,1));
D = diag(C).^(-.5);
Astar = diag(D)*A;
gamma = .5;
P0= initCovar(gamma, 1);
FP = FactorPrecision(gamma,P0, 1, T)\eye(T) ;
Ft = mvnrnd(zeros(1,T), FP,1);
beta = ones(Q,1);
zt = reshape(X*beta,K,T) + Astar*Ft + normrnd(0,1/sqrt(2),K,T);
yt = double(zt > 0);
DataCell{1} = yt;
DataCell{2} = X;
DataCell{3} = Ft;
DataCell{4} = A; 
DataCell{5} = gamma;
save('MVPData/simdata_factor_d10', 'DataCell')

T = 100;
K=50;
Q = 3;
X = [ones(T*K,1), normrnd(0,1,T*K, Q-1)];
A = ones(K,1);
A(2:end,1) = (K-1:-1:1)'./10;
C = A*A' + diag(ones(K,1));
D = diag(C).^(-.5);
Astar = diag(D)*A;
gamma = .5;
P0= initCovar(gamma, 1);
FP = FactorPrecision(gamma,P0, 1, T)\eye(T) ;
Ft = mvnrnd(zeros(1,T), FP,1);
beta = ones(Q,1);
zt = reshape(X*beta,K,T) + Astar*Ft + normrnd(0,1/sqrt(2),K,T);
yt = double(zt > 0);
DataCell{1} = yt;
DataCell{2} = X;
DataCell{3} = Ft;
DataCell{4} = A; 
DataCell{5} = gamma;
save('MVPData/simdata_factor_d50', 'DataCell')

T = 100;
K=100;
Q = 3;
X = [ones(T*K,1), normrnd(0,1,T*K, Q-1)];
A = ones(K,1);
A(2:end,1) = (K-1:-1:1)'./10;
C = A*A' + diag(ones(K,1));
D = diag(C).^(-.5);
Astar = diag(D)*A;
gamma = .5;
P0= initCovar(gamma, 1);
FP = FactorPrecision(gamma,P0, 1, T)\eye(T) ;
Ft = mvnrnd(zeros(1,T), FP,1);
beta = ones(Q,1);
zt = reshape(X*beta,K,T) + Astar*Ft + normrnd(0,1/sqrt(2),K,T);
yt = double(zt > 0);
DataCell{1} = yt;
DataCell{2} = X;
DataCell{3} = Ft;
DataCell{4} = A; 
DataCell{5} = gamma;
save('MVPData/simdata_factor_d100', 'DataCell')