function [ logprob ] = crtorthant( a,b,mu,V,sims, burnin)
[~, J] = size(V);
sample = tmultnormrnd(a,b,mu,V, sims, zeros(J,1));
sample = sample(burnin:sims,:);
zs = mean(sample,1)';
K = gibbsKernel(a,b,mu, V, sample);
lmpk = log(mean(prod(K,2)));
lmvnpdf = log(mvnpdf(zs,mu, V));
logprob = lmvnpdf - lmpk;
end

