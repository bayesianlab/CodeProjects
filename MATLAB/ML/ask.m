function [outputArg1,outputArg2] = ask(a,b,mu,Sigma,y, X, N,burnin,blocks,b0,B0,a0,d0)
[J,~] = size(Sigma);
sample = adaptiveSampler(a,b,mu,Sigma,N, burnin, blocks)
zs = mean(sample,1)
K = gibbsKernel(a,b,mu, Sigma, sample);
lig = loginvgampdf(zs(1), a0, d0);
lmvn = logmvnpdf(zs(2:J)', b0, B0);
lmpk = log(mean(prod(K,2)));
like = lrLikelihood(y, X, zs(2:J)', zs(1));
ml = like + lmvn + lig - lmpk;
fprintf('Log marginal likelihood %f\n', ml)
end

