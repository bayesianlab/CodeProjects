function [ ml,v ] = askSimulator( a,b, mu, sigma, sims, burnin)
[J, ~] =size(sigma);
sample = askGibbs(a,b,mu, sigma,sims,burnin);
eta = squeeze(sample(:,1,:));
L = chol(sigma, 'lower');
z = mu + (L*eta')';
zStar = mean(z,1);
Kernel = askKernel(a,b, z,zStar, mu, sigma);
v = kernelNSE(a,b,z,mu,sigma, 20);
ml = log(mvnpdf(zStar,mu,sigma)/mean(prod(Kernel,2)));
end

