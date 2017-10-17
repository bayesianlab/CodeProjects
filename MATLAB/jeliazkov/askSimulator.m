function [ ml,se ] = askSimulator( a,b, mu, sigma, sims, burnin)
eta = askGibbs(a,b,mu, sigma,sims,burnin);
L = chol(sigma, 'lower');
z = mu + (L*eta')';
zStar = mean(z,1)
Kernel = askKernel(a,b, z,zStar, mu, sigma);
mvnpdf(zStar,mu,sigma)
mean(prod(Kernel,2))
mvnpdf(zStar,mu,sigma)/mean(prod(Kernel,2))
ml = log(mvnpdf(zStar,mu,sigma)/mean(prod(Kernel,2)));
se = lpVarASK(z,40,a,b,mu,sigma);
end

