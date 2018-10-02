clear;
clc;

Sims = 100;
N = 50;
K = 5;
Covariates = 2;
   r0indx = [2,5; 3,2; 4,1; 2,1]; 
R = correlationAntedependence([.7,.9,.5,.3])
Reps = 10;
bbar = zeros(Reps,Covariates);
r0 = zeros(size(R,1), size(R,1), Reps);
post = zeros(Sims - floor(.1*Sims),size(r0indx,1), Reps);
ar = zeros(Reps,1);
loss = zeros(Reps,1);
for i = 1:Reps

iR = inv(R);
beta = [.5, 1]';
b0 = zeros(length(beta),1);
B0 = eye(length(b0))*10;
wishartDf = 300;
% R0 = createSigma(.5,K);
% R0 = eye(K);
% W0 = inv(wishrnd(inv(R0), wishartDf));
% D0 = diag(W0);
D0 = ones(size(R,1),1);
R0 = eye(K);
timetrend = (-2:2)';
timetrendsqd = timetrend.^2;
t = 1:K;

for k = 1:N
    select = t + (k-1)*K;
    X(select, :) = [ones(K,1), timetrend];
end

sum = [0,0]';

E=mvnrnd(zeros(K,1),R, 50)';
vecz = X*beta + E(:);
vecy = double(vecz>0);
y = reshape(vecy, K,N);
z = reshape(vecz, K,N);

demean = y - reshape(X*beta, K,N);
W0 = demean * demean'./N;
d0 = diag(W0);
D0half = diag(d0.^(.5));
D0halfinv = D0half\eye(K);

R0 = D0halfinv *W0 *D0halfinv;

i
[bbar(i,:), r0(:,:, i),ar(i), post(:,:,i),R0sto ] =mv_probit(y, X, beta,B0, wishartDf,...
    diag(d0), R, Sims, r0indx);

bbar'
r0
ar

steinloss(R,r0(:,:,i))
% [bbar, r0, ar, r0post] = mv_probit_new_proposal(y, X, b0,B0, wishartDf,...
%     diag(D0), R0, 50, r0indx);
% bbar'
% r0
% ar
% r0post;
end