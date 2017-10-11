clear;clc;
sims = 500;
tau = .33;
ctau = (10*tau);
cctautau= ctau^2;
tautau= .33^2;
ssize = 60;
ssizehalf = ssize/2;
beta = [0,0,0,1,1.2]';
dim = 5;
X = normrnd(0, 1, [ssize, dim]);
noise = normrnd(0, 2.5^2, [ssize,1]);
y = X*beta + noise;
gammas = zeros(sims, dim);
gammas(1,:) = ones(1,dim);
diagonalVect = zeros(1,dim);

I = eye(dim);
XpX = X'*X;
Xpy = X'*y;
XpXinv = inv(XpX);
betaLS = XpXinv*(Xpy)
resid = y - X*betaLS;
resid2 = resid'*resid;
resid2

covarmat = resid2*(1/(ssize-dim))*XpXinv;
ses = diag(covarmat)
tStats = betaLS./ses
sigs = zeros(sims, 1);
sigs(1) = 1;
betaUpdate = zeros(sims, dim);
p = .5;
for i = 2:sims
    for j = 1:dim
        if gammas(i-1,j) == 1
            diagonalVect(j) = ctau;
        else
            diagonalVect(j) = tau;
        end
    end
    D = diag(diagonalVect);
    DD = D*D;
    DDinv = inv(DD);
    
    
    A = sigs(i-1).*inv(XpX + sigs(i-1)*DDinv);
    mu = A*XpX*betaLS./sigs(i-1);
    
    betaUpdate(i, :) = mvnrnd(mu,A,1);
    
    residual = y - X*betaUpdate(i,:)';
    residual2 = residual'*residual;
    sigs(i) = 1/gamrnd(ssizehalf, 2/residual2,1);
    
    for j = 1:dim
        pa = normpdf(betaUpdate(i,j), 0, cctautau)*p;
        pb = normpdf(betaUpdate(i,j), 0, tautau)*p;
        gammas(i,j) = binornd(1, pa/(pa+pb));
    end
end
    
gammas
sum(gammas,1)./sims
    
    
