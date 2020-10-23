clear, clc;
% rng(0)


N = 100;
K = 2;
X = normrnd(1,1, N,K);
y = X*[.25;.45]  + normrnd(0,1, N,1);

[N, p] = size(X);
XpX = (X'*X);
XpXinv = (XpX)^(-1);
Xpy = X'*y;
bMLE = XpX\Xpy;
e = y - X*bMLE;
sSqd = (e'*e)/N;
thetaMLE = [sSqd; bMLE];
invFisher = [(2*sSqd^2)/N, [0,0];[0;0], sSqd*XpXinv];
variances = diag(invFisher);
Draws = 1000;
Sims = 100;
bn = 1;

Constraints = [1,1];
% [betaDraws, sigmaDraws,~, ml] = LRGibbs(y, X, zeros(K,1),...
%     100*eye(K), 6, 12, Sims, bn, 0, 0);

mltype = 2;
samplerType = 3;
[betaDrawsR, sigmaDrawsR,mlR] = RestrictedLR_Gibbs(Constraints, y, X,...
    zeros(K,1), 100*eye(K), 6, 12, Sims, bn, samplerType, mltype);
mlR
clear

% rental_import
% rmpp = rentaldata{:,3}./rentaldata{:,2};
% x1 = rmpp.*rentaldata{:,4};
% x2 = rmpp.*(1-rentaldata{:,4});
% x3 = rentaldata{:,5}.*rentaldata{:,4};
% x4 = rentaldata{:,5}.*(1-rentaldata{:,4});
% T= length(x1);
% X = [ones(T,1),x1,x2,x3,x4];
% y = rentaldata{:,6};
% 
% 
% 
% ols = (X'*X)\(X'*y)
% e = y - X*ols;
% sig_ols = sqrt((e'*e)/(length(y)-4))
% [T,K] = size(X);
% Sims = 10000;
% bn = 2000;
% iga = 6;
% igb = 12;
% b0 = ones(K,1);
% B0 = 1000.*eye(K);
% [betaDraws, sigmaDraws,~, ml] = LRGibbs(y, X, b0,...
%     B0, iga, igb, Sims, bn, 0, 0);
% Constraints = [0,1,1,-1,-1];
% [betaDrawsR, sigmaDrawsR,mlR] = RestrictedLR_Gibbs(Constraints, y, X,...
%     b0, B0, iga, igb, Sims, bn);
% mean(betaDraws,2)
% qbeta = [quantile(betaDraws, .05,2), quantile(betaDraws, .5,2),...
%     quantile(betaDraws, .95,2)]
% sqrt(mean(sigmaDraws))
% mean(betaDrawsR,2)
% qbetaR= [quantile(betaDrawsR, .05,2), quantile(betaDrawsR, .5,2),...
%     quantile(betaDrawsR, .95,2)]
% [qbeta, qbetaR]
% 
% ml 
% mlR
% A = tnormpdf(0,Inf, sSqd, sqrt(variances(1)), sigmaDraws');
% B = tnormpdf(0,Inf, thetaMLE(2,1), sqrt(variances(2)), betaDraws(1,:)');
% C = tnormpdf(0,Inf, thetaMLE(3,1), sqrt(variances(3)), betaDraws(2,:)');
% 
% hTheta = prod([A,B,C],2);
% 
% % lrmlRestricted(0,Inf, y, X, 3, 6, thetaMLE, invFisher, 101, 1)
% 
% importance = mean(lrLikelihood(y,X,betaDraws, sigmaDraws) +...
%     log(mvnpdf(betaDraws',[0,0], eye(2))) +...
%     log(invgampdf(sigmaDraws, 3,6)) -...
%     log(hTheta));
% params = {sSqd, (2*sSqd^2)/N, bMLE, sSqd*XpXinv};

% samp = tmvnGibbsSampler(0,Inf, thetaMLE', invFisher, 100,10, [0,0,0]);
% [z, fz] = crbMarginalLikelihood(0, Inf, thetaMLE', inv(invFisher), samp, 100);
% b = z(2:3)';
% s = z(1);
% crb = lrLikelihood(y,X, b, s)  + log(mvnpdf(b', [0,0], eye(2))) + ...
%     log(invgampdf(s, 3,6)) - log(prod(fz,2))
% 
% K = crtMarginalLikelihood(0,Inf, thetaMLE', invFisher, 100, 10, [0,0,0]);
% crt = lrLikelihood(y,X, b, s)  + log(mvnpdf(b', [0,0], eye(2))) +...
%     log(invgampdf(s, 3,6)) - log(mean(prod(K,2)))

% K = arkMarginalLikelihood(0, Inf, thetaMLE', invFisher, 1000);
% ark = lrLikelihood(y,X, b, s)  + log(mvnpdf(b', [0,0], eye(2))) +...
%     log(invgampdf(s, 3,6)) - log(mean(prod(K,2)))
% 
% K = askMarginalLikelihood(0, Inf, thetaMLE', invFisher, 100,10);
% ask = lrLikelihood(y,X, b, s)  + log(mvnpdf(b', [0,0], eye(2))) +...
%     log(invgampdf(s, 3,6)) - log(mean(prod(K,2)))


