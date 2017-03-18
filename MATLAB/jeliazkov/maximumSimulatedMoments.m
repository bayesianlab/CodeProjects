
clear; clc;
load '/Users/dillonflannery-valadez/Google Drive/CodeProjects/MATLAB/jeliazkov/y' ...
    y
load '/Users/dillonflannery-valadez/Google Drive/CodeProjects/MATLAB/jeliazkov/yi' ...
    yi
load '/Users/dillonflannery-valadez/Google Drive/CodeProjects/MATLAB/jeliazkov/x1' ...
    x1 
load '/Users/dillonflannery-valadez/Google Drive/CodeProjects/MATLAB/jeliazkov/x2' ...
    x2
load '/Users/dillonflannery-valadez/Google Drive/CodeProjects/MATLAB/jeliazkov/post1' ...
    post1 
load '/Users/dillonflannery-valadez/Google Drive/CodeProjects/MATLAB/jeliazkov/post2' ...
    post2
load '/Users/dillonflannery-valadez/Google Drive/CodeProjects/MATLAB/jeliazkov/eps' ...
    eps
rng(101, 'twister')
X = [x1,x2];
beta = [post1;post2];
N = 1000;
Sims = 1000;
qi = 2.*y-1;


delta = .01;
tol = 1e-3

gp = @(b)probitLL(y,X, b);
hp = @(b)probitJ(y,X,b);
ll = @(b)probitL(y,X, b);
t = @(b)test(b,ll,gp);

% [yi, ARsimulator(X, beta, eps)];
b = [.01; .02];
format
% simulatedDerivative(b,eps,delta)

pSS = @(b)probitSimulatedScore(b,delta);
% aRMSM = @(b)ARmethodSimulateMoments(b);
% sPWG = @(b)simulatedProbitWithGrad(b, aRMSM, pSS);
% optimizeNewton(b,gp,hp,1e-3,20,1)
% pSS(beta)


% options = optimset('Display', 'iter', 'MaxFunEvals', 100, 'TolX', 1e-8, 'TolFun', 1e-8);


% simulatedDerivative(beta, eps, delta)
% simulatedHessian(beta, eps, delta);
% simd = @(b)simulatedDerivative(b,eps, delta);
% simh = @(b)simulatedHessian(b,eps,delta);

% newtonMSM([0;0], simd, simh, 1e-3, 500, 1)

% simd(beta)

