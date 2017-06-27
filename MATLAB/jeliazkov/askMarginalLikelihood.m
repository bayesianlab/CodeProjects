function [ Kernel ] = askMarginalLikelihood( a,b, mu, sigma, sims, burnin )
eta = askGibbs(a,b,mu, sigma,sims,burnin);
L = chol(sigma, 'lower');
z = mu + (L*eta')';
zStar = mean(z,1);
Kernel = askKernel(a,b, z,zStar, mu, sigma);
end

