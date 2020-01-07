function [logp] = logmvnpdf2(x,mu,Sigma)
% outputs log likelihood array for observations x  where x_n ~ N(mu,Sigma)
% x is NxD, mu is 1xD, Sigma is DxD

D = size(x,2);

xc = bsxfun(@minus,x,mu);
logp =-.5* (( D * log(2*pi)) - logdet(Sigma) + (sum((xc * Sigma) .* xc, 2))'); 


end

function y = logdet(A)

U = chol(A);
y = 2*sum(log(diag(U)));

end