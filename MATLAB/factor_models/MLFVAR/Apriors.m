function [priorAstar] = Apriors(Info, Astar)
Regions = size(Info,1);
priorAstar = 0;
for r = 1:Regions
    subsetSelect = Info(r,1):Info(r,2);
    K = length(subsetSelect);
    astar = Astar(subsetSelect);
    astar = reshape(astar(2:end), 1, K-1);
    
    ObsPriorMean = ones(1, K-1);
    ObsPriorVariance = eye(K-1);    
    priorAstar = priorAstar + logmvnpdf(astar, ObsPriorMean, ObsPriorVariance);
end
end

