function [ y ] = specialLogWishart( Jac, Sigma,W,v )

% Input:
%   Sigma: d x d covariance matrix
%   W: d x d covariance parameter
%   v: degree of freedom
% Output:
%   y: probability density in logrithm scale y=log p(Sigma)
d = length(Sigma);
B = -0.5*v*logdet(W)-0.5*v*d*log(2)-logmvgamma(0.5*v,d);
y = log(Jac) + B+0.5*(v-d-1)*logdet(Sigma)-0.5*trace(W\Sigma);
end

