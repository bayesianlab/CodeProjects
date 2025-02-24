function [ logpdf ] = logigampdf( x,alpha,beta )
% Verified in R
constant = alpha.*log(beta) - gammaln(alpha);
nonexpterm = -(alpha+1).*log(x);
logpdf = constant + nonexpterm - (beta./x);


end

