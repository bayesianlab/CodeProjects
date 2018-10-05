% liu 2006 main
clear;
clc;

rng(2)
Sims = 100;
burnin = 0;
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
wishartDf = 10;
wishartPrior = eye(K).*1000;

R0 =  eye(K);
D0 = 10*diag(R0);
timetrend = (1:K)';
% timetrend =(1:K)'-4;
timetrendsqd = timetrend.^2;
bi = round(unifrnd(0,1,N*K,1));


for i = 1:N
    select = timetrend + (i-1)*K;
    binary = bi(select);
    X(select, :) = [ones(K,1), timetrend, timetrendsqd, binary,...
        binary.*timetrend, binary.*timetrendsqd];
end
E=mvnrnd(zeros(K,1),R, N)';
vecz = X*beta + E(:);
vecy = double(vecz>0);
y = reshape(vecy, K,N);
z = reshape(vecz, K,N);
mu = reshape(X*beta, K,N);



Reps = 1;
posttrackingnums = [2,1;3,2; 6,3; 7,1]; 
bbar = zeros(Reps,length(b0));
r0 = zeros(size(R,1), size(R,1), Reps);
post = zeros(Sims,size(posttrackingnums,1), Reps);
ar = zeros(Reps,1);
loss = zeros(Reps,1);
mean(z,2)
for i =1:Reps
    i
    [bbar(i,:), stoB, r0(:,:, i),ar(i), post(:,:,i), stoR0] = liu2006(y, X, beta,...
        B0, wishartDf, diag(D0), R,...
        Sims, burnin, posttrackingnums);
    bbar
    r0
    ar
    steinloss(R,r0)
    steinloss(R,eye(K))
end

% [betabar, R0bar, acceptrate, r0Elems, stoR0] =newmethod(y, X, beta,B0,...
%     wishartPrior, wishartDf, diag(D0), R, ...
%         Sims, posttrackingnums);
% R0bar    
% acceptrate
    
