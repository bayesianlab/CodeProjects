function [ml] = crt(a,b,mu,V,y,X, sims, burnin, b0,B0,a0,d0)
[~, J] = size(V);
sample = tmultnormrnd(a,b,mu,V, sims, zeros(J,1));
sample = sample(burnin:sims,:);
zs = mean(sample,1)';
K = gibbsKernel(a,b,mu, V, sample);
lig = loginvgampdf(zs(1), a0, d0);
lmvn = logmvnpdf(zs(2:J), mu(2:J), 1000*B0);
lmpk = log(mean(prod(K,2)));
like = lrLikelihood(y, X, zs(2:J), zs(1));
fprintf('Log Likelihood %f  Log MVNPDF %f Log InvGammaPdf %f Log mean product Kernel %f\n', like, lmvn, lig, lmpk)
ml = like + lmvn + lig - lmpk;
fprintf('Crt Log marginal likelihood %f\n', ml)
end

