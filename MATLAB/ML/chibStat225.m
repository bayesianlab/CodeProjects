function [outputArg1,outputArg2] = chibStat225(a,b,mu,Sigma,postSample, rrSims, rrBurnin)
post = chibml(a,b, mu, Sigma, postSample, rrSims, rrBurnin);

end

