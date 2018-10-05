clear;
clc;
R = [1, .8, .6, .4, .2, 0, 0;
    .8, 1, .8, .6, .4, .2, 0;
    .6, .8, 1, .8, .6, .4, .2;
    .4, .6, .8, 1, .8, .6, .4;
    .2, .4, .6, .8, 1, .8, .6;
    0, .2, .4, .6, .8, 1, .8;
    0, 0, .2, .4, .6, .8, 1];
N = 100;
K = size(R,1);
Sims = 200;
burnin = 1;
z= mvnrnd(zeros(K,1),R, N)';
W = z*z'./(K*N);
dw = diag(W);
fprintf('right\n')
R0t = diag(dw.^(-.5))*W * diag(dw.^(-.5))

a = ones(K,1)*(-Inf);
b = ones(K,1)*Inf;

R0 = eye(K);
D0 = diag(R0);
%     for t = 1:N
%         newz(:,t) = geweke91(a,b,zeros(K,1),R,1,0,z(:,t));
%     end
% newz*newz'
% W = newz*newz'./(K*N);
% dw = diag(W);
% diag(dw.^(-.5))*W * diag(dw.^(-.5))
[sto, ar] = liutest(a,b,z, R0, diag(D0), Sims, burnin)