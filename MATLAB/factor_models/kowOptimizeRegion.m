function [ll] = kowOptimizeRegion(regionguess, currobsmod, IOregion,...
    IOcountry, StateVariance, ydemuregion, ObsDiagVariance, bdex, edex, T)

newregion = currobsmod(:,2);
newregion(bdex:edex, 1) = regionguess;
StateObsModel = [currobsmod(:,1), IOregion .* newregion, IOcountry .*currobsmod(:,2)];
speyet = speye(T);
kronobs = kron(speyet, StateObsModel);
V = kronobs*StateVariance*kronobs'...
    + ObsDiagVariance;

ll = logmvnpdf(ydemuregion', zeros(1,length(ydemuregion)), V);

end

