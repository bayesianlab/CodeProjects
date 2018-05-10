clear; clc;
N = 100;
p = 5;
X = normrnd(0,1,[N,p]);
beta = [1,.4,-.5,.6,.9]';
z = X*beta + normrnd(0,1,N,1);
y = (z > -inf) + (z > -1) + (z > 0) + (z > 2);
d = [.1,.1];
beta = inv(X'*X)*X'*y;
h = .0001;
nu = 7;
b0 = zeros(length(beta),1);
B0 = eye(length(beta));
nSims = 100;
lambda = .5;
tol = 1e-2;
maxits = 5;
[b,g] = OrdinalProbitGibbs(d, y,X,beta, h, nu, b0,B0, nSims, lambda,tol,maxits);
mean(b)
mean(g)
y = (z > -inf) + (z > -1) + (z > 0);

m = find(y == 3);
for i = 1:length(m)
    u  = unifrnd(0,1,1);
    if u < .5 
        y(m(i)) = 4;
    end
end


beta = inv(X'*X)*X'*y;
h = .0001;
nu = 7;
b0 = zeros(length(beta),1);
B0 = eye(length(beta));
nSims = 100;
lambda = .5;
tol = 1e-2;
maxits = 5;
[b,g] = OrdinalProbitGibbs(d, y,X,beta, h, nu, b0,B0, nSims, lambda,tol,maxits);
mean(b)
mean(g)

delta = .1;

y(y == 4) = 3;
[b,g] = OrdinalProbitGibbs(delta, y,X,beta, h, nu, b0,B0, nSims, lambda,tol,maxits);
mean(b)
mean(g)