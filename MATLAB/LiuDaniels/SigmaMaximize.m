function [ll] = SigmaMaximize(sigma, sigma0, iCommuteMat, Q, K, T)
Sigma = reshape(iCommuteMat*sigma, K,K);
[L, p] = chol(Sigma);
if p ~= 0
    ll = -Inf;
else
logdetSigma = -T*sum(log(diag(L)));
BigSigmaInverse = kron(speye(T), Sigma\eye(K));
ll = logdetSigma -.5*( (Q'*BigSigmaInverse)*Q + (sigma'*sigma0)*sigma);
end
end

