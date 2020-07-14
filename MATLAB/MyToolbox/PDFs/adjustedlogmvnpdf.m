function [logp] = adjustedlogmvnpdf(z, SigmaLowerInv)
% Where z has been normalized by its mean and variance
% The inverse of Sigma's lower cholesky is expected
D=size(z,2);
term1 = -0.5 * sum(z  .* z, 2); % N x 1
term2 =-0.5 * D * log(2*pi) +sum(log(diag(SigmaLowerInv))) ; % scalar
logp = term1' + term2;
end

