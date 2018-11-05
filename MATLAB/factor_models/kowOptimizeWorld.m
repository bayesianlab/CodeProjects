function [ll] = kowOptimizeWorld(worldguess, currobsmod, IOregion, IOcountry, StateVariable, ydemu, variance)
StateObsModel = [worldguess, IOregion .* currobsmod(:,2), IOcountry .* currobsmod(:,3)];
ss = StateObsModel*StateVariable;
ydemu = ydemu - ss(:);
ll = kowLogLikelihood(ydemu, variance);
end

