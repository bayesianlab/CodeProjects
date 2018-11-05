function [ll] = kowOptimizeRegion(regionguess, world, country, IOregion,...
    IOcountry, StateVariable, ydemuregion, variance)
StateObsModel = [world, IOregion .* regionguess, IOcountry .*country];
ss = StateObsModel*StateVariable;
ydemuregion = ydemuregion - ss(:);
ll = kowLogLikelihood(ydemuregion, variance);
end

