clear; clc;
leftTruncation(8);
twoSided(1,2);
truncNormalRand(10, Inf, 9, .01);
truncNormalRand(-Inf, 10, 11, .01);
a = [0,0, 0];
b = [Inf, Inf, Inf];
mu = [0,.5,1];
S = createSigma(-.7, 3);
N = 10;
bn = 1;
% [sample, means] = tmultnormrndSaveMeans(a,b,mu,S, N);
% sample = sample(bn:N,:)
% [x, m] = tmultnormrndSaveMeans(a,b,mu,S,10);
% tmultnormrndEta(a,b,mu,S,10, mu);

% z = zeros(5,1);
% for i = 1:5
%     sample = adaptiveSampler(a,b,mu,S, 1100, 100, 100);
%     zs = mean(sample,1);
%     K = gibbsKernel(a,b,mu, S, sample);
%     z(i) =  log(mvnpdf(zs,mu,S)) - log(mean(prod(K,2)));
% end
% 
% sample = arSample(a,b,mu,S,N);
% zs = mean(sample,1);
% K = gibbsKernel(a,b,mu, S, sample);
% log(mvnpdf(zs,mu,S)) - log(mean(prod(K,2)))
sample = tmultnormrnd(a,b,mu,S,N,a);
sample = sample(bn:N,:);
[zs,fz] = chibml(a,b,mu,S,sample,N, bn);

sto = zeros(10,1);
for i = 1:10
    sto(i) = log(mvnpdf(zs',mu,S)/prod(fz));
end
mean(sto)

sample  = tmultnormrndEta(a,b,mu,S,N);

% tmultnormrndEta(a,b,mu,S,10)