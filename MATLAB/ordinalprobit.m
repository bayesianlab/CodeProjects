 clear;clc;
N = 1000;
p = 5;
rng(2)
X = normrnd(0,1,[N,p]);
beta = [1,.4,-.5,.6,.9]';
z = X*beta + normrnd(0,1,N,1);
y = (z > -inf) + (z > -2) + (z > 0) + (z > 2);
gamma = [1,2,3,4];
delta = [.1, .2]';


nu =5;
b0 = zeros(length(beta),1);
B0 = 10*eye(length(beta));
nSims = 1000;
h = .1;
lambda = .5;
tol = 1e-3;
maxit = 10;



a = GradOrdProbLike(delta,y,X,beta);
delta1 = delta;
delta1(1) = delta1(1) + h;
% OpLogLikelihood(delta,y,X,beta)
% b = GradOrdProbLike(delta1,y,X,beta);
% OrdinalProbitGradient(delta,y,X,beta, h)
% OrdinalProbitObservedHessian(delta,y,X,beta,h)
% DopLogLikelihood(delta,y,X,beta)
% DDopLogLikelihood(delta,y,X,beta)
% [c,d] = MaxDelta(delta,y,X,beta, h,lambda,tol,maxit);


% [b,g] = OrdinalProbitGibbs(delta,y,X,beta,h,nu, b0,B0, nSims, lambda, tol, maxit);
