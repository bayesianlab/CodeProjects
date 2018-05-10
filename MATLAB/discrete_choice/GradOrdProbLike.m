function [Like] = GradOrdProbLike(delta, y, X, beta)
Xbeta = X*beta;
[n,~] = size(Xbeta);
NumChoices = length(delta) + 2;
gamma = CutPoints(delta);
Like = zeros(n,1);
for i = 1:NumChoices
    if i == 1
        matches = (y==i);
        insidei = gamma(i) - Xbeta(matches);
        Like(matches) = log(normcdf(insidei));
    elseif i == NumChoices
        matches = (y==i);
        insidei = gamma(i-1) - Xbeta(matches);
        Like(matches) = log(1-normcdf(insidei));
    else
        matches = (y==i);
        insideim1 = gamma(i-1) - Xbeta(matches);
        insidei = gamma(i) - Xbeta(matches);
        Like(matches) = log(normcdf(insidei) - normcdf(insideim1));
    end
end
end

