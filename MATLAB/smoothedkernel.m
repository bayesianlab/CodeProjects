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

% LogitPosteriorPlots;
% 
% probitPosterior = table2array(probitPosterior);
% figure(1)
% nbins = 25;
% subplot(2,2,1)
% hist(probitPosterior(:,1), nbins)
% title('Constant')
% subplot(2,2,2)
% hist(probitPosterior(:,2), nbins)
% title('\beta_1')
% subplot(2,2,3)
% hist(probitPosterior(:,3), nbins)
% title('\beta_2')
% subplot(2,2,4)
% hist(probitPosterior(:,4), nbins)
% title('\beta_3')
% 
% probitposterior;
% 
% figure(1)
% nbins = 25;
% subplot(2,2,1)
% hist(probitPosterior(:,1), nbins)
% title('Constant')
% subplot(2,2,2)
% hist(probitPosterior(:,2), nbins)
% title('\beta_1')
% subplot(2,2,3)
% hist(probitPosterior(:,3), nbins)
% title('\beta_2')
% subplot(2,2,4)
% hist(probitPosterior(:,4), nbins)
% title('\beta_3')

x = normrnd(0,1,[100,3])
VAR_Swan(x,2)