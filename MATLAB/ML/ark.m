function [ml] = ark(a,b,alpha, beta, mu,Sigma, y,X, N, b0,B0, a0,d0)
[J,~] = size(Sigma);
sample = tmultnormrndEta(a,b, alpha, beta, mu,Sigma,N);
zs = mean(sample,1)';
K = gibbsKernel(a,b,mu, Sigma, sample);
lig = loginvgampdf(zs(1), a0, d0);
lmvn = logmvnpdf(zs(2:J), mu(2:J), 100*B0);
lmpk = log(mean(prod(K,2)));
like = lrLikelihood(y, X, zs(2:J), zs(1));
ml = like + lmvn + lig - lmpk;
fprintf('Log marginal likelihood %f\n', ml)
end

