function [ chibml ] = chibsMethod( betas, sigmas, X, y, B0, beta0, a0, d0 )
% Chib's (1995) method for computing marginal likelihoods using
% Rao-Blackwellization
[r,c] = size(X);
[n,~] = size(betas);
ordinatesB = mean(betas);
ordinateS = mean(sigmas);
B0inv = inv(B0);
B0invb0 = (B0inv) * beta0';
XpX = X'*X;
Xpy = X'*y;
B1 = inv( XpX + B0inv );
B1inv = inv(B1);
betabar = (B1*( Xpy + B0invb0 ))';
fBeta = zeros(r,1);
for s = 1:n
    fBeta(s,:) = mvnpdf(ordinatesB, betabar, sigmas(s,:)*B1);
end
fBeta = mean(fBeta);
a1 = a0+r;
resid = y - X*ordinatesB';
d1 = d0 + (y'*y) + (beta0*B0inv*beta0') - (betabar*B1inv*betabar');
fSigma = invgampdf(ordinateS, a1/2, 2/d1);
% likelihood
constant = (2*pi*ordinateS)^(-r/2);
expTerm = exp((-1/(2*ordinateS))*(resid'*resid));
like= constant * expTerm;
% Log priors 
sigmaPrior = invgampdf(ordinateS, a0/2, 2/d0);
betaPrior = mvnpdf(ordinatesB, beta0, ordinateS.*B0);
chibml = log((like*betaPrior*sigmaPrior)/(fBeta*fSigma));

end
