function [ beta, sigma] = lrGibbs(G, burn, y,X, betaInit, B0, sigmaInit, a0, d0)
% Pass d0 as the inverse because this method follows Greenberg's notation
% which uses the gamma parameterization with B^alpha in the numerator. 
[r,J] = size(X);
XpX = X'*X;
Xpy = X'*y;
B0inv = inv(B0);
B0invb0 = (B0inv) * betaInit';
beta = zeros(G,J);
sigma = zeros(G,1);
beta(1,:) = betaInit;
sigma(1,:) = sigmaInit;
a1 = a0 + r;
for g = 2:G
   B1 = inv( XpX + B0inv );
   betabar = (B1*( Xpy + B0invb0 ))';
   beta(g, :)  = mvnrnd(betabar, sigma(g-1,:)*B1);
   resids = y - X*beta(g,:)';
   d1 = d0 + (resids'*resids) + (beta(g,:)*B0inv*beta(g,:)');
   sigma(g, :) = 1/gamrnd(a1/2, 2/d1);
end
beta = beta(burn+1:G, :);
sigma = sigma(burn+1:G, :);
end

