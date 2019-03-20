clear;clc;
% rng(10)
N = 1000;
T = 7;
nCovariates = 6;
onesN = ones(N,1);
onesT = ones(T,1);
r = [onesT.*.2, onesT.*.4, onesT.*.6,onesT.*.8, onesT];
LD = spdiags(r, [-4,-3,-2,-1], T,T);
LD = LD + LD';
R = full(eye(T) + LD);

b = double(unifrnd(0,1,N,1) > .5);

X = zeros(N*T, nCovariates*T);
Xit = zeros(N*T, nCovariates);
crange = 1:nCovariates;
rrange = 1:T;
c = 0;
sum = zeros(42,42);
for i = 1:N
    bi = b(i);
    rows = rrange + (i-1)*T;
    for t = 1:T
        c = c + 1;
        Xit(c, :)= [1, t, t^2, bi, bi*t, bi*t^2];
    end    
end

beta = ones(nCovariates,1);
err = mvnrnd(zeros(1,T), R, N)';
mu = Xit*beta;
ystar = mvnrnd(reshape(mu, T, N)', R)';
y = double(ystar>0);


[a1, a2] = mvProbit(y,Xit, beta, R,  ystar, 100)
%  V = [1,.3,.3;.3,1,.3;.3,.3,1];
% hh = GibbsTruncNormBelow([0;0;0], [1,1,1],V, 10000,100);
% mean(hh)
% corr(hh)
