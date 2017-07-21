function [ draw ] = tnormrnd(a,b,mu,sigma)
% interval = abs(mu-a);
% if (interval / sigma) < 6
    alpha = (a - mu) / sigma;
    beta = (b - mu) / sigma;
    Fa = normcdf(alpha);
    Fb = normcdf(beta);
    draw = mu + (sigma*norminv(Fa + unifrnd(0,1,1)*(Fb - Fa)));
% else
%     uncenteredDraw = robertRandVars(interval, b, 1, 1);
%     draw = uncenteredDraw*sigma + mu;
% end
end

