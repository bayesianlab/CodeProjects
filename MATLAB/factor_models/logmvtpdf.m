function [tpdf] = logmvtpdf(x,mu,Sigma,nu)
dim = length(mu);
nuPdimhalf = .5*(nu + dim);
nuhalf = nu*.5;
dimhalf = dim*.5;
mah = x - mu;
const = gammaln(nuPdimhalf) - ...
    ( gammaln(nuhalf) + dimhalf*log(nu*pi) + .5*log(det(Sigma)) ) ; 
tpdf =const  -...
    nuPdimhalf*log(1 + ((1/nu) * mah'*inv(Sigma)*mah ));
end

