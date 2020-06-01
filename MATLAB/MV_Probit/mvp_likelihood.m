function [val] = mvp_likelihood(vechSigma,zt, mu, sig0, Sig0, unvech, K)

Sigma = unvech*vechSigma;
Sigma = reshape(Sigma, K,K);
Sigma = Sigma + Sigma' + eye(K);
[~, p ] = chol(Sigma, 'lower');
if p ~= 0
    val = Inf;
else
    val = sum(logmvnpdf(zt', mu, Sigma)) +  logmvnpdf(vechSigma', sig0', Sig0);
    val = -val;
end
end

