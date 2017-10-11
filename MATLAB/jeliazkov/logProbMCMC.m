function [ lp ] = logProbMCMC(zStar,fzStar, mu, sigma)
log(prod(fzStar))
log(mvnpdf(zStar, mu, sigma))
lp = log(mvnpdf(zStar,mu,sigma)/prod(fzStar));
end

