function [ pdfval ] = mvstudenttpdf( X,mu, Scale,nu )
% Correct.
p = size(Scale,1);
nuphalf = .5*(nu + p);
phalf = .5*p;
demean = X-mu;
C = gammaln(nuphalf) - gammaln(nu*.5) - phalf*log(nu*pi)-...
    .5*log(det(Scale));
inner= ((demean'/Scale)*demean)/nu;
pdfval = C - nuphalf*log(1 +inner );
end

