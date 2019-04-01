function [obsupdate, backup, f] = ...
    AmarginalF(Info, Factor, yt, currobsmod,  stateTransitions, factorVariance,...
      obsPrecision, backup, options, identification)

[K,T] = size(yt);

RegionInfo = Info;
Regions = size(Info,1);
f = zeros(Regions,T);
obsupdate = zeros(K,1);
for r = 1:Regions
    subsetSelect = RegionInfo(r,1):RegionInfo(r,2);
    yslice = yt(subsetSelect,:);
    precisionSlice = obsPrecision(subsetSelect);
    x0 = currobsmod(subsetSelect);
    factorPrecision = kowStatePrecision(stateTransitions(r), factorVariance(r), T);
    lastMean = backup{r,1};
    lastHessian = backup{r,2};
    [xt, lastMean, lastHessian] = optimizeA(x0, yslice,...
        precisionSlice,  Factor(r,:), factorPrecision, lastMean, lastHessian, options, identification);
    obsupdate(subsetSelect) = xt;
    backup{r,1} = lastMean;
    backup{r,2} = lastHessian;
    
    f(r,:) =  kowUpdateLatent(yslice(:),  xt, factorPrecision, precisionSlice);
end
end