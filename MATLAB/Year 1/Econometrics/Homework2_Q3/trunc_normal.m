function [ yStar ] = trunc_normal( beta, sig_sqd, X, oldY )
[r,c] = size(beta);
if r<c
    beta = beta';
end

n = length(oldY);
us = unifrnd(0,1,n,1);
yStar = zeros(n,1);
mus = X*beta;
sigma = sqrt(sig_sqd);

yEquals1 = [-Inf, 0];
yEquals2 = [0,1];
yEquals3 = [1, Inf];
 
for elem = 1:n
    y = oldY(elem);
    if y == 1
        yStar(elem) = truncatedNormal(mus(elem), sigma, us(elem), yEquals1(1),...
            yEquals1(2));
    elseif y == 2
        yStar(elem) = truncatedNormal(mus(elem), sigma, us(elem), yEquals2(1),...
            yEquals2(2));
    else 
        yStar(elem) = truncatedNormal(mus(elem), sigma, us(elem), yEquals3(1),...
            yEquals3(2));        

    end
end
        

end

