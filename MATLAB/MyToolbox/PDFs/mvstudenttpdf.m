function [ pdfval ] = mvstudenttpdf( X,mu, Scale,nu )
% Correct.
RRR = size(X,2);
TTT = size(mu,2);
if RRR ~= TTT
    error('X and mu must have save number of columns.')
end
p = size(Scale,1);
logdetscale = sum(log(diag(chol(Scale))));
diag(chol(Scale))
nuphalf = .5*(nu + p);
phalf = .5*p;
demean = X-mu;
C = gammaln(nuphalf) - gammaln(nu*.5) - phalf*log(nu*pi)-...
    logdetscale
gammaln(nuphalf)
logdetscale
inner= ((demean/Scale)*demean')/nu;
pdfval = C - nuphalf*log(1 +inner );
end

