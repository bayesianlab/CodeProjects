function [ll] = SigmaMaximize(freeSigma, sigma0, iCommuteMat, Q, K, T)
Sigma = reshape(iCommuteMat*freeSigma, K,K);
Sigma = Sigma + Sigma' + eye(K);
[L, p] = chol(Sigma);
if p ~= 0
    ll = -Inf;
else
logdetSigma = -T*sum(log(diag(L)));
BigSigmaInverse = kron(speye(T), Sigma\eye(K));
ll = logdetSigma -.5*( (Q'*BigSigmaInverse)*Q + (freeSigma'*sigma0)*freeSigma);
end
end

