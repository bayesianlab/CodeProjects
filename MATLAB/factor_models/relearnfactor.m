% re learn factor models
clear;clc;
rng(14)
K = 4;
T = 2500;
lag = 1;
om = 1;
sii2 = ones(K,1);
mu = ones(K,1);
G = ones(K,K).*[.75,.5,-.6,-.9];
a = ones(K-1,1).*.75;
ap = [1;a ];
g = .5;
epst = mvnrnd(zeros(K,1), diag(sii2), T+1)';
vut = normrnd(0,om, T+1,1);
yt = zeros(K,T+1);
ft = zeros(1,T+1);
ft(1) = normrnd(0,1/(1-g^2));
yt(:,1) = epst(:,1);

for i = 2:(T+1)
    yt(:,i) = mu + G*yt(:,i-1) + ap.*ft(i-1) + epst(:,i);
    ft(i) = g*ft(i-1) + vut(i);
end
ytorig = yt;
beta= [mu,G];
ytlag = yt(:,1:T);
Xtest = [ones(1,T);ytlag];
ytlag =[ones(1,T);ytlag]'; 
yt = yt(:,2:T+1);
yt*Xtest' *inv(Xtest*Xtest');
Xt = repmat(kron(eye(K), ones(1,K+1)),T,1)...
    .*repmat(kron(ytlag, ones(K,1)),1,K);
[rowX, colX] = size(Xt);

e = epst(:,2:T+1);
h = [ones(T,1).*(-g), ones(T,1), ones(T,1).*(-g)];
p = full(spdiags(h,[-1,0],T,T));
F0 = p'*p;
b0 = zeros(colX,1); 
B0 = 100.* eye(colX);
F0i = om*inv(F0);



b = beta';

index =1:K;
xpxsum = zeros(colX,colX);
xpysum = zeros(colX,1);
yh = yt(:);
for t = 1:T
    select = index + (t-1)*K;
    xpysum = xpysum + Xt(select,:)'*yh(select);
    xpxsum = xpxsum + Xt(select,:)'*Xt(select,:);
end
bols = inv(xpxsum)*xpysum;
mu = Xt*b(:);

dll = @(guess) marginalLogLikelihood(yh,mu,sii2,guess,F0);
[g,bt] = bhhh([0;0;0], dll, 100, 1e-3, .5)
% dfgibbs(yt(:),Xt,a, F0, sii2, om, b0, B0, 10) 