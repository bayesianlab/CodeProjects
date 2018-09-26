clear
clc
rng(1000)
Sims = 1000;
N = 2000;
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
b0 = zeros(length(beta),1);
B0 = eye(length(b0))*10;
wishartDf = N;
D0 = ones(K,1);
R0 = eye(K);
timetrend = (1:K)';
% timetrend =(1:K)'-4;
timetrendsqd = timetrend.^2;
bi = round(unifrnd(0,1,K,N));

for i = 1:N
    select = timetrend + (i-1)*K;
    X(select, :) = [ones(K,1), timetrend, timetrendsqd, bi(:,i),...
        bi(:,i).*timetrend, bi(:,i).*timetrendsqd];
end
E=mvnrnd(zeros(K,1),R, N)';
vecz = X*beta + E(:);
vecy = double(vecz>0);
y = reshape(vecy, K,N);
z = reshape(vecz, K,N);
beta = b0
for i = 1:100
mu = reshape(X*beta, K,N);

  reshapedmu = reshape(mu, K, N);
z = updateLatentZ(y,reshapedmu, R);

s1 = zeros(size(B0,1),size(B0,1));
s1eye = eye(size(B0,1),size(B0,1));
r0i = eye(K);
s2= zeros(size(B0,1),1);
r0i = eye(K);
tempSum1 = s1;
tempSum2=s2;
    index =1:K;
     R0i = R\r0i;
for k = 1:N
    select = index + (k-1)*K;
    tempSum1 = tempSum1 + X(select, :)'*R0i*X(select,:);
    tempSum2 = tempSum2 + X(select, :)'*R0i*z(:,k);
end

ist = (inv(B0) + tempSum1)\s1eye

v = ist*tempSum2
beta = v + chol(ist, 'lower')*normrnd(0,1,size(B0,1), 1)

end
