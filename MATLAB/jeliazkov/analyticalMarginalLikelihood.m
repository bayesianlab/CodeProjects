function [ logml ] = analyticalMarginalLikelihood(y,X, beta0, B0, a0, d0)
% Analyitical marginal likelihood of the linear regression model. Pass
% d0 as the inverse because following Greenberg parameterization of the 
% IG distribution
[r,~] = size(X);
XpX = X'*X;
Xpy = X'*y;
B0inv = inv(B0);
B1 = inv(XpX + B0inv);
B1inv = inv(B1);
a1 = a0+r;
betaBar = B1*(Xpy + B0inv*beta0);
d1 = d0 + (y'*y) + (beta0'*B0inv*beta0) - (betaBar'*B1inv*betaBar);
rootDet = (det(B1)/det(B0))^(1/2);
piterms = (pi)^(-r*.5);
gammaterms = gamma(a1*.5)/gamma(a0*.5);
deltaterms = (d0^(a0*.5))/(d1^(a1*.5));

logml=log(piterms*deltaterms*rootDet*gammaterms);


end

