clear;
clc;
% r= 75;
% N = 1000;
% bn = 100;
% beta = [2, 1.5, 1.5, -.5]';
% X = [ones(r,1), normrnd(0,1,r,3)];
% 
% y = X*beta + normrnd(0,.25,r,1);
% XpXinv = inv(X'*X);
% Mles =  XpXinv* X'*y;
% resids = y - X*Mles;
% res2 = resids'*resids;
% sHat = res2/(r);
% [~, J] = size(X);
% V = zeros(J+1, J+1);
% V(1,1) = 2*(sHat^2)/r;
% V(2:(J+1), 2:(J+1)) = sHat * XpXinv;
% mu = [sHat, Mles']'
% 
% a = [0, -inf, 0, -inf, -inf]'
% b = [inf, inf, 1, inf, inf]'
% 
% C = chol(V, 'lower');
% Cinv = inv(C)
% alpha = a- mu;
% beta = b
% beta(:) = inf
% alpha(2:length(a)) = -inf;
% alpha(1,1) = alpha(1,1) * Cinv(1,1)
% 
% b0 = zeros(J,1);
% B0 = eye(J);
% a0 = 6;
% d0 =12;
% 
% init = zeros(length(a), 1);
% 
% tmultnormrndEta(a,b,alpha,beta,mu,V,10)
% 
% ask(a,b, alpha, beta, mu,V,y,X,1000,100, 100, b0,B0,a0,d0);
% ark(a,b,alpha,beta,mu,V, y, X, 1000, b0, B0, a0, d0);
% crt(a,b,mu,V,y,X,1000,100,b0,B0,a0,d0);
% crb(a,b,mu,V,y,X, 1000, 100, 1000,100,  init, b0,B0,a0,d0);
% lognrnd(0,1,1)
% a = -log(2)
% b = log(1-
% exp(tlnrnd(.5, .75, 0, 1, 10))