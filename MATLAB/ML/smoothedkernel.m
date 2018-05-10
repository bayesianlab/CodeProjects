function[] = smoothedkernel(mu,S,smoother, N)

ziDb = mvnrnd(mu,S, N)./smoother;
logis = makedist('Logistic');
K = cdf(logis, ziDb);
pK = prod(K,2);
logp = log(pK);
maxlogp = max(logp);
-log(N) + log(sum(exp(logp - maxlogp))) + maxlogp



