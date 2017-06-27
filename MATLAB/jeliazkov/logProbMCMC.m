function [ lp ] = logProbMCMC(zStar,fzStar, mu, sigma)
lp = log(mvnpdf(zStar,mu,sigma)/prod(fzStar));
end

