function [pdfval] = logtpdf(x,mu,Sigma,df)
[J,~]=size(Sigma);
exponent = .5*(J+df);
halflogdetsigma = -sum(log(diag(chol(Sigma))));
gammas = gammaln(exponent) - gammaln(.5*df);
logpi = -(.5*J)*log(df*pi);
nconst = halflogdetsigma + gammas + logpi;
demu = x-mu;
pdfval = nconst -(exponent*log( 1 + (1/df)*( (demu'/Sigma)*demu ) ) );
end

