% liu 2006 main
clear;
clc;
Sims = 1000;
N = 200;
K = 7;
R = createSigma(-.5, K);
iR = inv(R);
beta = [.5, .8,.3]';
Covariates = length(beta);
b0 = zeros(length(beta),1);
B0 = eye(length(b0))*10;
wishartDf = N;
W0 = wishrnd(eye(K), wishartDf)./wishartDf;
D0 = diag(W0).^(.5);
R0 = diag(D0.^(-1))*W0*diag(D0.^(-1));
timetrend =(1:K)'-4;
timetrendsqd = timetrend.^2;
t = 1:K;
for i = 1:N
    select = t + (i-1)*K;
    X(select, :) = [ones(K,1), timetrend, normrnd(0,3,K,1)];
end
E=mvnrnd(zeros(K,1),R, N)';
vecz = X*beta + E(:);
vecy = double(vecz>0);
y = reshape(vecy, K,N);
z = reshape(vecz, K,N);
mu = reshape(X*beta, K,N);

[bbar, r0,ar] = liu2006(y, X, b0, B0, wishartDf, diag(D0), R0,...
    Sims, [2,1])
