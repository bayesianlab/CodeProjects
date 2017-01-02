function [ x ] = truncatedNormal( mu, sigma, u, lowLimit, uppLimit)
inside = u*(normcdf(uppLimit, mu, sigma)-normcdf(lowLimit, mu, sigma))...
    + normcdf(lowLimit, mu, sigma);

x = norminv(inside, mu, sigma);


end

