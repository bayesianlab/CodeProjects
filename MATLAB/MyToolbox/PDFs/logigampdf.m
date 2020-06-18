function [ logpdf ] = logigampdf( x,alpha,beta )
% Verified in R
% beta^alpha/ Gamma(alpha) x^{-1 - alpha}
% e ^{-beta/x)
constant = alpha.*log(beta) - gammaln(alpha);
nonexpterm = -(alpha+1).*log(x);
logpdf = constant + nonexpterm - (beta./x);

end

