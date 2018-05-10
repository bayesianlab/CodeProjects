function [V] = DDopLogLikelihood(delta,y,X,beta)
Xbeta = X*beta;
[n,~] = size(Xbeta);
NumChoices = length(delta) + 2;
gamma = CutPoints(delta);
H = zeros(NumChoices - 2,NumChoices - 2);
for i = 2:NumChoices-1
    matches = (y==i);
    insideim1 = (gamma(i-1) - Xbeta(matches));
    insideia = (gamma(i) - Xbeta(matches));
    cdfDiff1 = (normcdf(insideia) - normcdf(insideim1));
    npdfi = normpdf(insideia);
    Qa = npdfi.*(-gamma(i)*cdfDiff1 - npdfi)./cdfDiff1.^2;
    
    matches = (y==i+1);
    insideip1 = gamma(i+1) - Xbeta(matches);
    insidei = (gamma(i) - Xbeta(matches));
    npdfi = normpdf(insideip1);
    cdfDiff2 = normcdf(insideip1) - normcdf(insidei);
    Qb = npdfi.*( (gamma(i).*cdfDiff2) - npdfi)./cdfDiff2.^2;
    H(i-1,i-1) = sum(Qa) + sum(Qb);
    if i > 2
        H(i-1, i-2) = -sum(normpdf(insideim1).*normpdf(insideia)./ cdfDiff1.^2);
        H(i-2, i-1) = H(i-1, i-2);
    end
end
V = -inv(H)./n;
end

