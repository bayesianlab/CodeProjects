function [val] = mvp_likelihood(sigelems, constsigelems, zt, mu, sig0, Sig0,  unvech, vindex)
K = size(mu,2);
constsigelems(vindex) = sigelems;
Sigma = unvech*constsigelems;
Sigma = reshape(Sigma, K,K);
Sigma = Sigma + Sigma' + eye(K);
[~, p ] = chol(Sigma, 'lower');
if p ~= 0
    val = Inf;
else
    val = sum(logmvnpdf(zt', mu, Sigma)) +  logmvnpdf(sigelems', sig0', Sig0);
    val = -val;
end
end

