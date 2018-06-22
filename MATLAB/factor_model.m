% Dgp 
clear;clc;
rng(1);
T = 1000;
dim = 2;
IT = eye(T);
IK = eye(dim);
onesT = ones(T,1);
sigma2 = 1;
X = normrnd(0,1,dim,T);
X = [ones(1,T); X];
Theta0 = eye(1) * 10;

gamma = .5;
gamma2 = gamma*gamma;
onePgamma2 = 1 + gamma2;
OffDiag = [(onesT(1:T)*-gamma)']';
MainDiag = [1, (onesT(2:T-1).*onePgamma2)', 1]';
F0 = full(spdiags([OffDiag, MainDiag, OffDiag], [-1,0,1], T, T));
sigma2F0inv = sigma2*inv(F0);
f = mvnrnd(zeros(1,T), sigma2.*sigma2F0inv)';
a = [1, ones(1,dim-1)*.5]';


Sigma = sigma2 * eye(dim);
Omega = kron(IT, Sigma);
A = kron(IT, a);


V = Omega + (A*sigma2F0inv)*A';
Vinv = inv(V);

beta = unifrnd(-1,1,dim*(dim+1),1);

surX = repmat(kron(IK, ones(1,dim+1)),T,1).*repmat(X,dim)';

mu = surX*beta;
latent  =A*f;



yt = mu + latent + normrnd(0,1,dim*T,1);
s = yt - mu; 

dLogLikeFactorModel(a,  yt, mu, Sigma, sigma2F0inv);
gradLL = @(guess)dLogLikeFactorModel(guess, yt, mu, Sigma, sigma2F0inv);

[p,q] = bhhh([.1,.1]', gradLL, 10, 1e-3)




 





