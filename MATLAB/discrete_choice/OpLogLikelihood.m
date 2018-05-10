function [Like] = OpLogLikelihood(delta, y, X, beta)
Xbeta = X*beta;
[n,~] = size(Xbeta);
NumChoices = length(delta) + 2;
gamma = CutPoints(delta);
Like = 0;
for i = 1:NumChoices
    if i == 1
        matches = (y==i);
        insidei = gamma(i) - Xbeta(matches);
        Like = Like + sum(log(normcdf(insidei)));
    elseif i == NumChoices
        matches = (y==i);
        insidei = gamma(i-1) - Xbeta(matches);
        Like = Like + sum(log(1-normcdf(insidei)));
    else
        matches = (y==i);
        insidei = gamma(i) - Xbeta(matches);
        insideim1 = gamma(i-1) - Xbeta(matches);
        Like = Like + sum(log(normcdf(insidei) - normcdf(insideim1)));
    end
end
end

