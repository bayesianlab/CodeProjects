clear;clc;

mu = [0,.5,1];
S = createSigma(-.7,3);

b = .1;
N = 100000;
ziDb = mvnrnd(mu,S, N)./b;
logis = makedist('Logistic');
K = cdf(logis, ziDb);
pK = prod(K,2);
logp = log(pK);
maxlogp = max(logp);
-log(N) + log(sum(exp(logp - maxlogp))) + maxlogp