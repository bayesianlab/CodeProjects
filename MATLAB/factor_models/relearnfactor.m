% re learn factor models
clear;clc;
rng(14)
K = 4;
T = 10;
s2 = 1;
om = ones(K,1);
mu = ones(K,1);
G = ones(K,K).*[.75,.5,-.5,-.75];
a = [1, ones(1,K-1).*.75]';
g = .5;
epst = mvnrnd(zeros(K,1), diag(om), T)';
vut = normrnd(0,s2, T,1);
yt = zeros(K,T);
ft = zeros(1,T);
ft(1) = normrnd(0,1/(1-g^2));
yt(:,1) = epst(:,1);
for i = 2:T
    yt(:,i) = mu + G*yt(:,i-1) + a*ft(i-1) + epst(:,i);
    ft(i) = g*ft(i-1) + vut(i);
end
Xt = repmat(kron(eye(K),ones(1,K+1)), T,1).*repmat([ones(1,T);yt]',K);
h = [ones(T,1).*(-g), ones(T,1), ones(T,1).*(-g)];
p = full(spdiags(h,[-1,0],T,T));
F0 = p'*p;


calcSigmaInverse(yt(:),Xt,a, s2, F0,  om)