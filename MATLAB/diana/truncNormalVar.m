function [variance ] = truncNormalVar(a,b,mu,sigma)
alpha = (a- mu)/ sigma;
beta = (b - mu)/sigma;

if(beta > 10)
    numerator1 = alpha*normpdf(alpha) ;
    numerator2 = normpdf(alpha) ;
    Z = normcdf(beta) - normcdf(alpha);
    variance = (sigma^2) * (1 + numerator1/Z - (numerator2/Z)^2 );
else
    numerator1 = alpha*normpdf(alpha) - beta*normpdf(beta);
    numerator2 = normpdf(alpha) - normpdf(beta);
    Z = normcdf(beta) - normcdf(alpha)
    variance = (sigma^2) * (1 + numerator1/Z - (numerator2/Z)^2 );
end
end

