function [draw] = truncatedBelow(a, mu, sigma)
% Inaccurate after seven standard deviations
alpha = (a - mu) / sigma;
if alpha < 7
    Fa = normcdf(alpha);
    draw = mu + (sigma*norminv(Fa + unifrnd(0,1)*(1 - Fa)));
else
    draw = robertBelow(a,mu,sigma);
end
end

