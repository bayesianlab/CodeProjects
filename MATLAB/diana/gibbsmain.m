clear;
clc;
N = 500;
beta = [.5,.75, -.35]';
p = length(beta);
X = normrnd(0,1,N,p);
noise = normrnd(0,1,N,1);
y = X*beta + noise;

b0 = zeros(p,1);
B0 = eye(p);
a0 = 6;
d0 = 6;
[s2, b] = gibbslr(y,X, b0, B0, a0, d0, 1000, 500);
mle = inv(X'*X)*(X'*y);

resid2 = sum((y - X*mle).^2);
fprintf('MLES \n') 
disp(mle')
fprintf('Mean of the Gibbs sampler \n')
disp(mean([s2, b]))