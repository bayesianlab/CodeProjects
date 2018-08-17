clear;
clc;


Sims = 200;
N = 50;
K = 5;
Covariates = 2;
R = correlation([.9,.7,.5,.3]);
iR = inv(R);
beta = repmat([.5,1]', 5,1);
b0 = zeros(length(beta),1);
B0 = eye(length(b0))*10;
wishartDf = 300;
wishartPrior = eye(K);
D0 = eye(K);
R0 = eye(K);
t = 1:K;
for i = 1:N
    select = t + (i-1)*K;
    X(select, :) = kron(eye(K), [1,1]).*repmat([ones(K,1),...
        normrnd(0,1,K,1)],1,5);
end
sum = [0,0]';
for k = 1:1
E=mvnrnd(zeros(K,1),R, 50)';
vecz = X*beta + E(:);
vecy = double(vecz>0);
y = reshape(vecy, K,N);
z = reshape(vecz, K,N);

densum = zeros(K*Covariates);
numsum = zeros(K*Covariates,1);
for i = 1:N
    select = t + (i-1)*K;
    densum = densum + X(select,:)'*iR*X(select,:);
    numsum = numsum + X(select,:)'*iR*z(:,i);    
end
olsbeta = densum\numsum;
sum = sum + mean(reshape(olsbeta, Covariates, K),2);

[bbar, r0, ar] =mv_probit(y, X, b0,B0, wishartDf, wishartPrior, D0, R0, 3);

tmultnormrnd(

end