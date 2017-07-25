function [ draw ] = tnormrnd(a,b,mu,sigma)

    alpha = (a - mu) / sigma;
    beta = (b - mu) / sigma;
    Fa = normcdf(alpha);
    Fb = normcdf(beta);
    draw = mu + (sigma.*norminv(Fa + unifrnd(0,1,1, 1).*(Fb - Fa)));

end

