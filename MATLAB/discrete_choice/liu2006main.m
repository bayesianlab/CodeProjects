% liu 2006 main
clear;
clc;
Sims = 1000;
% burnin = 0;
% N = 200;
% K = 7;
% R = [1, .8, .6, .4, .2, 0, 0;
%     .8, 1, .8, .6, .4, .2, 0;
%     .6, .8, 1, .8, .6, .4, .2;
%     .4, .6, .8, 1, .8, .6, .4;
%     .2, .4, .6, .8, 1, .8, .6;
%     0, .2, .4, .6, .8, 1, .8;
%     0, 0, .2, .4, .6, .8, 1];
% iR = inv(R);
% beta = [1, 1,1, 1, 1, 1]';
% Covariates = length(beta);
% b0 = zeros(length(beta),1) ;
% B0 = eye(length(b0))*10;
% wishartDf = 10;

% 
% R0 =  eye(K);
% D0 = 10*diag(R0);
% timetrend = (1:K)';
% % timetrend =(1:K)'-4;
% timetrendsqd = timetrend.^2;
% bi = round(unifrnd(0,1,N*K,1));

burnin = 0;
N = 150;
K = 4;
R = createSigma(.9,K)
% R = zeros(K);
% rho = [.7, .2, .1];
% for i = 1:K
%     R(i, :) = [0, circshift(rho,i-1)];
% end
% R = (eye(K) + triu(R)) + triu(R)';
iR = inv(R);
beta = [.5, .5,1, 1]';

b0 = zeros(length(beta),1);
B0 = eye(length(b0))*10;
wishartDf = N;
D0 = 100.*ones(K,1);
R0 = eye(K);
timetrend = (1:K)';
timetrendsqd = timetrend.^2;
bi = round(unifrnd(0,1,N*K,1));
xi = normrnd(0,1,K*N, 1);
for i = 1:N
    select = timetrend + (i-1)*K;
    binary = bi(select);
    cont = xi(select);
    X(select, :) = [ones(K,1), timetrend, cont, binary ];
end


% for i = 1:N
%     select = timetrend + (i-1)*K;
%     binary = bi(select);
%     X(select, :) = [ones(K,1), timetrend, timetrendsqd, binary,...
%         binary.*timetrend, binary.*timetrendsqd];
% end
E=mvnrnd(zeros(K,1),R, N)';
vecz = X*beta + E(:);
vecy = double(vecz>0);
y = reshape(vecy, K,N);
z = reshape(vecz, K,N);
mu = reshape(X*beta, K,N);



wishartPrior = eye(K).*1000;
Reps = 1;
posttrackingnums = [2,1;3,2]; 
bbar = zeros(Reps,length(b0));
r0 = zeros(size(R,1), size(R,1), Reps);
post = zeros(Sims,size(posttrackingnums,1), Reps);
ar = zeros(Reps,1);
loss = zeros(Reps,1);
mean(z,2)

% updateLatentZ(y,mu,R)
% for i =1:Reps
%     i
%     [bbar(i,:), stoB, r0(:,:, i),ar(i), post(:,:,i), stoR0] = liu2006(y, X, beta,...
%         B0, wishartDf, diag(D0), R,...
%         Sims, burnin, posttrackingnums);
%     bbar
%     r0
%     ar
%     steinloss(R,r0)
%     steinloss(R,eye(K))
% end

% [betabar, stoB, R0bar, acceptrate, r0Elems, stoR0] =newmethod(y, X, beta,B0,...
%     wishartPrior, wishartDf, diag(D0), R, ...
%         Sims, burnin, posttrackingnums);
% R0bar    
% acceptrate
   


% posttrackingnums = [2,1;2,4; 1,4]; 
% bbar = zeros(Reps,length(b0));
% r0 = zeros(size(R,1), size(R,1), Reps);
% stoB = zeros(Sims, length(beta),Reps);
% stoR0 = zeros(K,K,Sims,Reps);
% post = zeros(Sims,size(posttrackingnums,1), Reps);
% ar = zeros(Reps,1);
% loss = zeros(Reps,1);
% 
% demean = y-mu;
% W = demean*demean'
% D0 = diag(W);
% dihalf = D0.^(-.5);
% R0 = diag(dihalf)*W*diag(dihalf)
 
for i =1:Reps
    i
    [bbar(i,:), r0(:,:, i),ar(i), post(:,:,i),stoR0(:,:,:,i), stoB(:,:,i)] = ...
        mv_probit(y, X, beta, B0, wishartDf, diag(D0), R0,...
        Sims, burnin, posttrackingnums);
    bbar
    r0
    r0ir = r0(:,:,i)*iR;
    steinloss(i) = trace(r0ir) - logdet(r0ir) - size(r0,1);
end
