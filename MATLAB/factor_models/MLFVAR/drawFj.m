function [f] = drawFj(Info, yt, xt, stateTransitions, factorVariance)
[K,T] = size(yt);
Regions = size(Info,1);
f = zeros(Regions,T);
for r = 1:Regions
    subsetSelect = Info(r,1):Info(r,2);
    ySlice = yt(subsetSelect,:);
    precisionSlice = obsPrecision(subsetSelect);
    factorPrecision = kowStatePrecision(stateTransitions(r), factorVariance(r), T);
    f(r,:) =  kowUpdateLatent(ySlice(:), xt(subsetSelect), factorPrecision, precisionSlice);
end
end

