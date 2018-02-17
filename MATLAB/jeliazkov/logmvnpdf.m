function [lmvnpdf ] = logmvnpdf( x, mu, sigma )
[~, J] = size(x);
[~,J2] = size(mu);

if isrow(x)
    x = x'
end
if isrow(mu)
    mu = mu'
end
[K, ~] = size(sigma);
C1 = ( K*log(2*pi) + log(det(sigma)) );
(x - mu)'
((x - mu)' *sigma^(-1)) 
(x - mu)
C2 = sum(((x - mu)' *sigma^(-1)) * (x - mu), 2);
lmvnpdf = -.5*(C1 + C2) ;
end

