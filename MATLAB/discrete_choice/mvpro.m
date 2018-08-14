clear;
clc;
rng(2);
load('pdat.mat')
pdat= table2array(pdat);
[r,~] = size(pdat);

N = 50;
K = 2;
c = ones(N,1);
Sigma = eye(K) +[0,.5;.5,0]
x1 = [c,normrnd(0,1, N,1)];
x2 = [c,normrnd(0, 1, N,2)];

[r1,c1] = size(x1);
[r2,c2]= size(x2);

T1 = kron(x1, eye(K));
T2 = kron(x2, eye(K));
T1 = [ T1(:,1), T1(:,3)];
T2 = [T2(:,2), T2(:,4), T2(:,6)];
surX = [T1,T2];
[nrow, ncol] = size(surX);
B = [.3, -.5, -1.5, .6, .3]'
eps = mvnrnd(zeros(K,1), Sigma,N)';
mu = surX*B;
vecz = mu + eps(:);
mles = inv(surX'*surX)*surX'*vecz
sigmamle = (reshape(vecz,K,N)' - reshape(mu,K,N)')'*(reshape(vecz,K,N)' - reshape(mu,K,N)')./N
y = vecz > 0;
y = reshape(y,K,N);
mu = reshape(mu, K,N);

b0 = zeros(ncol, 1);
B0 = eye(ncol)*10;
[bbar, Rbar, ar] = mv_probit(y, surX, b0, B0, eye(K),100)


