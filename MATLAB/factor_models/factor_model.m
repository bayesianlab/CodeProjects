% % Dgp 
clc;clear;
rng(1);
T = 25;
dim = 2;
nFacs = 1;
IT = eye(T);
IK = eye(dim);
IR = eye(nFacs);
onesT = ones(T,1);
sigma2 = IR;
X = normrnd(0,1,dim,T);
X = [ones(1,T); X];
Theta0 = eye(1) * 10;

% % gamma = [.5, .75;
% %          .25, -.5]';
gamma = .5;
FactorVarDiag= kron(IT, sigma2);
Idiagonal = full(spdiags(ones(T*nFacs,1), 0, T*nFacs, T*nFacs));
GammaOffDiagonal = kron(full(spdiags(ones(T,1),-1,T,T)), -gamma);
offBlockDiag =  Idiagonal + GammaOffDiagonal;
Sinv = offBlockDiag' * FactorVarDiag  * offBlockDiag;
Sinv = inv(Sinv);
factormean = zeros(1, T*nFacs);
f = mvnrnd(factormean, Sinv);
% 
% % a = [1, 0;
% %     2, 1];
a = [1,.5]'
Sigma = sigma2 * eye(dim);
Omega = kron(IT, Sigma);
A = kron(IT, a);

V = Omega + (A*Sinv)*A';
Vinv = inv(V);

beta = unifrnd(-1,1,dim*(dim+1),1);
beta'
surX = repmat(kron(IK, ones(1,dim+1)),T,1).*repmat(X,dim)';

mu = surX*beta;
latent = A*f';
error = mvnrnd(zeros(1,T*dim), Omega)';
yt = mu + latent + error;
% 
% [p,q] = dLogLikeFactorModel(a,  yt, mu, Sigma, Sinv);
% gradLL = @(guess)dLogLikeFactorModel(guess, yt, mu, Sigma, Sinv);
% 
% % [p,q] = bhhh([8,9]', gradLL, 10, 1e-8, .1)
% 
% % dLogLikeFactorModelSigma(a,yt,mu,[.1,.1],Sinv)
% % gradLLSigma = @(guess)dLogLikeFactorModelSigma(a,yt,mu,guess,Sinv);
% % [k,l]= bhhh( [1,1]', gradLLSigma, 100, 1e-3,  .1)
% 
% % [bhat, ahat, gammahat, factorhat,  Ahat,Sinv] = ...
% %     factorModelGibbs(yt,surX,Sigma,zeros(length(beta),1), eye(length(beta)), ...
% %     .5, eye(nFacs), [.1,.1]', 100, 10);

[bhat, ahat, gammahat, factorhat, factorVarHat, amle, Amle,Sinv] = ...
    factorModelGibbsCandJ2009(yt,surX,Sigma,zeros(length(beta),1), eye(length(beta)), ...
    .5, eye(nFacs), [.1,.1]', 10, 1);

e = yt - surX*bhat' - A*factorhat';
et = reshape(e,dim,T);
XPXinv = inv(surX'*surX);
c = 1;
for j = 1:dim 
    sigmahat(j) = (et(j,:)*et(j,:)')/T;
    Bhat(c:c+dim, c:c+dim) = sigmahat(j)*XPXinv(c:c+dim, c:c+dim);
    c = c+dim+1;
end


sigmahatcovar = diag(2*(sigmahat.^2)./T);


mles = [amle;bhat';sigmahat'];

[ra,ca] = size(Amle);
[rb,cb] = size(Bhat);
[rs, cs] = size(sigmahatcovar);

c1 = [Amle;zeros(rb+rs, ca)];
c2 = [zeros(ra, cb); Bhat; zeros(rs, cb)];
c3 = [zeros(ra,cs); zeros(rb, cs); sigmahatcovar];
mleVar = [c1,c2,c3];

lowerbound = [0; ones(ra+rb+rs-1,1).*(-inf)];
upperbound = [ones(ra+rb+rs,1).*inf];
% 
% impFactorModel(lowerbound, upperbound, mles, mleVar, yt, surX, Sigma,...
%     ahat, Sinv, 1000)
% 
% arkFactor(lowerbound, upperbound, mles, mleVar, yt, surX, Sigma,...
%     ahat, Sinv, 1000)
% 
% crbFactor(lowerbound, upperbound, mles, mleVar, yt, surX, Sigma,...
%     ahat, Sinv, 1000)
% 
% crtFactor(lowerbound, upperbound,mles, mleVar, yt, surX, Sigma,...
%     ahat, Sinv, 1000)
% 
% askFactor(lowerbound, upperbound,mles, mleVar, yt, surX, Sigma,...
%     ahat, Sinv, 1000, 1000)

% impFactorModel(lowerbound, upperbound, mles, mleVar, yt, surX, Sigma,...
%     ahat, Sinv, 1000)
% 
% arkFactor(lowerbound, upperbound, mles, mleVar, yt, surX, Sigma,...
%     ahat, Sinv, 1000)
% 
% crbFactor(lowerbound, upperbound, mles, mleVar, yt, surX, Sigma,...
%     ahat, Sinv, 1000)
% 
% crtFactor(lowerbound, upperbound,mles, mleVar, yt, surX, Sigma,...
%     ahat, Sinv, 1000)
% 
% askFactor(lowerbound, upperbound,mles, mleVar, yt, surX, Sigma,...
%     ahat, Sinv, 1000, 1000)


