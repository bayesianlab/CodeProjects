clear;
clc;
N = 1000;
K = 3;
p = 2;
sims = 100;
rng(1)
yt = zeros(N,K);
yt(1,1) = 1;
yt(1,2) = -1;
yt(1,3) = -2;
A = [.2, -.6 .3; .1, .3, -.4; .25, -.35, .4];
eig(A)
mu = [1;2; -1];
% Omega = [1, -.1,  -.15; -.1, 1, -.1; -.15, -.1, 1];
Omega = eye(3);
for i = 2:N
 yt(i,:) = (mu+ A * yt(i-1,:)' + mvnrnd(zeros(1,K), Omega, 1)')'; 
end

[yt, xt] = lagYt(yt,2);

xt\yt
% MinnesotaPrior(yt,xt,1,10,1,5)
b0 = zeros(K*p + 1, 1);
B0 = 10*eye(K*p + 1);


BvarMinnesota(yt, p, b0, B0, 10, 1, 2, sims)


