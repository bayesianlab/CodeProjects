
clear; clc;
load '/Users/dillonflannery-valadez/Google Drive/CodeProjects/MATLAB/jeliazkov/y' ...
    y
load '/Users/dillonflannery-valadez/Google Drive/CodeProjects/MATLAB/jeliazkov/x1' ...
    x1 
load '/Users/dillonflannery-valadez/Google Drive/CodeProjects/MATLAB/jeliazkov/x2' ...
    x2
load '/Users/dillonflannery-valadez/Google Drive/CodeProjects/MATLAB/jeliazkov/post1' ...
    post1 
load '/Users/dillonflannery-valadez/Google Drive/CodeProjects/MATLAB/jeliazkov/post2' ...
    post2
rng(101, 'twister')
X = [x1,x2];
beta = [0;0];
N = 1000;
Sims = 100;
qi = 2.*y-1;
eps = normrnd(0,1,N,Sims);
delta = .01
format long g
ARsimulator(X, beta, eps);

gp = @(b)probitLL(y,X, b);
hp = @(b)probitJ(y,X,b);
% simulatedDerivative(beta, eps, delta)
simulatedHessian(beta, eps, delta);
simd = @(b)simulatedDerivative(b,eps, delta);
simh = @(b)simulatedHessian(b,eps,delta);
% options = optimset('Display', 'iter', 'MaxFunEvals', 100, 'TolFun', 1e-4);
% fminunc(simd, [0;0], options)
% newtonMSM([0;0], simd, simh, 1e-3, 500, 1)

simd(beta)
probitLL(y,X,beta)
