function [lpdf] = logtpdf()
nu1half = (nu+1)*.5;
lpdf = gammaln(nu1half) - (.5*log(pi*nu)) - gammaln(nu*.5) - ...
    (nu1half*log(1 + (x-mu)*(sigma*nu)^(-1)));
end

