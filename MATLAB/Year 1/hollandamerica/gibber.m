
clc;
swissimp;
nsim = 2000;
constant = ones(47,1);
X = [constant, Agriculture, Catholic, Education, Examination, InfantMortality];
y = Fertility;
dimX = size(X);


betas = zeros(nsim-1, dimX(2));
sigma2 = zeros(nsim,1);

B0 = eye(dimX(2))./10;
beta0 = ones(dimX(2), 1);
delta0 = 1;
alpha0= 1;
alpha1 = .5*alpha0 + .5*dimX(1);
sigma2(1) = 1;
XpX = X'*X;
B0inv = inv(B0);
for i = 2:nsim
    v = 1/sigma2(i-1);
    Beta1 = inv(XpX*v + B0inv);
    betaBar = Beta1*(( v*X'*y) + (B0inv*beta0));
    betas(i-1,:) = mvnrnd(betaBar, Beta1);
    resid2 = sum((y-(X*betas(i-1,:)')).^2);
    delta1 = 1/(1/delta0 + .5*resid2);
    sigma2(i) = 1/gamrnd(alpha1, 2) * delta1/2;
    
end
mean(betas)
mean(sigma2)

