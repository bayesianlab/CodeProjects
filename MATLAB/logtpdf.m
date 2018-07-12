function [pdf] = logtpdf(x, mu, Sigma, nu)
[~,c] = size(Sigma);
demeaned = x-mu;
Mahalanobis = demeaned'*inv(Sigma)*demeaned;
kernel = 1 + Mahalanobis/nu;
nuPlusDimhalf = .5*(nu + c);
normalizingConstant = gammaln(nuPlusDimhalf) -...
    (gammaln(.5*nu) + ((c*.5)*log(nu)) + (c*.5)*log(pi) + (.5*log(det(Sigma))));
pdf = normalizingConstant  - nuPlusDimhalf*log(kernel);
end

