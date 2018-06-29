% Dgp 
clear;clc;
rng(1);
T = 100;
dim = 2;
nFacs = 2;
IT = eye(T);
IK = eye(dim);
IR = eye(nFacs);
onesT = ones(T,1);
sigma2 = IR;
X = normrnd(0,1,dim,T);
X = [ones(1,T); X];
Theta0 = eye(1) * 10;

gamma = [.5, .75;
         .25, -.5]';
FactorVarDiag= kron(IT, sigma2);
Idiagonal = full(spdiags(ones(T*nFacs,1), 0, T*nFacs, T*nFacs));
GammaOffDiagonal = kron(full(spdiags(ones(T,1),-1,T,T)), -gamma);
offBlockDiag =  Idiagonal + GammaOffDiagonal;
Sinv = offBlockDiag' * FactorVarDiag  * offBlockDiag;
Sinv = inv(Sinv);
factormean = zeros(1, T*nFacs);
f = mvnrnd(factormean, Sinv);


a = [1, 0;
    .5, .3];
Sigma = sigma2 * eye(dim);
Omega = kron(IT, Sigma);
A = kron(IT, a);

V = Omega + (A*Sinv)*A';
Vinv = inv(V);

beta = unifrnd(-1,1,dim*(dim+1),1);

surX = repmat(kron(IK, ones(1,dim+1)),T,1).*repmat(X,dim)';

mu = surX*beta;

latent = A*f';

yt = mu + latent + normrnd(0,1,dim*T,1);
s = yt - mu; 

dLogLikeFactorModel(a,  yt, mu, Sigma, Sinv);
gradLL = @(guess)dLogLikeFactorModel(guess, yt, mu, Sigma, Sinv);

[p,q] = bhhh([1,0 ;.5,.5]', gradLL, 10, 1e-3)


% conditional and marginal work
% mu = [1,.4, -.3]'
% x = [2,4,.2]'
% S =[ 1.0000    0.3000    0.4000
%     0.3000    1.0000    0.2000
%     0.4000    0.2000    1.0000]
% 
% H = inv(S);
% H22 = H(2:end,2:end);
% nu = 8;
% nu12 = nu + 2;
% S12 = ((nu + (x(2:end)-mu(2:end))'*(S(2:end,2:end)^(-1))*(x(2:end)-mu(2:end)))/nu12) * H(1,1)^(-1)
% mu12 = mu(1) - H(1,1)^(-1) * H(1, 2:end) *( x(2:end) - mu(2:end) )
% mhtpdf(x(1), mu12, S12, nu12, x(2:end),mu(2:end), S(2:end,2:end), nu)
% 
% logmvtpdf(x,mu,S,nu)
% 



