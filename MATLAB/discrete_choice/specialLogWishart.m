function [ y ] = specialLogWishart( Jac, Sigma,W,v )

% Input:
%   Sigma: d x d covariance matrix
%   W: d x d covariance parameter
%   v: degree of freedom
% Output:
%   y: probability density in logrithm scale y=log p(Sigma)
y = log(Jac) + logWishart(Sigma,W,v);
end

