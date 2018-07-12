function [fx] = ttpdf2(a,b,mu,sigma, nu, x)
[r,c] = size(x);
standardX = (x-mu)./sigma;
alpha = (a - mu)./sigma;
beta = (b-mu)./sigma;
normC = (sigma.*(tcdf(beta, nu) -  tcdf(alpha,nu))).^(-1);
fx = normC.*tpdf(standardX,nu);
end

