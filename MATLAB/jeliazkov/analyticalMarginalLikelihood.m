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
betaBar = B1*(Xpy + B0inv*beta0')
d1 = d0 + (y'*y) + (beta0*B0inv*beta0') - (betaBar*B1inv*betaBar')
rootDet = (det(XpX + B0inv)*det(B0))^(-1/2);
piterms = (pi)^(-r/2);
gammaterms = gamma((a1)/2)*inv(gamma(a0/2));
deltaterms = (d0^(a0/2))/(d1^(a1/2));
logml=log(piterms*deltaterms*rootDet*gammaterms);

end

