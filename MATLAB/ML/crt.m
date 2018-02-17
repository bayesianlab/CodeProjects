function [ml] = crt(a,b,mu,V,y,X, sims, burnin, b0,B0,a0,d0)
[~, J] = size(X);
sample = tmultnormrnd(a,b,mu,V, sims, zeros(J+1,1));
sample = sample(burnin:sims,:);
zs = mean(sample,1)';
K = gibbsKernel(a,b,mu, V, sample);
lig = loginvgampdf(zs(1), a0, d0);
lmvn = logmvnpdf(zs(2:J+1), mu(2:J+1), 100*B0);
lmpk = log(mean(prod(K,2)));
like = lrLikelihood(y, X, zs(2:J+1), zs(1));
ml = like + lmvn + lig - lmpk;
fprintf('Crt Log marginal likelihood %f\n', ml)
end

