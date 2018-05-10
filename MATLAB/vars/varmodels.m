clear;
clc;
N = 1000;
K = 3;
p = 3;
rng(1);
sims = 100;
burn = floor(.1*sims);

yt = zeros(N,K);
yt(1,1) = 1;
yt(1,2) = -1;
yt(1,3) = -2;
A = [.2, -.6 .3; .1, .3, -.4; .25, -.35, .4];
mu = [1;2; -1];
Omega = eye(K);
for i = 2:N
 yt(i,:) = (mu+ A * yt(i-1,:)' + mvnrnd(zeros(1,K), Omega, 1)')'; 
end
% yt
[u,i] = lagYt(yt,p);

% [a,~,~,~,e,~] = VAR_Swan(yt,p);
% MinnesotaPrior(yt,xt,1,10,1,5)
b0 = zeros(K*p + 1, 1);
B0 = 100*eye(K*p + 1);




% BvarMinnesota(yt, p, b0, B0, 10, 1, 1, sims)
nparams = K*(K*p+1);
b0 = zeros(nparams, 1);
B0 = 10*eye(nparams);
lambda0 = 5;
S0 = eye(K);

[a, sshat,D0inv] = gibbsvar(yt,p,b0,B0, lambda0, S0, sims, burn);
shock = [1;0;0];
BvarImpulse(a, D0inv,shock, 10)

createSigma(.5, 5)

