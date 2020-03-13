function [sigma2, beta] = gibbslr(y, X, b0, B0, a0, d0, sims, burnin)
[N,p]= size(X);
XpX = X'*X;
Xpy = X'*y;
aG = a0 + N;
B0inv = inv(B0);
B1 = inv(XpX+ B0inv);
sigma2 = zeros(sims-burnin, 1);
s = 1;
beta = zeros(p, sims-burnin);
for i = 2:sims
    betaUpdate = B1 * ( (Xpy/s) + B0inv*b0);
    B1 = inv( (XpX/s) + B0inv);
    b = mvnrnd(betaUpdate, B1, 1)';
    yMXbTyMXb = sum((y - X*b).^2);
    dG = d0 + yMXbTyMXb;
    s = 1/gamrnd(aG/2, 2/dG);
    if i > burnin
        beta(:, i-burnin) = b;
        sigma2(i-burnin) = s;
    end
end
beta = beta';
end

