function [Like] = OpNumDeriv(delta, y, X, beta,h)
Xbeta = X*beta;
[n,~] = size(Xbeta);
NumChoices = length(delta) + 2;
gamma = CutPoints(delta);
Like = 0;
for i = 1:n
    if y(i) == 1
        Like = Like + log(normcdf(gamma(y(i)) - Xbeta(i),0,1));
    elseif y(i) == NumChoices
        Like = Like + log(1- normcdf(gamma(y(i) - 1) - Xbeta(i),0,1));
    else
        Like = Like +...
            log(normcdf(gamma(y(i)) - Xbeta(i),0,1) -...
            normcdf(gamma(y(i) - 1) - Xbeta(i),0,1));
    end
end
deltaN = delta;
LikeN = zeros(n,1);
Fdelta = zeros(NumChoices-2,1);
ithDeriv = zeros(n,NumChoices-2);
for j = 1:NumChoices - 2
    deltaN(j) = delta(j) + h;
    gamma = CutPoints(deltaN);
    for i = 1:n
        if y(i) == 1
            LikeN(i) = log(normcdf(gamma(y(i)) - Xbeta(i),0,1));
        elseif y(i) == NumChoices
            LikeN(i) = log(1- normcdf(gamma(y(i) - 1) - Xbeta(i),0,1));
        else
            LikeN(i) = log(normcdf(gamma(y(i)) - Xbeta(i),0,1) -...
                normcdf(gamma(y(i) - 1) - Xbeta(i),0,1));
        end
    end
    ithDeriv(:,j) = (LikeN-Like) ./ h;
end
end
