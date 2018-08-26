clear;
clc;


Sims = 200;
N = 200;
K = 7;

R = createSigma(-.5, K)
iR = inv(R);
beta = [.5, .8,.3]';
Covariates = length(beta);
b0 = zeros(length(beta),1);
B0 = eye(length(b0))*10;
wishartDf = 50;
W0 = wishrnd(eye(K), wishartDf)./wishartDf;
D0 = diag(W0);
R0 = diag(D0.^(-.5))*W0*diag(D0.^(-.5));
timetrend =(1:K)'-4;
timetrendsqd = timetrend.^2;
t = 1:K;

for i = 1:N
    select = t + (i-1)*K;
    X(select, :) = [ones(K,1), timetrend, normrnd(0,3,K,1)];
end

sum = zeros(length(beta),1);
reps = 1;
for k = 1:reps
E=mvnrnd(zeros(K,1),R, N)';
vecz = X*beta + E(:);
vecy = double(vecz>0);
y = reshape(vecy, K,N);
z = reshape(vecz, K,N);
densum = zeros(Covariates);
numsum = zeros(Covariates,1);
for i = 1:N
    select = t + (i-1)*K;
    densum = densum + X(select,:)'*iR*X(select,:);
    numsum = numsum + X(select,:)'*iR*z(:,i); 
end
olsbeta = densum\numsum;
e = reshape(X*olsbeta, K, N) - z;
sols = e*e'/N;
dsols = diag(sols);
dsolsinv = dsols.^(-.5);
sols = diag(dsolsinv)*sols*diag(dsolsinv);

sum = sum + olsbeta;
% [bbar, r0, ar ] =mv_probit(y, X, b0,B0, wishartDf,...
%     diag(D0), R0, 50);
% bbar
% r0
% ar
[bbar, r0, ar] = mv_probit_new_proposal(y, X, b0,B0, wishartDf,...
    diag(D0), R0, 10);
bbar'
r0
ar

end
% sum./reps