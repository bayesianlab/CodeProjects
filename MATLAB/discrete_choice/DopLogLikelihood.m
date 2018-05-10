function [Fdel] = DopLogLikelihood(delta, y, X, beta)
Xbeta = X*beta;
[n,~] = size(Xbeta);
NumChoices = length(delta) + 2;
gamma = CutPoints(delta);
Fdel = zeros(NumChoices-2,1);
for i = 2:NumChoices-1
   matches = (y==i);
   insidei = (gamma(i) - Xbeta(matches));
   insideim1 = (gamma(i-1) - Xbeta(matches));
   ncdfi = (normcdf(insidei) - normcdf(insideim1)).^(-1);
   npdfi = normpdf(insidei);
   A = sum(npdfi.*ncdfi);
   
   matches = (y==i+1);
   insideip1 = (gamma(i+1) - Xbeta(matches));
   insidei = (gamma(i) - Xbeta(matches));
   ncdfip1 = (normcdf(insideip1) - normcdf(insidei)).^(-1);
   npdfip1 = normpdf(insideip1);
   Fdel(i-1,1) =  A - sum(npdfip1.*ncdfip1);
end
Fdel = Fdel./n;
end


