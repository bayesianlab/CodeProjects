function [ll] = kowOptimizeRegion(regionguess, currobsmod, IOregion,...
    IOcountry, StateVariable, ydemuregion, variance, bdex, edex, T)

newregion = currobsmod(:,2);
newregion(bdex:edex, 2) = regionguess;
StateObsModel = [currobsmod(:,1), IOregion .* newregion, IOcountry .*currobsmod(:,2)];
speyet = speye(T);
kronobs = kron(speyet, StateObsModel);
isinvertible = kronobs*StateVariance*kronobs' + ObsDiagVariance;
chol(isinvertible)
% ll = kowLogLikelihood(ydemuregion, variance);
end

