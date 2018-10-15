function [ pdfval ] = MVstudenttpdf( X,mu, Scale,nu )
% Double check
p = size(Scale,1);
nuphalf = .5*(nu + p);
phalf = .5*p;
demean = X-mu;
C = gammaln(nuphalf) - gammaln(phalf) - log(nu^phalf) -...
    log(pi^phalf) -log(det(Scale)^(.5));
pdfval = C - nuphalf*log(1 + (1/nu)*(demean'/Scale)*demean);
end

