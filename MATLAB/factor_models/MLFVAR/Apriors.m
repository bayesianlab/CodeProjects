function [priorAstar] = Apriors(Info, Astar)
Regions = size(Info,1);
priorAstar = 0;
for r = 1:Regions
    subsetSelect = Info(r,1):Info(r,2);
    astar = Astar(subsetSelect);
    astar = astar(2:end);
    K = length(subsetSelect);
    ObsPriorMean = ones(1, K-1);
    ObsPriorPrecision = eye(K-1);    
    priorAstar = priorAstar + logmvnpdf(astar', ObsPriorMean, ObsPriorPrecision);
end
end

