clear;
clc;
Sims= 100;
N = 200;
K = 7;
R = [1, .8, .6, .4, .2, 0, 0;
    .8, 1, .8, .6, .4, .2, 0;
    .6, .8, 1, .8, .6, .4, .2;
    .4, .6, .8, 1, .8, .6, .4;
    .2, .4, .6, .8, 1, .8, .6;
    0, .2, .4, .6, .8, 1, .8;
    0, 0, .2, .4, .6, .8, 1];
iR = inv(R);
beta = [1, 1,1, 1, 1, 1]';
Covariates = length(beta);
b0 = zeros(length(beta),1) ;
B0 = eye(length(b0))*10;
wishartDf = N;
wishartPrior = eye(K);

R0 =  eye(K);
D0 = diag(R0)*10;
timetrend = (1:K)';
% timetrend =(1:K)'-4;
timetrendsqd = timetrend.^2;
bi = [0,1,0,1,0,1,0]';

for i = 1:N
    select = timetrend + (i-1)*K;
    X(select, :) = [ones(K,1), timetrend, timetrendsqd, bi,...
        bi.*timetrend, bi.*timetrendsqd];
end
W  = diag(D0)*R*diag(D0);
E=mvnrnd(zeros(K,1),W, N)';
vecz = X*beta + E(:);
vecy = double(vecz>0);
y = reshape(vecy, K,N);
z = reshape(vecz, K,N);
mu = reshape(X*beta, K,N);

maxsig(z-mu, diag(D0), R)
dll = @(guess) maxsig(z-mu, diag(D0), guess);

[x, H] = bhhhProbit(eye(K), dll, 10, 1e-3, 10)
reshape(x, K,K)
