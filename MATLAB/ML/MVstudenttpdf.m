function [ pdfval ] = MVstudenttpdf( X,mu, Scale,nu )
% Correct.
p = size(Scale,1);
nuphalf = .5*(nu + p);
phalf = .5*p;
demean = X-mu;
C = gammaln(nuphalf) - gammaln(nu*.5) - log(nu^phalf) -...
    log(pi^phalf) - .5*log(det(Scale));
inner= ((demean'/Scale)*demean)/nu;
pdfval = C - nuphalf*log(1 +inner );
end

