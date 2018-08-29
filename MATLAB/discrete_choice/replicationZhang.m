clear;
clc;


Sims = 200;
N = 50;
K = 5;
Covariates = 2;
R = correlationAntedependence([.9,.7,.5,.3]);
iR = inv(R);
beta = [.5, 1]';
b0 = zeros(length(beta),1);
B0 = eye(length(b0))*10;
wishartDf = 20;
% R0 = createSigma(.5,K);
R0 = eye(K);
W0 = wishrnd(R0, wishartDf);
D0 = diag(W0);
timetrend = (-2:2)';
timetrendsqd = timetrend.^2;
t = 1:K;

for i = 1:N
    select = t + (i-1)*K;
    X(select, :) = [ones(K,1), timetrend];
end

sum = [0,0]';
reps = 1;
for k = 1:reps
E=mvnrnd(zeros(K,1),R, 50)';
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
% olsbeta = densum\numsum;
% e = reshape(X*olsbeta, K, N) - z;
% sols = e*e'/N;
% dsols = diag(sols);
% dsolsinv = dsols.^(-.5);
% sols = diag(dsolsinv)*sols*diag(dsolsinv)
% sum = sum + olsbeta;
r0indx = [2,5; 3,2; 4,1; 2,1];
[bbar, r0, ar, r0post ] =mv_probit(y, X, b0,B0, wishartDf,...
    diag(D0), R0, 50, r0indx);
bbar'
r0
ar
r0post
[bbar, r0, ar, r0post] = mv_probit_new_proposal(y, X, b0,B0, wishartDf,...
    diag(D0), R0, 50, r0indx);
bbar'
r0
ar
r0post
end
sum./reps