function [ draw ] = truncNormRnd(a,b,mu,sigma, N)
stdevs = abs(mu-a)/sigma
if stdevs > 5 
    stdevs = abs(mu-a)/sigma;
    draw = robertRandVars(stdevs, b, N, 1);
    draw = draw.*sigma + mu;
else
    alpha = (a - mu) ./ sigma;
    beta = (b - mu) ./ sigma;
    Fa = normcdf(alpha);
    Fb = normcdf(beta);
    draw = mu + (sigma.*norminv(Fa + unifrnd(0,1,N, 1).*(Fb - Fa)));
end

end
