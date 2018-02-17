function [ml] = ark(a,b,mu,Sigma, y,X, N, b0,B0, a0,d0)
[J,~] = size(Sigma);
sample = arSample(a,b,mu,Sigma,N);
zs = mean(sample,1)';
K = gibbsKernel(a,b,mu, Sigma, sample);
like = lrLikelihood(y, X, zs(2:J), zs(1));
lmvn = logmvnpdf(zs(2:J), mu(2:J), 100*B0);
lig = loginvgampdf(zs(1), a0, d0);
lmpk = log(mean(prod(K,2)));
ml = like + lmvn + lig - lmpk;
fprintf('Ark Log marginal likelihood %f\n', ml)
end

