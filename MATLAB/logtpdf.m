function [pdf] = logtpdf(x, mu, sigma, nu)
[~,c] = size(sigma);
demeaned = x-mu;
Mahalanobis = demeaned'*inv(sigma)*demeaned;
kernel = 1 + Mahalanobis/nu;
nuPlusDimhalf = .5*(nu + c);
normalizingConstant = gammaln(nuPlusDimhalf) -...
    (gammaln(.5*nu) + ((c*.5)*log(nu)) + (c*.5)*log(pi) + (.5*log(det(sigma))));
pdf = normalizingConstant  - nuPlusDimhalf*log(kernel);
end

